ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Food"
ENT.Author = "Pcwizdan"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:DTVar("Entity",1,"owning_ent")
end