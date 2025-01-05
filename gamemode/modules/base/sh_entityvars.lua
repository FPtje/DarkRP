DarkRP.RegisteredDarkRPVarsMaxId = DarkRP.RegisteredDarkRPVarsMaxId or 0
DarkRP.RegisteredDarkRPVars = DarkRP.RegisteredDarkRPVars or {}
DarkRP.RegisteredDarkRPVarsById = DarkRP.RegisteredDarkRPVarsById or {}

-- the amount of bits assigned to the value that determines which DarkRPVar we're sending/receiving
local DARKRP_ID_BITS = 8
local UNKNOWN_DARKRPVAR = 255 -- Should be equal to 2^DARKRP_ID_BITS - 1
DarkRP.DARKRP_ID_BITS = DARKRP_ID_BITS

function DarkRP.registerDarkRPVar(name, writeFn, readFn)
    -- After a reload, only update the write and read function
    if DarkRP.RegisteredDarkRPVars[name] then
        DarkRP.RegisteredDarkRPVars[name].writeFn = writeFn
        DarkRP.RegisteredDarkRPVars[name].readFn = readFn
        return
    end

    DarkRP.RegisteredDarkRPVarsMaxId = DarkRP.RegisteredDarkRPVarsMaxId + 1

    -- UNKNOWN_DARKRPVAR is reserved for unknown values
    if DarkRP.RegisteredDarkRPVarsMaxId >= UNKNOWN_DARKRPVAR then DarkRP.error(string.format("Too many DarkRPVar registrations! DarkRPVar '%s' triggered this error", name), 2) end

    DarkRP.RegisteredDarkRPVars[name] = {id = DarkRP.RegisteredDarkRPVarsMaxId, name = name, writeFn = writeFn, readFn = readFn}
    DarkRP.RegisteredDarkRPVarsById[DarkRP.RegisteredDarkRPVarsMaxId] = DarkRP.RegisteredDarkRPVars[name]
end

-- Unknown values have unknown types and unknown identifiers, so this is sent inefficiently
local function writeUnknown(name, value)
    net.WriteUInt(UNKNOWN_DARKRPVAR, 8)
    net.WriteString(name)
    net.WriteType(value)
end

-- Read the value of a DarkRPVar that was not registered
local function readUnknown()
    return net.ReadString(), net.ReadType(net.ReadUInt(8))
end

local warningsShown = {}
local function warnRegistration(name)
    if warningsShown[name] then return end
    warningsShown[name] = true

    DarkRP.errorNoHalt(string.format([[Warning! DarkRPVar '%s' wasn't registered!
        Please contact the author of the DarkRP Addon to fix this.
        Until this is fixed you don't need to worry about anything. Everything will keep working.
        It's just that registering DarkRPVars would make DarkRP faster.]], name), 4)
end

function DarkRP.writeNetDarkRPVar(name, value)
    local DarkRPVar = DarkRP.RegisteredDarkRPVars[name]
    if not DarkRPVar then
        warnRegistration(name)

        return writeUnknown(name, value)
    end

    net.WriteUInt(DarkRPVar.id, DARKRP_ID_BITS)
    return DarkRPVar.writeFn(value)
end

function DarkRP.writeNetDarkRPVarRemoval(name)
    local DarkRPVar = DarkRP.RegisteredDarkRPVars[name]
    if not DarkRPVar then
        warnRegistration(name)

        net.WriteUInt(UNKNOWN_DARKRPVAR, 8)
        net.WriteString(name)
        return
    end

    net.WriteUInt(DarkRPVar.id, DARKRP_ID_BITS)
end

function DarkRP.readNetDarkRPVar()
    local DarkRPVarId = net.ReadUInt(DARKRP_ID_BITS)
    local DarkRPVar = DarkRP.RegisteredDarkRPVarsById[DarkRPVarId]

    if DarkRPVarId == UNKNOWN_DARKRPVAR then
        local name, value = readUnknown()

        return name, value
    end

    local val = DarkRPVar.readFn(value)

    return DarkRPVar.name, val
end

function DarkRP.readNetDarkRPVarRemoval()
    local id = net.ReadUInt(DARKRP_ID_BITS)
    return id == 255 and net.ReadString() or DarkRP.RegisteredDarkRPVarsById[id].name
end

-- The money is a double because it accepts higher values than Int and UInt, which are undefined for >32 bits
DarkRP.registerDarkRPVar("money",         net.WriteDouble, net.ReadDouble)
DarkRP.registerDarkRPVar("salary",        fp{fn.Flip(net.WriteInt), 32}, fp{net.ReadInt, 32})
DarkRP.registerDarkRPVar("rpname",        net.WriteString, net.ReadString)
DarkRP.registerDarkRPVar("job",           net.WriteString, net.ReadString)
DarkRP.registerDarkRPVar("HasGunlicense", net.WriteBit, fc{tobool, net.ReadBit})
DarkRP.registerDarkRPVar("Arrested",      net.WriteBit, fc{tobool, net.ReadBit})
DarkRP.registerDarkRPVar("wanted",        net.WriteBit, fc{tobool, net.ReadBit})
DarkRP.registerDarkRPVar("wantedReason",  net.WriteString, net.ReadString)
DarkRP.registerDarkRPVar("agenda",        net.WriteString, net.ReadString)

--[[---------------------------------------------------------------------------
RP name override
---------------------------------------------------------------------------]]
local pmeta = FindMetaTable("Player")
pmeta.SteamName = pmeta.SteamName or pmeta.Name
function pmeta:Name()
    if not self:IsValid() then DarkRP.error("Attempt to call Name/Nick/GetName on a non-existing player!", SERVER and 1 or 2) end
    return GAMEMODE.Config.allowrpnames and self:getDarkRPVar("rpname")
        or self:SteamName()
end
pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
