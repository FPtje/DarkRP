ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "DarkRP Laws"
ENT.Instructions = "Use /addlaws to add a custom law, /removelaw <num> to remove a law."
ENT.Author = "Drakehawke"

ENT.Spawnable = false

local plyMeta = FindMetaTable("Player")
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

DarkRP.getLaws = DarkRP.stub{
	name = "getLaws",
	description = "Get the table of all current laws. While the law numbers are only found in the table keys serverside, the table also includes the law number in the table values on the client side.",
	parameters = {
	},
	returns = {
		{
			name = "laws",
			description = "A table of all current laws.",
			type = "table"
		}
	},
	metatable = DarkRP,
	realm = "Shared"
}

DarkRP.hookStub{
	name = "addLaw",
	description = "Called when a law is added.",
	parameters = {
		{
			name = "law",
			description = "Law string",
			type = "string"
		}
	},
	returns = {
	}
}

DarkRP.hookStub{
	name = "removeLaw",
	description = "Called when a law is removed.",
	parameters = {
		{
			name = "index",
			description = "Index of law",
			type = "number"
		}
	},
	returns = {
	}
}
