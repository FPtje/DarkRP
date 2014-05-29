ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Money Printer"
ENT.Author = "Render Case and philxyz"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "price")
	self:NetworkVar("Entity", 0, "owning_ent")
end

DarkRP.hookStub{
	name = "moneyPrinterCatchFire",
	description = "Called when a money printer is about to catch fire.",
	parameters = {
		{
			name = "moneyprinter",
			description = "The money printer that is about to catch fire",
			type = "Entity"
		}
	},
	returns = {
		{
			name = "prevent",
			description = "Set to true to prevent the money printer from catching fire",
			type = "boolean"
		}
	},
	realm = "Server"
}

DarkRP.hookStub{
	name = "moneyPrinterPrintMoney",
	description = "Called when a money printer is about to print money.",
	parameters = {
		{
			name = "moneyprinter",
			description = "The money printer that is about to print money",
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
			description = "Set to true to prevent the money printer from printing the money.",
			type = "boolean"
		},
		{
			name = "amount",
			description = "Optionally override the amount of money that will be printed.",
			type = "number"
		}
	},
	realm = "Server"
}

DarkRP.hookStub{
	name = "moneyPrinterPrinted",
	description = "Called after a money printer is has printed money.",
	parameters = {
		{
			name = "moneyprinter",
			description = "The money printer",
			type = "Entity"
		},
		{
			name = "moneybag",
			description = "The moneybag produced by the printer.",
			type = "Entity"
		}
	},
	returns = {
	},
	realm = "Server"
}
