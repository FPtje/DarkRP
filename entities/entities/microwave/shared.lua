ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Microwave"
ENT.Author = "Pcwizdan"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"price");
	self:NetworkVar("Entity",1,"owning_ent");
end