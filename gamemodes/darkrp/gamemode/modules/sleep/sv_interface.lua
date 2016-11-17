DarkRP.toggleSleep = DarkRP.stub{
    name = "toggleSleep",
    description = "Old function to toggle sleep. I'm not proud of it.",
    parameters = {
        {
            name = "ply",
            description = "The player to toggle sleep of.",
            type = "Player",
            optional = false
        },
        {
            name = "command",
            description = "Set to \"force\" to force the sleep toggle. Set to true to arrest the player.",
            type = "any",
            optional = true
        }
    },
    returns = {
        {
            name = "str",
            description = "Empty string (since it's a called in a chat command)",
            type = "string"
        }
    },
    metatable = DarkRP
}

DarkRP.hookStub{
    name = "canSleep",
    description = "Whether someone is allowed to sleep.",
    parameters = {
        {
            name = "player",
            description = "The player trying to sleep.",
            type = "Player"
        },
        {
            name = "force",
            description = "Whether the sleep is being forced.",
            type = "boolean"
        }
    },
    returns = {
        {
            name = "canSleep",
            description = "A yes or no as to whether the player can sleep.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message that is shown when they can't sleep.",
            type = "string"
        }
    }
}
