fprp.PLAYER.changeTeam = fprp.stub{
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
	metatable = fprp.PLAYER
}

fprp.PLAYER.updateJob = fprp.stub{
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
	metatable = fprp.PLAYER
}

fprp.PLAYER.teamUnBan = fprp.stub{
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
	metatable = fprp.PLAYER
}

fprp.PLAYER.teamBan = fprp.stub{
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
	metatable = fprp.PLAYER
}

fprp.PLAYER.changeAllowed = fprp.stub{
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
	metatable = fprp.PLAYER
}

fprp.hookStub{
	name = "canChangeJob",
	description = "Whether a player can change their job. NOTE: This is only for the /job comand! The hook for changing to a pre-existing job is playerCanChangeTeam.",
	parameters = {
		{
			name = "ply",
			description = "The player whom is to change their job.",
			type = "Player"
		},
		{
			name = "job",
			description = "The job name (what the player entered in the /job command).",
			type = "string"
		}
	},
	returns = {
		{
			name = "canChangeJob",
			description = "Whether the player can change their job name (doesn't change their team).",
			type = "boolean"
		},
		{
			name = "message",
			description = "The message to show when the player cannot take the job. Only useful when canChangeJob is false.",
			type = "string"
		},
		{
			name = "replace",
			description = "A replacement for the job name. Only useful when canChangeJob is true.",
			type = "string"
		}
	}
}

fprp.hookStub{
	name = "playerCanChangeTeam",
	description = "Whether a player can change their team.",
	parameters = {
		{
			name = "ply",
			description = "The player whom is to change their team.",
			type = "Player"
		},
		{
			name = "team",
			description = "The team number.",
			type = "number"
		},
		{
			name = "force",
			description = "Whether this team change is important.",
			type = "boolean"
		}
	},
	returns = {
		{
			name = "canChange",
			description = "Whether the player can change their team.",
			type = "boolean"
		}
	}
}
