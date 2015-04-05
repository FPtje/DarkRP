util.AddNetworkString("fprp_UpdateDoorData")
util.AddNetworkString("fprp_RemoveDoorData")
util.AddNetworkString("fprp_AllDoorData")

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
local eMeta = FindMetaTable("Entity")
function eMeta:getDoorData()
	if not self:isKeysOwnable() then return {} end

	self.DoorData = self.DoorData or {}
	return self.DoorData
end

function eMeta:setKeysNonOwnable(ownable)
	self:getDoorData().nonOwnable = ownable
	fprp.updateDoorData(self, "nonOwnable")
end

function eMeta:setKeysTitle(title)
	self:getDoorData().title = title
	fprp.updateDoorData(self, "title")
end

function eMeta:setDoorGroup(group)
	self:getDoorData().groupOwn = group
	fprp.updateDoorData(self, "groupOwn")
end

function eMeta:addKeysDoorTeam(t)
	local doorData = self:getDoorData()
	doorData.teamOwn = doorData.teamOwn or {}
	doorData.teamOwn[t] = true

	fprp.updateDoorData(self, "teamOwn")
end

function eMeta:removeKeysDoorTeam(t)
	local doorData = self:getDoorData()
	doorData.teamOwn = doorData.teamOwn or {}
	doorData.teamOwn[t] = nil

	if fn.Null(doorData.teamOwn) then
		doorData.teamOwn = nil
	end

	fprp.updateDoorData(self, "teamOwn")
end

function eMeta:removeAllKeysDoorTeams()
	local doorData = self:getDoorData()
	doorData.teamOwn = nil

	fprp.updateDoorData(self, "teamOwn")
end

function eMeta:addKeysAllowedToOwn(ply)
	local doorData = self:getDoorData()
	doorData.allowedToOwn = doorData.allowedToOwn or {}
	doorData.allowedToOwn[ply:UserID()] = true

	fprp.updateDoorData(self, "allowedToOwn")
end

function eMeta:removeKeysAllowedToOwn(ply)
	local doorData = self:getDoorData()
	doorData.allowedToOwn = doorData.allowedToOwn or {}
	doorData.allowedToOwn[ply:UserID()] = nil

	if fn.Null(doorData.allowedToOwn) then
		doorData.allowedToOwn = nil
	end

	fprp.updateDoorData(self, "allowedToOwn")
end

function eMeta:removeAllKeysAllowedToOwn()
	local doorData = self:getDoorData()
	doorData.allowedToOwn = nil

	fprp.updateDoorData(self, "allowedToOwn")
end

function eMeta:addKeysDoorOwner(ply)
	local doorData = self:getDoorData()
	doorData.extraOwners = doorData.extraOwners or {}
	doorData.extraOwners[ply:UserID()] = true

	fprp.updateDoorData(self, "extraOwners")

	self:removeKeysAllowedToOwn(ply)
end

function eMeta:removeKeysDoorOwner(ply)
	local doorData = self:getDoorData()
	doorData.extraOwners = doorData.extraOwners or {}
	doorData.extraOwners[ply:UserID()] = nil

	if fn.Null(doorData.extraOwners) then
		doorData.extraOwners = nil
	end

	fprp.updateDoorData(self, "extraOwners")
end

function eMeta:removeAllKeysExtraOwners()
	local doorData = self:getDoorData()
	doorData.extraOwners = nil

	fprp.updateDoorData(self, "extraOwners")
end

function eMeta:removeDoorData()
	net.Start("fprp_RemoveDoorData")
		net.WriteUInt(self:EntIndex(), 32)
	net.Send(player.GetAll())
end

/*---------------------------------------------------------------------------
Networking
---------------------------------------------------------------------------*/
local plyMeta = FindMetaTable("Player")
function plyMeta:sendDoorData()
	if self:EntIndex() == 0 then return end

	local res = {}
	for k,v in pairs(ents.GetAll()) do
		if not IsValid(v) or not v:getDoorData() or table.Count(v:getDoorData()) == 0 then continue end

		res[v:EntIndex()] = v:getDoorData()
	end

	net.Start("fprp_AllDoorData")
		net.WriteTable(res)
	net.Send(self)
end
concommand.Add("_sendAllDoorData", function(ply)
	if ply.doorDataSent and ply.doorDataSent > (CurTime() - 3) then return end -- prevent spammers
	ply.doorDataSent = CurTime()

	ply:sendDoorData()
end)

function fprp.updateDoorData(door, member)
	if not IsValid(door) or not door:getDoorData() then error("Calling updateDoorData on a door that has no data!") end

	net.Start("fprp_UpdateDoorData")
		net.WriteUInt(door:EntIndex(), 32)
		net.WriteString(member)
		net.WriteType(door:getDoorData()[member])
	net.Send(player.GetAll())
end
