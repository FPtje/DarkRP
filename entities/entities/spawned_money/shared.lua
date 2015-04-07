ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spawned shekel"
ENT.Author = "FPtje"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"amount");
end
