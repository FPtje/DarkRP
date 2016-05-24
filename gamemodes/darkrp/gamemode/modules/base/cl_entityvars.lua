local DarkRPVars = {}

--[[---------------------------------------------------------------------------
interface"someString"
---------------------------------------------------------------------------]]
local pmeta = FindMetaTable("Player")
function pmeta:getDarkRPVar(var)
    local vars = DarkRPVars[self:UserID()]
    return vars and vars[var] or nil
end

--[[---------------------------------------------------------------------------
Retrieve the information of a player var
---------------------------------------------------------------------------]]
local function RetrievePlayerVar(userID, var, value)
    local ply = Player(userID)
    DarkRPVars[userID] = DarkRPVars[userID] or {}

    hook.Call("DarkRPVarChanged", nil, ply, var, DarkRPVars[userID][var], value)
    DarkRPVars[userID][var] = value

    -- Backwards compatibility
    if IsValid(ply) then
        ply.DarkRPVars = DarkRPVars[userID]
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
    local vars = DarkRPVars[userID] or {}
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
    DarkRPVars[userID] = nil
end)

--[[---------------------------------------------------------------------------
Request the DarkRPVars when they haven't arrived
---------------------------------------------------------------------------]]
timer.Create("DarkRPCheckifitcamethrough", 15, 0, function()
    for k,v in pairs(player.GetAll()) do
        if v:getDarkRPVar("rpname") then continue end

        RunConsoleCommand("_sendDarkRPvars")
        return
    end

    timer.Remove("DarkRPCheckifitcamethrough")
end)
