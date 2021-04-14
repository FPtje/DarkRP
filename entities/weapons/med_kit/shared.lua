if SERVER then
    AddCSLuaFile("shared.lua")
end

SWEP.PrintName = "Medic Kit"
SWEP.Author = "DarkRP Developers"
SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.Description = "Heals the wounded."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Left click to heal someone\nRight click to heal yourself"
SWEP.IsDarkRPMedKit = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"

SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel = "models/weapons/w_medkit.mdl"
SWEP.UseHands = true

SWEP.Primary.Recoil = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Recoil = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0.3
SWEP.Secondary.Ammo = "none"

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    local found
    local lastDot = -1 -- the opposite of what you're looking at
    Owner:LagCompensation(true)
    local aimVec = Owner:GetAimVector()
    local shootPos = Owner:GetShootPos()

    for _, v in ipairs(player.GetAll()) do
        local maxhealth = v:GetMaxHealth() or 100
        local targetShootPos = v:GetShootPos()
        if v == Owner or targetShootPos:DistToSqr(shootPos) > 7225 or v:Health() >= maxhealth or not v:Alive() then continue end

        local direction = targetShootPos - shootPos
        direction:Normalize()
        local dot = direction:Dot(aimVec)

        -- Looking more in the direction of this player
        if dot > lastDot then
            lastDot = dot
            found = v
        end
    end
    Owner:LagCompensation(false)

    if found then
        found:SetHealth(found:Health() + 1)
        self:EmitSound("hl1/fvox/boop.wav", 150, math.max(found:Health() / found:GetMaxHealth() * 100, 25), 1, CHAN_AUTO)
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    local ply = self:GetOwner()
    local maxhealth = ply:GetMaxHealth() or 100
    if ply:Health() < maxhealth then
        ply:SetHealth(ply:Health() + 1)
        self:EmitSound("hl1/fvox/boop.wav", 150, math.max(ply:Health() / ply:GetMaxHealth() * 100, 25), 1, CHAN_AUTO)
    end
end
