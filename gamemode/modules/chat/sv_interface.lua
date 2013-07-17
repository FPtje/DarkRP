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
