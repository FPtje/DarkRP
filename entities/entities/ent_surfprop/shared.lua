ENT.Type             = "anim"
ENT.Base             = "base_entity"
ENT.PrintName        = "Proplympics surfing prop"
ENT.Author            = "FPtje Falco"
ENT.Information        = "The prop to race on"
ENT.Category        = ""

ENT.Spawnable            = true
ENT.AdminSpawnable        = true

function ENT:SetupDataTables()
	self:DTVar("Entity", 1, "lastCheckpoint")
end