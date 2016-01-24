DarkRP.readNetDoorVar = DarkRP.stub{
    name = "readNetDoorVar",
    description = "Internal function. You probably shouldn't need this. DarkRP calls this function when reading DoorVar net messages. This function reads the net data for a specific DoorVar.",
    parameters = {
    },
    returns = {
        {
            name = "name",
            description = "The name of the DoorVar.",
            type = "string"
        },
        {
            name = "value",
            description = "The value of the DoorVar.",
            type = "any"
        }
    },
    metatable = DarkRP
}

DarkRP.ENTITY.drawOwnableInfo = DarkRP.stub{
    name = "drawOwnableInfo",
    description = "Draw the ownability information on a door or vehicle.",
    parameters = {
    },
    returns = {
    },
    metatable = DarkRP.ENTITY
}

DarkRP.hookStub{
    name = "HUDDrawDoorData",
    description = "Called when DarkRP is about to draw the door ownability information of a door or vehicle. Override this hook to ",
    parameters = {
        {
            name = "ent",
            description = "The door or vehicle of which the ownability information is about to be drawn.",
            type = "Entity"
        }
    },
    returns = {
        {
            name = "override",
            description = "Return true in your hook to disable the default drawing and use your own.",
            type = "boolean"
        }
    }
}
