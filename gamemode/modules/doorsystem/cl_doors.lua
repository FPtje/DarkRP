local meta = FindMetaTable("Entity")
local black = Color(0, 0, 0, 255)
local white = Color(255, 255, 255, 200)
local red = Color(128, 30, 30, 255)

function meta:drawOwnableInfo()
	if LocalPlayer():InVehicle() then return end

	-- Look, if you want to change the way door ownership is drawn, don't edit this file, use the hook instead!
	local doorDrawing = hook.Call("HUDDrawDoorData", nil, self)
	if doorDrawing == true then return end

	local blocked = self:getKeysNonOwnable()
	local superadmin = LocalPlayer():IsSuperAdmin()
	local doorTeams = self:getKeysDoorTeams()
	local doorGroup = self:getKeysDoorGroup()
	local playerOwned = self:isKeysOwned() or table.GetFirstValue(self:getKeysCoOwners() or {}) ~= nil
	local owned = playerOwned or doorGroup or doorTeams

	local doorInfo = {}

	local title = self:getKeysTitle()
	if title then table.insert(doorInfo, title) end

	if owned then
		table.insert(doorInfo, fprp.getPhrase("keys_owned_by"))
	end

	if playerOwned then
		if self:isKeysOwned() then table.insert(doorInfo, self:getDoorOwner():Nick()) end
		for k,v in pairs(self:getKeysCoOwners() or {}) do
			local ent = Player(k)
			if not IsValid(ent) or not ent:IsPlayer() then continue end
			table.insert(doorInfo, ent:Nick())
		end

		local allowedCoOwn = self:getKeysAllowedToOwn()
		if allowedCoOwn and not fn.Null(allowedCoOwn) then
			table.insert(doorInfo, fprp.getPhrase("keys_other_allowed"))

			for k,v in pairs(allowedCoOwn) do
				local ent = Player(k)
				if not IsValid(ent) or not ent:IsPlayer() then continue end
				table.insert(doorInfo, ent:Nick())
			end
		end
	elseif doorGroup then
		table.insert(doorInfo, doorGroup)
	elseif doorTeams then
		for k, v in pairs(doorTeams) do
			if not v or not RPExtraTeams[k] then continue end

			table.insert(doorInfo, RPExtraTeams[k].name)
		end
	elseif blocked and superadmin then
		table.insert(doorInfo, fprp.getPhrase("keys_allow_ownership"))
	elseif not blocked then
		table.insert(doorInfo, fprp.getPhrase("keys_unowned"))
		if superadmin then
			table.insert(doorInfo, fprp.getPhrase("keys_disallow_ownership"))
		end
	end

	if self:IsVehicle() then
		for k,v in pairs(player.GetAll()) do
			if v:GetVehicle() ~= self then continue end

			table.insert(doorInfo, fprp.getPhrase("driver", v:Nick()))
			break
		end
	end

	local x, y = ScrW()/2, ScrH() / 2
	draw.DrawNonParsedText(table.concat(doorInfo, "\n"), "TargetID", x , y + 1 , black, 1)
	draw.DrawNonParsedText(table.concat(doorInfo, "\n"), "TargetID", x, y, (blocked or owned) and white or red, 1)
end


/*---------------------------------------------------------------------------
Door data
---------------------------------------------------------------------------*/
fprp.doorData = fprp.doorData or {}

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function meta:getDoorData()
	local doorData = fprp.doorData[self:EntIndex()] or {}

	self.DoorData = doorData -- Backwards compatibility

	return doorData
end

/*---------------------------------------------------------------------------
Networking
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
Retrieve all the data for all doors
---------------------------------------------------------------------------*/
local receivedDoorData = false
local function retrieveAllDoorData(len)
	receivedDoorData = true
	local data = net.ReadTable()
	fprp.doorData = data
end
net.Receive("fprp_AllDoorData", retrieveAllDoorData)
hook.Add("InitPostEntity", "DoorData", fp{RunConsoleCommand, "_sendAllDoorData"})

/*---------------------------------------------------------------------------
Update changed variables
---------------------------------------------------------------------------*/
local function updateDoorData()
	local door = net.ReadUInt(32)

	fprp.doorData[door] = fprp.doorData[door] or {}

	local var = net.ReadString()
	local valueType = net.ReadUInt(8)
	local value = net.ReadType(valueType)

	fprp.doorData[door][var] = value
end
net.Receive("fprp_UpdateDoorData", updateDoorData)

/*---------------------------------------------------------------------------
Remove doordata of removed entity
---------------------------------------------------------------------------*/
local function removeDoorData()
	local door = net.ReadUInt(32)
	fprp.doorData[door] = nil
end
net.Receive("fprp_RemoveDoorData", removeDoorData)
