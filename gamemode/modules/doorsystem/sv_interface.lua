DarkRP.doorToEntIndex = DarkRP.stub{
    name = "doorToEntIndex",
    description = "Get an ENT index from a door index.",
    parameters = {
        {
            name = "index",
            description = "The door index",
            type = "number",
            optional = false
        }
    },
    returns = {
        {
            name = "index",
            description = "The ENT index",
            type = "number",
        }
    },
    metatable = DarkRP
}

DarkRP.doorIndexToEnt = DarkRP.stub{
    name = "doorIndexToEnt",
    description = "Get the entity of a door index (inverse of ent:doorIndexToEnt()). Note: the door MUST have been created by the map!",
    parameters = {
        {
            name = "index",
            description = "The door index",
            type = "number",
            optional = false
        }
    },
    returns = {
        {
            name = "door",
            description = "The door entity",
            type = "Entity",
        }
    },
    metatable = DarkRP
}

DarkRP.writeNetDoorVar = DarkRP.stub{
    name = "writeNetDoorVar",
    description = "Internal function. You probably shouldn't need this. DarkRP calls this function when sending DoorVar net messages. This function writes the net data for a specific DoorVar.",
    parameters = {
        {
            name = "name",
            description = "The name of the DoorVar.",
            type = "string",
            optional = false
        },
        {
            name = "value",
            description = "The value of the DoorVar.",
            type = "any",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.ENTITY.doorIndex = DarkRP.stub{
    name = "doorIndex",
    description = "Get the door index of a door. Use this to store door information in the database.",
    parameters = {
    },
    returns = {
        {
            name = "index",
            description = "The door index.",
            type = "number"
        }
    },
    metatable = DarkRP.ENTITY
}

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

DarkRP.ENTITY.setKeysNonOwnable = DarkRP.stub{
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
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.setKeysTitle = DarkRP.stub{
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
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.setDoorGroup = DarkRP.stub{
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
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.addKeysDoorTeam = DarkRP.stub{
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
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.removeKeysDoorTeam = DarkRP.stub{
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
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.removeAllKeysDoorTeams = DarkRP.stub{
    name = "removeAllKeysDoorTeams",
    description = "Disallow all teams from locking/unlocking a door.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.removeAllKeysExtraOwners = DarkRP.stub{
    name = "removeAllKeysExtraOwners",
    description = "Remove all co-owners from a door.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.removeAllKeysAllowedToOwn = DarkRP.stub{
    name = "removeAllKeysAllowedToOwn",
    description = "Disallow all people from owning the door.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.removeKeysAllowedToOwn = DarkRP.stub{
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
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isLocked = DarkRP.stub{
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

DarkRP.PLAYER.sendDoorData = DarkRP.stub{
    name = "sendDoorData",
    description = "Internal function. Sends all door data to a player.",
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
            type = "Entity"
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

DarkRP.hookStub{
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

DarkRP.hookStub{
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

DarkRP.hookStub{
    name = "canTax",
    description = "Called before a player pays taxes. This hook differs from onPaidTax in that this hook can prevent the taxing and change the tax amount.",
    parameters = {
        {
            name = "ply",
            description = "The player who was taxed.",
            type = "Player"
        },
        {
            name = "tax",
            description = "The amount of money that is about to be taxed from the player.",
            type = "number"
        }
    },
    returns = {
        {
            name = "shouldTax",
            description = "Whether the player is to be taxed. Return false here to prevent the player from being taxed.",
            type = "boolean"
        },
        {
            name = "tax",
            description = "Overrides the amount of money that is taxed.",
            type = "number"
        }
    }
}

DarkRP.hookStub{
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
            description = "The amount of money the player had before the tax was applied.",
            type = "number"
        }
    },
    returns = {

    }
}

DarkRP.hookStub{
    name = "canTaxEntity",
    description = "Called right before a player's property is taxed. Decides per entity whether it can be taxed.",
    parameters = {
        {
            name = "ply",
            description = "The player whose property will be taxed.",
            type = "Player"
        },
        {
            name = "ent",
            description = "The door or vehicle that is to be taxed",
            type = "Entity"
        }
    },
    returns = {
        {
            name = "shouldTax",
            description = "Return false here to prevent this specific entity from being taxed.",
            type = "boolean"
        }
    }
}

DarkRP.hookStub{
    name = "canPropertyTax",
    description = "Called right before a player's property is taxed. This hook differs from onPropertyTax in that onPropertyTax is called AFTER the taxing. With this hook, one can influence the taxing process.",
    parameters = {
        {
            name = "ply",
            description = "The player whose property will be taxed.",
            type = "Player"
        },
        {
            name = "tax",
            description = "The amount of money that will be taxed (unless overridden by this hook).",
            type = "number"
        }
    },
    returns = {
        {
            name = "shouldTax",
            description = "Return false here to prevent the doors from being taxed.",
            type = "boolean"
        },
        {
            name = "taxOverride",
            description = "Override the tax amount.",
            type = "number"
        }
    }
}

DarkRP.hookStub{
    name = "onPropertyTax",
    description = "Called right AFTER a player's property is taxed. Please use canPropertyTax if you want to influence the taxing process.",
    parameters = {
        {
            name = "ply",
            description = "The player whose property has been taxed.",
            type = "Player"
        },
        {
            name = "tax",
            description = "The amount of money that has been taxed.",
            type = "number"
        },
        {
            name = "couldAfford",
            description = "Whether the player was able to afford the tax.",
            type = "boolean"
        }
    },
    returns = {
    }
}
