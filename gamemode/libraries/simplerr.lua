local CompileFile = CompileFile
local CompileString = CompileString
local debug = debug
local error = error
local file = file
local hook = hook
local include = include
local isfunction = isfunction
local isstring = isstring
local math = math
local os = os
local string = string
local table = table
local tonumber = tonumber
local unpack = unpack
local xpcall = xpcall

-- Template for syntax errors
-- The [ERROR] start of it cannot be removed, because that would make the
-- error mechanism remove all square brackets. Only Garry can make that bullshit up.
local synErrTranslation = [=[[ERROR] Lua is unable to understand file "%s" because its author made a mistake around line number %i.
The best help I can give you is this:

%s

Hints:
%s

------- End of Simplerr error -------
]=] -- The end is a special string by which simplerr errors are internally recognised

-- Template for runtime errors
local runErrTranslation = [=[[ERROR] A runtime error has occurred in "%s" on line %i.
The best help I can give you is this:

%s

Hints:
%s

The responsibility for the error above lies with (the authors of) one (or more) of these files:
%s
------- End of Simplerr error -------
]=]

-- Structure that contains syntax errors and their translations. Catches only the most common errors.
-- Order is important: the structure with the first match is taken.
local synErrs = {
    {
        match = "'=' expected near '(.*)'",
        text = "Right before the '%s', Lua expected to read an '='-sign, but it didn't.",
        format = function(m) return m[1] end,
        hints = {
            "Did you simply forget the '='-sign?",
            "Did you forget a comma?",
            "Is this supposed to be a local variable?"
        }
    },
    {
        match = "'.' expected [(]to close '([{[(])' at line ([0-9-]+)[)] near '(.*)'",
        text = "There is an opening '%s' bracket at line %i, but this bracket is never closed or not closed in time. It was expected to be closed before the '%s' at line %i.",
        format = function(m, l) return m[1], m[2], m[3], l end,
        hints = {
            "Did you forget a comma?",
            "All open brackets ({, (, [) must have a matching closing bracket. Are you sure it's there?",
            "Brackets must be opened and closed in the right order. This will work: ({}), but this won't: ({)}."
        }
    },
    {
        match = "'end' expected [(]to close '(.*)' at line ([0-9-]+)[)] near '(.*)'",
        text = "An '%s' was started on line %i, but it was never ended or not ended in time. It was expected to be ended before the '%s' at line %i",
        format = function(m, l) return m[1], m[2], m[3], l end,
        hints = {
            "For every if/for/do/while/function there must be an 'end' that closes it."
        }
    },
    {
        match = "unfinished string near '(.*)'",
        text = "The string '%s' at line %i is opened, but not closed.",
        format = function(m, l) return m[1], l end,
        hints = {
            "A string is a different word for literal text.",
            "Strings must be in single or double quotation marks (e.g. 'example', \"example\")",
            "A third option for strings is for them to be in double square brackets.",
            "Whatever you use (quotations or square brackets), you must not forget that strings are enclosed within a pair of quotation marks/square brackets."
        }
    },
    {
        match = "unfinished long string near '(.*)'",
        text = "Lua expected to see the end of a multiline string somewhere before the '%s' at line %i.",
        format = function(m, l) return m[1], l end,
        hints = {
            "A string is a different word for literal text.",
            "Multiline strings are strings that span over multiple lines.",
            "Multiline strings must be enclosed by double square brackets.",
            "Whatever you use (quotations or square brackets), you must not forget that strings are enclosed within a pair of quotation marks/square brackets.",
            "If you used brackets, the source of the mistake may be somewhere above the reported line."
        }
    },
    {
        match = "unfinished long comment near '(.*)'",
        text = "Lua expected to see the end of a multiline comment somewhere before the '%s' at line %i.",
        format = function(m, l) return m[1], l end,
        hints = {
            "A comment is text ignored by Lua.",
            "Multiline comments are ones that span multiple lines.",
            "Multiline comments must be enclosed by either /* and */ or double square brackets.",
            "Whatever you use (/**/ or square brackets), you must not forget that once you start a comment, you must end it.",
            "The source of the mistake may be somewhere above the reported line."
        }
    },
    -- Generic error messages
    {
        match = "function arguments expected near '(.*)'",
        text = "A function is being called right before '%s', but its arguments are not given.",
        format = function(m) return m[1] end,
        hints = {
            "Did you write 'something:otherthing'? Try changing it to 'something:otherthing()'"
        }
    },
    {
        match = "unexpected symbol near '(.*)'",
        text = "Right before the '%s', Lua encountered something it could not make sense of.",
        format = function(m) return m[1] end,
        hints = {"Did you forget something here? (Perhaps a closing bracket)", "Is it a typo?"}
    },
    {
        match = "'(.*)' expected near '(.*)'",
        text = "Right before the '%s', Lua expected to read a '%s', but it didn't.",
        format = function(m) return m[2], m[1] end,
        hints = {"Did you forget a keyword?", "Did you forget a comma?"}
    },
    {
        match = "malformed number near '(.*)'",
        text = "Lua attempted to read '%s' as a number, but failed to do so.",
        format = function(m) return m[1] end,
        hints = {
            "Numbers starting with '0x' are hexidecimal.",
            "Lua can get confused when doing '<number>..\"some text\"'. Try inserting a space between the number and the '..'."
        }
    },
}

-- Similar structure for runtime errors. Catches only the most common errors.
-- Order is important: the structure with the first match is taken
local runErrs = {
    {
        match = "table index is nil",
        text = "A table is being indexed by something that does not exist (table index is nil).", -- Requires improvement
        format = function() end,
        hints = {
            "The thing between square brackets does not exist (is nil)."
        }
    },
    {
        match = "table index is NaN",
        text = "A table is being indexed by something that is not really a number (table index is NaN).",
        format = function() end,
        hints = {
            "Did you divide zero by zero thinking it would be funny?"
        }
    },
    {
        match = "attempt to index global '(.*)' [(]a nil value[)]",
        text = "'%s' is being indexed like it is a table, but in reality it does not exist (is nil).",
        format = function(m) return m[1] end,
        hints = {
            "You either have 'something.somethingElse', 'something[somethingElse]' or 'something:somethingElse(more)'. The 'something' here does not exist."
        }
    },
    {
        match = "attempt to index global '(.*)' [(]a (.*) value[)]",
        text = "'%s' is being indexed like it is a table, but in reality it is a %s value.",
        format = function(m) return m[1], m[2] end,
        hints = {
            "You either have 'something.somethingElse' or 'something:somethingElse(more)'. The 'something' here is not a table."
        }
    },
    {
        match = "attempt to index a nil value",
        text = "Something is being indexed like it is a table, but in reality does not exist (is nil).",
        format = function() end,
        hints = {
            "You either have 'something.somethingElse', 'something[somethingElse]' or 'something:somethingElse(more)'. The 'something' here does not exist."
        }
    },
    {
        match = "attempt to index a (.*) value",
        text = "Something is being indexed like it is a table, but in reality it is a %s value.",
        format = function(m) return m[1] end,
        hints = {
            "You either have 'something.somethingElse', 'something[somethingElse]' or 'something:somethingElse(more)'. The 'something' here is not a table."
        }
    },
    {
        match = "attempt to call global '(.*)' [(]a nil value[)]",
        text = "'%s' is being called like it is a function, but in reality does not exist (is nil).",
        format = function(m) return m[1] end,
        hints = {
            "You are doing something(<otherstuff>). The 'something' here does not exist."
        }
    },
    {
        match = "attempt to call a nil value",
        text = "Something is being called like it is a function, but in reality it does not exist (is nil).",
        format = function() end,
        hints = {
            "You are doing something(<otherstuff>). The 'something' here does not exist."
        }
    },
    {
        match = "attempt to call global '(.*)' [(]a (.*) value[)]",
        text = "'%s' is being called like it is a function, but in reality it is a %s.",
        format = function(m) return m[1], m[2] end,
        hints = {
            "You are doing something(<otherstuff>). The 'something' here is not a function."
        }
    },
    {
        match = "attempt to call a (.*) value",
        text = "Something is being called like it is a function, but in reality it is a %s.",
        format = function(m) return m[1] end,
        hints = {
            "You are doing something(<otherstuff>). The 'something' here is not a function."
        }
    },
    {
        match = "attempt to call field '(.*)' [(]a nil value[)]",
        text = "'%s' is being called like it is a function, but in reality it does not exist (is nil).",
        format = function(m) return m[1] end,
        hints = {
            "You are doing either stuff.something(<otherstuff>) or stuff:something(<otherstuff>). The 'something' here does not exist."
        }
    },
    {
        match = "attempt to call field '(.*)' [(]a (.*) value[)]",
        text = "'%s' is being called like it is a function, but in reality it is a %s.",
        format = function(m) return m[1], m[2] end,
        hints = {
            "You are doing either stuff.something(<otherstuff>) or stuff:something(<otherstuff>). The 'something' here is not a function."
        }
    },
    {
        match = "attempt to concatenate global '(.*)' [(]a nil value[)]",
        text = "'%s' is being concatenated to something else, but '%s' does not exist (is nil).",
        format = function(m) return m[1], m[1] end,
        hints = {
            "Concatenation looks like this: something .. otherThing. Either something or otherThing does not exist."
        }
    },
    {
        match = "attempt to concatenate global '(.*)' [(]a (.*) value[)]",
        text = "'%s' is being concatenated to something else, but %s values cannot be concatenated.",
        format = function(m) return m[1], m[2] end,
        hints = {
            "Concatenation looks like this: something .. otherThing. Either something or otherThing is neither string nor number."
        }
    },
    {
        match = "attempt to concatenate a nil value",
        text = "Two (or more) things are being concatenated and one of them does not exist (is nil).",
        format = function() end,
        hints = {
            "Concatenation looks like this: something .. otherThing. Either something or otherThing does not exist."
        }
    },
    {
        match = "attempt to concatenate a (.*) value",
        text = "Two (or more) things are being concatenated and one of them is neither string nor number, but a %s.",
        format = function(m) return m[1] end,
        hints = {
            "Concatenation looks like this: something .. otherThing. Either something or otherThing is neither string nor number."
        }
    },
    {
        match = "stack overflow",
        text = "The stack of function calls has overflowed",
        format = function() end,
        hints = {
            "Most likely infinite recursion.",
            "Do you have a function calling itself?"
        }
    },
    {
        match = "attempt to compare two (.*) values",
        text = "A comparison is being made between two %s values. They cannot be compared.",
        format = function(m) return m[1] end,
        hints = {
            "This error usually occurs when two incompatible things are being compared.",
            "'comparison' in this context means one of <, >, <=, >= (smaller than, greater than, etc.)"
        }
    },
    {
        match = "attempt to compare (.*) with (.*)",
        text = "A comparison is being made between a %s and a %s. This is not possible.",
        format = function(m) return m[1], m[2] end,
        hints = {
            "This error usually occurs when two incompatible things are being compared.",
            "'Comparison' in this context means one of <, >, <=, >= (smaller than, greater than, etc.)"
        }
    },
    {
        match = "attempt to perform arithmetic on a (.*) value",
        text = "Arithmetic operations are being performed on a %s. This is not possible.",
        format = function(m) return m[1] end,
        hints = {
            "'Arithmetic' in this context means adding, multiplying, dividing, etc."
        }
    },
    {
        match = "attempt to get length of global '(.*)' [(]a nil value[)]",
        text = "The length of '%s' is requested as if it is a table, but in reality it does not exist (is nil).",
        format = function(m) return m[1] end,
        hints = {
            "You are doing #something. The 'something' here is does not exist."
        }
    },
    {
        match = "attempt to get length of global '(.*)' [(]a (.*) value[)]",
        text = "The length of '%s' is requested as if it is a table, but in reality it is a %s.",
        format = function(m) return m[1], m[2] end,
        hints = {
            "You are doing #something. The 'something' here is not a table."
        }
    },
    {
        match = "attempt to get length of a nil value",
        text = "The length of something is requested as if it is a table, but in reality it does not exist (is nil).",
        format = function(m) return m[1] end,
        hints = {
            "You are doing #something. The 'something' here is does not exist."
        }
    },
    {
        match = "attempt to get length of a (.*) value",
        text = "The length of something is requested as if it is a table, but in reality it is a %s.",
        format = function(m) return m[1] end,
        hints = {
            "You are doing #something. The 'something' here is not a table."
        }
    },
}

module("simplerr")

-- Get a nicely formatted stack trace. Start is where to start numbering
-- stackMod allows the caller to modify the stack before it is numbered
local function getStack(i, start, stackMod)
    i = i or 1
    start = start or 1
    local stack = {}

    -- Invariant: stack level (i + count) >= 2 and <= last stack item
    for count = 1, math.huge do -- user visible count
        local info = debug.getinfo(i + count, "Sln")
        if not info then break end

        local line = info.currentline or "unknown"
        if line == -1 and info.name then
            table.insert(stack, string.format("function '%s'", info.name))
        else
            table.insert(stack, string.format("%s on line %s", info.short_src, line))
        end
    end

    -- Allow modification of the stack
    if stackMod then stack = stackMod(stack) end

    -- add the numbering
    for count = 1, #stack do
        local stackLevel = start + count - 1
        stack[count] = string.format("\t%i. %s", stackLevel, stack[count])
    end

    return table.concat(stack, "\n")
end

-- Translate a runtime error to simplerr format.
-- Decorate with e.g. wrapError to have it actually throw the error.
function runError(msg, stackNr, hints, path, line, stack)
    stackNr = stackNr or 1
    hints = hints or {"No hints, sorry."}
    hints = "\t- " .. table.concat(hints, "\n\t- ")

    if not path and not line then
        local info = debug.getinfo(stackNr + 1, "Sln") or debug.getinfo(stackNr, "Sln")
        path = info.short_src
        line = info.currentline
    end

    return false, string.format(runErrTranslation, path, line, msg, hints, stack or getStack(stackNr + 1))
end

-- Translate the message of an error
local function translateMsg(msg, path, line, errs)
    local res
    local hints = {"No hints, sorry."}

    for i = 1, #errs do
        local trans = errs[i]
        if not string.find(msg, trans.match) then continue end

        -- translate <eof>
        msg = string.Replace(msg, "<eof>", "end of the file")

        res = string.format(trans.text, trans.format({string.match(msg, trans.match)}, line, path))
        hints = trans.hints

        break
    end

    return res or msg, "\t- " .. table.concat(hints, "\n\t- ")
end

-- Translate an error into a language understandable by non-programmers
local function translateError(path, line, err, translation, errs, stack)
    -- Using .* instead of path because path may be wrong when error is called
    local msg, hints = translateMsg(string.match(err, ".*:[0-9-]+: (.*)"), path, line, errs)
    local res = string.format(translation, path, line, msg, hints, stack)
    return res
end


-- Trims the [C] functions at the beginning of the stack
local function trimStart(stack)
    while true do
        if string.StartWith(stack[1], "function ") then
            table.remove(stack, 1)
        else
            break
        end
    end

    return stack
end

-- safeCall uses xpcall, which has the downside that both xpcall and
-- the safeCall function itself end up in the stack trace.
-- This function removes them from the stack trace
local function removeXpcall(stack)
    for i = #stack - 1, 1, -1 do
        if stack[i] == "function 'xpcall'" and string.find(stack[i + 1], "simplerr") then
            table.remove(stack, i)
            table.remove(stack, i) -- also remove the simplerr safeCall call

            return stack
        end
    end

    return stack
end

-- Combines the two above functions
local function stackModAggregate(stack)
    stack = trimStart(stack)
    return removeXpcall(stack)
end

-- Used as the error handler in safeCall
local function errorHandler(err, func)
    -- Investigate the stack. Not using err matching because calls to error can give a different path and line
    local stack = getStack(func and 1 or 2, 1, stackModAggregate) -- add called func to stack

    -- Fetch the path and line number from the top of the stack
    local firstLine = string.sub(stack, 1, string.match(stack, "()\n") - 1)
    local path, line = string.match(firstLine, "\t[0-9-]+%. (.*) on line ([0-9-]+)")
    line = tonumber(line)

    return {err, path, line, stack}
end

-- Call a function and catch immediate runtime errors
function safeCall(f, ...)
    -- Use xpcall so fetching of debug info is in the stack of the error rather than after it is unwound
    local res = {xpcall(f, errorHandler, ...)}

    local succ, errInfo = res[1], res[2]

    if succ then return unpack(res) end

    -- This will only happen if the error is "not enough memory" or "error in error handling".
    -- The former tends to crash the game and the latter will mean it'll probably error in the next line.
    -- But we will try anyway.
    -- Note: stack trace will be less accurate.
    if isstring(errInfo) then errInfo = errorHandler(errInfo, f) end

    -- Skip translation if the error is already a simplerr error
    -- This prevents nested simplerr errors when runError is called by a file loaded by runFile
    local mustTranslate = not string.find(errInfo[1], "------- End of Simplerr error -------")
    return false, mustTranslate and translateError(errInfo[2], errInfo[3], errInfo[1], runErrTranslation, runErrs, errInfo[4]) or errInfo[1]
end

-- Run a file or explain its syntax errors in layman's terms
-- Returns bool succeed, [string error]
-- Do NOT use this on clientside files.
-- Clientside files sent by the server cannot be read using file.Read unless you're the host of a listen server
function runFile(path)
    if not file.Exists(path, "LUA") then error(string.format("Could not run file '%s' (file not found)", path)) end
    local contents = file.Read(path, "LUA")

    -- Files can make a comment containing #NoSimplerr# to disable simplerr (and thus enable autorefresh)
    if string.find(contents, "#NoSimplerr#") then include(path) return true end

    -- Catch syntax errors with CompileString
    local err = CompileString(contents, path, false)

    -- CompileString returns the following string whenever a file is empty: Invalid script - or too short.
    -- It also prints: Not running script <path> - it's too short.
    -- If so, do nothing.
    if err == "Invalid script - or too short." then return true end

    -- No syntax errors, check for immediate runtime errors using CompileFile
    -- Using the function CompileString returned leads to relative path trouble
    if isfunction(err) then return safeCall(CompileFile(path), path) end

    -- Fetch the line number from the error
    local line = string.match(err, ".*:([0-9-]+): .*")
    line = tonumber(line)

    return false, translateError(path, line, err, synErrTranslation, synErrs)
end

-- Error wrapper: decorator for runFile and safeCall that throws an error on failure.
-- Breaks execution. Must be the last decorator.
function wrapError(succ, err, ...)
    if succ then return succ, err, ... end

    error(err)
end

-- Hook wrapper: Calls a hook on error
function wrapHook(succ, err, ...)
    if not succ then hook.Call("onSimplerrError", nil, err) end

    return succ, err, ...
end

-- Logging wrapper: decorator for runFile and safeCall that logs failures.
local log = {}
function wrapLog(succ, err, ...)
    if succ then return succ, err, ... end

    local data = {
        err = err,
        time = os.time()
    }

    table.insert(log, data)

    return succ, err, ...
end

-- Retrieve the log
function getLog() return log end

-- Clear the log
function clearLog() log = {} end
