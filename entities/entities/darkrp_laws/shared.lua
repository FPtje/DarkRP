ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "DarkRP Laws"
ENT.Instructions = "Use /addlaws to add a custom law, /removelaw <num> to remove a law."
ENT.Author = "Drakehawke"

ENT.Spawnable = false

local plyMeta = FindMetaTable("Player")
DarkRP.declareChatCommand{
    command = "addlaw",
    description = "Add a law to the laws board.",
    delay = 1.5,
    condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
    command = "removelaw",
    description = "Remove a law from the laws board.",
    delay = 1.5,
    condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
    command = "placelaws",
    description = "Place a laws board.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "resetlaws",
    description = "Reset all laws.",
    delay = 1.5
}

DarkRP.getLaws = DarkRP.stub{
    name = "getLaws",
    description = "Get the table of all current laws.",
    parameters = {
    },
    returns = {
        {
            name = "laws",
            description = "A table of all current laws.",
            type = "table"
        }
    },
    metatable = DarkRP,
    realm = "Shared"
}

DarkRP.resetLaws = DarkRP.stub{
    name = "resetLaws",
    description = "Reset to default laws.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP,
    realm = "Server"
}

DarkRP.hookStub{
    name = "addLaw",
    description = "Called when a law is added.",
    parameters = {
        {
            name = "index",
            description = "Index of the law",
            type = "number"
        },
        {
            name = "law",
            description = "Law string",
            type = "string"
        },
        {
            name = "player",
            description = "The player who added the law",
            type = "Player"
        }
    },
    returns = {
    },
    realm = "Shared"
}

DarkRP.hookStub{
    name = "removeLaw",
    description = "Called when a law is removed.",
    parameters = {
        {
            name = "index",
            description = "Index of law",
            type = "number"
        },
        {
            name = "law",
            description = "Law string",
            type = "string"
        },
        {
            name = "player",
            description = "The player who removed the law",
            type = "Player"
        }
    },
    returns = {
    },
    realm = "Shared"
}

DarkRP.hookStub{
    name = "resetLaws",
    description = "Called when laws are reset.",
    parameters = {
        {
            name = "player",
            description = "The player resetting the laws.",
            type = "Player"
        }
    },
    returns = {
    },
    realm = "Shared"
}

DarkRP.hookStub{
    name = "canEditLaws",
    description = "Whether someone can edit laws.",
    parameters = {
        {
            name = "player",
            description = "The player trying to edit laws.",
            type = "Player"
        },
        {
            name = "action",
            description = "How the player is trying to edit laws.",
            type = "string"
        },
        {
            name = "arguments",
            description = "Arguments related to editing laws.",
            type = "table"
        }
    },
    returns = {
        {
            name = "canEdit",
            description = "A yes or no as to whether the player can edit the law.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message that is shown when they can't edit the law.",
            type = "string"
        }
    },
    realm = "Server"
}
