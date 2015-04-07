local fprpVars = {}

/*---------------------------------------------------------------------------
interface functions
---------------------------------------------------------------------------*/
local pmeta = FindMetaTable("Player");
function pmeta:getfprpVar(var)
	local vars = fprpVars[self:UserID()]
	return vars and vars[var] or nil
end

/*---------------------------------------------------------------------------
Retrieve the information of a player var
---------------------------------------------------------------------------*/
local function RetrievePlayerVar(userID, var, value)
	local ply = Player(userID);
	fprpVars[userID] = fprpVars[userID] or {}

	hook.Call("fprpVarChanged", nil, ply, var, fprpVars[userID][var], value);
	fprpVars[userID][var] = value

	-- Backwards compatibility
	if IsValid(ply) then
		ply.fprpVars = fprpVars[userID]
	end
end

/*---------------------------------------------------------------------------
Retrieve a player var.
Read the usermessage and attempt to set the fprp var
---------------------------------------------------------------------------*/
local function doRetrieve()
	local userID = net.ReadUInt(16);
	local var, value = fprp.readNetfprpVar();

	RetrievePlayerVar(userID, var, value);
end
net.Receive("fprp_PlayerVar", doRetrieve);

/*---------------------------------------------------------------------------
Retrieve the message to remove a fprpVar
---------------------------------------------------------------------------*/
local function doRetrieveRemoval()
	local userID = net.ReadUInt(16);
	local vars = fprpVars[userID] or {}
	local var = fprp.readNetfprpVarRemoval();
	local ply = Player(userID);

	hook.Call("fprpVarChanged", nil, ply, var, vars[var], nil);

	vars[var] = nil
end
net.Receive("fprp_PlayerVarRemoval", doRetrieveRemoval);

/*---------------------------------------------------------------------------
Initialize the fprpVars at the start of the game
---------------------------------------------------------------------------*/
local function InitializefprpVars(len)
	local plyCount = net.ReadUInt(8);

	for i = 1, plyCount, 1 do
		local userID = net.ReadUInt(16);
		local varCount = net.ReadUInt(fprp.fprp_ID_BITS + 2);

		for j = 1, varCount, 1 do
			local var, value = fprp.readNetfprpVar();
			RetrievePlayerVar(userID, var, value);
		end
	end
end
net.Receive("fprp_InitializeVars", InitializefprpVars);
timer.Simple(0, fp{RunConsoleCommand, "_sendfprpvars"});

net.Receive("fprp_fprpVarDisconnect", function(len)
	local userID = net.ReadUInt(16);
	fprpVars[userID] = nil
end);

/*---------------------------------------------------------------------------
Request the fprpVars when they haven't arrived
---------------------------------------------------------------------------*/
timer.Create("fprpCheckifitcamethrough", 15, 0, function()
	for k,v in pairs(player.GetAll()) do
		if v:getfprpVar("rpname") then continue end

		RunConsoleCommand("_sendfprpvars");
		return
	end

	timer.Destroy("fprpCheckifitcamethrough");
end);

/*---------------------------------------------------------------------------
RP name override
---------------------------------------------------------------------------*/
pmeta.SteamName = pmeta.SteamName or pmeta.Name
function pmeta:Name()
	if not self:IsValid() then fprp.error("Attempt to call Name/Nick/GetName on a non-existing player!", 2) end
	return GAMEMODE.Config.allowrpnames and self:getfprpVar("rpname")
		or self:SteamName();
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
