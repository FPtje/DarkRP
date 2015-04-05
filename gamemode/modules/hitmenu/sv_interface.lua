fprp.PLAYER.requestHit = fprp.stub{
	name = "requestHit",
	description = "Request a hit to a hitman.",
	parameters = {
		{
			name = "customer",
			description = "The customer who paid for the hit.",
			type = "Player",
			optional = false
		},
		{
			name = "target",
			description = "The target of the hit.",
			type = "Player",
			optional = false
		},
		{
			name = "price",
			description = "The price of the hit.",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "succeeded",
			description = "Whether the hit request could be made.",
			type = "boolean"
		}
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.placeHit = fprp.stub{
	name = "placeHit",
	description = "Place an actual hit.",
	parameters = {
		{
			name = "customer",
			description = "The customer who paid for the hit.",
			type = "Player",
			optional = false
		},
		{
			name = "target",
			description = "The target of the hit.",
			type = "Player",
			optional = false
		},
		{
			name = "price",
			description = "The price of the hit.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.setHitTarget = fprp.stub{
	name = "setHitTarget",
	description = "Set the target of a hit",
	parameters = {
		{
			name = "target",
			description = "The target of the hit.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.setHitPrice = fprp.stub{
	name = "setHitPrice",
	description = "Set the price of a hit",
	parameters = {
		{
			name = "price",
			description = "The price of the hit.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.setHitCustomer = fprp.stub{
	name = "setHitCustomer",
	description = "Set the customer who pays for the hit.",
	parameters = {
		{
			name = "customer",
			description = "The customer who paid for the hit.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.getHitCustomer = fprp.stub{
	name = "getHitCustomer",
	description = "Get the customer for the current hit",
	parameters = {
	},
	returns = {
		{
			name = "customer",
			description = "The customer for the current hit",
			type = "Player"
		}
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.abortHit = fprp.stub{
	name = "abortHit",
	description = "Abort a hit",
	parameters = {
		{
			name = "message",
			description = "The reason why the hit was aborted",
			type = "string",
			optional = true
		}
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.finishHit = fprp.stub{
	name = "finishHit",
	description = "End a hit without a message",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}
