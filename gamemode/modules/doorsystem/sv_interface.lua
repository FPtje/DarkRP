
fprp.ENTITY.keysLock = fprp.stub{
	name = "keysLock",
	description = "Lock this door or vehicle.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.keysUnLock = fprp.stub{
	name = "keysUnLock",
	description = "Unlock this door or vehicle.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.addKeysAllowedToOwn = fprp.stub{
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
	metatable = fprp.ENTITY
}

fprp.ENTITY.addKeysDoorOwner = fprp.stub{
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
	metatable = fprp.ENTITY
}

fprp.ENTITY.removeKeysDoorOwner = fprp.stub{
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
	metatable = fprp.ENTITY
}

fprp.ENTITY.keysOwn = fprp.stub{
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
	metatable = fprp.ENTITY
}

fprp.ENTITY.keysUnOwn = fprp.stub{
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
	metatable = fprp.ENTITY
}

fprp.ENTITY.setKeysNonOwnable = fprp.stub{
	name = "setKeysNonOwnable",
	description = "Set whether this door or vehicle is ownable or not.",
	parameters = {
		{
			name = "ownable",
			description = "Whether the door or vehicle is blocked from ownership.",
			type = "boolean",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.setKeysTitle = fprp.stub{
	name = "setKeysTitle",
	description = "Set the title of a door or vehicle.",
	parameters = {
		{
			name = "title",
			description = "The title of the door.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.setDoorGroup = fprp.stub{
	name = "setDoorGroup",
	description = "Set the door group of a door.",
	parameters = {
		{
			name = "group",
			description = "The door group.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.addKeysDoorTeam = fprp.stub{
	name = "addKeysDoorTeam",
	description = "Allow a team to lock/unlock a door..",
	parameters = {
		{
			name = "team",
			description = "The team to add to team owners.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.removeKeysDoorTeam = fprp.stub{
	name = "removeKeysDoorTeam",
	description = "Disallow a team from locking/unlocking a door.",
	parameters = {
		{
			name = "team",
			description = "The team to remove from team owners.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.removeAllKeysDoorTeams = fprp.stub{
	name = "removeAllKeysDoorTeams",
	description = "Disallow all teams from locking/unlocking a door.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.removeAllKeysExtraOwners = fprp.stub{
	name = "removeAllKeysExtraOwners",
	description = "Remove all co-owners from a door.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.removeAllKeysAllowedToOwn = fprp.stub{
	name = "removeAllKeysAllowedToOwn",
	description = "Disallow all people from owning the door.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.removeKeysAllowedToOwn = fprp.stub{
	name = "removeKeysAllowedToOwn",
	description = "Remove a player from being allowed to co-own a door.",
	parameters = {
		{
			name = "ply",
			description = "The player to be removed.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.ENTITY.isLocked = fprp.stub{
	name = "isLocked",
	description = "Whether this door/vehicle is locked.",
	parameters = {
	},
	returns = {
		{
			name = "answer",
			description = "Whether it's locked.",
			type = "boolean"
		}
	},
	metatable = fprp.ENTITY
}

fprp.PLAYER.keysUnOwnAll = fprp.stub{
	name = "keysUnOwnAll",
	description = "Unown every door and vehicle owned by this player.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.sendDoorData = fprp.stub{
	name = "sendDoorData",
	description = "Internal function. Sends all door data to a player.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.doPropertyTax = fprp.stub{
	name = "doPropertyTax",
	description = "Tax a player based on the amount of doors and vehicles they have.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.initiateTax = fprp.stub{
	name = "initiateTax",
	description = "Internal function, starts the timer that taxes the player every once in a while.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
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
			name = "GiveshekelBack",
			description = "The amount of shekel refunded to the player",
			type = "number"
		}
	},
	returns = {

	}
}

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
	name = "playerSellDoor",
	description = "When a player is about to sell a door.",
	parameters = {
		{
			name = "ply",
			description = "The player who is to sell the door.",
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
			description = "Whether the player is allowed to sell the door.",
			type = "boolean"
		},
		{
			name = "reason",
			description = "The reason why a player is not allowed to sell the door, if applicable.",
			type = "string"
		}
	}
}

fprp.hookStub{
	name = "onAllowedToOwnAdded",
	description = "When a player adds a co-owner to a door.",
	parameters = {
		{
			name = "ply",
			description = "The player who adds the co-owner.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The door.",
			type = "Entity"
		},
		{
			name = "target",
			description = "The target who will be allowed to own the door.",
			type = "Player"
		}
	},
	returns = {
		{
			name = "allowed",
			description = "Whether the player is allowed to add this player as co-owner.",
			type = "boolean"
		}
	}
}

fprp.hookStub{
	name = "onAllowedToOwnRemoved",
	description = "When a player removes a co-owner to a door.",
	parameters = {
		{
			name = "ply",
			description = "The player who removes the co-owner.",
			type = "Player"
		},
		{
			name = "ent",
			description = "The door.",
			type = "Entity"
		},
		{
			name = "target",
			description = "The target who will not be allowed to own the door anymore.",
			type = "Player"
		}
	},
	returns = {
		{
			name = "allowed",
			description = "Whether the player is allowed to remove this player as co-owner.",
			type = "boolean"
		}
	}
}

fprp.hookStub{
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

fprp.hookStub{
	name = "playerSellVehicle",
	description = "When a player is about to sell a vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player who is to sell the vehicle.",
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
			description = "Whether the player is allowed to sell the vehicle.",
			type = "boolean"
		},
		{
			name = "reason",
			description = "The reason why a player is not allowed to sell the vehicle, if applicable.",
			type = "string"
		}
	}
}

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
	name = "onPaidTax",
	description = "Called when a player has paid tax.",
	parameters = {
		{
			name = "ply",
			description = "The player who was taxed.",
			type = "Player"
		},
		{
			name = "tax",
			description = "The percentage of tax taken from his wallet.",
			type = "number"
		},
		{
			name = "wallet",
			description = "The amount of shekel the player had before the tax was applied.",
			type = "number"
		}
	},
	returns = {

	}
}
