DarkRP.PLAYER.canAfford = DarkRP.stub{
	name = "canAfford",
	description = "Whether the player can afford the given amount of money",
	parameters = {
		{
			name = "amount",
			description = "The amount of money",
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
	metatable = DarkRP.PLAYER
}
