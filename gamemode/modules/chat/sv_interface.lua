DarkRP.defineChatCommand = DarkRP.stub{
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
	metatable = DarkRP
}

DarkRP.hookStub{
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
