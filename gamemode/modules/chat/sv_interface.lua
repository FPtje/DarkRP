fprp.defineChatCommand = fprp.stub{
	name = "defineChatCommand",
	description = "Create a chat command that calls the function",
	parameters = {
		{
			name = "chat command",
			description = "The registered chat command",
			type = "string",
			optional = false
		},
		{
			name = "callback",
			description = "The function that is called when the chat command is executed",
			type = "function",
			optional = false
		}
	},
	returns = {},
	metatable = fprp
}

fprp.hookStub{
	name = "PostPlayerSay",
	description = "Called after a player has said something.",
	parameters = {
		{
			name = "ply",
			description = "The player who spoke.",
			type = "Player"
		},
		{
			name = "text",
			description = "The thing they said.",
			type = "string"
		},
		{
			name = "teamonly",
			description = "Whether they said it to their team only.",
			type = "boolean"
		},
		{
			name = "dead",
			description = "Whether they are dead.",
			type = "boolean"
		}
	},
	returns = {

	}
}

fprp.hookStub{
	name = "canChatCommand",
	description = "Called when a player tries to run any chat command or uses the fprp console command. ",
	parameters = {
		{
			name = "ply",
			description = "The player who spoke.",
			type = "Player"
		},
		{
			name = "command",
			description = "The thing they said.",
			type = "string"
		},
		{
			name = "arguments",
			description = "The arguments of the chat command, given as one string.",
			type = "string"
		}
	},
	returns = {
		{
			name = "canChatCommand",
			description = "Whether the player is allowed to run the chat command.",
			type = "boolean"
		},
	}
}
