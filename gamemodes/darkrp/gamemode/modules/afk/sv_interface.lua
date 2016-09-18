DarkRP.hookStub{
    name = "playerAFKDemoted",
    description = "When a player is demoted for being AFK.",
    parameters = {
        {
            name = "ply",
            description = "The player being demoted.",
            type = "Player"
        }
    },
    returns = {
        {
            name = "shouldDemote",
            description = "Prevent the player from being actually demoted.",
            type = "boolean"
        },
        {
            name = "team",
            description = "The team the player is to be demoted to (shouldDemote must be true.)",
            type = "number"
        },
        {
            name = "suppressMessage",
            description = "Suppress the demote message.",
            type = "boolean"
        },
        {
            name = "demoteMessage",
            description = "Replacement of the demote message text.",
            type = "string"
        }
    }
}

DarkRP.hookStub{
    name = "playerSetAFK",
    description = "When a player is set to AFK or returns from AFK.",
    parameters = {
        {
            name = "ply",
            description = "The player.",
            type = "Player"
        },
        {
            name = "afk",
            description = "True when the player starts being AFK, false when the player stops being AFK.",
            type = "boolean"
        }
    },
    returns = {
    }
}

DarkRP.hookStub{
    name = "canGoAFK",
    description = "When a player can MANUALLY start being AFK by entering the chat command. Note: this hook does NOT get called when a player is set to AFK automatically! That hook will not be added, because I don't want asshole server owners to make AFK rules not apply to admins.",
    parameters = {
        {
            name = "ply",
            description = "The player.",
            type = "Player"
        },
        {
            name = "afk",
            description = "True when the player starts being AFK, false when the player stops being AFK.",
            type = "boolean"
        }
    },
    returns = {
        {
            name = "canGoAFK",
            description = "Whether the player is allowed to go AFK",
            type = "boolean"
        }
    }
}
