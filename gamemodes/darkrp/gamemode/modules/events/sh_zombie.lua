local plyMeta = FindMetaTable("Player")

DarkRP.addPhrase("en", "zombie_approaching", "WARNING: Zombies are approaching!")
DarkRP.addPhrase("en", "zombie_leaving", "Zombies are leaving.")
DarkRP.addPhrase("en", "zombie_spawn_not_exist", "Zombie Spawn %s does not exist.")
DarkRP.addPhrase("en", "zombie_spawn_removed", "You have removed this zombie spawn.")
DarkRP.addPhrase("en", "zombie_spawn_added", "You have added a zombie spawn.")
DarkRP.addPhrase("en", "zombie_maxset", "Maximum amount of zombies is now set to %s")
DarkRP.addPhrase("en", "zombie_enabled", "Zombies are now enabled.")
DarkRP.addPhrase("en", "zombie_disabled", "Zombies are now disabled.")
DarkRP.addPhrase("en", "zombie_spawn", "Zombie Spawn")
DarkRP.addPhrase("en", "zombie_toggled", "Zombies toggled.")

DarkRP.registerDarkRPVar("zombieToggle", net.WriteBit, fn.Compose{tobool, net.ReadBit})
DarkRP.registerDarkRPVar("zPoints", function(zSpawns)
	net.WriteUInt(#zSpawns, 16)
	for _, pos in pairs(zSpawns) do
		net.WriteVector(pos)
	end
end,
function()
	local res = {}
	local count = net.ReadUInt(16)
	for i = 1, count, 1 do
		table.insert(res, net.ReadVector())
	end

	return res
end)

local hasCommandsPriv = fn.Curry(fn.Flip(plyMeta.hasDarkRPPrivilege), 2)("rp_commands")
DarkRP.declareChatCommand{
	command = "enablestorm",
	description = "Enable meteor storms.",
	delay = 1.5,
	condition = hasCommandsPriv
}

DarkRP.declareChatCommand{
	command = "disablestorm",
	description = "Disable meteor storms.",
	delay = 1.5,
	condition = hasCommandsPriv
}

DarkRP.declareChatCommand{
	command = "removezombie",
	description = "Remove a zombie spawn pos by id (get id with /showzombie).",
	delay = 1.5,
	condition = hasCommandsPriv
}

DarkRP.declareChatCommand{
	command = "addzombie",
	description = "Add a zombie spawn pos.",
	delay = 1.5,
	condition = hasCommandsPriv
}

DarkRP.declareChatCommand{
	command = "showzombie",
	description = "Show zombie spawn positions.",
	delay = 1.5,
	condition = hasCommandsPriv
}

DarkRP.declareChatCommand{
	command = "zombiemax",
	description = "Set the maximum amount of zombies that can be in a level.",
	delay = 1.5,
	condition = hasCommandsPriv
}

DarkRP.declareChatCommand{
	command = "maxzombie",
	description = "Set the maximum amount of zombies that can be in a level.",
	delay = 1.5,
	condition = hasCommandsPriv
}

DarkRP.declareChatCommand{
	command = "maxzombies",
	description = "Set the maximum amount of zombies that can be in a level.",
	delay = 1.5,
	condition = hasCommandsPriv
}

DarkRP.declareChatCommand{
	command = "enablezombie",
	description = "Enable zombie mod.",
	delay = 1.5,
	condition = hasCommandsPriv
}

DarkRP.declareChatCommand{
	command = "disablezombie",
	description = "Disable zombie mod.",
	delay = 1.5,
	condition = hasCommandsPriv
}

