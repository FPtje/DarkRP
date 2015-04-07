local plyMeta = FindMetaTable("Player");
fprp.chatCommands = fprp.chatCommands or {}

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

function fprp.declareChatCommand(tbl)
	local valid, element = checkChatCommand(tbl);
	if not valid then
		fprp.error("Incorrect chat command! " .. element .. " is invalid!", 2);
	end

	tbl.command = string.lower(tbl.command);
	fprp.chatCommands[tbl.command] = fprp.chatCommands[tbl.command] or tbl
	for k, v in pairs(tbl) do
		fprp.chatCommands[tbl.command][k] = v
	end
end

function fprp.removeChatCommand(command)
	fprp.chatCommands[string.lower(command)] = nil
end

function fprp.chatCommandAlias(command, ...)
	local name
	for k, v in pairs{...} do
		name = string.lower(v);

		fprp.chatCommands[name] = table.Copy(fprp.chatCommands[command]);
		fprp.chatCommands[name].command = name
	end
end

function fprp.getChatCommand(command)
	return fprp.chatCommands[string.lower(command)]
end

function fprp.getChatCommands()
	return fprp.chatCommands
end

function fprp.getSortedChatCommands()
	local tbl = fn.Compose{table.ClearKeys, table.Copy, fprp.getChatCommands}();
	table.SortByMember(tbl, "command", true);

	return tbl
end

-- chat commands that have been defined, but not declared
fprp.getIncompleteChatCommands = fn.Curry(fn.Filter, 3)(fn.Compose{fn.Not, checkChatCommand})(fprp.chatCommands);

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
fprp.declareChatCommand{
	command = "pm",
	description = "Send a private message to someone.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "w",
	description = "Say something in whisper voice.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "y",
	description = "Yell something out loud.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "me",
	description = "Chat roleplay to say you're doing things that you can't show otherwise.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "/",
	description = "Global server chat.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "a",
	description = "Global server chat.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "ooc",
	description = "Global server chat.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "advert",
	description = "Advertise something to everyone in the server.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "broadcast",
	description = "Broadcast something as a mayor.",
	delay = 1.5,
	condition = plyMeta.isMayor
}

fprp.declareChatCommand{
	command = "channel",
	description = "Tune into a radio channel.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "radio",
	description = "Say something through the radio.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "g",
	description = "Group chat.",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "credits",
	description = "Send the fprp credits to someone.",
	delay = 1.5
}
