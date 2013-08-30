util.AddNetworkString("DarkRP_PlayerVar")
util.AddNetworkString("DarkRP_UpdateDoorData")
util.AddNetworkString("DarkRP_AllDoorData")

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
local eMeta = FindMetaTable("Entity")
function eMeta:getDoorData()
	if not self:isKeysOwnable() then return nil end

	self.DoorData = self.DoorData or {}
	return self.DoorData
end

function eMeta:setKeysNonOwnable(ownable)
	self:getDoorData().nonOwnable = ownable
	DarkRP.updateDoorData(self, "nonOwnable")
end

function eMeta:setKeysTitle(title)
	self:getDoorData().title = title
	DarkRP.updateDoorData(self, "title")
end

function eMeta:setDoorGroup(group)
	self:getDoorData().groupOwn = group
	DarkRP.updateDoorData(self, "groupOwn")
end

function eMeta:addKeysDoorTeam(t)
	local doorData = self:getDoorData()
	doorData.teamOwn = doorData.teamOwn or {}
	doorData.teamOwn[t] = true

	DarkRP.updateDoorData(self, "teamOwn")
end

function eMeta:removeKeysDoorTeam(t)
	local doorData = self:getDoorData()
	doorData.teamOwn = doorData.teamOwn or {}
	doorData.teamOwn[t] = nil

	if fn.Null(doorData.teamOwn) then
		doorData.teamOwn = nil
	end

	DarkRP.updateDoorData(self, "teamOwn")
end

function eMeta:removeAllKeysDoorTeams()
	local doorData = self:getDoorData()
	doorData.teamOwn = nil

	DarkRP.updateDoorData(self, "teamOwn")
end

function eMeta:addKeysAllowedToOwn(ply)
	local doorData = self:getDoorData()
	doorData.allowedToOwn = doorData.allowedToOwn or {}
	doorData.allowedToOwn[ply:EntIndex()] = true

	DarkRP.updateDoorData(self, "allowedToOwn")
end

function eMeta:removeKeysAllowedToOwn(ply)
	local doorData = self:getDoorData()
	doorData.allowedToOwn = doorData.allowedToOwn or {}
	doorData.allowedToOwn[ply:EntIndex()] = nil

	if fn.Null(doorData.allowedToOwn) then
		doorData.allowedToOwn = nil
	end

	DarkRP.updateDoorData(self, "allowedToOwn")
end

function eMeta:removeAllKeysAllowedToOwn()
	local doorData = self:getDoorData()
	doorData.allowedToOwn = nil

	DarkRP.updateDoorData(self, "allowedToOwn")
end

function eMeta:addKeysDoorOwner(ply)
	local doorData = self:getDoorData()
	doorData.extraOwners = doorData.extraOwners or {}
	doorData.extraOwners[ply:EntIndex()] = true

	DarkRP.updateDoorData(self, "extraOwners")

	self:removeKeysAllowedToOwn(ply)
end

function eMeta:removeKeysDoorOwner(ply)
	local doorData = self:getDoorData()
	doorData.extraOwners = doorData.extraOwners or {}
	doorData.extraOwners[ply:EntIndex()] = nil

	if fn.Null(doorData.extraOwners) then
		doorData.extraOwners = nil
	end

	DarkRP.updateDoorData(self, "extraOwners")
end

function eMeta:removeAllKeysExtraOwners()
	local doorData = self:getDoorData()
	doorData.extraOwners = nil

	DarkRP.updateDoorData(self, "extraOwners")
end

/*---------------------------------------------------------------------------
Networking
---------------------------------------------------------------------------*/
local function sendDoorData(ply)
	if ply:EntIndex() == 0 then return end
	if ply.doorDataSent and ply.doorDataSent > (CurTime() - 1) then return end -- prevent spammers

	local res = {}
	for k,v in pairs(ents.GetAll()) do
		if not IsValid(v) or not v.DoorData then continue end

		res[v:EntIndex()] = v.DoorData
	end

	net.Start("DarkRP_AllDoorData")
		net.WriteTable(res)
	net.Send(ply)
end
concommand.Add("_sendAllDoorData", sendDoorData)

function DarkRP.updateDoorData(door, member)
	if not IsValid(door) or not door.DoorData then error("Calling updateDoorData on a door that has no data!") end

	net.Start("DarkRP_UpdateDoorData")
		net.WriteFloat(door:EntIndex())
		net.WriteString(member)
		net.WriteType(door.DoorData[member])
	net.Send(player.GetAll())
end
