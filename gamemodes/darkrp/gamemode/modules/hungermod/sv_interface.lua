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
