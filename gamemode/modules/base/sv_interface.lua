DarkRP.PLAYER.setDarkRPVar = DarkRP.stub{
	name = "setDarkRPVar",
	description = "Set a shared variable.",
	parameters = {
		{
			name = "variable",
			description = "The name of the variable",
			type = "string",
			optional = false
		},
		{
			name = "value",
			description = "The value of the variable",
			type = "any",
			optional = false
		},
		{
			name = "target",
			description = "the clients to whom this variable is sent",
			type = "RecipientFilter",
			optional = true
		}
	},
	returns = {},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.setSelfDarkRPVar = DarkRP.stub{
	name = "setSelfDarkRPVar",
	description = "Set a shared variable that is only seen by the player to whom this variable applies.",
	parameters = {
		{
			name = "variable",
			description = "The name of the variable",
			type = "string",
			optional = false
		},
		{
			name = "value",
			description = "The value of the variable",
			type = "any",
			optional = false
		}
	},
	returns = {},
	metatable = DarkRP.PLAYER
}