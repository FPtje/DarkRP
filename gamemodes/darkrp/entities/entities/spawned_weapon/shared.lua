ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spawned Weapon"
ENT.Author = "Rickster"
ENT.Spawnable = false
ENT.IsSpawnedWeapon = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "amount")
    self:NetworkVar("String", 0, "WeaponClass")
end
