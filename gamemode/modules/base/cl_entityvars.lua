DarkRP.ClientsideDarkRPVars = DarkRP.ClientsideDarkRPVars or {}

--[[---------------------------------------------------------------------------
Interface
---------------------------------------------------------------------------]]
local pmeta = FindMetaTable("Player")
-- This function is made local to optimise getDarkRPVar, which is called often
-- enough to warrant optimizing. See https://github.com/FPtje/DarkRP/pull/3212
local get_user_id = pmeta.UserID
function pmeta:getDarkRPVar(var, fallback)
    local vars = DarkRP.ClientsideDarkRPVars[get_user_id(self)]
    if vars == nil then return fallback end

    local results = vars[var]
    if results == nil then return fallback end

    return results
end

--[[---------------------------------------------------------------------------
Retrieve the information of a player var
---------------------------------------------------------------------------]]
local function RetrievePlayerVar(userID, var, value)
    local ply = Player(userID)
    DarkRP.ClientsideDarkRPVars[userID] = DarkRP.ClientsideDarkRPVars[userID] or {}

    hook.Call("DarkRPVarChanged", nil, ply, var, DarkRP.ClientsideDarkRPVars[userID][var], value)
    DarkRP.ClientsideDarkRPVars[userID][var] = value

    -- Backwards compatibility
    if IsValid(ply) then
        ply.DarkRPVars = DarkRP.ClientsideDarkRPVars[userID]
    end
end

--[[---------------------------------------------------------------------------
Retrieve a player var.
Read the usermessage and attempt to set the DarkRP var
---------------------------------------------------------------------------]]
local function doRetrieve()
    local userID = net.ReadUInt(16)
    local var, value = DarkRP.readNetDarkRPVar()

    RetrievePlayerVar(userID, var, value)
end
net.Receive("DarkRP_PlayerVar", doRetrieve)

--[[---------------------------------------------------------------------------
Retrieve the message to remove a DarkRPVar
---------------------------------------------------------------------------]]
local function doRetrieveRemoval()
    local userID = net.ReadUInt(16)
    local vars = DarkRP.ClientsideDarkRPVars[userID] or {}
    local var = DarkRP.readNetDarkRPVarRemoval()
    local ply = Player(userID)

    hook.Call("DarkRPVarChanged", nil, ply, var, vars[var], nil)

    vars[var] = nil
end
net.Receive("DarkRP_PlayerVarRemoval", doRetrieveRemoval)

--[[---------------------------------------------------------------------------
Initialize the DarkRPVars at the start of the game
---------------------------------------------------------------------------]]
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
timer.Simple(0, fp{RunConsoleCommand, "_sendDarkRPvars"})

net.Receive("DarkRP_DarkRPVarDisconnect", function(len)
    local userID = net.ReadUInt(16)
    timer.Simple(10, function()
        DarkRP.ClientsideDarkRPVars[userID] = nil
    end)
end)

--[[---------------------------------------------------------------------------
Request the DarkRPVars when they haven't arrived
---------------------------------------------------------------------------]]
timer.Create("DarkRPCheckifitcamethrough", 15, 0, function()
    for _, v in ipairs(player.GetAll()) do
        if v:getDarkRPVar("rpname") then continue end

        RunConsoleCommand("_sendDarkRPvars")
        return
    end

    timer.Remove("DarkRPCheckifitcamethrough")
end)
