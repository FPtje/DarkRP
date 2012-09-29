ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Shipment"
ENT.Author = "philxyz"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:DTVar("Int",0,"contents")
	self:DTVar("Int",1,"count")
	self:DTVar("Float", 0, "gunspawn")
	self:DTVar("Entity", 0, "owning_ent")
	self:DTVar("Entity", 1, "gunModel")
end