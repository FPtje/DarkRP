ENT.Type            = "anim"
ENT.Base            = "base_entity"
ENT.PrintName       = "Proplympics setup controller"
ENT.Author          = "FPtje Falco"
ENT.Information     = "the proplympics setup controller"
ENT.Category		= ""

ENT.Spawnable            = false
ENT.AdminSpawnable       = false

function ENT:SetupDataTables()
	self:DTVar("Int", 1, "stage") -- Current stage: setup, idle and playing
end