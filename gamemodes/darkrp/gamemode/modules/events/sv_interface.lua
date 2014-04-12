DarkRP.storeZombies = DarkRP.stub{
	name = "storeZombies",
	description = "Store all the zombie positions.",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP
}

DarkRP.retrieveZombies = DarkRP.stub{
	name = "retrieveZombies",
	description = "Retrieve the zombie positions in a callback.",
	parameters = {
		{
			name = "callback",
			description = "The callback that receives the positions in its first parameter.",
			type = "function",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}

DarkRP.retrieveRandomZombieSpawnPos = DarkRP.stub{
	name = "retrieveRandomZombieSpawnPos",
	description = "Retrieve a random zombie spawn position.",
	parameters = {
	},
	returns = {
		{
			name = "pos",
			description = "A random zombie spawn position.",
			type = "Vector"
		}
	},
	metatable = DarkRP
}
