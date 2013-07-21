local chatCommands

function searchChatCommand(str)
	-- Fuzzy search regex string
	str = ".*" .. str:gsub("[a-zA-Z0-9]", function(a) return a:lower() .. ".*" end)
	local condition = fn.Compose{fn.Curry(fn.Flip(string.match), 2)(str), fn.Curry(fn.GetValue, 2)("command")}
	return fn.Compose{table.ClearKeys, fn.Curry(fn.Filter, 2)(condition)}(chatCommands)
end
