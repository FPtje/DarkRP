ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Reports Console"
ENT.Author = "Eusion"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 1, "reporter")
	self:NetworkVar("Bool", 0, "alarm")
	self:NetworkVar("Entity", 2, "reported")
end