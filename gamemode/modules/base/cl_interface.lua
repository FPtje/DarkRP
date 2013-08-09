DarkRP.PLAYER.isInRoom = DarkRP.stub{
	name = "isInRoom",
	description = "Whether the player is in the same room as the LocalPlayer.",
	parameters = {},
	returns = {
		{
			name = "inRoom",
			description = "Whether the player is in the same room.",
			type = "boolean"
		}
	},
	metatable = DarkRP.PLAYER
}

DarkRP.textWrap = DarkRP.stub{
	name = "textWrap",
	description = "Wrap a text around when reaching a certain width.",
	parameters = {},
	returns = {
		{
			name = "text",
			description = "The text to wrap.",
			type = "string"
		},
		{
			name = "font",
			description = "The font of the text.",
			type = "string"
		},
		{
			name = "width",
			description = "The maximum width in pixels.",
			type = "number"
		}
	},
	metatable = DarkRP
}
