fprp.PLAYER.canAfford = fprp.stub{
	name = "canAfford",
	description = "Whether the player can afford the given amount of shekel",
	parameters = {
		{
			name = "amount",
			description = "The amount of shekel",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "answer",
			description = "Whether the player can afford it",
			type = "boolean"
		}
	},
	metatable = fprp.PLAYER
}

fprp.ENTITY.isshekelBag = fprp.stub{
	name = "isshekelBag",
	description = "Whether this entity is a shekel bag",
	parameters = {

	},
	returns = {
		{
			name = "answer",
			description = "Whether this entity is a shekel bag.",
			type = "boolean"
		}
	},
	metatable = fprp.ENTITY
}
