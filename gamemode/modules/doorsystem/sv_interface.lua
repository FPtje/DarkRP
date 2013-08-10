
DarkRP.ENTITY.keysLock = DarkRP.stub{
	name = "keysLock",
	description = "Lock this door or vehicle.",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.keysUnLock = DarkRP.stub{
	name = "keysUnLock",
	description = "Unlock this door or vehicle.",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.addKeysAllowedToOwn = DarkRP.stub{
	name = "addKeysAllowedToOwn",
	description = "Make this player allowed to co-own the door or vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player to give permission to co-own.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.removeKeysAllowedToOwn = DarkRP.stub{
	name = "removeKeysAllowedToOwn",
	description = "Remove the player from the list of players who are allowed to co-own the door or vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player to remove.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.addKeysDoorOwner = DarkRP.stub{
	name = "addKeysDoorOwner",
	description = "Make this player a co-owner of the door.",
	parameters = {
		{
			name = "ply",
			description = "The player to add as co-owner.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.removeKeysDoorOwner = DarkRP.stub{
	name = "removeKeysDoorOwner",
	description = "Remove this player as co-owner",
	parameters = {
		{
			name = "ply",
			description = "The player to remove from the co-owners list.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.keysOwn = DarkRP.stub{
	name = "keysOwn",
	description = "Make the player the master owner of the door",
	parameters = {
		{
			name = "ply",
			description = "The player set as master owner.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.keysUnOwn = DarkRP.stub{
	name = "keysUnOwn",
	description = "Make this player unown the door/vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.ENTITY
}


DarkRP.PLAYER.keysUnOwnAll = DarkRP.stub{
	name = "keysUnOwnAll",
	description = "Unown every door and vehicle owned by this player.",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.doPropertyTax = DarkRP.stub{
	name = "doPropertyTax",
	description = "Tax a player based on the amount of doors and vehicles they have.",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.initiateTax = DarkRP.stub{
	name = "initiateTax",
	description = "Internal function, starts the timer that taxes the player every once in a while.",
	parameters = {
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.hookStub{
	name = "onKeysLocked",
	description = "Called when a door or vehicle was locked.",
	parameters = {
		{
			name = "ent",
			description = "The entity that was locked.",
			type = "Entity"
		}
	},
	returns = {

	}
}

DarkRP.hookStub{
	name = "onKeysUnlocked",
	description = "Called when a door or vehicle was unlocked.",
	parameters = {
		{
			name = "ent",
			description = "The entity that was unlocked.",
			type = "Entity"
		}
	},
	returns = {

	}
}

DarkRP.hookStub{
	name = "playerKeysSold",
	description = "When a player sold a door or vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player who sold the door or vehicle.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The entity that was sold.",
			type = "Player"
		},
		{
			name = "GiveMoneyBack",
			description = "The amount of money refunded to the player",
			type = "number"
		}
	},
	returns = {

	}
}

DarkRP.hookStub{
	name = "hideSellDoorMessage",
	description = "Whether to hide the door/vehicle sold notification",
	parameters = {
		{
			name = "ply",
			description = "The player who sold the door or vehicle.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The entity that was sold.",
			type = "Player"
		},
	},
	returns = {
		{
			name = "hide",
			description = "Whether to hide the notification.",
			type = "boolean"
		}
	}
}

DarkRP.hookStub{
	name = "getDoorCost",
	description = "Get the cost of a door.",
	parameters = {
		{
			name = "ply",
			description = "The player who has the intention to purchase the door.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The door",
			type = "Entity"
		}
	},
	returns = {
		{
			name = "cost",
			description = "The price of the door.",
			type = "number"
		}
	}
}

DarkRP.hookStub{
	name = "getVehicleCost",
	description = "Get the cost of a vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player who has the intention to purchase the vehicle.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The vehicle",
			type = "Entity"
		}
	},
	returns = {
		{
			name = "cost",
			description = "The price of the vehicle.",
			type = "number"
		}
	}
}

DarkRP.hookStub{
	name = "playerBuyDoor",
	description = "When a player purchases a door.",
	parameters = {
		{
			name = "ply",
			description = "The player who is to buy the door.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The door.",
			type = "Entity"
		}
	},
	returns = {
		{
			name = "allowed",
			description = "Whether the player is allowed to buy the door.",
			type = "boolean"
		},
		{
			name = "reason",
			description = "The reason why a player is not allowed to buy the door, if applicable.",
			type = "string"
		},
		{
			name = "surpress",
			description = "Whether to show the reason in a notification to the player, return true here to surpress the message.",
			type = "boolean"
		}
	}
}

DarkRP.hookStub{
	name = "playerBuyVehicle",
	description = "When a player purchases a vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player who is to buy the vehicle.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The vehicle.",
			type = "Entity"
		}
	},
	returns = {
		{
			name = "allowed",
			description = "Whether the player is allowed to buy the vehicle.",
			type = "boolean"
		},
		{
			name = "reason",
			description = "The reason why a player is not allowed to buy the vehicle, if applicable.",
			type = "string"
		},
		{
			name = "surpress",
			description = "Whether to show the reason in a notification to the player, return true here to surpress the message.",
			type = "boolean"
		}
	}
}

DarkRP.hookStub{
	name = "playerBoughtDoor",
	description = "Called when a player has purchased a door.",
	parameters = {
		{
			name = "ply",
			description = "The player who has purchased the door.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The purchased door.",
			type = "Entity"
		},
		{
			name = "cost",
			description = "The cost of the purchased door.",
			type = "number"
		}
	},
	returns = {

	}
}

DarkRP.hookStub{
	name = "playerBoughtVehicle",
	description = "Called when a player has purchased a vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player who has purchased the vehicle.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The purchased vehicle.",
			type = "Entity"
		},
		{
			name = "cost",
			description = "The cost of the purchased vehicle.",
			type = "number"
		}
	},
	returns = {

	}
}
