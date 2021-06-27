FPP = FPP or {}
local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

/*---------------------------------------------------------------------------
Entity data explanation.
Every ent has a field FPPCanTouch. This is a table with one entry per player.
Every bit in FPPCanTouch represents a type.
    The first bit says whether the player can physgun the ent
    The second bit whether the player can use gravun on the ent
    etc.

Then there is the FPPCanTouchWhy var This var follows the same idea as FPPCanTouch
except there are five bits for each type. These 4 bits represent a number that shows the reason
why a player can or cannot touch a prop.
---------------------------------------------------------------------------*/

local touchTypes = {
    Physgun = 1,
    Gravgun = 2,
    Toolgun = 4,
    PlayerUse = 8,
    EntityDamage = 16
}

local touchTypeNumbers = {
    [1] = "Physgun",
    [2] = "Gravgun",
    [4] = "Toolgun",
    [8] = "PlayerUse",
    [16] = "EntityDamage"
}

local reasonSize = 4 -- bits

local reasonNumbers = {
    ["owner"] = 1,
    ["world"] = 2,
    ["disconnected"] = 3,
    ["blocked"] = 4,
    ["constrained"] = 5,
    ["buddy"] = 6,
    ["shared"] = 7,
    ["player"] = 8,
}

/*---------------------------------------------------------------------------
Utility functions
---------------------------------------------------------------------------*/
local function getPlySetting(ply, settingName)
    return (ply[settingName] or ply:GetInfo(settingName)) == "1"
end

local function getSetting(touchType)
    return touchType .. "1", string.upper("FPP_" .. touchType .. "1")
end

local constraints = { -- These little buggers think they're not constraints, but they are
    ["phys_spring"] = true,
}
local function isConstraint(ent)
    return ent:IsConstraint() or constraints[ent:GetClass()] or false
end

/*---------------------------------------------------------------------------
Touch calculations
---------------------------------------------------------------------------*/
local hardWhiteListed = { -- things that mess up when not allowed
    ["worldspawn"] = true, -- constraints with the world
    ["gmod_anchor"] = true -- used in slider constraints with world
}
local function calculateCanTouchForType(ply, ent, touchType)
    if not IsValid(ent) then return false, 0 end

    ply.FPP_Privileges = ply.FPP_Privileges or {}
    local class = ent:GetClass()
    local setting, tablename = getSetting(touchType)
    local FPPSettings = FPP.Settings[tablename]

    -- hard white list
    if hardWhiteListed[class] then return true, reasonNumbers.world end

    -- picking up players
    if touchType == "Physgun" and ent:IsPlayer() and not getPlySetting(ply, "cl_pickupplayers") then
        return false, reasonNumbers.player
    end

    -- blocked entity
    local whitelist = FPPSettings.iswhitelist ~= 0
    local isInList = FPP.Blocked[setting][string.lower(class)] or false

    local isAdmin = ply.FPP_Privileges.FPP_TouchOtherPlayersProps
    local isBlocked = whitelist ~= isInList -- XOR

    if isBlocked then
        local adminsCanTouchBlocked = FPPSettings.admincanblocked ~= 0
        local playersCanBlocked = FPPSettings.canblocked ~= 0

        return (playersCanBlocked or isAdmin and adminsCanTouchBlocked) and not getPlySetting(ply, "FPP_PrivateSettings_BlockedProps"),
               reasonNumbers.blocked
    end

    -- touch own props
    local owner = ent.FPPOwner -- Circumvent CPPI for micro-optimisation
    if owner == ply then
        return not getPlySetting(ply, "FPP_PrivateSettings_OwnProps"),
               reasonNumbers.owner
    end

    local noTouchOtherPlayerProps = getPlySetting(ply, "FPP_PrivateSettings_OtherPlayerProps")

    -- Shared entity
    if ent.AllowedPlayers and table.HasValue(ent.AllowedPlayers, ply) then
        return not noTouchOtherPlayerProps, reasonNumbers.shared
    end
    if ent["Share" .. setting] then return not noTouchOtherPlayerProps, reasonNumbers.shared end

    if IsValid(owner) then
        -- Player is buddies with the owner of the entity
        if owner.Buddies and owner.Buddies[ply] and owner.Buddies[ply][touchType] then return not noTouchOtherPlayerProps, reasonNumbers.buddy end

        -- Someone else's prop
        local adminProps = FPPSettings.adminall ~= 0
        return isAdmin and adminProps and not noTouchOtherPlayerProps, reasonNumbers.owner
    end

    -- World props and disconnected players' props
    local adminWorldProps = FPPSettings.adminworldprops ~= 0
    local peopleWorldProps = FPPSettings.worldprops ~= 0
    local restrictWorld = getPlySetting(ply, "FPP_PrivateSettings_WorldProps")

    return not restrictWorld and (peopleWorldProps or (isAdmin and adminWorldProps)),
           owner == nil and reasonNumbers.world or reasonNumbers.disconnected
end

local blockedEnts = {
    ["ai_network"] = true,
    ["network"] = true, -- alternative name for ai_network
    ["ambient_generic"] = true,
    ["beam"] = true,
    ["bodyque"] = true,
    ["env_soundscape"] = true,
    ["env_sprite"] = true,
    ["env_sun"] = true,
    ["env_tonemap_controller"] = true,
    ["func_useableladder"] = true,
    ["gmod_hands"] = true,
    ["info_ladder_dismount"] = true,
    ["info_player_start"] = true,
    ["info_player_terrorist"] = true,
    ["light_environment"] = true,
    ["light_spot"] = true,
    ["physgun_beam"] = true,
    ["player_manager"] = true,
    ["point_spotlight"] = true,
    ["predicted_viewmodel"] = true,
    ["scene_manager"] = true,
    ["shadow_control"] = true,
    ["soundent"] = true,
    ["spotlight_end"] = true,
    ["water_lod_control"] = true,
    ["gmod_gamerules"] = true,
    ["bodyqueue"] = true,
    ["phys_bone_follower"] = true,
}
function FPP.calculateCanTouch(ply, ent)
    local canTouch = 0

    local reasons = 0
    local i = 0

    for Bit, touchType in pairs(touchTypeNumbers) do
        local canTouchType, why = calculateCanTouchForType(ply, ent, touchType)
        if canTouchType then
            canTouch = bit.bor(canTouch, Bit)
        end

        reasons = bit.bor(reasons, bit.lshift(why, i * reasonSize))

        i = i + 1
    end

    ent.FPPCanTouch = ent.FPPCanTouch or {}
    ent.FPPCanTouchWhy = ent.FPPCanTouchWhy or {}

    local changed = ent.FPPCanTouch[ply] ~= canTouch or ent.FPPCanTouchWhy[ply] ~= reasons or ent.FPPOwnerChanged
    ent.FPPCanTouch[ply] = canTouch
    ent.FPPCanTouchWhy[ply] = reasons

    return changed
end

-- try not to call this with both player.GetAll() and ents.GetAll()
local function recalculateCanTouch(players, entities)
    for k, v in pairs(entities) do
        if not IsValid(v) then entities[k] = nil continue end
        if v:IsEFlagSet(EFL_SERVER_ONLY) then entities[k] = nil continue end
        if blockedEnts[v:GetClass()] then entities[k] = nil continue end
        if v:IsWeapon() and IsValid(v.Owner) then entities[k] = nil continue end
    end

    for _, ply in pairs(players) do
        if not IsValid(ply) then continue end
        -- optimisations
        ply.FPPIsAdmin = ply.FPP_Privileges.FPP_TouchOtherPlayersProps
        ply.FPP_PrivateSettings_OtherPlayerProps = ply:GetInfo("FPP_PrivateSettings_OtherPlayerProps")
        ply.cl_pickupplayers = ply:GetInfo("cl_pickupplayers")
        ply.FPP_PrivateSettings_BlockedProps = ply:GetInfo("FPP_PrivateSettings_BlockedProps")
        ply.FPP_PrivateSettings_OwnProps = ply:GetInfo("FPP_PrivateSettings_OwnProps")
        ply.FPP_PrivateSettings_WorldProps = ply:GetInfo("FPP_PrivateSettings_WorldProps")
        local changed = {}

        for _, ent in pairs(entities) do
            local hasChanged = FPP.calculateCanTouch(ply, ent)
            if hasChanged then table.insert(changed, ent) end
        end

        FPP.plySendTouchData(ply, changed)

        -- end optimisations
        ply.FPP_PrivateSettings_OtherPlayerProps = nil
        ply.cl_pickupplayers = nil
        ply.FPP_PrivateSettings_BlockedProps = nil
        ply.FPP_PrivateSettings_OwnProps = nil
        ply.FPP_PrivateSettings_WorldProps = nil
        ply.FPPIsAdmin = nil
    end
end

function FPP.recalculateCanTouch(plys, ens)
    FPP.calculatePlayerPrivilege("FPP_TouchOtherPlayersProps", function() recalculateCanTouch(plys, ens) end)
end

/*---------------------------------------------------------------------------
Touch interface
---------------------------------------------------------------------------*/
function FPP.plyCanTouchEnt(ply, ent, touchType)
    ent.FPPCanTouch = ent.FPPCanTouch or {}
    ent.FPPCanTouch[ply] = ent.FPPCanTouch[ply] or 0
    ent.AllowedPlayers = ent.AllowedPlayers or {}

    local canTouch = ent.FPPCanTouch[ply]
    -- if an entity is constrained, return the least of the rights
    if ent.FPPRestrictConstraint and ent.FPPRestrictConstraint[ply] then
        canTouch = bit.band(ent.FPPRestrictConstraint[ply], ent.FPPCanTouch[ply])
    end

    -- return the answer for every touch type if parameter is empty
    if not touchType then
        return canTouch
    end

    return bit.bor(canTouch, touchTypes[touchType]) == canTouch
end

function FPP.entGetOwner(ent)
    return ent.FPPOwner
end

/*---------------------------------------------------------------------------
Networking
---------------------------------------------------------------------------*/
util.AddNetworkString("FPP_TouchabilityData")
local function netWriteEntData(ply, ent)
    -- EntIndex for when it's out of the PVS of the player
    net.WriteUInt(ent:EntIndex(), 32)

    local owner = ent:CPPIGetOwner()
    net.WriteUInt(IsValid(owner) and owner:EntIndex() or -1, 32)
    net.WriteUInt(ent.FPPRestrictConstraint and ent.FPPRestrictConstraint[ply] or ent.FPPCanTouch[ply], 5) -- touchability information
    net.WriteUInt(ent.FPPConstraintReasons and ent.FPPConstraintReasons[ply] or ent.FPPCanTouchWhy[ply], 20) -- reasons
end

function FPP.plySendTouchData(ply, ents)
    local count = #ents

    if count == 0 then return end
    net.Start("FPP_TouchabilityData")
        for i = 1, count do
            netWriteEntData(ply, ents[i])
            net.WriteBit(i == count)
        end
    net.Send(ply)
end

/*---------------------------------------------------------------------------
Events that trigger recalculation
---------------------------------------------------------------------------*/
local function handleConstraintCreation(ent)
    local ent1, ent2 = ent:GetConstrainedEntities()
    ent1, ent2 = ent1 or ent.Ent1, ent2 or ent.Ent2

    if not ent1 or not ent2 or not ent1.FPPCanTouch or not ent2.FPPCanTouch then return end
    local reason = 0
    local i = 0
    for Bit, touchType in pairs(touchTypeNumbers) do
        reason = bit.bor(reason, bit.lshift(reasonNumbers.constrained, i * reasonSize))
        i = i + 1
    end

    for _, ply in ipairs(player.GetAll()) do
        local touch1, touch2 = FPP.plyCanTouchEnt(ply, ent1), FPP.plyCanTouchEnt(ply, ent2)

        -- The constrained entities have the same touching rights.
        if touch1 == touch2 then continue end

        local restrictedAccess = bit.band(touch1, touch2)

        local send = {}
        for _, e in pairs(constraint.GetAllConstrainedEntities(ent1) or {}) do
            if not IsValid(e) then continue end
            if FPP.plyCanTouchEnt(ply, e) == restrictedAccess then continue end

            e.FPPRestrictConstraint = e.FPPRestrictConstraint or {}
            e.FPPConstraintReasons = e.FPPConstraintReasons or {}
            e.FPPRestrictConstraint[ply] = restrictedAccess
            e.FPPConstraintReasons[ply] = reason

            table.insert(send, e)
        end

        FPP.plySendTouchData(ply, send)
    end

end

/*---------------------------------------------------------------------------
On entity created
---------------------------------------------------------------------------*/
local function onEntitiesCreated(ents)
    local send = {}

    for _, ent in pairs(ents) do
        if not IsValid(ent) then continue end

        if isConstraint(ent) then
            handleConstraintCreation(ent)
            continue
        end

        -- Don't send information about server only entities to the clients
        if ent:GetSolid() == 0 or ent:IsEFlagSet(EFL_SERVER_ONLY) then
            continue
        end

        if blockedEnts[ent:GetClass()] then continue end

        for _, ply in ipairs(player.GetAll()) do
            FPP.calculateCanTouch(ply, ent)
        end
        table.insert(send, ent)
    end

    for _, ply in ipairs(player.GetAll()) do
        FPP.plySendTouchData(ply, send)
    end
end


-- Make a queue of entities created per frame, so the server will send out a maximum-
-- of one message per player per frame
local entQueue = {}
local timerFunc = function()
    onEntitiesCreated(entQueue)
    entQueue = {}
    timer.Remove("FPP_OnEntityCreatedTimer")
end
hook.Add("OnEntityCreated", "FPP_EntityCreated", function(ent)
    table.insert(entQueue, ent)

    if timer.Exists("FPP_OnEntityCreatedTimer") then return end
    timer.Create("FPP_OnEntityCreatedTimer", 0, 1, timerFunc)
end)


/*---------------------------------------------------------------------------
On entity removed
---------------------------------------------------------------------------*/
-- Recalculates touchability information for constrained entities
-- Note: Assumes normal touchability information is up to date!
-- Update constraints, O(players * (entities + constraints))
function FPP.RecalculateConstrainedEntities(players, entities)
    for i, ent in pairs(entities) do
        if not IsValid(ent) then entities[i] = nil continue end
        if ent:IsEFlagSet(EFL_SERVER_ONLY) then entities[i] = nil continue end
        if blockedEnts[ent:GetClass()] then entities[i] = nil continue end

        ent.FPPRestrictConstraint = ent.FPPRestrictConstraint or {}
        ent.FPPConstraintReasons = ent.FPPConstraintReasons or {}
    end

    -- constrained entities form a graph.
    -- and graphs are things you can traverse with BFS
    for _, ply in pairs(players) do
        local discovered = {}
        -- BFS vars
        local BFSQueue = {}
        local black, gray = {}, {} -- black = fully discovered, gray = seen, but discovery from this point is needed
        local value -- used as key and value of the BFSQueue

        for _, ent in pairs(entities) do
            if discovered[ent] then continue end -- We've seen this ent in a graph
            ent.FPPCanTouch = ent.FPPCanTouch or {}
            ent.FPPCanTouch[ply] = ent.FPPCanTouch[ply] or 0

            local left, right = 1, 2
            BFSQueue[left] = ent

            local FPP_CanTouch = ent.FPPCanTouch[ply] -- Find out the canTouch state
            while BFSQueue[left] do
                value = BFSQueue[left]
                BFSQueue[left] = nil
                left = left + 1

                for _, constr in pairs(value.Constraints or {}) do
                    local otherEnt = constr.Ent1 == value and constr.Ent2 or constr.Ent1

                    if not IsValid(otherEnt) or gray[otherEnt] or black[otherEnt] then continue end

                    gray[otherEnt] = true
                    BFSQueue[right] = otherEnt
                    right = right + 1
                end

                black[value] = true
                discovered[value] = true

                -- The entity doesn't necessarily have CanTouch data at this point
                value.FPPCanTouch = value.FPPCanTouch or {}
                value.FPPCanTouch[ply] = value.FPPCanTouch[ply] or 0
                FPP_CanTouch = bit.band(FPP_CanTouch or 0, value.FPPCanTouch[ply])
            end

            -- now update the ents to the client
            local updated = {}
            for e in pairs(black) do
                if FPP.plyCanTouchEnt(ply, e) ~= FPP_CanTouch then
                    e.FPPRestrictConstraint = e.FPPRestrictConstraint or {}
                    e.FPPRestrictConstraint[ply] = e.FPPCanTouch[ply] ~= FPP_CanTouch and FPP_CanTouch or nil
                    table.insert(updated, e)
                end
            end
            FPP.plySendTouchData(ply, updated)

            -- reset BFS information for next BFS round
            black = {}
            gray = {}
        end
    end
end

local entMem = {}
local function constraintRemovedTimer(ent1, ent2, constrainedEnts)
    if not IsValid(ent1) and not IsValid(ent2) or not constrainedEnts then return end

    FPP.RecalculateConstrainedEntities(player.GetAll(), constrainedEnts)
    entMem = {}
end

local function handleConstraintRemoved(ent)
    local ent1, ent2 = ent:GetConstrainedEntities()
    ent1, ent2 = ent1 or ent.Ent1, ent2 or ent.Ent2

    if not IsValid(ent1) or not IsValid(ent2) then return end
    -- prevent the function from being called too often when many constraints are removed at once
    if entMem[ent1] or entMem[ent2] then return end
    entMem[ent1] = true
    entMem[ent2] = true

    -- the constraint is still there, so this includes ent2's constraints
    local constrainedEnts = constraint.GetAllConstrainedEntities(ent1)

    timer.Create("FPP_ConstraintRemovedTimer", 0, 1, function() constraintRemovedTimer(ent1, ent2, constrainedEnts) end)
end

local function onEntityRemoved(ent)
    if isConstraint(ent) then handleConstraintRemoved(ent) end
end

hook.Add("EntityRemoved", "FPP_OnEntityRemoved", onEntityRemoved)

/*---------------------------------------------------------------------------
Player disconnected
---------------------------------------------------------------------------*/
local function playerDisconnected(ply)
    local ownedEnts = {}
    for _, ent in ipairs(ents.GetAll()) do
        if ent:CPPIGetOwner() == ply then
            table.insert(ownedEnts, ent)
        end
    end

    timer.Simple(0, function() FPP.recalculateCanTouch(player.GetAll(), ownedEnts) end)
end
hook.Add("PlayerDisconnected", "FPP_PlayerDisconnected", playerDisconnected)

/*---------------------------------------------------------------------------
Usergroup changed
---------------------------------------------------------------------------*/
local function userGroupRecalculate(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    timer.Create("FPP_recalculate_cantouch_" .. ply:UserID(), 0, 1, function()
        FPP.recalculateCanTouch({ply}, ents.GetAll())
    end)
end

FPP.oldSetUserGroup = FPP.oldSetUserGroup or plyMeta.SetUserGroup
function plyMeta:SetUserGroup(group)
    userGroupRecalculate(self)

    return FPP.oldSetUserGroup(self, group)
end

FPP.oldSetNWString = FPP.oldSetNWString or entMeta.SetNWString
function entMeta:SetNWString(str, val)
    if str ~= "usergroup" then return FPP.oldSetNWString(self, str, val) end

    userGroupRecalculate(self)
    return FPP.oldSetNWString(self, str, val)
end

FPP.oldSetNetworkedString = FPP.oldSetNetworkedString or entMeta.SetNetworkedString
function entMeta:SetNetworkedString(str, val)
    if str ~= "usergroup" then return FPP.oldSetNetworkedString(self, str, val) end

    userGroupRecalculate(self)
    return FPP.oldSetNetworkedString(self, str, val)
end
