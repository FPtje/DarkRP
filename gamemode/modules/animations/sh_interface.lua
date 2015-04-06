fprp.addPlayerGesture = fprp.stub{
    name = "addPlayerGesture",
    description = "Add a player gesture to the fprp animations menu (the one that opens with the keys weapon.). Note: This function must be called BOTH serverside AND clientside!",
    parameters = {
        {
            name = "anim",
            description = "The gesture enumeration.",
            type = "number",
            optional = false
        },
        {
            name = "text",
            description = "The textual description of the animation. This is what players see on the button in the menu.",
            type = "string",
            optional = false
        }
    },
    returns = {
    },
    metatable = fprp
}

fprp.removePlayerGesture = fprp.stub{
    name = "removePlayerGesture",
    description = "Removes a player gesture from the fprp animations menu (the one that opens with the keys weapon.). Note: This function must be called BOTH serverside AND clientside!",
    parameters = {
        {
            name = "anim",
            description = "The gesture enumeration.",
            type = "number",
            optional = false
        }
    },
    returns = {
    },
    metatable = fprp
}
