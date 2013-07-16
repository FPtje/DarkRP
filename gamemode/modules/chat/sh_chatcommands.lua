local chatCommands = {}

local validChatCommand = {
	command = isstring,
	description = isstring,
	condition = fn.FOr{fn.Curry(fn.Eq, 2)(nil), isfunction},
	delay = isnumber
}

local checkChatCommand = function(tbl)
	for k,v in pairs(validChatCommand) do
		if not validChatCommand[k](tbl[k]) then
			return false, k
		end
	end
	return true
end

function DarkRP.declareChatCommand(tbl)
	local valid, element = checkChatCommand(tbl)
	if not valid then
		error("Incorrect chat command! " .. element .. " is invalid!", 2)
	end

	chatCommands[tbl.command] = chatCommands[tbl.command] or tbl
	for k, v in pairs(tbl) do
		chatCommands[tbl.command][k] = v
	end
end

function DarkRP.removeChatCommand(command)
	chatCommands[string.lower(command)] = nil
end

function DarkRP.getChatCommand(command)
	return chatCommands[string.lower(command)]
end

function DarkRP.getChatCommands()
	return chatCommands
end

-- chat commands that have been defined, but not declared
DarkRP.getIncompleteChatCommands = fn.Curry(fn.Filter, 3)(fn.Compose{fn.Not, checkChatCommand})(chatCommands)
