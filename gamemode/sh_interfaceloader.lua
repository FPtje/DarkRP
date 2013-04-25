module("DarkRP", package.seeall)

-- Variable that maintains the existing stubs
local stubs = {}

-- Delay the calling of methods until the functions are implemented
local delayedCalls = {}

local returnsLayout, isreturns
local parmeterLayout, isparameters
local isreturns
local checkStub

/*---------------------------------------------------------------------------
Methods that check whether certain fields are valid
---------------------------------------------------------------------------*/
isreturns = function(tbl)
	if not istable(tbl) then return false end
	for k,v in pairs(tbl) do
		if not checkStub(v, returnsLayout) then return false end
	end
	return true
end

isparameters = function(tbl)
	if not istable(tbl) then return false end
	for k,v in pairs(tbl) do
		if not checkStub(v, returnsLayout) then return false end
	end
	return true
end

/*---------------------------------------------------------------------------
The layout of a method stub
---------------------------------------------------------------------------*/
local stubLayout = {
	name = isstring,
	description = isstring,
	parameters = isparameters, -- the parameters of a method
	returns = isreturns, -- the return values of a method
	metatable = istable -- DarkRP, Player, Entity, Vector, ...
}

returnsLayout = {
	name = isstring,
	description = isstring,
	type = isstring
}

parmeterLayout = {
	name = isstring,
	description = isstring,
	type = isstring,
	optional = isbool
}

/*---------------------------------------------------------------------------
Check the validity of a stub
---------------------------------------------------------------------------*/
checkStub = function(tbl, stub)
	if not istable(tbl) then return false, "table" end

	for name, check in pairs(stub) do
		if not check(tbl[name]) then
			return false, name
		end
	end

	return true
end

/*---------------------------------------------------------------------------
When a stub is called, the calling of the method is delayed
---------------------------------------------------------------------------*/
local function notImplemented(name, args)
	delayedCalls[name] = delayedCalls[name] or {}
	table.insert(delayedCalls[name], args)

	return nil -- no return value because the method is not implemented
end

/*---------------------------------------------------------------------------
Generate a stub
---------------------------------------------------------------------------*/
function stub(tbl)
	local isStub, field = checkStub(tbl, stubLayout)
	if not isStub then
		error("Invalid DarkRP method stub! Field \"" .. field .. "\" is invalid!", 2)
	end

	stubs[tbl.name] = tbl

	return function(...) return notImplemented(tbl.name, {...}) end
end

/*---------------------------------------------------------------------------
Retrieve the stubs
---------------------------------------------------------------------------*/
function getStubs()
	return table.Copy(stubs)
end

/*---------------------------------------------------------------------------
Call the cached methods
---------------------------------------------------------------------------*/
function finish()
	for name, log in pairs(delayedCalls) do
		if not stubs[name] then ErrorNoHalt("Calling non-existing stub \"" .. name .. "\"") continue end

		for _, args in pairs(log) do
			stubs[name].metatable[name](unpack(args))
		end
	end
end

/*---------------------------------------------------------------------------
Load the interface files
---------------------------------------------------------------------------*/
local function loadInterfaces()
	local root = GM.FolderName.."/gamemode/modules/"

	local _, folders = file.Find(root.."*", "LUA")

	ENTITY = FindMetaTable("Entity")
	PLAYER = FindMetaTable("Player")
	VECTOR = FindMetaTable("Vector")

	for _, folder in SortedPairs(folders, true) do
		if GM.Config.DisabledModules[folder] then continue end

		for _, File in SortedPairs(file.Find(root .. folder .."/sh_interface.lua", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end

		local realmInterface = CLIENT and "cl" or "sv"
		for _, File in SortedPairs(file.Find(root .. folder .."/" .. realmInterface .. "_interface.lua", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end
	end

	ENTITY, PLAYER, VECTOR = nil, nil, nil
end
loadInterfaces()
