fprp.PLAYER.addshekel = fprp.stub{
	name = "addshekel",
	description = "Give shekel to a player.",
	parameters = {
		{
			name = "amount",
			description = "The amount of shekel to give to the player. A negative amount means you're substracting shekel.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.payDay = fprp.stub{
	name = "payDay",
	description = "Give a player their salary.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}


fprp.payPlayer = fprp.stub{
	name = "payPlayer",
	description = "Make one player give shekel to the other player.",
	parameters = {
		{
			name = "sender",
			description = "The player who gives the shekel.",
			type = "Player",
			optional = false
		},
		{
			name = "receiver",
			description = "The player who receives the shekel.",
			type = "Player",
			optional = false
		},
		{
			name = "amount",
			description = "The amount of shekel.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.createshekelBag = fprp.stub{
	name = "createshekelBag",
	description = "Create a shekel bag.",
	parameters = {
		{
			name = "pos",
			description = "The The position where the shekel bag is to be spawned.",
			type = "Vector",
			optional = false
		},
		{
			name = "amount",
			description = "The amount of shekel.",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "shekelbag",
			description = "The shekel bag entity.",
			type = "Entity"
		}
	},
	metatable = fprp
}
