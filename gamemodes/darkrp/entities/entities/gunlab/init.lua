AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:createItem()
    local gun = ents.Create("spawned_weapon")

    local wep = weapons.Get(GAMEMODE.Config.gunlabweapon)
    gun:SetModel(wep and wep.WorldModel or "models/weapons/w_pist_p228.mdl")
    gun:SetWeaponClass(GAMEMODE.Config.gunlabweapon)
    local gunPos = self:GetPos()
    gun:SetPos(Vector(gunPos.x, gunPos.y, gunPos.z + 27))
    gun.nodupe = true
    gun:Spawn()
end
