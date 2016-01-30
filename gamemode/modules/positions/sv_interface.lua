DarkRP.storeJailPos = DarkRP.stub{
    name = "storeJailPos",
    description = "Store a jailposition from a player's location.",
    parameters = {
        {
            name = "ply",
            description = "The player of whom to get the location.",
            type = "Player",
            optional = false
        },
        {
            name = "addingPos",
            description = "Whether to reset all jailpositions and to create a new one here or to add it to the existing jailpos.",
            type = "boolean",
            optional = true
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.setJailPos = DarkRP.stub{
    name = "setJailPos",
    description = "Remove all jail positions in this map and create a new one. To add a jailpos without removing previous ones use DarkRP.addJailPos. This jail position will be saved in the database.",
    parameters = {
        {
            name = "pos",
            description = "The position to set as jailpos.",
            type = "Vector",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.addJailPos = DarkRP.stub{
    name = "addJailPos",
    description = "Add a jail position to the map. This jail position will be saved in the database.",
    parameters = {
        {
            name = "pos",
            description = "The position to add as jailpos.",
            type = "Vector",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.retrieveJailPos = DarkRP.stub{
    name = "retrieveJailPos",
    description = "Retrieve a jail position.",
    parameters = {
        {
            name = "index",
            description = "Which jailpos to return.",
            type = "number",
            optional = true
        }
    },
    returns = {
        {
            name = "pos",
            description = "A jail position.",
            type = "Vector"
        }
    },
    metatable = DarkRP
}

DarkRP.jailPosCount = DarkRP.stub{
    name = "jailPosCount",
    description = "The amount of jail positions in the current map.",
    parameters = {
    },
    returns = {
        {
            name = "count",
            description = "The amount of jail positions in the current map.",
            type = "number"
        }
    },
    metatable = DarkRP
}

DarkRP.storeTeamSpawnPos = DarkRP.stub{
    name = "storeTeamSpawnPos",
    description = "Store a spawn position of a job in the database (replaces all other spawn positions).",
    parameters = {
        {
            name = "team",
            description = "The job to store the spawn position of.",
            type = "number",
            optional = false
        },
        {
            name = "pos",
            description = "The position to store.",
            type = "Vector",
            optional = false
        }
    },
    returns = {

    },
    metatable = DarkRP
}

DarkRP.addTeamSpawnPos = DarkRP.stub{
    name = "addTeamSpawnPos",
    description = "Add a spawn position to the database. The position will not replace other spawn positions.",
    parameters = {
        {
            name = "team",
            description = "The job to store the spawn position of.",
            type = "number",
            optional = false
        },
        {
            name = "pos",
            description = "The position to store.",
            type = "Vector",
            optional = false
        }
    },
    returns = {

    },
    metatable = DarkRP
}

DarkRP.removeTeamSpawnPos = DarkRP.stub{
    name = "removeTeamSpawnPos",
    description = "Remove a single spawn position.",
    parameters = {
        {
            name = "team",
            description = "The job to remove the spawn position of.",
            type = "number",
            optional = false
        },
        {
            name = "pos",
            description = "The position to remove.",
            type = "Vector",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.retrieveTeamSpawnPos = DarkRP.stub{
    name = "retrieveTeamSpawnPos",
    description = "Retrieve a random spawn position for a job.",
    parameters = {
        {
            name = "team",
            description = "The job to get a spawn position for.",
            type = "number",
            optional = false
        }
    },
    returns = {
        {
            name = "pos",
            description = "A nice spawn position.",
            type = "Vector"
        }
    },
    metatable = DarkRP
}
