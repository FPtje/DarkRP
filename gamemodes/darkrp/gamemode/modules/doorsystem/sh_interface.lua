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

DarkRP.ENTITY.getDoorData = DarkRP.stub{
    name = "getDoorData",
    description = "Internal function to get the door/vehicle data.",
    parameters = {
    },
    returns = {
        {
            name = "doordata",
            description = "All the DarkRP information on a door or vehicle.",
            type = "table"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isKeysOwnable = DarkRP.stub{
    name = "isKeysOwnable",
    description = "Whether this door can be bought.",
    parameters = {
    },
    returns = {
        {
            name = "answer",
            description = "Whether the door can be bought.",
            type = "boolean"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isDoor = DarkRP.stub{
    name = "isDoor",
    description = "Whether this entity is considered a door in DarkRP.",
    parameters = {
    },
    returns = {
        {
            name = "answer",
            description = "Whether it's a door.",
            type = "boolean"
        }
    },
    metatable = DarkRP.ENTITY
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

DarkRP.ENTITY.isKeysOwned = DarkRP.stub{
    name = "isKeysOwned",
    description = "Whether this door is owned by someone.",
    parameters = {
    },
    returns = {
        {
            name = "answer",
            description = "Whether it's owned.",
            type = "boolean"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.getDoorOwner = DarkRP.stub{
    name = "getDoorOwner",
    description = "Get the owner of a door.",
    parameters = {
    },
    returns = {
        {
            name = "owner",
            description = "The owner of the door.",
            type = "Player"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isMasterOwner = DarkRP.stub{
    name = "isMasterOwner",
    description = "Whether the player is the main owner of the door (as opposed to a co-owner).",
    parameters = {
        {
            name = "ply",
            description = "The player to query.",
            type = "Player",
            optional = false
        }
    },
    returns = {
        {
            name = "answer",
            description = "Whether this player is the master owner.",
            type = "boolean"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isKeysOwnedBy = DarkRP.stub{
    name = "isKeysOwnedBy",
    description = "Whether this door is owned or co-owned by this player",
    parameters = {
        {
            name = "ply",
            description = "The player to query.",
            type = "Player",
            optional = false
        }
    },
    returns = {
        {
            name = "answer",
            description = "Whether this door is (co-)owned by the player.",
            type = "boolean"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.isKeysAllowedToOwn = DarkRP.stub{
    name = "isKeysAllowedToOwn",
    description = "Whether this player is allowed to co-own a door, as decided by the master door owner.",
    parameters = {
        {
            name = "ply",
            description = "The player to query.",
            type = "Player",
            optional = false
        }
    },
    returns = {
        {
            name = "answer",
            description = "Whether this door is (co-)ownable by the player.",
            type = "boolean"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.getKeysNonOwnable = DarkRP.stub{
    name = "getKeysNonOwnable",
    description = "Whether ownability of this door/vehicle is disabled.",
    parameters = {
    },
    returns = {
        {
            name = "title",
            description = "The ownability status.",
            type = "boolean"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.getKeysTitle = DarkRP.stub{
    name = "getKeysTitle",
    description = "Get the title of this door or vehicle.",
    parameters = {
    },
    returns = {
        {
            name = "title",
            description = "The title of the door or vehicle.",
            type = "string"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.getKeysDoorGroup = DarkRP.stub{
    name = "getKeysDoorGroup",
    description = "The door group of a door if it exists.",
    parameters = {
    },
    returns = {
        {
            name = "group",
            description = "The door group.",
            type = "string"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.getKeysDoorTeams = DarkRP.stub{
    name = "getKeysDoorTeams",
    description = "The teams that are allowed to open this door.",
    parameters = {
    },
    returns = {
        {
            name = "teams",
            description = "The door teams.",
            type = "table"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.getKeysAllowedToOwn = DarkRP.stub{
    name = "getKeysAllowedToOwn",
    description = "The list of people of which the master door owner has added as allowed to own.",
    parameters = {
    },
    returns = {
        {
            name = "players",
            description = "The list of people allowed to own.",
            type = "table"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.ENTITY.getKeysCoOwners = DarkRP.stub{
    name = "getKeysCoOwners",
    description = "The list of people who co-own the door.",
    parameters = {
    },
    returns = {
        {
            name = "players",
            description = "The list of people allowed to own. The keys of this table are UserIDs, the values are booleans.",
            type = "table"
        }
    },
    metatable = DarkRP.ENTITY
}

DarkRP.PLAYER.canKeysLock = DarkRP.stub{
    name = "canKeysLock",
    description = "Whether the player can lock a given door.",
    parameters = {
        {
            name = "door",
            description = "The door",
            optional = false,
            type = "Entity"
        }
    },
    returns = {
        {
            name = "allowed",
            description = "Whether the player is allowed to lock the door.",
            type = "boolean"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.canKeysUnlock = DarkRP.stub{
    name = "canKeysUnlock",
    description = "Whether the player can unlock a given door.",
    parameters = {
        {
            name = "door",
            description = "The door",
            optional = false,
            type = "Entity"
        }
    },
    returns = {
        {
            name = "allowed",
            description = "Whether the player is allowed to unlock the door.",
            type = "boolean"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.hookStub{
    name = "canKeysLock",
    description = "Whether the player can lock a given door. This hook is run when ply:canKeysLock is called.",
    parameters = {
        {
            name = "ply",
            description = "The player",
            type = "Player"
        },
        {
            name = "door",
            description = "The door",
            type = "Entity"
        }
    },
    returns = {
        {
            name = "allowed",
            description = "Whether the player is allowed to lock the door.",
            type = "boolean"
        }
    }
}

DarkRP.hookStub{
    name = "canKeysUnlock",
    description = "Whether the player can unlock a given door. This hook is run when ply:canKeysUnlock is called.",
    parameters = {
        {
            name = "ply",
            description = "The player",
            type = "Player"
        },
        {
            name = "door",
            description = "The door",
            type = "Entity"
        }
    },
    returns = {
        {
            name = "allowed",
            description = "Whether the player is allowed to unlock the door.",
            type = "boolean"
        }
    }
}
