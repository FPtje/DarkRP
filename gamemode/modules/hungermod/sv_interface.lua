fprp.PLAYER.newHungerData = fprp.stub{
	name = "newHungerData",
	description = "Create the initial hunger data (called on PlayerInitialSpawn).",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.hungerUpdate = fprp.stub{
	name = "hungerUpdate",
	description = "Makes the player slightly more hungry. Called in a timer by default.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}
