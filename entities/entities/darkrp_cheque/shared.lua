ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Cheque"
ENT.Author = "Eusion"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Entity", 1, "recipient")
	self:NetworkVar("Int", 0, "amount")
end