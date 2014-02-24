DarkRP.findPlayer = DarkRP.stub{
	name = "findPlayer",
	description = "Find a player based on vague information.",
	parameters = {
		{
			name = "info",
			description = "The information of the player (UserID, SteamID, name).",
			type = "string",
			optional = false
		}
	},
	returns = {
		{
			name = "found",
			description = "The player that matches the description.",
			type = "Player"
		}
	},
	metatable = DarkRP
}

DarkRP.formatMoney = DarkRP.stub{
	name = "formatMoney",
	description = "Format a number as a money value. Includes currency symbol.",
	parameters = {
		{
			name = "amount",
			description = "The money to format, e.g. 100000.",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "money",
			description = "The money as a nice string, e.g. \"$100,000\".",
			type = "string"
		}
	},
	metatable = DarkRP
}


DarkRP.PLAYER.getJobTable = DarkRP.stub{
	name = "getJobTable",
	description = "Get the job table of a player.",
	parameters = {
	},
	returns = {
		{
			name = "job",
			description = "Table with the job information.",
			type = "table"
		}
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.getDarkRPVar = DarkRP.stub{
	name = "getDarkRPVar",
	description = "Get the value of a DarkRPVar, which is shared between server and client.",
	parameters = {
		{
			name = "var",
			description = "The name of the variable.",
			type = "string",
			optional = false
		}
	},
	returns = {
		{
			name = "value",
			description = "The value of the DarkRP var.",
			type = "any"
		}
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.getAgenda = DarkRP.stub{
	name = "getAgenda",
	description = "(Deprecated, use getAgendaTable) Get the agenda a player manages.",
	parameters = {
	},
	returns = {
		{
			name = "agenda",
			description = "The agenda.",
			type = "table"
		}
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.getAgendaTable = DarkRP.stub{
	name = "getAgendaTable",
	description = "Get the agenda a player can see. Note: when a player is not the manager of an agenda, it returns the agenda of the manager.",
	parameters = {
	},
	returns = {
		{
			name = "agenda",
			description = "The agenda.",
			type = "table"
		}
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.hasDarkRPPrivilege = DarkRP.stub{
	name = "hasDarkRPPrivilege",
	description = "Whether the player has a certain privilege.",
	parameters = {
		{
			name = "priv",
			description = "The name of the privilege.",
			type = "string",
			optional = false
		}
	},
	returns = {
		{
			name = "answer",
			description = "Whether the player has the privilege.",
			type = "boolean"
		}
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.getEyeSightHitEntity = DarkRP.stub{
	name = "getEyeSightHitEntity",
	description = "Get the entity that is closest to a player's line of sight and its distance.",
	parameters = {
		{
			name = "searchDistance",
			description = "How far to look. You usually don't want this function to return an entity millions of units away. The default is 100 units.",
			type = "number",
			optional = true
		},
		{
			name = "hitDistance",
			description = "The maximum distance between the player's line of sight and the object. The default is 15.",
			type = "number",
			optional = true
		},
		{
			name = "filter",
			description = "The filter for which entities to look for. By default it only looks for players.",
			type = "function",
			optional = true
		}
	},
	returns = {
		{
			name = "closestEnt",
			description = "The entity that is closest to the player's line of sight. Returns nil when not found.",
			type = "Entity"
		},
		{
			name = "distance",
			description = "The (minimum) distance between the player's line of sight and the object.",
			type = "number"
		}
	},
	metatable = DarkRP.PLAYER
}

DarkRP.VECTOR.isInSight = DarkRP.stub{
	name = "isInSight",
	description = "Decides whether the vector could be seen by the player if they were to look at it.",
	parameters = {
		{
			name = "filter",
			description = "Trace filter that decides what the player can see through.",
			type = "table",
			optional = false
		},
		{
			name = "ply",
			description = "The player for whom the vector may or may not be visible.",
			type = "Player",
			optional = false
		}
	},
	returns = {
		{
			name = "answer",
			description = "Whether the player can see the position.",
			type = "boolean"
		},
		{
			name = "HitPos",
			description = "The position of the thing that blocks the player's sight.",
			type = "Vector"
		}
	},
	metatable = DarkRP.VECTOR
}

/*---------------------------------------------------------------------------
Creating custom items
---------------------------------------------------------------------------*/
DarkRP.createJob = DarkRP.stub{
	name = "createJob",
	description = "Create a job for DarkRP.",
	parameters = {
		{
			name = "name",
			description = "The name of the job.",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the job.",
			type = "table",
			optional = false
		}
	},
	returns = {
		{
			name = "team",
			description = "The team number of the job you've created.",
			type = "number"
		}
	},
	metatable = DarkRP
}
AddExtraTeam = DarkRP.createJob

DarkRP.createEntityGroup = DarkRP.stub{
	name = "createEntityGroup",
	description = "Create a entity group for DarkRP.",
	parameters = {
		{
			name = "name",
			description = "The name of the entity group.",
			type = "string",
			optional = false
		},
		{
			name = "teamNrs",
			description = "Vararg team numbers.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddDoorGroup = DarkRP.createEntityGroup

DarkRP.createShipment = DarkRP.stub{
	name = "createShipment",
	description = "Create a shipment for DarkRP.",
	parameters = {
		{
			name = "name",
			description = "The name of the shipment.",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the shipment.",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddCustomShipment = DarkRP.createShipment

DarkRP.createVehicle = DarkRP.stub{
	name = "createVehicle",
	description = "Create a vehicle for DarkRP.",
	parameters = {
		{
			name = "name",
			description = "The name of the vehicle.",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the vehicle.",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddCustomVehicle = DarkRP.createVehicle

DarkRP.createEntity = DarkRP.stub{
	name = "createEntity",
	description = "Create a entity for DarkRP.",
	parameters = {
		{
			name = "name",
			description = "The name of the entity.",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the entity.",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddCustomVehicle = DarkRP.createEntity

DarkRP.createAgenda = DarkRP.stub{
	name = "createAgenda",
	description = "Create an agenda for groups of jobs to communicate.",
	parameters = {
		{
			name = "title",
			description = "The name of the agenda.",
			type = "string",
			optional = false
		},
		{
			name = "manager",
			description = "The team numer of the manager of the agenda (the one who can set the agenda).",
			type = "number",
			optional = false
		},
		{
			name = "listeners",
			description = "The jobs that can see this agenda.",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}
AddAgenda = DarkRP.createAgenda

DarkRP.createGroupChat = DarkRP.stub{
	name = "createGroupChat",
	description = "Create a group chat.",
	parameters = {
		{
			name = "functionOrJob",
			description = "A function that returns whether the person can see the group chat, or a team number.",
			type = "any",
			optional = false
		},
		{
			name = "teamNr",
			description = "VarArg team number.",
			type = "number",
			optional = true
		}
	},
	returns = {
	},
	metatable = DarkRP
}
GM.AddGroupChat = DarkRP.createGroupChat

DarkRP.createAmmoType = DarkRP.stub{
	name = "createAmmoType",
	description = "Create an ammo type.",
	parameters = {
		{
			name = "name",
			description = "The name of the ammo.",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table containing the information for the ammo.",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}

DarkRP.createDemoteGroup = DarkRP.stub{
	name = "createDemoteGroup",
	description = "Create a demote group. When you get banned (demoted) from one of the jobs in this group, you will be banned from every job in this group.",
	parameters = {
		{
			name = "name",
			description = "The name of the demote group.",
			type = "string",
			optional = false
		},
		{
			name = "tbl",
			description = "Table consisting of a list of job.",
			type = "table",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP
}

DarkRP.getDemoteGroup = DarkRP.stub{
	name = "getDemoteGroup",
	description = "Get the demote group of a team. Every team in the same group will return the same object.",
	parameters = {
		{
			name = "teamNr",
			description = "Table consisting of a list of job.",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "set",
			description = "The demote group identifier.",
			type = "Disjoint-Set"
		}
	},
	metatable = DarkRP
}

DarkRP.hookStub{
	name = "DarkRPVarChanged",
	description = "Called when a DarkRPVar was changed.",
	parameters = {
		{
			name = "ply",
			description = "The player for whom the DarkRPVar changed.",
			type = "Player"
		},
		{
			name = "varname",
			description = "The name of the variable that has changed.",
			type = "string"
		},
		{
			name = "oldValue",
			description = "The old value of the DarkRPVar.",
			type = "any"
		},
		{
			name = "newvalue",
			description = "The new value of the DarkRPVar.",
			type = "any"
		}
	},
	returns = {
	}
}

DarkRP.hookStub{
	name = "canBuyPistol",
	description = "Whether a player can buy a pistol.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "shipmentTable",
			description = "The table, as defined in the shipments file.",
			type = "table"
		}
	},
	returns = {
		{
			name = "canBuy",
			description = "Whether it can be bought.",
			type = "boolean"
		},
		{
			name = "suppressMessage",
			description = "Suppress the notification message when it cannot be bought.",
			type = "boolean"
		},
		{
			name = "message",
			description = "A replacement for the message that shows if it cannot be bought.",
			type = "string"
		},
		{
			name = "price",
			description = "An optional override for the price.",
			type = "number"
		}
	}
}

DarkRP.hookStub{
	name = "canBuyShipment",
	description = "Whether a player can buy a shipment.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "shipmentTable",
			description = "The table, as defined in the shipments file.",
			type = "table"
		}
	},
	returns = {
		{
			name = "canBuy",
			description = "Whether it can be bought.",
			type = "boolean"
		},
		{
			name = "suppressMessage",
			description = "Suppress the notification message when it cannot be bought.",
			type = "boolean"
		},
		{
			name = "message",
			description = "A replacement for the message that shows if it cannot be bought.",
			type = "string"
		},
		{
			name = "price",
			description = "An optional override for the price.",
			type = "number"
		}
	}
}

DarkRP.hookStub{
	name = "canBuyVehicle",
	description = "Whether a player can buy a vehicle.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "vehicleTable",
			description = "The table, as defined in the vehicles file.",
			type = "table"
		}
	},
	returns = {
		{
			name = "canBuy",
			description = "Whether it can be bought.",
			type = "boolean"
		},
		{
			name = "suppressMessage",
			description = "Suppress the notification message when it cannot be bought.",
			type = "boolean"
		},
		{
			name = "message",
			description = "A replacement for the message that shows if it cannot be bought.",
			type = "string"
		},
		{
			name = "price",
			description = "An optional override for the price.",
			type = "number"
		}
	}
}

DarkRP.hookStub{
	name = "canBuyAmmo",
	description = "Whether a player can buy ammo.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "ammoTable",
			description = "The table, as defined in the a ammo file.",
			type = "table"
		}
	},
	returns = {
		{
			name = "canBuy",
			description = "Whether it can be bought.",
			type = "boolean"
		},
		{
			name = "suppressMessage",
			description = "Suppress the notification message when it cannot be bought.",
			type = "boolean"
		},
		{
			name = "message",
			description = "A replacement for the message that shows if it cannot be bought.",
			type = "string"
		},
		{
			name = "price",
			description = "An optional override for the price.",
			type = "number"
		}
	}
}

DarkRP.hookStub{
	name = "canBuyCustomEntity",
	description = "Whether a player can a certain custom entity.",
	parameters = {
		{
			name = "ply",
			description = "The player.",
			type = "Player"
		},
		{
			name = "entTable",
			description = "The table, as defined by the user.",
			type = "table"
		}
	},
	returns = {
		{
			name = "canBuy",
			description = "Whether it can be bought.",
			type = "boolean"
		},
		{
			name = "suppressMessage",
			description = "Suppress the notification message when it cannot be bought.",
			type = "boolean"
		},
		{
			name = "message",
			description = "A replacement for the message that shows if it cannot be bought.",
			type = "string"
		},
		{
			name = "price",
			description = "An optional override for the price.",
			type = "number"
		}
	}
}
