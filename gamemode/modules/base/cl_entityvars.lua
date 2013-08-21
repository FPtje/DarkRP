/*---------------------------------------------------------------------------
interface functions
---------------------------------------------------------------------------*/
local pmeta = FindMetaTable("Player")
function pmeta:getDarkRPVar(var)
	self.DarkRPVars = self.DarkRPVars or {}
	return self.DarkRPVars[var]
end

/*---------------------------------------------------------------------------
Retrieve the information of a player var
---------------------------------------------------------------------------*/
local function RetrievePlayerVar(entIndex, var, value, tries)
	local ply = Entity(entIndex)

	-- Usermessages _can_ arrive before the player is valid.
	-- In this case, chances are huge that this player will become valid.
	if not IsValid(ply) then
		if (tries or 0) >= 5 then return end

		timer.Simple(0.5, function() RetrievePlayerVar(entIndex, var, value, (tries or 0) + 1) end)
		return
	end

	ply.DarkRPVars = ply.DarkRPVars or {}

	hook.Call("DarkRPVarChanged", nil, ply, var, ply.DarkRPVars[var], value)
	ply.DarkRPVars[var] = value
end

/*---------------------------------------------------------------------------
Retrieve a player var.
Read the usermessage and attempt to set the DarkRP var
---------------------------------------------------------------------------*/
local function doRetrieve()
	local entIndex = net.ReadFloat()
	local var = net.ReadString()
	local valueType = net.ReadUInt(8)
	local value = net.ReadType(valueType)

	RetrievePlayerVar(entIndex, var, value)
end
net.Receive("DarkRP_PlayerVar", doRetrieve)

/*---------------------------------------------------------------------------
Initialize the DarkRPVars at the start of the game
---------------------------------------------------------------------------*/
local function InitializeDarkRPVars(len)
	local vars = net.ReadTable()

	if not vars then return end
	for k,v in pairs(vars) do
		if not IsValid(k) then continue end
		k.DarkRPVars = k.DarkRPVars or {}

		-- Merge the tables
		for a, b in pairs(v) do
			k.DarkRPVars[a] = b
		end
	end
end
net.Receive("DarkRP_InitializeVars", InitializeDarkRPVars)

/*---------------------------------------------------------------------------
Request the DarkRPVars
---------------------------------------------------------------------------*/
hook.Add("InitPostEntity", "CheckDarkRPVars", function()
	RunConsoleCommand("_sendDarkRPvars")
	timer.Create("DarkRPCheckifitcamethrough", 15, 0, function()
		for k,v in pairs(player.GetAll()) do
			if v.DarkRPVars and v:getDarkRPVar("rpname") then continue end

			RunConsoleCommand("_sendDarkRPvars")
			return
		end
	end)
end)

/*---------------------------------------------------------------------------
RP name overrid
---------------------------------------------------------------------------*/
pmeta.SteamName = pmeta.SteamName or pmeta.Name
function pmeta:Name()
	return GAMEMODE.Config.allowrpnames and self:getDarkRPVar("rpname")
		or self:SteamName()
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name

/*---------------------------------------------------------------------------
Door data
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
Retrieve all the data for one door
---------------------------------------------------------------------------*/
local function RetrieveDoorData(len)
	local door = net.ReadEntity()
	local doorData = net.ReadTable()
	if not door or not door.IsValid or not IsValid(door) or not doorData then return end

	if doorData.TeamOwn then
		local tdata = {}
		for k, v in pairs(string.Explode("\n", doorData.TeamOwn or "")) do
			if v and v != "" then
				tdata[tonumber(v)] = true
			end
		end
		doorData.TeamOwn = tdata
	else
		doorData.TeamOwn = nil
	end

	door.DoorData = doorData
end
net.Receive("DarkRP_DoorData", RetrieveDoorData)

/*---------------------------------------------------------------------------
Update changed variables
---------------------------------------------------------------------------*/
local function UpdateDoorData(um)
	local door = um:ReadEntity()
	if not IsValid(door) then return end

	local var, value = um:ReadString(), um:ReadString()
	value = tonumber(value) or value

	if string.match(tostring(value), "Entity .([0-9]*)") then
		value = Entity(string.match(value, "Entity .([0-9]*)"))
	end

	if string.match(tostring(value), "Player .([0-9]*)") then
		value = Entity(string.match(value, "Player .([0-9]*)"))
	end

	if value == "true" or value == "false" then value = tobool(value) end

	if value == "nil" then value = nil end

	if var == "TeamOwn" then
		local decoded = {}
		for k, v in pairs(string.Explode("\n", value or "")) do
			if v and v != "" then
				decoded[tonumber(v)] = true
			end
		end
		if table.Count(decoded) == 0 then
			value = nil
		else
			value = decoded
		end
	end

	door.DoorData = door.DoorData or {}
	door.DoorData[var] = value
end
usermessage.Hook("DRP_UpdateDoorData", UpdateDoorData)
