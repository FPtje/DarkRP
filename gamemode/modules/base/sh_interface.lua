fprp.registerfprpVar = fprp.stub{
	name = "registerfprpVar",
	description = "Register a fprpVar by name. You should definitely register fprpVars. Registering fprpVars will make networking much more efficient.",
	parameters = {
		{
			name = "name",
			description = "The name of the fprpVar.",
			type = "string",
			optional = false
		},
		{
			name = "writeFn",
			description = "The function that writes a value for this fprpVar. Examples: net.WriteString, function(val) net.WriteUInt(val, 8) end.",
			type = "function",
			optional = false
		},
		{
			name = "readFn",
			description = "The function that reads and returns a value for this fprpVar. Examples: net.ReadString, function() return net.ReadUInt(8) end.",
			type = "function",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.writeNetfprpVar = fprp.stub{
	name = "writeNetfprpVar",
	description = "Internal function. You probably shouldn't need this. fprp calls this function when sending fprpVar net messages. This function writes the net data for a specific fprpVar.",
	parameters = {
		{
			name = "name",
			description = "The name of the fprpVar.",
			type = "string",
			optional = false
		},
		{
			name = "value",
			description = "The value of the fprpVar.",
			type = "any",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.writeNetfprpVarRemoval = fprp.stub{
	name = "writeNetfprpVarRemoval",
	description = "Internal function. You probably shouldn't need this. fprp calls this function when sending fprpVar net messages. This function sets a fprpVar to nil.",
	parameters = {
		{
			name = "name",
			description = "The name of the fprpVar.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.readNetfprpVar = fprp.stub{
	name = "readNetfprpVar",
	description = "Internal function. You probably shouldn't need this. fprp calls this function when reading fprpVar net messages. This function reads the net data for a specific fprpVar.",
	parameters = {
	},
	returns = {
		{
			name = "name",
			description = "The name of the fprpVar.",
			type = "string"
		},
		{
			name = "value",
			description = "The value of the fprpVar.",
			type = "any"
		}
	},
	metatable = fprp
}

fprp.readNetfprpVarRemoval = fprp.stub{
	name = "readNetfprpVarRemoval",
	description = "Internal function. You probably shouldn't need this. fprp calls this function when reading fprpVar net messages. This function the removal of a fprpVar.",
	parameters = {
	},
	returns = {
		{
			name = "name",
			description = "The name of the fprpVar.",
			type = "string"
		}
	},
	metatable = fprp
}

fprp.findPlayer = fprp.stub{
	name = "findPlayer",
	description = "Find a single player based on vague information.",
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
	metatable = fprp
}

fprp.findPlayers = fprp.stub{
	name = "findPlayers",
	description = "Find a list of players based on vague information.",
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
			description = "Table of players that match the description.",
			type = "table"
		}
	},
	metatable = fprp
}

fprp.nickSortedPlayers = fprp.stub{
	name = "nickSortedPlayers",
	description = "A table of players sorted by RP name.",
	parameters = {},
	returns = {
		{
			name = "players",
			description = "The list of players sorted by RP name.",
			type = "table"
		}
	},
	metatable = fprp
}


fprp.formatshekel = fprp.stub{
	name = "formatshekel",
	description = "Format a number as a shekel value. Includes currency symbol.",
	parameters = {
		{
			name = "amount",
			description = "The shekel to format, e.g. 100000.",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "shekel",
			description = "The shekel as a nice string, e.g. \"$100,000\".",
			type = "string"
		}
	},
	metatable = fprp
}

fprp.getJobByCommand = fprp.stub{
	name = "getJobByCommand",
	description = "Get the job table and number from the command of the job.",
	parameters = {
		{
			name = "command",
			description = "The command of the job, without preceding slash (e.g. 'medic' for medic)",
			type = "string",
			optional = false
		}
	},
	returns = {
		{
			name = "tbl",
			description = "A table containing all information about the job.",
			type = "table"
		},
		{
			name = "jobindex",
			description = "The index of the job (for 'medic' it's the value of TEAM_MEDIC).",
			type = "number"
		}
	},
	metatable = fprp
}

fprp.simplerrRun = fprp.stub{
	name = "simplerrRun",
	description = "Run a function with the given parameters and send any runtime errors to admins.",
	parameters = {
		{
			name = "f",
			description = "The function to be called.",
			type = "function",
			optional = false
		},
		{
			name = "args",
			description = "The arguments to be given to f.",
			type = "vararg",
			optional = true
		},
	},
	returns = {
		{
			name = "retVals",
			description = "The return values of f.",
			type = "vararg"
		}
	},
	metatable = fprp
}

fprp.error = fprp.stub{
	name = "error",
	description = "Throw a simplerr formatted error. Also halts the stack, which means that statements after calling this function will not execute.",
	parameters = {
		{
			name = "message",
			description = "The message of the error.",
			type = "string",
			optional = false
		},
		{
			name = "stack",
			description = "From which point in the function call stack to report the error. 1 to include the function that called fprp.error, 2 to exclude it, etc. The default value is 1.",
			type = "number",
			optional = true
		},
		{
			name = "hints",
			description = "Table containing hint strings. Use these hints to explain the error, describe possible causes or provide help to solve the problem.",
			type = "table",
			optional = true
		},
		{
			name = "path",
			description = "Override the path of the error. Will be shown in the error message. By default this is determined by the stack level.",
			type = "string",
			optional = true
		},
		{
			name = "line",
			description = "Override the line number of the error. By default this is determined by the stack level.",
			type = "number",
			optional = true
		},

	},
	returns = {
		{
			name = "succeed",
			description = "Simplerr return value: whether the calculation succeeded. Always false. This return value will never be reached.",
			type = "boolean"
		},
		{
			name = "msg",
			description = "Simplerr return value: nicely formatted error message. This return value will never be reached.",
			type = "string"
		}
	},
	metatable = fprp
}

fprp.errorNoHalt = fprp.stub{
	name = "errorNoHalt",
	description = "Throw a simplerr formatted error. Unlike fprp.error, this does not halt the stack. This means that statements after calling this function will be executed like normal.",
	parameters = {
		{
			name = "message",
			description = "The message of the error.",
			type = "string",
			optional = false
		},
		{
			name = "stack",
			description = "From which point in the function call stack to report the error. 1 to include the function that called fprp.error, 2 to exclude it, etc. The default value is 1.",
			type = "number",
			optional = true
		},
		{
			name = "hints",
			description = "Table containing hint strings. Use these hints to explain the error, describe possible causes or provide help to solve the problem.",
			type = "table",
			optional = true
		},
		{
			name = "path",
			description = "Override the path of the error. Will be shown in the error message. By default this is determined by the stack level.",
			type = "string",
			optional = true
		},
		{
			name = "line",
			description = "Override the line number of the error. By default this is determined by the stack level.",
			type = "number",
			optional = true
		},

	},
	returns = {
		{
			name = "succeed",
			description = "Simplerr return value: whether the calculation succeeded. Always false.",
			type = "boolean"
		},
		{
			name = "msg",
			description = "Simplerr return value: nicely formatted error message.",
			type = "string"
		}
	},
	metatable = fprp
}

-- This function is one of the few that's already defined before the stub is created
fprp.stub{
	name = "SteamName",
	description = "Retrieve a player's real (steam) name.",
	parameters = {

	},
	returns = {
		{
			name = "name",
			description = "The player's steam name.",
			type = "string"
		}
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.getJobTable = fprp.stub{
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
	metatable = fprp.PLAYER
}

fprp.PLAYER.getfprpVar = fprp.stub{
	name = "getfprpVar",
	description = "Get the value of a fprpVar, which is shared between server and client.",
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
			description = "The value of the fprp var.",
			type = "any"
		}
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.getAgenda = fprp.stub{
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
	metatable = fprp.PLAYER
}

fprp.PLAYER.getAgendaTable = fprp.stub{
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
	metatable = fprp.PLAYER
}

fprp.PLAYER.hasfprpPrivilege = fprp.stub{
	name = "hasfprpPrivilege",
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
	metatable = fprp.PLAYER
}

fprp.PLAYER.getEyeSightHitEntity = fprp.stub{
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
			description = "The maximum distance between the player's line of sight and the object. Basically how far the player can be 'looking away' from the object. The default is 15 units.",
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
	metatable = fprp.PLAYER
}

fprp.VECTOR.isInSight = fprp.stub{
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
	metatable = fprp.VECTOR
}

/*---------------------------------------------------------------------------
Creating custom items
---------------------------------------------------------------------------*/
fprp.createJob = fprp.stub{
	name = "createJob",
	description = "Create a job for fprp.",
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
	metatable = fprp
}
AddExtraTeam = fprp.createJob

fprp.removeJob = fprp.stub{
	name = "removeJob",
	description = "Remove a job from fprp.",
	parameters = {
		{
			name = "i",
			description = "The TEAM_ number of the job. Also the index of the job in RPExtraTeams.",
			type = "number",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.createEntityGroup = fprp.stub{
	name = "createEntityGroup",
	description = "Create a entity group for fprp.",
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
	metatable = fprp
}
AddDoorGroup = fprp.createEntityGroup

fprp.createShipment = fprp.stub{
	name = "createShipment",
	description = "Create a shipment for fprp.",
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
	metatable = fprp
}
AddCustomShipment = fprp.createShipment

fprp.createVehicle = fprp.stub{
	name = "createVehicle",
	description = "Create a vehicle for fprp.",
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
	metatable = fprp
}
AddCustomVehicle = fprp.createVehicle

fprp.createEntity = fprp.stub{
	name = "createEntity",
	description = "Create a entity for fprp.",
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
	metatable = fprp
}
AddCustomVehicle = fprp.createEntity

fprp.createAgenda = fprp.stub{
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
	metatable = fprp
}
AddAgenda = fprp.createAgenda

fprp.getAgendas = fprp.stub{
	name = "getAgendas",
	description = "Get all agendas. Note: teams that share an agenda use the exact same agenda table. E.g. when you change the agenda of the CP, the agenda of the Chief will automatically be updated as well. Make sure this property is maintained when modifying the agenda table. Not maintaining that property will lead to players not seeing the right agenda text.",
	parameters = {

	},
	returns = {
		{
			name = "agendas",
			description = "Table in which the keys are team numbers and the values agendas.",
			type = "table"
		}
	},
	metatable = fprp
}

fprp.createGroupChat = fprp.stub{
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
	metatable = fprp
}
GM.AddGroupChat = fprp.createGroupChat

fprp.createAmmoType = fprp.stub{
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
	metatable = fprp
}

fprp.createDemoteGroup = fprp.stub{
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
	metatable = fprp
}

fprp.getDemoteGroup = fprp.stub{
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
	metatable = fprp
}

fprp.getDemoteGroups = fprp.stub{
	name = "getDemoteGroups",
	description = "Get all demote groups Every team in the same group will return the same object.",
	parameters = {

	},
	returns = {
		{
			name = "set",
			description = "Table in which the keys are team numbers and the values Disjoint-Set.",
			type = "table"
		}
	},
	metatable = fprp
}

fprp.createCategory = fprp.stub{
    name = "createCategory",
    description = "Create a category for the F4 menu.",
    parameters = {
        {
            name = "tbl",
            description = "Table describing the category.",
            type = "table",
            optional = false
        }
    },
    returns = {
    },
    metatable = fprp
}

fprp.addToCategory = fprp.stub{
    name = "addToCategory",
    description = "Create a category for the F4 menu.",
    parameters = {
        {
            name = "item",
            description = "Table of the custom entity/job/etc.",
            type = "table",
            optional = false
        },
        {
            name = "kind",
            description = "The kind of the category (e.g. 'jobs' for job stuff).",
            type = "string",
            optional = false
        },
        {
            name = "cat",
            description = "The name of the category. Note that the category must exist. Defaults to 'Other'.",
            type = "string",
            optional = true
        }
    },
    returns = {
    },
    metatable = fprp
}

fprp.removeFromCategory = fprp.stub{
    name = "removeFromCategory",
    description = "Create a category for the F4 menu.",
    parameters = {
        {
            name = "item",
            description = "Table of the custom entity/job/etc.",
            type = "table",
            optional = false
        },
        {
            name = "kind",
            description = "The kind of the category (e.g. 'jobs' for job stuff).",
            type = "string",
            optional = false
        }
    },
    returns = {
    },
    metatable = fprp
}

fprp.getCategories = fprp.stub{
    name = "getCategories",
    description = "Get all categories for all F4 menu tabs.",
    parameters = {
    },
    returns = {
        {
            name = "tbl",
            description = "all categories.",
            type = "table"
        }
    },
    metatable = fprp
}

fprp.hookStub{
	name = "fprpVarChanged",
	description = "Called when a fprpVar was changed.",
	parameters = {
		{
			name = "ply",
			description = "The player for whom the fprpVar changed.",
			type = "Player"
		},
		{
			name = "varname",
			description = "The name of the variable that has changed.",
			type = "string"
		},
		{
			name = "oldValue",
			description = "The old value of the fprpVar.",
			type = "any"
		},
		{
			name = "newvalue",
			description = "The new value of the fprpVar.",
			type = "any"
		}
	},
	returns = {
	}
}

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
	name = "onJobRemoved",
	description = "Called when a job was removed.",
	parameters = {
		{
			name = "num",
			description = "The TEAM_ number of the job.",
			type = "number"
		},
		{
			name = "jobbtable",
			description = "The table containing all the job info.",
			type = "table"
		}
	},
	returns = {
	}
}

fprp.hookStub{
	name = "loadCustomfprpItems",
	description = "Runs right after the scripts from the fprpMod are run. You can add custom jobs, entities, shipments and whatever in this hook.",
	parameters = {
	},
	returns = {
	}
}

fprp.hookStub{
	name = "fprpStartedLoading",
	description = "Runs at the very start of loading fprp. Not even sandbox has loaded here yet.",
	parameters = {
	},
	returns = {
	}
}

fprp.hookStub{
	name = "fprpFinishedLoading",
	description = "Runs right after fprp itself has loaded. All fprpMod stuff (except for disabled_defaults) is loaded during this hook. NOTE! NO CUSTOM STUFF WILL BE AVAILABLE DURING THIS HOOK. USE `loadCustomfprpItems` INSTEAD IF YOU WANT THAT!",
	parameters = {
	},
	returns = {
	}
}
