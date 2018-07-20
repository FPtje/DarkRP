DarkRP.addChatReceiver = DarkRP.stub{
    name = "addChatReceiver",
    description = "Add a chat command with specific receivers",
    parameters = {
        {
            name = "prefix",
            description = "The chat command itself (\"/pm\", \"/ooc\", \"/me\" are some examples)",
            type = "string",
            optional = false
        },
        {
            name = "text",
            description = "The text that shows up when it says \"Some people can hear you X\"",
            type = "string",
            optional = false
        },
        {
            name = "hearFunc",
            description = "A function(ply, splitText) that decides whether this player can or cannot hear you.",
            type = "function",
            optional = false
        }
    },
    returns = {},
    metatable = DarkRP
}

DarkRP.removeChatReceiver = DarkRP.stub{
    name = "removeChatReceiver",
    description = "Remove a chat command receiver",
    parameters = {
        {
            name = "prefix",
            description = "The chat command itself (\"/pm\", \"/ooc\", \"/me\" are some examples)",
            type = "string",
            optional = false
        }
    },
    returns = {},
    metatable = DarkRP
}

DarkRP.hookStub{
    name = "chatHideRecipient",
    description = "Hide a receipent from who can hear/see your text GUI.",
    parameters = {
        {
            name = "ply",
            description = "The player who spoke.",
            type = "Player"
        }
    },
    returns = {

    }
}
