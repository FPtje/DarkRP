fprp.ENTITY.drawOwnableInfo = fprp.stub{
	name = "drawOwnableInfo",
	description = "Draw the ownability information on a door or vehicle.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.ENTITY
}

fprp.hookStub{
	name = "HUDDrawDoorData",
	description = "Called when fprp is about to draw the door ownability information of a door or vehicle. Override this hook to ",
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
