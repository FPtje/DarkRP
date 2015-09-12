DarkRP.openHitMenu = DarkRP.stub{
    name = "openHitMenu",
    description = "Open the menu that requests a hit.",
    parameters = {
        {
            name = "hitman",
            description = "The hitman to request the hit to.",
            type = "Player",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.PLAYER.drawHitInfo = DarkRP.stub{
    name = "drawHitInfo",
    description = "Start drawing the hit information above a hitman.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.stopHitInfo = DarkRP.stub{
    name = "stopHitInfo",
    description = "Stop drawing the hit information above a hitman.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}
