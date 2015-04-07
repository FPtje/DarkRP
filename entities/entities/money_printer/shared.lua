ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "shekel Printer"
ENT.Author = "Render Case and philxyz"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "price");
	self:NetworkVar("Entity", 0, "owning_ent");
end

fprp.hookStub{
	name = "shekelPrinterCatchFire",
	description = "Called when a shekel printer is about to catch fire.",
	parameters = {
		{
			name = "shekelprinter",
			description = "The shekel printer that is about to catch fire",
			type = "Entity"
		}
	},
	returns = {
		{
			name = "prevent",
			description = "Set to true to prevent the shekel printer from catching fire",
			type = "boolean"
		}
	},
	realm = "Server"
}

fprp.hookStub{
	name = "shekelPrinterPrintshekel",
	description = "Called when a shekel printer is about to print shekel.",
	parameters = {
		{
			name = "shekelprinter",
			description = "The shekel printer that is about to print shekel",
			type = "Entity"
		},
		{
			name = "amount",
			description = "The amount to be printed",
			type = "number"
		}
	},
	returns = {
		{
			name = "prevent",
			description = "Set to true to prevent the shekel printer from printing the shekel.",
			type = "boolean"
		},
		{
			name = "amount",
			description = "Optionally override the amount of shekel that will be printed.",
			type = "number"
		}
	},
	realm = "Server"
}

fprp.hookStub{
	name = "shekelPrinterPrinted",
	description = "Called after a shekel printer is has printed shekel.",
	parameters = {
		{
			name = "shekelprinter",
			description = "The shekel printer",
			type = "Entity"
		},
		{
			name = "shekelbag",
			description = "The shekelbag produced by the printer.",
			type = "Entity"
		}
	},
	returns = {
	},
	realm = "Server"
}
