DarkRP.log = DarkRP.stub{
    name = "log",
    description = "Log a message in DarkRP",
    parameters = {
        {
            name = "message",
            description = "The message to log",
            type = "string",
            optional = false
        },
        {
            name = "colour",
            description = "The color of the message in the admin's console. Admins won't see the message if this is not defined.",
            type = "Color",
            optional = true
        },
        {
            name = "noFileSave",
            description = "Whether to write the log to a file or not.",
            type = "boolean",
            optional = true
        }
    },
    returns = {},
    metatable = DarkRP
}
