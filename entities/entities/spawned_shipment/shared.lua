ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Shipment"
ENT.Author = "philxyz"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"contents")
	self:NetworkVar("Int",1,"count")
	self:NetworkVar("Float", 0, "gunspawn")
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Entity", 1, "gunModel")
end