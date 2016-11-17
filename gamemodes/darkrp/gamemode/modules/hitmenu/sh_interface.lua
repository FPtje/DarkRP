DarkRP.PLAYER.isHitman = DarkRP.stub{
    name = "isHitman",
    description = "Whether this player is a hitman.",
    parameters = {
    },
    returns = {
        {
            name = "answer",
            description = "Whether this player is a hitman.",
            type = "boolean"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.hasHit = DarkRP.stub{
    name = "hasHit",
    description = "Whether this hitman has a hit.",
    parameters = {
    },
    returns = {
        {
            name = "answer",
            description = "Whether this player has a hit.",
            type = "boolean"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.getHitTarget = DarkRP.stub{
    name = "getHitTarget",
    description = "Get the target of a hitman.",
    parameters = {
    },
    returns = {
        {
            name = "target",
            description = "The target of the hit.",
            type = "Player"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.getHitPrice = DarkRP.stub{
    name = "getHitPrice",
    description = "Get the price the hitman demands for his work.",
    parameters = {
    },
    returns = {
        {
            name = "price",
            description = "The price of the next hit.",
            type = "number"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.addHitmanTeam = DarkRP.stub{
    name = "addHitmanTeam",
    description = "Make this team a hitman.",
    parameters = {
        {
            name = "team number",
            description = "The number of the team (e.g. TEAM_MOB)",
            type = "number",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.getHitmanTeams = DarkRP.stub{
    name = "getHitmanTeams",
    description = "Get all the hitman teams.",
    parameters = {
    },
    returns = {
        {
            name = "tbl",
            description = "A table in which the keys are TEAM_ numbers and the values are just true.",
            type = "table"
        }
    },
    metatable = DarkRP
}

DarkRP.hookStub{
    name = "canRequestHit",
    description = "Whether someone can request a hit.",
    parameters = {
        {
            name = "hitman",
            description = "The hitman performing the hit",
            type = "Player"
        },
        {
            name = "customer",
            description = "The customer for the current hit.",
            type = "Player"
        },
        {
            name = "target",
            description = "The target of the current hit",
            type = "Player"
        },
        {
            name = "price",
            description = "The agreed upon price.",
            type = "number"
        }
    },
    returns = {
        {
            name = "canRequest",
            description = "A yes or no as to whether the hit can be requested.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message that is shown when they can't request the hit.",
            type = "string"
        },
        {
            name = "price",
            description = "An override for the price of the hit.",
            type = "number"
        }
    }
}

DarkRP.hookStub{
    name = "onHitAccepted",
    description = "When a hitman accepts a hit.",
    parameters = {
        {
            name = "hitman",
            description = "The hitman performing the hit.",
            type = "Player"
        },
        {
            name = "target",
            description = "The target of the current hit.",
            type = "Player"
        },
        {
            name = "customer",
            description = "The customer of the current hit.",
            type = "Player"
        }
    },
    returns = {

    }
}

DarkRP.hookStub{
    name = "onHitCompleted",
    description = "When a hitman finishes a hit.",
    parameters = {
        {
            name = "hitman",
            description = "The hitman performing the hit.",
            type = "Player"
        },
        {
            name = "target",
            description = "The target of the current hit.",
            type = "Player"
        },
        {
            name = "customer",
            description = "The customer of the current hit.",
            type = "Player"
        }
    },
    returns = {

    }
}

DarkRP.hookStub{
    name = "onHitFailed",
    description = "When a hit fails for some reason.",
    parameters = {
        {
            name = "hitman",
            description = "The hitman performing the hit.",
            type = "Player"
        },
        {
            name = "target",
            description = "The target of the current hit.",
            type = "Player"
        },
        {
            name = "reason",
            description = "why the hit failed.",
            type = "string"
        }
    },
    returns = {

    }
}
