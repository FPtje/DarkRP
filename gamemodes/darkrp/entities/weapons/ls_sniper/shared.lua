AddCSLuaFile()

if SERVER then
    AddCSLuaFile("cl_init.lua")
end

if CLIENT then
    SWEP.Author = "DarkRP Developers"
    SWEP.Slot = 0
    SWEP.SlotPos = 0
    SWEP.IconLetter = "n"

    killicon.AddFont("ls_sniper", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

DEFINE_BASECLASS("weapon_cs_base2")

SWEP.PrintName = "Silenced Sniper"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "DarkRP (Weapon)"

SWEP.ViewModel = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"

SWEP.Weight = 3

SWEP.HoldType = "ar2"
SWEP.LoweredHoldType = "passive"

SWEP.Primary.Sound = Sound("Weapon_M4A1.Silenced")
SWEP.Primary.Damage = 100
SWEP.Primary.Recoil = 0.03
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.0001 - .05
SWEP.Primary.ClipSize = 25
SWEP.Primary.Delay = 0.7
SWEP.Primary.DefaultClip = 75
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "smg1"
SWEP.IronSightsPos = Vector(0, 0, 0) -- this is just to make it disappear so it doesn't show up whilst scoped

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)
    -- Int 0 = BurstBulletNum
    -- Int 1 = TotalUsedMagCount
    self:NetworkVar("Int", 2, "ScopeLevel")
end

function SWEP:Deploy()
    self:GetOwner():SetFOV(0, 0)

    self:SetScopeLevel(0)

    return BaseClass.Deploy(self)
end

function SWEP:Holster()
    self:GetOwner():SetFOV(0, 0)

    self:SetScopeLevel(0)

    return BaseClass.Holster(self)
end

local zoomFOV = {0, 0, 25, 5}
function SWEP:SecondaryAttack()
    if not self.IronSightsPos then return end

    self:SetNextSecondaryFire(CurTime() + 0.1)

    self:SetScopeLevel((self:GetScopeLevel() + 1) % 4)
    self:SetIronsights(self:GetScopeLevel() > 0)

    self:GetOwner():SetFOV(zoomFOV[self:GetScopeLevel() + 1], 0)
end

function SWEP:Reload()
    self:GetOwner():SetFOV(0, 0)

    self:SetScopeLevel(0)

    return BaseClass.Reload(self)
end
