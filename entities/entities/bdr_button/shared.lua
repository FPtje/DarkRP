ENT.Type             = "anim"
ENT.Base             = "base_entity"
ENT.PrintName        = "Proplympics button"
ENT.Author            = "FPtje Falco"
ENT.Information        = "Proplympics button"
ENT.Category        = ""

ENT.Spawnable            = false
ENT.AdminSpawnable        = false

function ENT:SetupDataTables()
	self:DTVar("Entity", 1, "owner")
end