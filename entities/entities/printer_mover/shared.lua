ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName= "Printer Mover"
ENT.Author= "Dannelor"
ENT.Purpose = "Allows for the movement of printer objects"
ENT.Instructions = "Touch printers to the object to attach them"
ENT.Classname = "printer_mover"

ENT.Spawnable = false
ENT.AdminSpawnable = true

fprp.hookStub{
	name = "printerMoverDropPrinters",
	description = "Called when a printer mover drops printers",
	parameters = {
		{
			name = "printer_mover",
			description = "The printer mover about to drop printers",
			type = "Entity"
		}
	},
	returns = {
		{
			name = "prevent",
			description = "Set to true to prevent printer drop",
			type = "boolean"
		}
	},
	realm = "Server"
}

fprp.hookStub{
	name = "printerMoverTakeDamage",
	description = "Called when a printer mover takes damage.",
	parameters = {
		{
			name = "printer_mover",
			description = "The printer mover about to take damage",
			type = "Entity"
		}
	},
	returns = {
		{
			name = "damage",
			description = "Set to apply damage.",
			type = "number"
		}
	},
	realm = "Server"
}