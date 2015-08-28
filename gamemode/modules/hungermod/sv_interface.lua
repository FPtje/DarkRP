DarkRP.PLAYER.newHungerData = DarkRP.stub{
	name = "newHungerData",
	description = "Create the initial hunger data (called on PlayerInitialSpawn).",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.hungerUpdate = DarkRP.stub{
	name = "hungerUpdate",
	description = "Makes the player slightly more hungry. Called in a timer by default.",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.hookStub{
	name = "playerBoughtFood",
	description = "When a player boughts food.",
	parameters = {
		{
			name = "ply",
			description = "The player who bought food.",
			type = "Player"
		},
		{
			name = "food",
			description = "Food table.",
			type = "table"
		},
		{
			name = "spawnedfood",
			description = "Entity of spawned food.",
			type = "entity"
		},
		{
			name = "cost",
			description = "How mush player paid.",
			type = "entity"
		}
	},
	returns = {
	}
}
