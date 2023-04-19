DarkRP.hookStub{
    name = "DrawChatIndicator",
    description = "Call when the Chat Indicator is drawn. Return to overwrite.",
    parameters = {
        {
            name = "ply",
            description = "The player the indicator should be drawn for.",
            type = "Player"
        }
    },
    returns = {
        {
            name = "override",
            description = "Return true in your hook to disable the default drawing.",
            type = "boolean"
        }
    }
}
