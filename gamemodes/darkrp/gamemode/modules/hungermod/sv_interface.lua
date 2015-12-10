DarkRP.PLAYER.newHungerData = DarkRP.stub{
    name = "newHungerData",
    description = "Create the initial hunger data (called on PlayerInitialSpawn).",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.hungerUpdate = DarkRP.stub{
    name = "hungerUpdate",
    description = "Makes the player slightly more hungry. Called in a timer by default.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.hookStub{
    name = "playerBoughtFood",
    description = "Called when a player bought food.",
    parameters = {
        {
            name = "ply",
            description = "The player who bought food.",
            type = "Player"
        },
        {
            name = "food",
            description = "Food table.",
            type = "table"
        },
        {
            name = "spawnedfood",
            description = "Entity of spawned food.",
            type = "Entity"
        },
        {
            name = "cost",
            description = "How much player paid.",
            type = "number"
        }
    },
    returns = {
    }
}

DarkRP.hookStub{
    name = "hungerUpdate",
    description = "Called every 10 seconds for every player when hungermod is on. This updates the player's hunger level.",
    parameters = {
        {
            name = "ply",
            description = "The player who might be slightly more hungery.",
            type = "Player"
        },
        {
            name = "energy",
            description = "The energy the player has left.",
            type = "number"
        }
    },
    returns = {
        {
            name = "override",
            description = "Override the default behaviour of substracting some and killing the player when starving.",
            type = "boolean"
        }
    }
}

DarkRP.hookStub{
    name = "playerStarved",
    description = "Called when a player dies of starvation.",
    parameters = {
        {
            name = "ply",
            description = "The player who died of starvation.",
            type = "Player"
        }
    },
    returns = {
    }
}
