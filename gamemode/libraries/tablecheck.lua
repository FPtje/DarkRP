--[[
tablecheck

WIP

Author: FPtje Falco

Purpose:
Allow validating tables by creating schemas of tables. Inspired by Joi (https://github.com/hapijs/joi)

Requires fn library (https://github.com/FPtje/GModFunctional),

Example:
```lua
local schema = tc.assertTable{
    name   = tc.assert(isstring, "The name must be a string!"),
    id     = tc.assert(isnumber, "The id must be a number!"),
    gender = tc.assert(tc.oneOf{"male", "female", "carp"}, "Gender missing or not recognised!", {"Perhaps you are a carp?"}),
}

local correct, err, hints = schema({name = "Dick", id = 3, gender = "carp"})
print(correct) -- true


local correct, err, hints = schema({name = "Dick", id = 3, gender = "crap"})
print(correct) -- false
print(err) -- Gender missing or not recognised!
PrintTable(hints) -- {"Perhaps you are a carp?"}
```

For further examples, including nesting and combining of schemas, please see the `unitTests` function for now.
--]]

module("tc", package.seeall)

-- Helpers for quick access to metatables
angle                  = FindMetaTable("Angle")
convar                 = FindMetaTable("ConVar")
effectdata             = FindMetaTable("CEffectData")
entity                 = FindMetaTable("Entity")
file                   = FindMetaTable("File")
imaterial              = FindMetaTable("IMaterial")
irestore               = FindMetaTable("IRestore")
isave                  = FindMetaTable("ISave")
itexture               = FindMetaTable("ITexture")
lualocomotion          = FindMetaTable("CLuaLocomotion")
movedata               = FindMetaTable("CMoveData")
navarea                = FindMetaTable("CNavArea")
navladder              = FindMetaTable("CNavLadder")
nextbot                = FindMetaTable("NextBot")
npc                    = FindMetaTable("NPC")
pathfollower           = FindMetaTable("PathFollower")
physobj                = FindMetaTable("PhysObj")
player                 = FindMetaTable("Player")
recipientfilter        = FindMetaTable("CRecipientFilter")
soundpatch             = FindMetaTable("CSoundPatch")
takedamageinfo         = FindMetaTable("CTakeDamageInfo")
usercmd                = FindMetaTable("CUserCmd")
vector                 = FindMetaTable("Vector")
vehicle                = FindMetaTable("Vehicle")
vmatrix                = FindMetaTable("VMatrix")
weapon                 = FindMetaTable("Weapon")

-- Assert function, asserts a property and returns the error if false.
-- Allows f to override err and hints by simply returning them
assert = function(f, err, hints) return function(...)
    local res = {f(...)}
    table.insert(res, err)
    table.insert(res, hints)

    return unpack(res)
end end

--[[ Validates a table against a schema
Capable of nesting
--]]
function assertTable(schema)
    return function(tbl)
        if not istable(tbl) then
            return false, "Not a table!"
        end

        for k, v in pairs(schema or {}) do
            local correct, err, hints = tbl[v] ~= nil
            if isfunction(v) then correct, err, hints, replace, replaceWith = v(tbl[k], tbl) end


            if not correct then
                err = err or string.format("Element '%s' is corrupt!", k)
                return correct, err, hints
            end

            -- Update the value
            if correct and replace == true and replaceWith then
                tbl[k] = replaceWith
            end
        end

        return true
    end
end

-- Returns whether a value is nil
isnil = fn.Curry(fn.Eq, 2)(nil)

-- Returns whether a value is a color
iscolor = IsColor

-- Returns true on the client
client = function() return CLIENT end

-- returns true on the server
server = function() return SERVER end

-- Optional value, when filled in it must meet the conditions
optional = function(...) return fn.FOr{isnil, ...} end

-- Default value, implies optional. Only works in combination with assertTable
-- Note that the tc.assert is to be the second parameter of default.
--      tc.assert(default(x)) does NOT work, default(x, tc.assert(...)) does.
-- example: tcassertTable{test = default(3, tc.assert(isnumber, "must be a number"))}
-- example: tcassertTable{test = default(3)}
default = function(def, f)
    return function(val)
        if val == nil then
            -- second return value is the default value. Expects parent function to actually change the value
            return true, nil, nil, true, def
        end
        -- Return in if statement rather than "return f and f(val) or true" to allow multiple return values
        if f then return f(val) else return true end
    end
end

-- A table of which each element must meet condition f
-- i.e. "this must be a table of xxx"
-- example: tc.tableOf(isnumber) demands that the table contains only numbers
tableOf = function(f) return function(tbl)
    if not istable(tbl) then return false end
    for k,v in pairs(tbl) do if not f(v) then return false end end
    return true
end end

-- Checks whether a value is amongst a given set of values
-- exapmle: tc.oneOf{"jobs", "entities", "shipments", "weapons", "vehicles", "ammo"}
oneOf = function(f) return fp{table.HasValue, f} end

-- A table that is non-empty, also useful for wrapping around tableOf
-- example: tc.nonEmpty(tc.tableOf(isnumber))
-- example: tc.nonEmpty() -- just checks that the table is non-empty
nonEmpty = function(f) return function(tbl) return istable(tbl) and #tbl > 0 and (not f or f(tbl)) end end

-- Number check: minimum
min = function(n) return fn.FAnd{isnumber, fp{fn.Lte, n}} end

-- Number check: maximum
max = function(n) return fn.FAnd{isnumber, fp{fn.Gte, n}} end

-- Test cases. Also serve as nice examples
function unitTests()
    local id = 0

    -- unit test helper functions
    local function checkCorrect(correct, err, hints)
        id = id + 1

        if correct ~= true then
            print(id, "Incorrect value that should be correct!", correct, err, hints)
            if hints then PrintTable(hints) end
            return
        end

        print(id, "Correct")
    end

    local function checkIncorrect(correct, err, hints)
        id = id + 1

        if correct then
            print(id, "Correct value that should be incorrect!", correct, err, hints)
            if hints then PrintTable(hints) end
            return
        end

        print(id, "Correct")
    end

    --[[
    Simple value schema. Checks whether the input is a number.
    ]]
    local simpleSchema = tc.assert(isnumber, "Must be a number!")

    -- This is how a schema is to be used. Just call it with the value you want to check.
    -- In further unit tests, the schema function is immediately called inside the checkCorrect/checIncorrect call for brevity
    local correct, err, hints = simpleSchema(3)

    checkCorrect(correct, err, hints)


    --[[
    Simple table schema
    ]]
    local simpleTableSchema = tc.assertTable{
        name        = tc.assert(isstring, "The name must be a string!"),
        id          = tc.assert(isnumber, "The id must be a number!"),
        gender      = tc.assert(tc.oneOf{"male", "female", "carp"}, "Gender missing or not recognised!", {"Perhaps you are a carp?"}),
        nilthing    = tc.assert(tc.isnil, "nilthing must be nil"),
        nonEmpty    = tc.assert(tc.nonEmpty(tc.tableOf(isnumber)), "nonEmpty not table of numbers"),
        optnum      = tc.assert(tc.optional(isnumber), "optnum given, but not a number"),
        strnum      = tc.assert(fn.FOr{isstring, isnumber}, "strnum must either be a string or a number"),
        minmax      = tc.assert(fn.FAnd{tc.min(5), tc.max(10)}),
    }

    checkCorrect(simpleTableSchema({name = "Dick", id = 3, gender = "carp", nonEmpty = {1,2,3}, strnum = "str", minmax = 5}))

    -- Counterexamples, should throw errors
    local badTables = {
        {},
        {name = 1, id = 3, gender = "carp", nonEmpty = {1,2,3}, strnum = "str", minmax = 7},
        {name = "Dick", id = "3", gender = "carp", nonEmpty = {1,2,3}, strnum = "str", minmax = 7},
        {name = "Dick", id = 3, gender = "other", nonEmpty = {1,2,3}, strnum = "str", minmax = 7},
        {name = "Dick", id = 3, gender = "carp", nonEmpty = {}, strnum = "str", minmax = 7},
        {name = "Dick", id = 3, gender = "carp", nonEmpty = {1,2,3}, strnum = {}, minmax = 7},
        {name = "Dick", id = 3, gender = "carp", nonEmpty = {1,2,3}, strnum = "str", optnum = "nope", minmax = 7},
        {name = "Dick", id = 3, gender = "carp", nonEmpty = {1,2,3}, strnum = "str", minmax = 4},
        {name = "Dick", id = 3, gender = "carp", nonEmpty = {1,2,3}, strnum = "str", minmax = 11},
        {name = "Dick", id = 3, gender = "carp", nonEmpty = {1,2,3}, strnum = "str"},
    }

    for _, tbl in pairs(badTables) do
        checkIncorrect(simpleTableSchema(tbl))
    end

    --[[
    Table Schema with no explicit keys
    ]]
    local nokeysSchema = tc.assertTable{
        tc.assert(isstring, "The first value must be a string."),
        tc.assert(isnumber, "The second value must be a number!"),
    }
    checkCorrect(nokeysSchema({"string", 3}))

    --[[
    Nested table schema
    ]]
    local nestedSchema = tc.assertTable{
        nested = tc.assertTable{
            val = tc.assert(isnumber, "'val' must be a number!")
        }
    }

    checkCorrect(nestedSchema({nested = {val = 3}}))
    checkIncorrect(nestedSchema({}))

    --[[
    Combining schemas using the fn library
    ]]
    local andSchema = fn.FAnd{
        tc.assertTable{
            num = tc.assert(isnumber, "num is not a number")
        },
        tc.assertTable{
            str = tc.assert(isstring, "str is not a string")
        }
    }

    checkCorrect(andSchema({num = 1, str = "string!"}))
    checkIncorrect(andSchema({num = 1}))
    checkIncorrect(andSchema({str = "string!"}))

    local orSchema = fn.FOr{
        tc.assertTable{
            num = tc.assert(isnumber, "num is not a number")
        },
        tc.assertTable{
            str = tc.assert(isstring, "str is not a string")
        }
    }
    checkCorrect(orSchema({num = 1}))
    checkCorrect(orSchema({str = "string!"}))

    --[[
    Default value with a check
    ]]
    local withDefaultSchema = tc.assertTable{
        value = tc.default(10, tc.assert(isnumber, "must be a number!"))
    }
    checkCorrect(withDefaultSchema({value = 30}))
    checkIncorrect(withDefaultSchema({value = "string"}))

    local empty = {}
    checkCorrect(withDefaultSchema(empty))
    if empty.value ~= 10 then
        print("Default did NOT set the value to 10!")
    else
        print("Default test OK!")
    end

    --[[
    Default value with no checks
    ]]
    local withDefaultNoCheck = tc.assertTable{
        value = tc.default(10)
    }
    checkCorrect(withDefaultNoCheck({}))
    checkCorrect(withDefaultNoCheck({value = "string"}))

    --[[
    Creating your own checker function that returns an error message
    When both the function and the tc.assert define error messages, there's a conflict
    ]]
    local function customCheck(val)
        return false, "function error message", {"function hint"}
    end

    local customCheckSchema = tc.assertTable{
        value = tc.assert(customCheck, "conflicting error message", {"conflicting hint"})
    }
    checkIncorrect(customCheckSchema{value = 1})
    checkIncorrect(customCheckSchema{})

    _, err, hints = customCheckSchema{value = 2}
    if err ~= "function error message" or hints[1] ~= "function hint" then
        print("Wrong conflict solution", err, hints[1])
    else
        print("Conflict solution OK!")
    end

    print("finished")
end
