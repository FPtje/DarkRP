fprp.initDatabase = fprp.stub{
	name = "initDatabase",
	description = "Initialize the fprp database.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp
}

fprp.storeRPName = fprp.stub{
	name = "storeRPName",
	description = "Store an RP name in the database.",
	parameters = {
		{
			name = "ply",
			description = "The player that gets the RP name.",
			type = "Player",
			optional = false
		},
		{
			name = "name",
			description = "The new name of the player.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.retrieveRPNames = fprp.stub{
	name = "retrieveRPNames",
	description = "Whether a given RP name is taken by someone else.",
	parameters = {
		{
			name = "name",
			description = "The RP name.",
			type = "string",
			optional = false
		},
		{
			name = "callback",
			description = "The function that receives the boolean answer in its first parameter.",
			type = "function",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.retrievePlayerData = fprp.stub{
	name = "retrievePlayerData",
	description = "Get a player's information from the database.",
	parameters = {
		{
			name = "ply",
			description = "The player to get the data for.",
			type = "Player",
			optional = false
		},
		{
			name = "callback",
			description = "The function that receives the information.",
			type = "function",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.createPlayerData = fprp.stub{
	name = "createPlayerData",
	description = "Internal function: creates an entry in the database for a player who has joined for the first time.",
	parameters = {
		{
			name = "ply",
			description = "The player to create the data for.",
			type = "Player",
			optional = false
		},
		{
			name = "name",
			description = "The name of the player.",
			type = "string",
			optional = false
		},
		{
			name = "wallet",
			description = "The amount of money the player has.",
			type = "number",
			optional = false
		},
		{
			name = "salary",
			description = "The salary of the player.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.storeMoney = fprp.stub{
	name = "storeMoney",
	description = "Internal function. Store a player's money in the database. Do not call this if you just want to set someone's money, the player will not see the change!",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player",
			optional = false
		},
		{
			name = "amount",
			description = "The new contents of the player's wallet.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.storeSalary = fprp.stub{
	name = "storeSalary",
	description = "Internal function. Store a player's salary in the database. Do not call this if you just want to set someone's salary, the player will not see the change!",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player",
			optional = false
		},
		{
			name = "amount",
			description = "The new contents of the player's wallet.",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "amount",
			description = "The new contents of the player's wallet.",
			type = "number"
		}
	},
	metatable = fprp
}

fprp.retrieveSalary = fprp.stub{
	name = "retrieveSalary",
	description = "Get a player's salary from the database.",
	parameters = {
		{
			name = "ply",
			description = "The player to get the data for.",
			type = "Player",
			optional = false
		},
		{
			name = "callback",
			description = "The function that receives the salary.",
			type = "function",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.restorePlayerData = fprp.stub{
	name = "restorePlayerData",
	description = "Internal function that restores a player's fprp information when they join.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp
}

fprp.storeDoorData = fprp.stub{
	name = "storeDoorData",
	description = "Store the information about a door in the database.",
	parameters = {
		{
			name = "ent",
			description = "The door.",
			type = "Entity",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.storeTeamDoorOwnability = fprp.stub{
	name = "storeTeamDoorOwnability",
	description = "Store the ownability information of a door in the database.",
	parameters = {
		{
			name = "ent",
			description = "The door.",
			type = "Entity",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.storeDoorGroup = fprp.stub{
	name = "storeDoorGroup",
	description = "Store the group of a door in the database.",
	parameters = {
		{
			name = "ent",
			description = "The door.",
			type = "Entity",
			optional = false
		},
		{
			name = "group",
			description = "The group of the door.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.notify = fprp.stub{
	name = "notify",
	description = "Make a notification pop up on the player's screen.",
	parameters = {
		{
			name = "ply",
			description = "The receiver of the message.",
			type = "Player",
			optional = false
		},
		{
			name = "MsgType",
			description = "The type of the message.",
			type = "number",
			optional = false
		},
		{
			name = "time",
			description = "For how long the notification should stay on the screen.",
			type = "number",
			optional = false
		},
		{
			name = "message",
			description = "The actual message.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.notifyAll = fprp.stub{
	name = "notifyAll",
	description = "Make a notification pop up on the everyone's screen.",
	parameters = {
		{
			name = "msgType",
			description = "The type of the message.",
			type = "number",
			optional = false
		},
		{
			name = "time",
			description = "For how long the notification should stay on the screen.",
			type = "number",
			optional = false
		},
		{
			name = "message",
			description = "The actual message.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.printMessageAll = fprp.stub{
	name = "printMessageAll",
	description = "Make a notification pop up in the middle of everyone's screen.",
	parameters = {
		{
			name = "msgType",
			description = "The type of the message.",
			type = "number",
			optional = false
		},
		{
			name = "message",
			description = "The actual message.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.talkToRange = fprp.stub{
	name = "talkToRange",
	description = "Send a chat message to people close to a player.",
	parameters = {
		{
			name = "ply",
			description = "The sender of the message.",
			type = "Player",
			optional = false
		},
		{
			name = "playerName",
			description = "The name of the sender of the message.",
			type = "string",
			optional = false
		},
		{
			name = "message",
			description = "The actual message.",
			type = "string",
			optional = false
		},
		{
			name = "size",
			description = "The radius of the circle in which players can see the message in chat.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.talkToPerson = fprp.stub{
	name = "talkToPerson",
	description = "Send a chat message to a player.",
	parameters = {
		{
			name = "receiver",
			description = "The receiver of the message.",
			type = "Player",
			optional = false
		},
		{
			name = "col1",
			description = "The color of the first part of the message.",
			type = "Color",
			optional = false
		},
		{
			name = "text1",
			description = "The first part of the message.",
			type = "string",
			optional = false
		},
		{
			name = "col2",
			description = "The color of the second part of the message.",
			type = "Color",
			optional = false
		},
		{
			name = "text2",
			description = "The secpnd part of the message.",
			type = "string",
			optional = false
		},
		{
			name = "sender",
			description = "The sender of the message.",
			type = "Player",
			optional = true
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.isEmpty = fprp.stub{
	name = "isEmpty",
	description = "Check whether the given position is empty.",
	parameters = {
		{
			name = "pos",
			description = "The position to check for emptiness.",
			type = "Vector",
			optional = false
		},
		{
			name = "ignore",
			description = "Table of things the algorithm can ignore.",
			type = "table",
			optional = true
		}
	},
	returns = {
		{
			name = "empty",
			description = "Whether the given position is empty.",
			type = "boolean"
		}
	},
	metatable = fprp
}
-- findEmptyPos(pos, ignore, distance, step, area) -- returns pos
fprp.findEmptyPos = fprp.stub{
	name = "findEmptyPos",
	description = "Find an empty position as close as possible to the given position (Note: this algorithm is slow!).",
	parameters = {
		{
			name = "pos",
			description = "The position to check for emptiness.",
			type = "Vector",
			optional = false
		},
		{
			name = "ignore",
			description = "Table of things the algorithm can ignore.",
			type = "table",
			optional = true
		},
		{
			name = "distance",
			description = "The maximum distance to look for empty positions.",
			type = "number",
			optional = false
		},
		{
			name = "step",
			description = "The size of the steps to check (it places it will look are STEP units removed from one another).",
			type = "number",
			optional = false
		},
		{
			name = "area",
			description = "The hull to check, this is Vector(16, 16, 64) for players.",
			type = "Vector",
			optional = false
		}
	},
	returns = {
		{
			name = "pos",
			description = "A found position. When no position was found, the parameter is returned",
			type = "Vector"
		}
	},
	metatable = fprp
}

fprp.PLAYER.removefprpVar = fprp.stub{
	name = "removefprpVar",
	description = "Remove a shared variable. Exactly the same as ply:setfprpVar(nil).",
	parameters = {
		{
			name = "variable",
			description = "The name of the variable.",
			type = "string",
			optional = false
		},
		{
			name = "target",
			description = "the clients to whom this variable is sent.",
			type = "CRecipientFilter",
			optional = true
		}
	},
	returns = {},
	metatable = fprp.PLAYER
}

fprp.PLAYER.setfprpVar = fprp.stub{
	name = "setfprpVar",
	description = "Set a shared variable. Make sure the variable is registered with fprp.registerfprpVar!",
	parameters = {
		{
			name = "variable",
			description = "The name of the variable.",
			type = "string",
			optional = false
		},
		{
			name = "value",
			description = "The value of the variable.",
			type = "any",
			optional = false
		},
		{
			name = "target",
			description = "the clients to whom this variable is sent.",
			type = "CRecipientFilter",
			optional = true
		}
	},
	returns = {},
	metatable = fprp.PLAYER
}

fprp.PLAYER.setSelffprpVar = fprp.stub{
	name = "setSelffprpVar",
	description = "Set a shared variable that is only seen by the player to whom this variable applies.",
	parameters = {
		{
			name = "variable",
			description = "The name of the variable.",
			type = "string",
			optional = false
		},
		{
			name = "value",
			description = "The value of the variable.",
			type = "any",
			optional = false
		}
	},
	returns = {},
	metatable = fprp.PLAYER
}

fprp.PLAYER.sendfprpVars = fprp.stub{
	name = "sendfprpVars",
	description = "Internal function. Sends all visiblefprpVars of all players to this player.",
	parameters = {
	},
	returns = {},
	metatable = fprp.PLAYER
}

fprp.PLAYER.setRPName = fprp.stub{
	name = "setRPName",
	description = "Set the RPName of a player.",
	parameters = {
		{
			name = "name",
			description = "The new name of the player.",
			type = "string",
			optional = false
		},
		{
			name = "firstrun",
			description = "Whether to play nice and find a different name if it has been taken (true) or to refuse the name change when taken (false).",
			type = "boolean",
			optional = true
		}
	},
	returns = {},
	metatable = fprp.PLAYER
}

fprp.PLAYER.addCustomEntity = fprp.stub{
	name = "addCustomEntity",
	description = "Add a custom entity to the player's limit.",
	parameters = {
		{
			name = "tblEnt",
			description = "The entity table (from the fprpEntities table).",
			type = "table",
			optional = false
		}
	},
	returns = {},
	metatable = fprp.PLAYER
}

fprp.PLAYER.removeCustomEntity = fprp.stub{
	name = "removeCustomEntity",
	description = "Remove a custom entity to the player's limit.",
	parameters = {
		{
			name = "tblEnt",
			description = "The entity table (from the fprpEntities table).",
			type = "table",
			optional = false
		}
	},
	returns = {},
	metatable = fprp.PLAYER
}

fprp.PLAYER.customEntityLimitReached = fprp.stub{
	name = "customEntityLimitReached",
	description = "Set a shared variable.",
	parameters = {
		{
			name = "tblEnt",
			description = "The entity table (from the fprpEntities table).",
			type = "table",
			optional = false
		}
	},
	returns = {
		{
			name = "limitReached",
			description = "Whether the limit has been reached.",
			type = "boolean"
		}
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.getPreferredModel = fprp.stub{
	name = "getPreferredModel",
	description = "Get the preferred model of a player for a job.",
	parameters = {
		{
			name = "TeamNr",
			description = "The job number.",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "model",
			description = "The preferred model for the job.",
			type = "string"
		}
	},
	metatable = fprp.PLAYER
}

fprp.hookStub{
	name = "UpdatePlayerSpeed",
	description = "Change a player's walking and running speed.",
	parameters = {
		{
			name = "ply",
			description = "The player for whom the speed changes.",
			type = "Player"
		}
	},
	returns = {
	}
}

fprp.hookStub{
	name = "fprpDBInitialized",
	description = "Called when fprp is done initializing the database.",
	parameters = {
	},
	returns = {
	}
}

fprp.hookStub{
	name = "CanChangeRPName",
	description = "Whether a player can change their RP name.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "name",
			description = "The name.",
			type = "string"
		}
	},
	returns = {
		{
			name = "answer",
			description = "Whether the player can change their RP names.",
			type = "boolean"
		},
		{
			name = "reason",
			description = "When answer is false, this return value is the reason why.",
			type = "string"
		}
	}
}

fprp.hookStub{
	name = "onPlayerChangedName",
	description = "Called when a player's fprp name has been changed.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "oldName",
			description = "The old name.",
			type = "string"
		},
		{
			name = "newName",
			description = "The new name.",
			type = "string"
		}
	},
	returns = {
	}
}

fprp.hookStub{
	name = "playerBoughtPistol",
	description = "Called when a player bought a pistol.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "weaponTable",
			description = "The table (from the CustomShipments table).",
			type = "table"
		},
		{
			name = "ent",
			description = "The spawned weapon.",
			type = "Weapon"
		},
		{
			name = "price",
			description = "The eventual price.",
			type = "number"
		}
	},
	returns = {
	}
}

fprp.hookStub{
	name = "playerBoughtShipment",
	description = "Called when a player bought a shipment.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "shipmentTable",
			description = "The table (from the CustomShipments table).",
			type = "table"
		},
		{
			name = "ent",
			description = "The spawned entity.",
			type = "Entity"
		},
		{
			name = "price",
			description = "The eventual price.",
			type = "number"
		}
	},
	returns = {
	}
}

fprp.hookStub{
	name = "playerBoughtCustomVehicle",
	description = "Called when a player bought a vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "vehicleTable",
			description = "The table (from the CustomVehicles table).",
			type = "table"
		},
		{
			name = "ent",
			description = "The spawned vehicle.",
			type = "Entity"
		},
		{
			name = "price",
			description = "The eventual price.",
			type = "number"
		}
	},
	returns = {
	}
}

fprp.hookStub{
	name = "playerBoughtCustomEntity",
	description = "Called when a player bought an entity (like a money printer or a gun lab).",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "entityTable",
			description = "The table of the custom entity (from the fprpEntities table).",
			type = "table"
		},
		{
			name = "ent",
			description = "The spawned vehicle.",
			type = "Entity"
		},
		{
			name = "price",
			description = "The eventual price.",
			type = "number"
		}
	},
	returns = {
	}
}

fprp.hookStub{
	name = "canDemote",
	description = "Whether a player can demote another player.",
	parameters = {
		{
			name = "ply",
			description = "The player who wants to demote.",
			type = "Player"
		},
		{
			name = "target",
			description = "The player whom is to be demoted.",
			type = "Player"
		},
		{
			name = "reason",
			description = "The reason provided for the demote.",
			type = "string"
		}
	},
	returns = {
		{
			name = "canDemote",
			description = "Whether the player can change demote the target.",
			type = "boolean"
		},
		{
			name = "message",
			description = "The message to show when the player cannot demote the other player. Only useful when canDemote is false.",
			type = "string"
		}
	}
}

fprp.hookStub{
	name = "onPlayerDemoted",
	description = "Called when a player is demoted.",
	parameters = {
		{
			name = "source",
			description = "The player who demoted the target.",
			type = "Player"
		},
		{
			name = "target",
			description = "The player who has been demoted.",
			type = "Player"
		},
		{
			name = "reason",
			description = "The reason provided for the demote.",
			type = "string"
		}
	},
	returns = {
	}
}

fprp.hookStub{
	name = "canDropWeapon",
	description = "Whether a player can drop a certain weapon.",
	parameters = {
		{
			name = "ply",
			description = "The player who wants to drop the weapon.",
			type = "Player"
		},
		{
			name = "weapon",
			description = "The weapon the player wants to drop.",
			type = "Weapon"
		}
	},
	returns = {
		{
			name = "canDrop",
			description = "Whether the player can drop the weapon.",
			type = "boolean"
		}
	}
}

fprp.hookStub{
	name = "canSeeLogMessage",
	description = "Whether a player can see a fprp log message in the console.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "message",
			description = "The log message.",
			type = "string"
		},
		{
			name = "color",
			description = "The color of the message.",
			type = "Color"
		}
	},
	returns = {
		{
			name = "canHear",
			description = "Whether the player can see the log message.",
			type = "boolean"
		}
	}
}

fprp.hookStub{
	name = "canVote",
	description = "Whether a player can cast a vote.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "vote",
			description = "Table containing all information about the vote.",
			type = "table"
		}
	},
	returns = {
		{
			name = "canVote",
			description = "Whether the player can vote.",
			type = "boolean"
		},
		{
			name = "message",
			description = "The message to show when the player cannot vote. Only useful when canVote is false.",
			type = "string"
		}
	}
}

fprp.hookStub{
	name = "playerGetSalary",
	description = "When a player receives salary.",
	parameters = {
		{
			name = "ply",
			description = "The player who is receiving salary.",
			type = "Player"
		},
		{
			name = "amount",
			description = "The amount of money given to the player.",
			type = "number"
		}
	},
	returns = {
		{
			name = "suppress",
			description = "Suppress the salary message.",
			type = "boolean"
		},
		{
			name = "message",
			description = "Override the default message (suppress must be false).",
			type = "string"
		},
		{
			name = "amount",
			description = "Override the salary.",
			type = "number"
		}
	}
}

fprp.hookStub{
	name = "playerWalletChanged",
	description = "When a player receives money.",
	parameters = {
		{
			name = "ply",
			description = "The player who is getting money.",
			type = "Player"
		},
		{
			name = "amount",
			description = "The amount of money given to the player.",
			type = "number"
		}
	},
	returns = {
		{
			name = "total",
			description = "Override the total amount of money (optional).",
			type = "number"
		}
	}
}
