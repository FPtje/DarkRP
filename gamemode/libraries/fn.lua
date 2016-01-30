/*---------------------------------------------------------------------------
Functional library

by FPtje Atheos
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
Function currying
    Take a function with n parameters.
    Currying is the procedure of storing k < n parameters "in the function"
     in such a way that the remaining function can be called with n - k parameters

    Example:
    DebugPrint = fp{print, "[DEBUG]"}
    DebugPrint("TEST")
    > [DEBUG] TEST
---------------------------------------------------------------------------*/
function fp(tbl)
    local func = tbl[1]

    return function(...)
        local fnArgs = {}
        local arg = {...}
        local tblN = table.maxn(tbl)

        for i = 2, tblN do fnArgs[i - 1] = tbl[i] end
        for i = 1, table.maxn(arg) do fnArgs[tblN + i - 1] = arg[i] end

        return func(unpack(fnArgs, 1, table.maxn(fnArgs)))
    end
end

local unpack = unpack
local table = table
local pairs = pairs
local ipairs = ipairs
local error = error
local math = math
local select = select
local type = type
local _G = _G
local fp = fp


module("fn")

/*---------------------------------------------------------------------------
Parameter manipulation
---------------------------------------------------------------------------*/
Id = function(...) return ... end

Flip = function(f)
    if not f then error("not a function") end
    return function(b, a, ...)
        return f(a, b, ...)
    end
end

-- Definition from http://lua-users.org/wiki/CurriedLua
ReverseArgs = function(...)

   --reverse args by building a function to do it, similar to the unpack() example
   local function reverse_h(acc, v, ...)
      if select('#', ...) == 0 then
         return v, acc()
      else
         return reverse_h(function () return v, acc() end, ...)
      end
   end

   -- initial acc is the end of the list
   return reverse_h(function () return end, ...)
end

/*---------------------------------------------------------------------------
Misc functions
---------------------------------------------------------------------------*/
-- function composition
do
    local function comp_h(a, b, ...)
        if b == nil then return a end
        b = comp_h(b, ...)
        return function(...)
            return a(b(...))
        end
    end
    Compose = function(funcs, ...)
        if type(funcs) == "table" then
            return comp_h(unpack(funcs))
        else
            return comp_h(funcs, ...)
        end
    end
end

_G.fc = Compose

-- Definition from http://lua-users.org/wiki/CurriedLua
Curry = function(func, num_args)
    if not num_args then error("Missing argument #2: num_args") end
    if not func then error("Function does not exist!", 2) end
    -- helper
    local function curry_h(argtrace, n)
        if n == 0 then
            -- reverse argument list and call function
            return func(ReverseArgs(argtrace()))
        else
            -- "push" argument (by building a wrapper function) and decrement n
            return function(x)
                return curry_h(function() return x, argtrace() end, n - 1)
            end
        end
   end

   -- no sense currying for 1 arg or less
   if num_args > 1 then
      return curry_h(function() return end, num_args)
   else
      return func
   end
end

-- Thanks Lexic!
Partial = function(func, ...)
    local args = {...}
    return function(...)
        return func(unpack(table.Add( args, {...})))
    end
end

Apply = function(f, ...) return f(...) end

Const = function(a, b) return a end
Until = function(cmp, fn, val)
    if cmp(val) then
        return val
    end
    return Until(cmp, fn, fn(val))
end

Seq = function(f, x) f(x) return x end

GetGlobalVar = function(key) return _G[key] end

/*---------------------------------------------------------------------------
Mathematical operators and functions
---------------------------------------------------------------------------*/
Add = function(a, b) return a + b end
Sub = function(a, b) return a - b end
Mul = function(a, b) return a * b end
Div = function(a, b) return a / b end
Mod = function(a, b) return a % b end
Neg = function(a)    return -a    end

Eq  = function(a, b) return a == b end
Neq = function(a, b) return a ~= b end
Gt  = function(a, b) return a > b  end
Lt  = function(a, b) return a < b  end
Gte = function(a, b) return a >= b end
Lte = function(a, b) return a <= b end

Succ = Compose{Add, 1}
Pred = Compose{Flip(Sub), 1}
Even = Compose{fp{Eq, 0}, fp{Flip(Mod), 2}}
Odd  = Compose{Not, Even}

/*---------------------------------------------------------------------------
Functional logical operators and conditions
---------------------------------------------------------------------------*/
FAnd = function(fns)
    return function(...)
        local val
        for _, f in pairs(fns) do
            val = {f(...)}
            if not val[1] then return unpack(val) end
        end
        if val then return unpack(val) end
    end
end

FOr = function(fns)
    return function(...)
        local val
        for _, f in pairs(fns) do
            val = {f(...)}
            if val[1] then return unpack(val) end
        end
        return false, unpack(val, 2)
    end
end

Not = function(x) return not x end

If = function(f, Then, Else)
    return function(x)
        if f(x) then
            return Then
        else
            return Else
        end
    end
end

/*---------------------------------------------------------------------------
List operations
---------------------------------------------------------------------------*/
Map = function(f, xs)
    for k, v in pairs(xs) do
        xs[k] = f(v)
    end
    return xs
end

Append = function(xs, ys)
    return table.Add(xs, ys)
end

Filter = function(f, xs)
    local res = {}
    for k,v in pairs(xs) do
        if f(v) then res[k] = v end
    end
    return res
end

ForEach = function(f, xs)
    for k,v in pairs(xs) do
        local val = f(k, v)
        if val ~= nil then return val end
    end
end

Head = function(xs)
    return table.GetFirstValue(xs)
end

Last = function(xs)
    return xs[#xs] or table.GetLastValue(xs)
end

Tail = function(xs)
    table.remove(xs, 1)
    return xs
end

Init = function(xs)
    xs[#xs] = nil
    return xs
end

GetValue = function(i, xs)
    return xs[i]
end

Null = function(xs)
    for k, v in pairs(xs) do
        return false
    end
    return true
end

Length = function(xs)
    return #xs
end

Index = function(xs, i)
    return xs[i]
end

Reverse = function(xs)
    local res = {}
    for i = #xs, 1, -1 do
        res[#xs - i + 1] = xs[i]
    end
    return res
end

/*---------------------------------------------------------------------------
Folds
---------------------------------------------------------------------------*/
Foldr = function(func, val, xs)
    for i = #xs, 1, -1 do
        val = func(xs[i], val)
    end

    return val
end

Foldl = function(func, val, xs)
    for k, v in ipairs(xs) do
        val = func(val, v)
    end

    return val
end

And = function(xs)
    for k, v in pairs(xs) do
        if v ~= true then return false end
    end
    return true
end

Or = function(xs)
    for k, v in pairs(xs) do
        if v == true then return true end
    end
    return false
end

Any = function(func, xs)
    for k, v in pairs(xs) do
        if func(v) == true then return true end
    end
    return false
end

All = function(func, xs)
    for k, v in pairs(xs) do
        if func(v) ~= true then return false end
    end
    return true
end

Sum = _G.fp{Foldr, Add, 0}

Product = _G.fp{Foldr, Mul, 1}

Concat = _G.fp{Foldr, Append, {}}

Maximum = _G.fp{Foldl, math.Max, -math.huge}

Minimum = _G.fp{Foldl, math.Min, math.huge}

Snd = _G.fp{select, 2}

Thrd = _G.fp{select, 3}
