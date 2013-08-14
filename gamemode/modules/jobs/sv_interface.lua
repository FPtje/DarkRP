DarkRP.PLAYER.changeTeam = DarkRP.stub{
	name = "changeTeam",
	description = "Change the team of a player.",
	parameters = {
		{
			name = "team",
			description = "The team (job number).",
			type = "number",
			optional = false
		},
		{
			name = "force",
			description = "Force the change (ignore restrictions that players usually have to get the job).",
			type = "boolean",
			optional = true
		}
	},
	returns = {
		{
			name = "allowed",
			description = "Whether the player is allowed to get the job.",
			type = "boolean"
		}
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.updateJob = DarkRP.stub{
	name = "updateJob",
	description = "Set the job name of a player (doesn't change the actual team).",
	parameters = {
		{
			name = "job",
			description = "The name of the job.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.teamUnBan = DarkRP.stub{
	name = "teamUnBan",
	description = "Unban someone from a team.",
	parameters = {
		{
			name = "team",
			description = "The team to unban from.",
			type = "number",
			optional = false
		}
	},
	returns = {

	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.teamBan = DarkRP.stub{
	name = "teamBan",
	description = "Ban someone from getting a certain job.",
	parameters = {
		{
			name = "team",
			description = "the number of the job (e.g. TEAM_MEDIC).",
			type = "number",
			optional = false
		},
		{
			name = "time",
			description = "For how long the player is banned from this job.",
			type = "number",
			optional = true
		}
	},
	returns = {
	},
	metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.changeAllowed = DarkRP.stub{
	name = "changeAllowed",
	description = "Returns whether a player is allowed to get a certain job.",
	parameters = {
		{
			name = "team",
			description = "The job.",
			type = "number",
			optional = false
		}
	},
	returns = {
		{
			name = "allowed",
			description = "Whether the player is allowed to get the job.",
			type = "boolean"
		}
	},
	metatable = DarkRP.PLAYER
}
