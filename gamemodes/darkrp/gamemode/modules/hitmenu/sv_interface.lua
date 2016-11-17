DarkRP.PLAYER.requestHit = DarkRP.stub{
    name = "requestHit",
    description = "Request a hit to a hitman.",
    parameters = {
        {
            name = "customer",
            description = "The customer who paid for the hit.",
            type = "Player",
            optional = false
        },
        {
            name = "target",
            description = "The target of the hit.",
            type = "Player",
            optional = false
        },
        {
            name = "price",
            description = "The price of the hit.",
            type = "number",
            optional = false
        }
    },
    returns = {
        {
            name = "succeeded",
            description = "Whether the hit request could be made.",
            type = "boolean"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.placeHit = DarkRP.stub{
    name = "placeHit",
    description = "Place an actual hit.",
    parameters = {
        {
            name = "customer",
            description = "The customer who paid for the hit.",
            type = "Player",
            optional = false
        },
        {
            name = "target",
            description = "The target of the hit.",
            type = "Player",
            optional = false
        },
        {
            name = "price",
            description = "The price of the hit.",
            type = "number",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.setHitTarget = DarkRP.stub{
    name = "setHitTarget",
    description = "Set the target of a hit",
    parameters = {
        {
            name = "target",
            description = "The target of the hit.",
            type = "Player",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.setHitPrice = DarkRP.stub{
    name = "setHitPrice",
    description = "Set the price of a hit",
    parameters = {
        {
            name = "price",
            description = "The price of the hit.",
            type = "number",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.setHitCustomer = DarkRP.stub{
    name = "setHitCustomer",
    description = "Set the customer who pays for the hit.",
    parameters = {
        {
            name = "customer",
            description = "The customer who paid for the hit.",
            type = "Player",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.getHitCustomer = DarkRP.stub{
    name = "getHitCustomer",
    description = "Get the customer for the current hit",
    parameters = {
    },
    returns = {
        {
            name = "customer",
            description = "The customer for the current hit",
            type = "Player"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.abortHit = DarkRP.stub{
    name = "abortHit",
    description = "Abort a hit",
    parameters = {
        {
            name = "message",
            description = "The reason why the hit was aborted",
            type = "string",
            optional = true
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.finishHit = DarkRP.stub{
    name = "finishHit",
    description = "End a hit without a message",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.getHits = DarkRP.stub{
    name = "getHits",
    description = "Get all the active hits",
    parameters = {
    },
    returns = {
        {
            name = "hits",
            description = "A table in which the keys are hitmen and the values are hit information, like the customer.",
            type = "table"
        }
    },
    metatable = DarkRP
}
