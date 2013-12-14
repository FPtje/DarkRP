DarkRP.hookStub{
	name = "playerAFKDemoted",
	description = "When a player is demoted for being AFK.",
	parameters = {
		{
			name = "ply",
			description = "The player being demoted.",
			type = "Player"
		}
	},
	returns = {
		{
			name = "shouldDemote",
			description = "Prevent the player from being actually demoted.",
			type = "boolean"
		},
		{
			name = "team",
			description = "The team the player is to be demoted to (shouldDemote must be true.)",
			type = "number"
		},
		{
			name = "suppressMessage",
			description = "Suppress the demote message.",
			type = "boolean"
		},
		{
			name = "demoteMessage",
			description = "Replacement of the demote message text.",
			type = "string"
		}
	}
}
