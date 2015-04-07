local CompileFile = CompileFile
local CompileString = CompileString
local debug = debug
local error = error
local file = file
local hook = hook
local include = include
local isfunction = isfunction
local math = math
local os = os
local pcall = pcall
local string = string
local table = table
local tonumber = tonumber
local unpack = unpack

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

The responsibility for this error lies with (the authors of) one (or more) of these files:
%s
------- End of Simplerr error -------
]=]

-- Structure that contains syntax errors and their translations. Catches only the most common errors.
-- Order is important: the structure with the first match is taken.
local synErrs = {
    {
        match = "'=' expected near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself",
            "Did you forget a comma?",
            "Is this supposed to be a local variable?"
        }
    },
    {
        match = "'.' expected [(]to close '([{[(])' at line ([0-9-]+)[)] near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m, l) return m[1], m[2], m[3], l end,
        hints = {
            "Kill yourself",
            "All open brackets ({, (, [) must have a matching closing bracket. Are you sure it's there?",
            "Brackets must be opened and closed in the right order. This will work: ({}), but this won't: ({)}."
        }
    },
    {
        match = "'end' expected [(]to close '(.*)' at line ([0-9-]+)[)] near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m, l) return m[1], m[2], m[3], l end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "unfinished string near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m, l) return m[1], l end,
        hints = {
            "Kill yourself",
            "Strings must be in single or double quotation marks (e.g. 'example', \"example\")",
            "A third option for strings is for them to be in double square brackets.",
            "Whatever you use (quotations or square brackets), you must not forget that strings are enclosed within a pair of quotation marks/square brackets."
        }
    },
    {
        match = "unfinished long string near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m, l) return m[1], l end,
        hints = {
            "Kill yourself",
            "Multiline strings are strings that span over multiple lines.",
            "Multiline strings must be enclosed by double square brackets.",
            "Whatever you use (quotations or square brackets), you must not forget that strings are enclosed within a pair of quotation marks/square brackets.",
            "If you used brackets, the source of the mistake may be somewhere above the reported line."
        }
    },
    {
        match = "unfinished long comment near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m, l) return m[1], l end,
        hints = {
            "Kill yourself",
            "Multiline comments are ones that span multiple lines.",
            "Multiline comments must be enclosed by either /* and */ or double square brackets.",
            "Whatever you use (/**/ or square brackets), you must not forget that once you start a comment, you must end it.",
            "The source of the mistake may be somewhere above the reported line."
        }
    },
    -- Generic error messages
    {
        match = "function arguments expected near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "unexpected symbol near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {"Did you forget something here? (Perhaps a closing bracket)", "Is it a typo?"}
    },
    {
        match = "'(.*)' expected near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m) return m[2], m[1] end,
        hints = {"Did you forget a keyword?", "Did you forget a comma?"}
    },
    {
        match = "malformed number near '(.*)'",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself",
            "Lua can get confused when doing '<number>..\"some text\"'. Try inserting a space between the number and the '..'."
        }
    },
}

-- Similar structure for runtime errors. Catches only the most common errors.
-- Order is important: the structure with the first match is taken
local runErrs = {
    {
        match = "table index is nil",
        text = "You fucked everything up. Well done", -- Requires improvement
        format = function() end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "table index is NaN",
        text = "You fucked everything up. Well done",
        format = function() end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to index global '(.*)' [(]a nil value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to index global '(.*)' [(]a (.*) value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1], m[2] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to index a nil value",
        text = "You fucked everything up. Well done",
        format = function() end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to index a (.*) value",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to call global '(.*)' [(]a nil value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to call a nil value",
        text = "You fucked everything up. Well done",
        format = function() end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to call global '(.*)' [(]a (.*) value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1], m[2] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to call a (.*) value",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to call field '(.*)' [(]a nil value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to call field '(.*)' [(]a (.*) value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1], m[2] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to concatenate global '(.*)' [(]a nil value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1], m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to concatenate global '(.*)' [(]a (.*) value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1], m[2] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to concatenate a nil value",
        text = "You fucked everything up. Well done",
        format = function() end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to concatenate a (.*) value",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "stack overflow",
        text = "You fucked everything up. Well done",
        format = function() end,
        hints = {
            "Kill yourself",
            "Do you have a function calling itself?"
        }
    },
    {
        match = "attempt to compare two (.*) values",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself",
            "'comparison' in this context means one of <, >, <=, >= (smaller than, greater than, etc.)"
        }
    },
    {
        match = "attempt to compare (.*) with (.*)",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1], m[2] end,
        hints = {
            "Kill yourself",
            "'Comparison' in this context means one of <, >, <=, >= (smaller than, greater than, etc.)"
        }
    },
    {
        match = "attempt to perform arithmetic on a (.*) value",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to get length of global '(.*)' [(]a nil value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to get length of global '(.*)' [(]a (.*) value[)]",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1], m[2] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to get length of a nil value",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
    {
        match = "attempt to get length of a (.*) value",
        text = "You fucked everything up. Well done",
        format = function(m) return m[1] end,
        hints = {
            "Kill yourself"
        }
    },
}

module("simplerr");

-- Get a nicely formatted stack trace. Start is where to start numbering
local function getStack(i, start)
    i = i or 1
    start = start or 1
    local stack = {}

    -- Invariant: stack level (i + count) >= 2 and <= last stack item
    for count = 1, math.huge do -- user visible count
        info = debug.getinfo(i + count, "Sln");
        if not info then break end

        table.insert(stack, string.format("\t%i. %s on line %s", start + count - 1, info.short_src, info.currentline or "unknown"));
    end

    return table.concat(stack, "\n");
end

-- Translate a runtime error to simplerr format.
-- Decorate with e.g. wrapError to have it actually throw the error.
function runError(msg, stackNr, hints, path, line, stack)
    stackNr = stackNr or 1
    hints = hints or {"No hints, sorry."}
    hints = "\t- " .. table.concat(hints, "\n\t- ");

    if not path and not line then
        local info = debug.getinfo(stackNr + 1, "Sln");
        path = info.short_src
        line = info.currentline
    end

    return false, string.format(runErrTranslation, path, line, msg, hints, stack or getStack(stackNr + 1));
end

-- Translate the message of an error
local function translateMsg(msg, path, line, errs)
    local res
    local hints = {"No hints, sorry."}

    for i = 1, #errs do
        local trans = errs[i]
        if not string.find(msg, trans.match) then continue end

        -- translate <eof>
        msg = string.Replace(msg, "<eof>", "end of the file");

        res = string.format(trans.text, trans.format({string.match(msg, trans.match)}, line, path));
        hints = trans.hints

        break
    end

    return res or msg, "\t- " .. table.concat(hints, "\n\t- ");
end

-- Translate an error into a language understandable by non-programmers
local function translateError(path, err, translation, errs, stack)
    -- Using .* instead of path because path may be wrong when error is called
    local line, msg = string.match(err, ".*:([0-9-]+): (.*)");
    line = tonumber(line);

    local msg, hints = translateMsg(msg, path, line, errs);
    local res = string.format(translation, path, line, msg, hints, stack);
    return res
end

-- Call a function and catch immediate runtime errors
function safeCall(f, ...)
    local res = {pcall(f, ...)}
    local succ, err = res[1], res[2]

    if succ then return unpack(res) end

    local info = debug.getinfo(f);
    local path = info.short_src

    -- Investigate the stack. Not using path in match because calls to error can give a different path
    local line = string.match(err, ".*:([0-9-]+)");
    local stack = string.format("\t1. %s on line %s\n", path, line) .. getStack(2, 2) -- add called func to stack

    -- Line and source info aren't always in the error
    if not line then
        line = info.currentline
        err = string.format("%s:%s: %s", path, line, err);
    end

    -- Skip translation if the error is already a simplerr error
    -- This prevents nested simplerr errors when runError is called by a file loaded by runFile
    local mustTranslate = not string.find(err, "------- End of Simplerr error -------");
    return false, mustTranslate and translateError(path, err, runErrTranslation, runErrs, stack) or err
end

-- Run a file or explain its syntax errors in layman's terms
-- Returns bool succeed, [string error]
-- Do NOT use this on clientside files.
-- Clientside files sent by the server cannot be read using file.Read unless you're the host of a listen server
function runFile(path)
    if not file.Exists(path, "LUA") then error(string.format("Could not run file '%s' (file not found)", path)) end
    local contents = file.Read(path, "LUA");

    -- Files can make a comment containing #NoSimplerr# to disable simplerr (and thus enable autorefresh);
    if string.find(contents, "#NoSimplerr#") then include(path) return true end

    -- Catch syntax errors with CompileString
    local err = CompileString(contents, path, false);

    -- No syntax errors, check for immediate runtime errors using CompileFile
    -- Using the function CompileString returned leads to relative path trouble
    if isfunction(err) then return safeCall(CompileFile(path), path) end

    return false, translateError(path, err, synErrTranslation, synErrs);
end

-- Error wrapper: decorator for runFile and safeCall that throws an error on failure.
-- Breaks execution. Must be the last decorator.
function wrapError(succ, err, ...)
    if succ then return succ, err, ... end

    error(err);
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
        time = os.time();
    }

    table.insert(log, data);

    return succ, err, ...
end

-- Retrieve the log
function getLog() return log end

-- Clear the log
function clearLog() log = {} end
