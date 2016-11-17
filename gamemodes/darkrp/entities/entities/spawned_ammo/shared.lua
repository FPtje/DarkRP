ENT.Type = "anim"
ENT.Base = "spawned_weapon"
ENT.PrintName = "Spawned Ammo"
ENT.Author = "FPtje"
ENT.Spawnable = false
ENT.IsSpawnedAmmo = true

function ENT:SetupDataTables()
    self.BaseClass.SetupDataTables(self)
end
