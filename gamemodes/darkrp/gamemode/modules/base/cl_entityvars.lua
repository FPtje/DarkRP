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
local function RetrievePlayerVar(userID, var, value, tries)
	local ply = Player(userID)

	-- Usermessages _can_ arrive before the player is valid.
	-- In this case, chances are huge that this player will become valid.
	if not IsValid(ply) then
		if (tries or 0) >= 5 then return end

		timer.Simple(0.5, function() RetrievePlayerVar(userID, var, value, (tries or 0) + 1) end)
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
	local userID = net.ReadFloat()
	local var = net.ReadString()
	local valueType = net.ReadUInt(8)
	local value = net.ReadType(valueType)

	RetrievePlayerVar(userID, var, value)
end
net.Receive("DarkRP_PlayerVar", doRetrieve)

/*---------------------------------------------------------------------------
Initialize the DarkRPVars at the start of the game
---------------------------------------------------------------------------*/
local function InitializeDarkRPVars(len)
	local vars = net.ReadTable()

	local askAgain = false
	if not vars then askAgain = true end
	for k,v in pairs(vars or {}) do
		if not IsValid(k) then askAgain = true continue end
		k.DarkRPVars = k.DarkRPVars or {}

		-- Merge the tables
		for a, b in pairs(v) do
			k.DarkRPVars[a] = b
		end
	end

	-- Sometimes players remain uninitialized
	-- Ask again for data when null players are found or when not every player is in it
	if askAgain or #vars < #player.GetAll() - 1 then -- Timer delay must be larger than 1, command will be ignored otherwise
		timer.Simple(3, fn.Curry(RunConsoleCommand, 2)("_sendDarkRPvars"))
	end
end
net.Receive("DarkRP_InitializeVars", InitializeDarkRPVars)

/*---------------------------------------------------------------------------
Request the DarkRPVars
---------------------------------------------------------------------------*/
timer.Simple(1, fn.Curry(RunConsoleCommand, 2)("_sendDarkRPvars"))

timer.Create("DarkRPCheckifitcamethrough", 15, 0, function()
	for k,v in pairs(player.GetAll()) do
		if v.DarkRPVars and v:getDarkRPVar("rpname") then continue end

		RunConsoleCommand("_sendDarkRPvars")
		return
	end

	timer.Destroy("DarkRPCheckifitcamethrough")
end)

/*---------------------------------------------------------------------------
RP name override
---------------------------------------------------------------------------*/
pmeta.SteamName = pmeta.SteamName or pmeta.Name
function pmeta:Name()
	return GAMEMODE.Config.allowrpnames and self:getDarkRPVar("rpname")
		or self:SteamName()
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
