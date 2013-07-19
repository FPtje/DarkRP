ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "DarkRP Laws"
ENT.Instructions = "Use /addlaws to add a custom law, /removelaw <num> to remove a law."
ENT.Author = "Drakehawke"

ENT.Spawnable = false
ENT.AdminSpawnable = false

DarkRP.declareChatCommand{
	command = "addlaw",
	description = "Add a law to the laws board.",
	delay = 1.5,
	condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
	command = "removelaw",
	description = "Remove a law from the laws board.",
	delay = 1.5,
	condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
	command = "placelaws",
	description = "Place a laws board.",
	delay = 1.5,
	condition = plyMeta.isMayor
}
