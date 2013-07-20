/*---------------------------------------------------------------------------
Functional library

by FPtje Atheos
---------------------------------------------------------------------------*/

local unpack = unpack
local table = table
local pairs = pairs
local ipairs = ipairs
local error = error
local math = math
local select = select


module("fn")

/*---------------------------------------------------------------------------
Parameter manipulation
---------------------------------------------------------------------------*/
Id = function(...) return ... end

Flip = function(f) return
	function(b, a, ...)
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

   -- initial acc is the end of	the list
   return reverse_h(function () return end, ...)
end

/*---------------------------------------------------------------------------
Misc functions
---------------------------------------------------------------------------*/
-- function composition
Compose = function(funcs)
	return function(...)
		local res = {...}
		for i = #funcs, 1, -1 do
			res = {funcs[i](unpack(res))}
		end
		return unpack(res)
	end
end

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

Apply = function(f, ...) return f(...) end

Const = function(a, b) return a end
Until = function(cmp, fn, val)
	if cmp(val) then
		return val
	end
	return Until(cmp, fn, fn(val))
end

/*---------------------------------------------------------------------------
Mathematical operators and functions
---------------------------------------------------------------------------*/
Add = function(a, b) return a + b end
Substract = function(a, b) return a - b end
Multiply = function(a, b) return a * b end
Divide = function(a, b) return a / b end
Mod = function(a, b) return a % b end
Neg = function(a) return -a end

Eq = function(a, b) return a == b end
Neq = function(a, b) return a ~= b end
Gt = function(a, b) return a > b end
Lt = function(a, b) return a < b end
Gte = function(a, b) return a >= b end
Lte = function(a, b) return a <= b end

Succ = Curry(Add, 2)(1)
Pred = Curry(Flip(Substract), 2)(1)
Even = Compose{Curry(Eq, 2)(0), Curry(Flip(Mod), 2)(2)}
Odd = Compose{Not, Even}

/*---------------------------------------------------------------------------
Functional logical operators and conditions
---------------------------------------------------------------------------*/
FAnd = function(fns)
	return function(x)
		for _, f in pairs(fns) do
			if not f(x) then return false end
		end
		return true
	end
end

FOr = function(fns)
	return function(x)
		for _, f in pairs(fns) do
			if f(x) then return true end
		end
		return false
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

Sum = Curry(Foldr, 3)(Add)(0)

Product = Curry(Foldr, 3)(Multiply)(1)

Concat = Curry(Foldr, 3)(Append)({})

Maximum = Curry(Foldl, 3)(math.Max)(-math.huge)

Minimum = Curry(Foldl, 3)(math.Min)(math.huge)
