local plyMeta = FindMetaTable("Player")

fprp.declareChatCommand{
	command = "job",
	description = "Change your job name",
	delay = 1.5,
	condition = fn.Compose{fn.Not, plyMeta.isArrested}
}

fprp.declareChatCommand{
	command = "demote",
	description = "Demote a player from their job",
	delay = 1.5,
	condition = fn.Compose{fn.Curry(fn.Flip(fn.Gt), 2)(1), fn.Length, player.GetAll}
}

fprp.declareChatCommand{
	command = "switchjob",
	description = "Switch jobs with the player you're looking at",
	delay = 1.5,
	condition = fn.Compose{fn.Curry(fn.GetValue, 2)("allowjobswitch"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}
}

fprp.declareChatCommand{
	command = "switchjobs",
	description = "Switch jobs with the player you're looking at",
	delay = 1.5,
	condition = fn.Compose{fn.Curry(fn.GetValue, 2)("allowjobswitch"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}
}

fprp.declareChatCommand{
	command = "jobswitch",
	description = "Switch jobs with the player you're looking at",
	delay = 1.5,
	condition = fn.Compose{fn.Curry(fn.GetValue, 2)("allowjobswitch"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}
}

fprp.declareChatCommand{
	command = "teamban",
	description = "Ban someone from getting a certain job",
	delay = 1.5,
	condition = fn.Curry(fn.Flip(plyMeta.hasfprpPrivilege), 2)("rp_commands")
}

fprp.declareChatCommand{
	command = "teamunban",
	description = "Undo a teamban",
	delay = 1.5,
	condition = fn.Curry(fn.Flip(plyMeta.hasfprpPrivilege), 2)("rp_commands")
}
