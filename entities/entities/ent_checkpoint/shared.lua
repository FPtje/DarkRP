ENT.Type             = "anim"
ENT.Base             = "base_entity"
ENT.PrintName        = "Proplympics checkpoint"
ENT.Author            = "FPtje Falco"
ENT.Information        = "the proplympics checkpoint"
ENT.Category        = ""

ENT.Spawnable            = false
ENT.AdminSpawnable        = false

function ENT:SetupDataTables()
	self:DTVar("Int", 1, "radius")
	self:DTVar("Bool", 2, "Activated")
	self:DTVar("Entity", 1, "nextCheckpoint")
	self:DTVar("Entity", 2, "previousCheckpoint")
	self:DTVar("Entity", 3, "manager")
end