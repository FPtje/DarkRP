DarkRP.initDatabase = DarkRP.stub{
    name = "initDatabase",
    description = "Initialize the DarkRP database.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.storeRPName = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.retrieveRPNames = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.retrievePlayerData = DarkRP.stub{
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
        },
        {
            name = "failure",
            description = "The function that is called when the information cannot be retrieved.",
            type = "function",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.offlinePlayerData = DarkRP.stub{
    name = "offlinePlayerData",
    description = "Get a player's information from the database using a SteamID for use when the player is offline.",
    parameters = {
        {
            name = "steamid",
            description = "The SteamID of the player to get the data for.",
            type = "string",
            optional = false
        },
        {
            name = "callback",
            description = "The function that receives the information.",
            type = "function",
            optional = false
        },
        {
            name = "failure",
            description = "The function that is called when the information cannot be retrieved.",
            type = "function",
            optional = false
        }
    },
    returns = {},
    metatable = DarkRP
}

DarkRP.storeOfflineMoney = DarkRP.stub{
    name = "storeOfflineMoney",
    description = "Store the wallet amount of an offline player. Use DarkRP.offlinePlayerData to fetch the current wallet amount.",
    parameters = {
        {
            name = "sid64",
            description = "The SteamID64 of the player to set the wallet of. NOTE: THIS USED TO BE THE UNIQUEID, BUT THIS CHANGED!",
            type = "number",
            optional = false
        },
        {
            name = "amount",
            description = "The amount of money.",
            type = "number",
            optional = false
        }
    },
    returns = {},
    metatable = DarkRP
}

DarkRP.createPlayerData = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.storeMoney = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.storeSalary = DarkRP.stub{
    name = "storeSalary",
    description = "Internal and deprecated function. Used to store a player's salary in the database.",
    deprecated = "Use the ply:setSelfDarkRPVar(\"salary\", value) function instead.",
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
    metatable = DarkRP
}

DarkRP.retrieveSalary = DarkRP.stub{
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
            description = "The function that receives the salary. Deprecated, use the return value.",
            type = "function",
            optional = false
        }
    },
    returns = {
        {
            name = "salary",
            description = "The salary.",
            type = "number"
        }
    },
    metatable = DarkRP
}

DarkRP.restorePlayerData = DarkRP.stub{
    name = "restorePlayerData",
    description = "Internal function that restores a player's DarkRP information when they join.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.storeDoorData = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.storeTeamDoorOwnability = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.storeDoorGroup = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.notify = DarkRP.stub{
    name = "notify",
    description = "Make a notification pop up on the player's screen.",
    parameters = {
        {
            name = "ply",
            description = "The receiver(s) of the message.",
            type = "Player, table",
            optional = true
        },
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
    metatable = DarkRP
}

DarkRP.notifyAll = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.printMessageAll = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.printConsoleMessage = DarkRP.stub{
    name = "printConsoleMessage",
    description = "Prints a message to a given player's console. This function also handles server consoles too (EntIndex = 0).",
    parameters = {
        {
            name = "ply",
            description = "The player to send the console message to.",
            type = "Player",
            optional = false
        },
        {
            name = "msg",
            description = "The actual message.",
            type = "string",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.talkToRange = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.talkToPerson = DarkRP.stub{
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
    metatable = DarkRP
}

DarkRP.isEmpty = DarkRP.stub{
    name = "isEmpty",
    description = "Check whether the given position is empty. If you want the function not to ignore your entity, set the variable NotEmptyPos (ex. ENT.NotEmptyPos = true)",
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
    metatable = DarkRP
}
-- findEmptyPos(pos, ignore, distance, step, area) -- returns pos
DarkRP.findEmptyPos = DarkRP.stub{
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
            description = "The hull to check, this is Vector(16, 16, 72) for players.",
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
    metatable = DarkRP
}

DarkRP.PLAYER.applyPlayerClassVars = DarkRP.stub{
    name = "applyPlayerClassVars",
    description = "Applies all variables in a player's associated GMod player class to the player.",
    parameters = {
        {
            name = "applyHealth",
            description = "Whether the player's health should be set to the starting health.",
            type = "boolean",
            optional = true
        }
    },
    returns = {},
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.removeDarkRPVar = DarkRP.stub{
    name = "removeDarkRPVar",
    description = "Remove a shared variable. Exactly the same as ply:setDarkRPVar(nil).",
    parameters = {
        {
            name = "variable",
            description = "The name of the variable.",
            type = "string",
            optional = false
        },
        {
            name = "target",
            description = "The clients to whom this variable is sent. Defaults to all players.",
            type = "table",
            optional = true
        }
    },
    returns = {},
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.setDarkRPVar = DarkRP.stub{
    name = "setDarkRPVar",
    description = "Set a shared variable. Make sure the variable is registered with DarkRP.registerDarkRPVar!",
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
            description = "The clients to whom this variable is sent. Defaults to all players.",
            type = "table",
            optional = true
        }
    },
    returns = {},
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.setSelfDarkRPVar = DarkRP.stub{
    name = "setSelfDarkRPVar",
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
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.sendDarkRPVars = DarkRP.stub{
    name = "sendDarkRPVars",
    description = "Internal function. Sends all visibleDarkRPVars of all players to this player.",
    parameters = {
    },
    returns = {},
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.setRPName = DarkRP.stub{
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
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.addCustomEntity = DarkRP.stub{
    name = "addCustomEntity",
    description = "Add a custom entity to the player's limit.",
    parameters = {
        {
            name = "tblEnt",
            description = "The entity table (from the DarkRPEntities table).",
            type = "table",
            optional = false
        }
    },
    returns = {},
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.removeCustomEntity = DarkRP.stub{
    name = "removeCustomEntity",
    description = "Remove a custom entity to the player's limit.",
    parameters = {
        {
            name = "tblEnt",
            description = "The entity table (from the DarkRPEntities table).",
            type = "table",
            optional = false
        }
    },
    returns = {},
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.customEntityLimitReached = DarkRP.stub{
    name = "customEntityLimitReached",
    description = "Set a shared variable.",
    parameters = {
        {
            name = "tblEnt",
            description = "The entity table (from the DarkRPEntities table).",
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
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.customEntityCount = DarkRP.stub{
    name = "customEntityCount",
    description = "Get the count of a custom entity.",
    parameters = {
        {
            name = "tblEnt",
            description = "The entity table (from the DarkRPEntities table).",
            type = "table",
            optional = false
        }
    },
    returns = {
        {
            name = "count",
            description = "The current count of the custom entity.",
            type = "number"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.getPreferredModel = DarkRP.stub{
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
    metatable = DarkRP.PLAYER
}

DarkRP.hookStub{
    name = "DarkRPDBInitialized",
    description = "Called when DarkRP is done initializing the database.",
    parameters = {
    },
    returns = {
    }
}

DarkRP.hookStub{
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

DarkRP.hookStub{
    name = "onNotify",
    description = "Called when a notification is sent.",
    parameters = {
        {
            name = "plys",
            description = "The table recipients of the notification.",
            type = "table"
        },
        {
            name = "msgType",
            description = "The notification type (NOTIFY_ enum)",
            type = "number"
        },
        {
            name = "duration",
            description = "How long the notification should stay on screen.",
            type = "number"
        },
        {
            name = "message",
            description = "The message of the notification.",
            type = "string"
        }
    },
    returns = {
        {
            name = "suppress",
            description = "Whether to suppress the notification. Return true to suppress.",
            type = "boolean"
        }
    }
}

DarkRP.hookStub{
    name = "onPlayerChangedName",
    description = "Called when a player's DarkRP name has been changed.",
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

DarkRP.hookStub{
    name = "onPlayerFirstJoined",
    description = "Called when a player joins this server for the first time (i.e. no entry for this player exists in the DarkRP database)",
    parameters = {
        {
            name = "ply",
            description = "The player.",
            type = "Player"
        },
        {
            name = "data",
            description = "Contains the default wallet, salary and RPName that will be put in the database",
            type = "table"
        }
    },
    returns = {
        {
            name = "data",
            description = "Override the data that is to be put in the database.",
            type = "table"
        }
    }
}

DarkRP.hookStub{
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

DarkRP.hookStub{
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

DarkRP.hookStub{
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

DarkRP.hookStub{
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
            description = "The table of the custom entity (from the DarkRPEntities table).",
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

DarkRP.hookStub{
    name = "playerBoughtAmmo",
    description = "Called when a player buys some ammo.",
    parameters = {
        {
            name = "ply",
            description = "The player.",
            type = "Player"
        },
        {
            name = "ammoTable",
            description = "The table (from the AmmoTypes table).",
            type = "table"
        },
        {
            name = "ent",
            description = "The spawned ammo entity.",
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

DarkRP.hookStub{
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

DarkRP.hookStub{
    name = "demoteTeam",
    description = "The team the player is to be demoted to instead of the default team.",
    parameters = {
        {
            name = "target",
            description = "The player whom is to be demoted.",
            type = "Player"
        },
    },
    returns = {
        {
            name = "demoteTeam",
            description = "The team the player is to be demoted to.",
            type = "number"
        },
    }
}

DarkRP.hookStub{
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

DarkRP.hookStub{
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

DarkRP.hookStub{
    name = "canSeeLogMessage",
    description = "Whether a player can see a DarkRP log message in the console.",
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

DarkRP.hookStub{
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

DarkRP.hookStub{
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

DarkRP.hookStub{
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
        },
        {
            name = "wallet",
            description = "How much money the player had before receiving the money.",
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

DarkRP.hookStub{
    name = "playerClassVarsApplied",
    description = "When a player has had GMod player class variables applied to them through ply:applyPlayerClassVars().",
    parameters = {
        {
            name = "ply",
            description = "The player in question.",
            type = "Player"
        }
    },
    returns = {}
}


DarkRP.hookStub{
    name = "canEarnNPCKillPay",
    description = "If a player should profit from killing a NPC",
    parameters = {
        {
            name = "ply",
            description = "The player who killed the NPC.",
            type = "Player"
        },
        {
            name = "npc",
            description = "The NPC that they killed.",
            type = "Entity"
        }
    },
    returns = {
        {
            name = "answer",
            description = "Whether the player can earn money.",
            type = "boolean"
        }
    }
}


DarkRP.hookStub{
    name = "calculateNPCKillPay",
    description = "How much a player should profit from killing a NPC",
    parameters = {
        {
            name = "ply",
            description = "The player who killed the NPC.",
            type = "Player"
        },
        {
            name = "npc",
            description = "The NPC that they killed.",
            type = "Entity"
        }
    },
    returns = {
        {
            name = "total",
            description = "How much money they should earn.",
            type = "number"
        }
    }
}
