if SERVER then
	AddCSLuaFile("cl_init.lua")
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Silenced Sniper"
	SWEP.Author = "DarkRP Developers"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.IconLetter = "n"

	killicon.AddFont("ls_sniper", "CSKillIcons", "n", Color(200, 200, 200, 255))
end

SWEP.Base = "weapon_cs_base2"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "DarkRP (Weapon)"

SWEP.ViewModel = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"

SWEP.Weight = 3

SWEP.HoldType = "ar2"

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

/*---------------------------------------------------------------------------
Reload
---------------------------------------------------------------------------*/
function SWEP:Reload()
	if not IsValid(self.Owner) then return end
	if SERVER then
		self.Owner:SetFOV(0, 0)
	end

	self.ScopeLevel = 0

	return self.BaseClass.Reload(self)
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
local zoomFOV = {0, 0, 25, 5}
SWEP.NextSecondaryAttack = 0
function SWEP:SecondaryAttack()
	if not IsValid(self.Owner) then return end
	if not self.IronSightsPos then return end

	if self.NextSecondaryAttack > CurTime() then return end

	self.NextSecondaryAttack = CurTime() + 0.1

	self.ScopeLevel = self.ScopeLevel or 0
	self.ScopeLevel = (self.ScopeLevel + 1) % 4
	self:SetIronsights(self.ScopeLevel > 0)
	self.CurHoldType = self.ScopeLevel > 0 and self.HoldType or "normal"
	self:NewSetWeaponHoldType(self.CurHoldType)

	if CLIENT then return end

	self.Owner:SetFOV(zoomFOV[self.ScopeLevel + 1], 0)
end

/*---------------------------------------------------------------------------
Holster the weapon
---------------------------------------------------------------------------*/
function SWEP:Holster()
	if not IsValid(self.Owner) then return end
	if SERVER then
		self.Owner:SetFOV(0, 0)
	end

	self.ScopeLevel = 0
	self:SetIronsights(false)

	return self.BaseClass.Holster(self)
end
