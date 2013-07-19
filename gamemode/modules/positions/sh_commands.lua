local plyMeta = FindMetaTable("Player")

DarkRP.declareChatCommand{
	command = "setspawn",
	description = "reset the spawn position for some job and place a new one at your position (use the command name of the job as argument)",
	delay = 1.5,
	condition = fn.Curry(fn.Flip(meta.hasDarkRPPrivilege), 2)("rp_commands")
}

DarkRP.declareChatCommand{
	command = "addspawn",
	description = "Add a spawn position for some job (use the command name of the job as argument)",
	delay = 1.5,
	condition = fn.Curry(fn.Flip(meta.hasDarkRPPrivilege), 2)("rp_commands")
}

DarkRP.declareChatCommand{
	command = "removespawn",
	description = "Add a spawn position for some job (use the command name of the job as argument)",
	delay = 1.5,
	condition = fn.Curry(fn.Flip(meta.hasDarkRPPrivilege), 2)("rp_commands")
}
