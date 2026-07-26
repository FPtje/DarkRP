FPP = FPP or {}

-- These tables are indexed by entity index. Note there is no code that removes
-- anything from these tables. This is because of a nice property of entity
-- indices: only indices 1 to 2^MAX_EDICT_BITS are used for entity indices.
-- Whenever an entity is removed, its index can be used again for the next
-- entity that is created. This provides a hard cap on the size of these tables.
--
-- Note that Lua's internal representation of tables only ever grows in size,
-- and never actually shrinks. That means that removing entries from these
-- tables would not actually free up memory.
FPP.entOwners       = FPP.entOwners or {}
FPP.entTouchability = FPP.entTouchability or {}
FPP.entTouchReasons = FPP.entTouchReasons or {}

local touchTypes = {
    Physgun = 1,
    Gravgun = 2,
    Toolgun = 4,
    PlayerUse = 8,
    EntityDamage = 16
}

local reasonSize = 4 -- bits
local reasons = {
    [1] = "owner", -- you can't touch other people's props
    [2] = "world",
    [3] = "disconnected",
    [4] = "blocked",
    [5] = "constrained",
    [6] = "buddy",
    [7] = "shared",
    [8] = "player", -- you can't pick up players
}

local MAX_PLAYER_BITS = math.ceil(math.log(1 + game.MaxPlayers()) / math.log(2))

local function receiveTouchData(len)
    repeat
        local entIndex = net.ReadUInt(MAX_EDICT_BITS)
        local ownerIndex = net.ReadUInt(MAX_PLAYER_BITS)
        local touchability = net.ReadUInt(5)
        local reason = net.ReadUInt(20)

        if ownerIndex == 0 then
            ownerIndex = -1
        end

        FPP.entOwners[entIndex] = ownerIndex
        FPP.entTouchability[entIndex] = touchability
        FPP.entTouchReasons[entIndex] = reason
    until net.ReadBit() == 1
end
net.Receive("FPP_TouchabilityData", receiveTouchData)

function FPP.entGetOwner(ent)
    local idx = FPP.entOwners[ent:EntIndex()]
    ent.FPPOwner = idx and Entity(idx) or nil

    return ent.FPPOwner
end

function FPP.canTouchEnt(ent, touchType)
    ent.FPPCanTouch = FPP.entTouchability[ent:EntIndex()]
    if not touchType or not ent.FPPCanTouch then
        return ent.FPPCanTouch
    end

    return bit.bor(ent.FPPCanTouch, touchTypes[touchType]) == ent.FPPCanTouch
end

local touchTypeMultiplier = {
    ["Physgun"] = 0,
    ["Gravgun"] = 1,
    ["Toolgun"] = 2,
    ["PlayerUse"] = 3,
    ["EntityDamage"] = 4
}

function FPP.entGetTouchReason(ent, touchType)
    local idx = FPP.entTouchReasons[ent:EntIndex()] or 0
    ent.FPPCanTouchWhy = idx

    if not touchType then return idx end

    local maxReasonValue = 15
    -- 1111 shifted to the right touch type
    local touchTypeMask = bit.lshift(maxReasonValue, reasonSize * touchTypeMultiplier[touchType])
    -- Extract reason for touch type from reason number
    local touchTypeReason = bit.band(idx, touchTypeMask)
    -- Shift it back to the right
    local reasonNr = bit.rshift(touchTypeReason, reasonSize * touchTypeMultiplier[touchType])

    local reason = reasons[reasonNr]
    local owner = ent:CPPIGetOwner()

    if reasonNr == 1 then -- convert owner to the actual player
        return not isnumber(owner) and IsValid(owner) and owner:Nick() or "Unknown player"
    elseif reasonNr == 6 then
        return "Buddy (" .. (IsValid(owner) and owner:Nick() or "Unknown player") .. ")"
    end

    return reason
end
