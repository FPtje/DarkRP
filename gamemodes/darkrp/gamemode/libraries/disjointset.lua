/*---------------------------------------------------------------------------
Disjoint-set forest implementation
Inspired by the book Introduction To Algorithms (third edition)

by FPtje Atheos

Running time per operation (Union/FindSet): O(a(n)) where a is the inverse of the Ackermann function.
---------------------------------------------------------------------------*/

local ipairs = ipairs
local setmetatable = setmetatable
local string = string
local table = table
local tostring = tostring

module("disjoint")

local metatable

-- Make a singleton set. Parent parameter is optional, must be a disjoint-set as well.
function MakeSet(x, parent)
    local set  = {}
    set.value  = x
    set.rank   = 0
    set.parent = parent or set

    setmetatable(set, metatable)

    return set
end

local function Link(x, y)
    if x == y then return x end

    -- Union by rank
    if x.rank > y.rank then
        y.parent = x
        return x
    end

    x.parent = y

    if x.rank == y.rank then
        y.rank = y.rank + 1
    end

    return y
end

-- Apply the union operation between two sets.
function Union(x, y)
    return Link(FindSet(x), FindSet(y))
end

function FindSet(x)
    local parent = x
    local listParents

    -- Go up the tree to find the parent
    while parent ~= parent.parent do
        parent = parent.parent

        listParents = listParents or {}
        table.insert(listParents, parent)
    end

    -- Path compression, update all parents to refer to the top parent
    if listParents then
        for _, v in ipairs(listParents) do
            v.parent = parent
        end
    end

    return parent
end

function Disconnect(x)
    x.parent = x

    return x
end


metatable = {
    __tostring = function(self)
        return string.format("Disjoint-Set [value: %s][Rank: %s][Parent: %s]", tostring(self.value), self.rank, tostring(self.parent.value))
    end,
    __metatable = true, -- restrict access to metatable
    __add = Union
}
