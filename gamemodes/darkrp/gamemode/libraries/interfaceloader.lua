module("DarkRP", package.seeall)

MetaName = "DarkRP"

-- Variables that maintain the existing stubs and hooks
local stubs = {}
local hookStubs = {}

-- Contains the functions that the hooks call by default
hooks = {}

-- Delay the calling of methods until the functions are implemented
local delayedCalls = {}

local returnsLayout, isreturns
local parameterLayout, isparameters
local isdeprecated
local checkStub

local hookLayout

local realm -- State variable to manage the realm of the stubs

--[[---------------------------------------------------------------------------
Methods that check whether certain fields are valid
---------------------------------------------------------------------------]]
isreturns = function(tbl)
    if not istable(tbl) then return false end
    for _, v in pairs(tbl) do
        if not checkStub(v, returnsLayout) then return false end
    end
    return true
end

isparameters = function(tbl)
    if not istable(tbl) then return false end
    for _, v in pairs(tbl) do
        if not checkStub(v, parameterLayout) then return false end
    end
    return true
end

isdeprecated = function(val)
    return val == nil or isstring(val)
end

--[[---------------------------------------------------------------------------
The layouts of stubs
---------------------------------------------------------------------------]]
local stubLayout = {
    name = isstring,
    description = isstring,
    deprecated = isdeprecated,
    parameters = isparameters, -- the parameters of a method
    returns = isreturns, -- the return values of a method
    metatable = istable -- DarkRP, Player, Entity, Vector, ...
}

hookLayout = {
    name = isstring,
    description = isstring,
    deprecated = isdeprecated,
    parameters = isreturns, -- doesn't have the 'optional' field
    returns = isreturns,
}

returnsLayout = {
    name = isstring,
    description = isstring,
    type = isstring
}

parameterLayout = {
    name = isstring,
    description = isstring,
    type = isstring,
    optional = isbool
}

--[[---------------------------------------------------------------------------
Check the validity of a stub
---------------------------------------------------------------------------]]
checkStub = function(tbl, stub)
    if not istable(tbl) then return false, "table" end

    for name, check in pairs(stub) do
        if not check(tbl[name]) then
            return false, name
        end
    end

    return true
end

--[[---------------------------------------------------------------------------
When a stub is called, the calling of the method is delayed
---------------------------------------------------------------------------]]
local function notImplemented(name, args, thisFunc)
    if stubs[name] and stubs[name].metatable[name] ~= thisFunc then -- when calling the not implemented function after the function was implemented
        return stubs[name].metatable[name](unpack(args))
    end
    table.insert(delayedCalls, {name = name, args = args})

    return nil -- no return value because the method is not implemented
end

--[[---------------------------------------------------------------------------
Generate a stub
---------------------------------------------------------------------------]]
function stub(tbl)
    local isStub, field = checkStub(tbl, stubLayout)
    if not isStub then
        error("Invalid DarkRP method stub! Field \"" .. field .. "\" is invalid!", 2)
    end

    tbl.realm = tbl.realm or realm
    stubs[tbl.name] = tbl

    local function retNotImpl(...)
        return notImplemented(tbl.name, {...}, retNotImpl)
    end

    return retNotImpl
end

--[[---------------------------------------------------------------------------
Generate a hook stub
---------------------------------------------------------------------------]]
function hookStub(tbl)
    local isStub, field = checkStub(tbl, hookLayout)
    if not isStub then
        error("Invalid DarkRP hook! Field \"" .. field .. "\" is invalid!", 2)
    end

    tbl.realm = tbl.realm or realm
    hookStubs[tbl.name] = tbl
end

--[[---------------------------------------------------------------------------
Retrieve the stubs
---------------------------------------------------------------------------]]
function getStubs()
    return table.Copy(stubs)
end

--[[---------------------------------------------------------------------------
Retrieve the hooks
---------------------------------------------------------------------------]]
function getHooks()
    return table.Copy(hookStubs)
end

--[[---------------------------------------------------------------------------
Call the cached methods
---------------------------------------------------------------------------]]
function finish()
    local calls = table.Copy(delayedCalls) -- Loop through a copy, so the notImplemented function doesn't get called again
    for _, tbl in ipairs(calls) do
        local name = tbl.name

        if not stubs[name] then ErrorNoHalt("Calling non-existing stub \"" .. name .. "\"") continue end

        stubs[name].metatable[name](unpack(tbl.args))
    end

    delayedCalls = {}
end

--[[---------------------------------------------------------------------------
Load the interface files
---------------------------------------------------------------------------]]
local function loadInterfaces()
    local root = GM.FolderName .. "/gamemode/modules"

    local _, folders = file.Find(root .. "/*", "LUA")

    ENTITY = FindMetaTable("Entity")
    PLAYER = FindMetaTable("Player")
    VECTOR = FindMetaTable("Vector")

    for _, folder in SortedPairs(folders, true) do
        local interfacefile = string.format("%s/%s/%s_interface.lua", root, folder, "%s")
        local client = string.format(interfacefile, "cl")
        local shared = string.format(interfacefile, "sh")
        local server = string.format(interfacefile, "sv")

        if file.Exists(shared, "LUA") then
            if SERVER then AddCSLuaFile(shared) end
            realm = "Shared"
            include(shared)
        end

        if SERVER and file.Exists(client, "LUA") then
            AddCSLuaFile(client)
        end

        if SERVER and file.Exists(server, "LUA") then
            realm = "Server"
            include(server)
        end

        if CLIENT and file.Exists(client, "LUA") then
            realm = "Client"
            include(client)
        end
    end

    ENTITY, PLAYER, VECTOR = nil, nil, nil
end
loadInterfaces()
