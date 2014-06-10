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
	local userID = net.ReadUInt(16)
	local var, value = DarkRP.readNetDarkRPVar()

	RetrievePlayerVar(userID, var, value)
end
net.Receive("DarkRP_PlayerVar", doRetrieve)

/*---------------------------------------------------------------------------
Retrieve the message to remove a DarkRPVar
---------------------------------------------------------------------------*/
local function doRetrieveRemoval()
	local userID = net.ReadUInt(16)
	local var = DarkRP.readNetDarkRPVarRemoval()
	local ply = Player(userID)

	if not IsValid(ply) then return end

	ply.DarkRPVars = ply.DarkRPVars or {}

	hook.Call("DarkRPVarChanged", nil, ply, var, ply.DarkRPVars[var], nil)

	ply.DarkRPVars[var] = nil
end
net.Receive("DarkRP_PlayerVarRemoval", doRetrieveRemoval)

/*---------------------------------------------------------------------------
Initialize the DarkRPVars at the start of the game
---------------------------------------------------------------------------*/
local function InitializeDarkRPVars(len)
	local plyCount = net.ReadUInt(8)

	for i = 1, plyCount, 1 do
		local userID = net.ReadUInt(16)
		local varCount = net.ReadUInt(DarkRP.DARKRP_ID_BITS + 2)

		for j = 1, varCount, 1 do
			local var, value = DarkRP.readNetDarkRPVar()
			RetrievePlayerVar(userID, var, value)
		end
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
