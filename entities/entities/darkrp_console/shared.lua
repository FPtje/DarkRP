ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Reports Console"
ENT.Author = "Eusion"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:DTVar("Entity", 1, "reporter")
	self:DTVar("Bool", 0, "alarm")
	self:DTVar("Entity", 2, "reported")
end