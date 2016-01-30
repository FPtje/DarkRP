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
        },
        {
            name = "suppressNotification",
            description = "Suppress any notifications.",
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

DarkRP.PLAYER.teamBanTimeLeft = DarkRP.stub{
    name = "teamBanTimeLeft",
    description = "Returns the time left on a player's teamban.",
    parameters = {
        {
            name = "team",
            description = "the number of the job (e.g. TEAM_MEDIC). Uses the player's team if not defined.",
            type = "number",
            optional = true
        }
    },
    returns = {
        {
            name = "time",
            description = "The time left on the teamban in seconds.",
            type = "number"
        }
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

DarkRP.hookStub{
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

DarkRP.hookStub{
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
        },
        {
            name = "reason",
            description = "The reason why the player cannot change their team.",
            type = "string",
            optional = true
        },
    }
}
