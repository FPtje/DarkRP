fprp.openHitMenu = fprp.stub{
	name = "openHitMenu",
	description = "Open the menu that requests a hit.",
	parameters = {
		{
			name = "hitman",
			description = "The hitman to request the hit to.",
			type = "Player",
			optional = false
		}
	},
	returns = {
	},
	metatable = fprp
}

fprp.PLAYER.drawHitInfo = fprp.stub{
	name = "drawHitInfo",
	description = "Start drawing the hit information above a hitman.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.PLAYER.stopHitInfo = fprp.stub{
	name = "stopHitInfo",
	description = "Stop drawing the hit information above a hitman.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}
