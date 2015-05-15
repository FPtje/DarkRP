local plyMeta = FindMetaTable("Player")
local chatCommands = chatCommands or {}

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
		DarkRP.error("Incorrect chat command! " .. element .. " is invalid!", 2)
	end

	tbl.command = string.lower(tbl.command)
	chatCommands[tbl.command] = chatCommands[tbl.command] or tbl
	for k, v in pairs(tbl) do
		chatCommands[tbl.command][k] = v
	end
end

function DarkRP.removeChatCommand(command)
	chatCommands[string.lower(command)] = nil
end

function DarkRP.chatCommandAlias(command, ...)
	local name
	for k, v in pairs{...} do
		name = string.lower(v)

		chatCommands[name] = table.Copy(chatCommands[command])
		chatCommands[name].command = name
	end
end

function DarkRP.getChatCommand(command)
	return chatCommands[string.lower(command)]
end

function DarkRP.getChatCommands()
	return chatCommands
end

function DarkRP.getSortedChatCommands()
	local tbl = fn.Compose{table.ClearKeys, table.Copy, chatCommands}()
	table.SortByMember(tbl, "command", true)

	return tbl
end

-- chat commands that have been defined, but not declared
DarkRP.getIncompleteChatCommands = fn.Curry(fn.Filter, 3)(fn.Compose{fn.Not, checkChatCommand})(chatCommands)

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
DarkRP.declareChatCommand{
	command = "pm",
	description = "Send a private message to someone.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "w",
	description = "Say something in whisper voice.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "y",
	description = "Yell something out loud.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "me",
	description = "Chat roleplay to say you're doing things that you can't show otherwise.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "/",
	description = "Global server chat.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "a",
	description = "Global server chat.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "ooc",
	description = "Global server chat.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "advert",
	description = "Advertise something to everyone in the server.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "broadcast",
	description = "Broadcast something as a mayor.",
	delay = 1.5,
	condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
	command = "channel",
	description = "Tune into a radio channel.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "radio",
	description = "Say something through the radio.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "g",
	description = "Group chat.",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "credits",
	description = "Send the DarkRP credits to someone.",
	delay = 1.5
}