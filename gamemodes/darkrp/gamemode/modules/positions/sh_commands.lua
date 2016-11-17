local plyMeta = FindMetaTable("Player")

DarkRP.declareChatCommand{
    command = "setspawn",
    description = "Reset the spawn position for some job and place a new one at your position (use the command name of the job as argument)",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "addspawn",
    description = "Add a spawn position for some job (use the command name of the job as argument)",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "removespawn",
    description = "Remove a spawn position for some job (use the command name of the job as argument)",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "jailpos",
    description = "Reset jail positions and create a new one at your position.",
    delay = 1.5,
    condition = fn.FAnd{plyMeta.isChief, fn.Compose{fn.Curry(fn.GetValue, 2)("chiefjailpos"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}}
}

DarkRP.declareChatCommand{
    command = "setjailpos",
    description = "Reset jail positions and create a new one at your position.",
    delay = 1.5,
    condition = fn.FAnd{plyMeta.isChief, fn.Compose{fn.Curry(fn.GetValue, 2)("chiefjailpos"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}}
}

DarkRP.declareChatCommand{
    command = "addjailpos",
    description = "Add a jail position where you're standing.",
    delay = 1.5,
    condition = fn.FAnd{plyMeta.isChief, fn.Compose{fn.Curry(fn.GetValue, 2)("chiefjailpos"), fn.Curry(fn.GetValue, 2)("Config"), gmod.GetGamemode}}
}
