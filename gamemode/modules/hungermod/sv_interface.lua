DarkRP.PLAYER.NewHungerData = DarkRP.stub{
	name = "NewHungerData",
	description = "Create the initial hunger data (called on PlayerInitialSpawn).",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.HungerUpdate = DarkRP.stub{
	name = "HungerUpdate",
	description = "Makes the player slightly more hungry. Called in a timer by default.",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}
