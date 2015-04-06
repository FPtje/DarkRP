fprp.declareChatCommand = fprp.stub{
	name = "declareChatCommand",
	description = "Declare a chat command (describe it)",
	parameters = {
		{
			name = "table",
			description = "The description of the chat command. Has to contain a string: command, string: description, number: delay, optional function: condition",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.removeChatCommand = fprp.stub{
	name = "removeChatCommand",
	description = "Remove a chat command",
	parameters = {
		{
			name = "command",
			description = "The chat command to remove",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.chatCommandAlias = fprp.stub{
	name = "chatCommandAlias",
	description = "Create an alias for a chat command",
	parameters = {
		{
			name = "command",
			description = "An already existing chat command.",
			type = "string",
			optional = false
		},
		{
			name = "alias",
			description = "One or more aliases for the chat command.",
			type = "vararg",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.getChatCommand = fprp.stub{
	name = "getChatCommand",
	description = "Get the information on a chat command.",
	parameters = {
		{
			name = "command",
			description = "The chat command",
			type = "string",
			optional = false
		}
	},
	returns = {
		{
			name = "chatTable",
			description = "A table containing the information of the chat command.",
			type = "table"
		}
	},
	metatable = fprp
}

fprp.getChatCommands = fprp.stub{
	name = "getChatCommands",
	description = "Get every chat command.",
	parameters = {

	},
	returns = {
		{
			name = "commands",
			description = "A table containing every command. Table indices are the command strings.",
			type = "table"
		}
	},
	metatable = fprp
}

fprp.getSortedChatCommands = fprp.stub{
	name = "getSortedChatCommands",
	description = "Get every chat command, sorted by their name.",
	parameters = {

	},
	returns = {
		{
			name = "commands",
			description = "A table containing every command.",
			type = "table"
		}
	},
	metatable = fprp
}

fprp.getIncompleteChatCommands = fprp.stub{
	name = "getIncompleteChatCommands",
	description = "chat commands that have been defined, but not declared. Information about these chat commands is missing.",
	parameters = {
	},
	returns = {
		{
			name = "commands",
			description = "A table containing the undeclared chat commands.",
			type = "table"
		}
	},
	metatable = fprp
}
