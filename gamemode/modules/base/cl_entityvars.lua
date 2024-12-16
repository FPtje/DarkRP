DarkRP.ClientsideDarkRPVars = DarkRP.ClientsideDarkRPVars or {}

--[[---------------------------------------------------------------------------
Interface
---------------------------------------------------------------------------]]
local pmeta = FindMetaTable("Player")
-- This function is made local to optimise getDarkRPVar, which is called often
-- enough to warrant optimizing. See https://github.com/FPtje/DarkRP/pull/3212
local get_user_id = pmeta.UserID
function pmeta:getDarkRPVar(var, fallback)
    local user_id = get_user_id(self)

    -- Special case: when in the EntityRemoved hook, UserID returns -1. In this
    -- case, hope that we still have a stored userID lying around somewhere.
    -- See https://github.com/FPtje/DarkRP/pull/3270
    if user_id == -1 then
        user_id = self._darkrp_stored_user_id_for_entity_removed_hook
    end

    local vars = DarkRP.ClientsideDarkRPVars[user_id]
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
    local ply = Player(userID)

    -- If the player is already gone, then immediately clear the data and move on.
    if not IsValid(ply) then
        DarkRP.ClientsideDarkRPVars[userID] = nil
        return
    end
    -- Otherwise, we need to wait until the player is actually removed
    -- clientside. The net message may come in _much_ earlier than the message
    -- that the player disconnected and should therefore be removed.
    local hook_name = "darkrp_remove_darkrp_var_" .. userID

    -- Workaround: the player's user ID is -1 in the EntityRemoved hook. This
    -- stores the user ID in a separate variable so that it is still accessible.
    -- See https://github.com/Facepunch/garrysmod-issues/issues/6117
    --
    -- This will allow getDarkRPVar to keep working
    if IsValid(ply) then
        ply._darkrp_stored_user_id_for_entity_removed_hook = userID
    end

    hook.Add("EntityRemoved", hook_name, function(ent)
        if ent ~= ply then return end
        hook.Remove("EntityRemoved", hook_name)

        -- Placing this in a timer allows for the rest of the hook runners to
        -- still use the DarkRPVars until the entity is _really_ gone.
        -- See https://github.com/FPtje/DarkRP/pull/3270
        timer.Simple(0, function()
            DarkRP.ClientsideDarkRPVars[userID] = nil
        end)
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
