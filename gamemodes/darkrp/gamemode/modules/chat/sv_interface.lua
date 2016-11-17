DarkRP.defineChatCommand = DarkRP.stub{
    name = "defineChatCommand",
    description = "Create a chat command that calls the function",
    parameters = {
        {
            name = "chat command",
            description = "The registered chat command",
            type = "string",
            optional = false
        },
        {
            name = "callback",
            description = "The function that is called when the chat command is executed",
            type = "function",
            optional = false
        }
    },
    returns = {},
    metatable = DarkRP
}

DarkRP.definePrivilegedChatCommand = DarkRP.stub{
    name = "definePrivilegedChatCommand",
    description = "Create a chat command that calls the function if the player has the right CAMI privilege. Will automatically notify the user when they don't have access. Note that chat command functions registered with this function can NOT override the chat that will appear after the command has been executed.",
    parameters = {
        {
            name = "chat command",
            description = "The registered chat command",
            type = "string",
            optional = false
        },
        {
            name = "privilege",
            description = "The name of the CAMI privilege",
            type = "string",
            optional = false
        },
        {
            name = "callback",
            description = "The function that is called when the chat command is executed",
            type = "function",
            optional = false
        }
    },
    returns = {},
    metatable = DarkRP
}

DarkRP.hookStub{
    name = "PostPlayerSay",
    description = "Called after a player has said something.",
    parameters = {
        {
            name = "ply",
            description = "The player who spoke.",
            type = "Player"
        },
        {
            name = "text",
            description = "The thing they said.",
            type = "string"
        },
        {
            name = "teamonly",
            description = "Whether they said it to their team only.",
            type = "boolean"
        },
        {
            name = "dead",
            description = "Whether they are dead.",
            type = "boolean"
        }
    },
    returns = {

    }
}

DarkRP.hookStub{
    name = "canChatCommand",
    description = "Called when a player tries to run any chat command or uses the DarkRP console command. ",
    parameters = {
        {
            name = "ply",
            description = "The player who spoke.",
            type = "Player"
        },
        {
            name = "command",
            description = "The thing they said.",
            type = "string"
        },
        {
            name = "arguments",
            description = "The arguments of the chat command, given as one string.",
            type = "string"
        }
    },
    returns = {
        {
            name = "canChatCommand",
            description = "Whether the player is allowed to run the chat command.",
            type = "boolean"
        },
    }
}

DarkRP.hookStub{
    name = "onChatCommand",
    description = "Called after a player has run any chat command or uses the DarkRP console command. Note: the chat command has already been run. Use canChatCommand if you want to stop chat commands from being run.",
    parameters = {
        {
            name = "ply",
            description = "The player who spoke.",
            type = "Player"
        },
        {
            name = "command",
            description = "The thing they said.",
            type = "string"
        },
        {
            name = "arguments",
            description = "The arguments of the chat command, given either as one string or a table of strings. That depends on whether the command is declared to use table arguments.",
            type = "string"
        },
        {
            name = "return",
            description = "The return value of the chat command function. Should contain a chat text override and/or a say function. See the return values of this hook for a description",
            type = "table"
        }
    },
    returns = {
        {
            name = "overrideText",
            description = "Overrides the text a chat command will put in everyone's chat box. Return nil to not change behaviour.",
            type = "string"
        },
        {
            name = "overrideSayFunc",
            description = "Say functions handle what needs to be said to whom. The say function for PMs for example make sure only the sender and receiver see the message. You can override this behaviour by returning a different say function in this hook. Return nil to not change behaviour.",
            type = "function"
        },
    }
}
