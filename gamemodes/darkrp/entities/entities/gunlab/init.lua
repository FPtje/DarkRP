AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.SpawnOffset = Vector(0, 0, 27)

function ENT:createItem()
    local gun = ents.Create("spawned_weapon")

    local wep = weapons.Get(GAMEMODE.Config.gunlabweapon)
    gun:SetModel(wep and wep.WorldModel or "models/weapons/w_pist_p228.mdl")
    gun:SetWeaponClass(GAMEMODE.Config.gunlabweapon)
    local gunPos = self:GetPos() + self.SpawnOffset
    gun:SetPos(gunPos)
    gun.nodupe = true
    gun:Spawn()
end
