local maxId = 0
local fprpVars = {}
local fprpVarById = {}

-- the amount of bits assigned to the value that determines which fprpVar we're sending/receiving
local fprp_ID_BITS = 8
local UNKNOWN_fprpVAR = 255 -- Should be equal to 2^fprp_ID_BITS - 1
fprp.fprp_ID_BITS = fprp_ID_BITS

function fprp.registerfprpVar(name, writeFn, readFn)
	maxId = maxId + 1

	-- UNKNOWN_fprpVAR is reserved for unknown values
	if maxId >= UNKNOWN_fprpVAR then fprp.error(string.format("Too many fprpVar registrations! fprpVar '%s' triggered this error", name), 2) end

	fprpVars[name] = {id = maxId, name = name, writeFn = writeFn, readFn = readFn}
	fprpVarById[maxId] = fprpVars[name]
end

-- Unknown values have unknown types and unknown identifiers, so this is sent inefficiently
local function writeUnknown(name, value)
	net.WriteUInt(UNKNOWN_fprpVAR, 8);
	net.WriteString(name);
	net.WriteType(value);
end

-- Read the value of a fprpVar that was not registered
local function readUnknown()
	return net.ReadString(), net.ReadType(net.ReadUInt(8));
end

local warningsShown = {}
local function warnRegistration(name)
	if warningsShown[name] then return end
	warningsShown[name] = true

	ErrorNoHalt(string.format([[Warning! fprpVar '%s' wasn't registered!
 		Please contact the author of the fprp Addon to fix this.
 		Until this is fixed you don't need to worry about anything. Everything will keep working.
 		It's just that registering fprpVars would make fprp faster.]], name));

	debug.Trace();
end

function fprp.writeNetfprpVar(name, value)
	local fprpVar = fprpVars[name]
	if not fprpVar then
		warnRegistration(name);

		return writeUnknown(name, value);
	end

	net.WriteUInt(fprpVar.id, fprp_ID_BITS);
	return fprpVar.writeFn(value);
end

function fprp.writeNetfprpVarRemoval(name)
	local fprpVar = fprpVars[name]
	if not fprpVar then
		warnRegistration(name);

		net.WriteUInt(UNKNOWN_fprpVAR, 8);
		net.WriteString(name);
		return
	end

	net.WriteUInt(fprpVar.id, fprp_ID_BITS);
end

function fprp.readNetfprpVar()
	local fprpVarId = net.ReadUInt(fprp_ID_BITS);
	local fprpVar = fprpVarById[fprpVarId]

	if fprpVarId == UNKNOWN_fprpVAR then
		local name, value = readUnknown();

		return name, value
	end

	local val = fprpVar.readFn(value);

	return fprpVar.name, val
end

function fprp.readNetfprpVarRemoval()
	local id = net.ReadUInt(fprp_ID_BITS);
	return id == 255 and net.ReadString() or fprpVarById[id].name
end

-- The shekel is a double because it accepts higher values than Int and UInt, which are undefined for >32 bits
fprp.registerfprpVar("shekel",         net.WriteDouble, net.ReadDouble);
fprp.registerfprpVar("salary",        fp{fn.Flip(net.WriteInt), 32}, fp{net.ReadInt, 32});
fprp.registerfprpVar("rpname",        net.WriteString, net.ReadString);
fprp.registerfprpVar("job",           net.WriteString, net.ReadString);
fprp.registerfprpVar("HasGunlicense", net.WriteBit, fc{tobool, net.ReadBit});
fprp.registerfprpVar("Arrested",      net.WriteBit, fc{tobool, net.ReadBit});
fprp.registerfprpVar("wanted",        net.WriteBit, fc{tobool, net.ReadBit});
fprp.registerfprpVar("wantedReason",  net.WriteString, net.ReadString);
fprp.registerfprpVar("agenda",        net.WriteString, net.ReadString);
