fprp.stub{
	name = "drawPlayerInfo",
	description = "Draw player info above a player's head (name, health job). Override this function to disable or change drawing behaviour in fprp.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}

fprp.stub{
	name = "drawWantedInfo",
	description = "Draw the wanted info above a player's head. Override this to disable or change the drawing of wanted info above players' heads.",
	parameters = {
	},
	returns = {
	},
	metatable = fprp.PLAYER
}
