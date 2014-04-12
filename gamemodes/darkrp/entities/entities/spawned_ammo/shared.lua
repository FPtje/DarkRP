if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "spawned_weapon"
ENT.PrintName = "Spawned Ammo"
ENT.Author = "FPtje"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
end
