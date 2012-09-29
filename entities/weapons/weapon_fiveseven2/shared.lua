if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "FiveSeven"
	SWEP.Author = "Rickster"
	SWEP.Slot = 1
	SWEP.SlotPos = 5
	SWEP.IconLetter = "u"

	killicon.AddFont("weapon_p228", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base = "weapon_cs_base2"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.HoldType = "pistol"

SWEP.Primary.Sound = Sound("Weapon_FiveSeven.Single")
SWEP.Primary.Recoil = .5
SWEP.Primary.Damage = 10
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.03
SWEP.Primary.ClipSize = 21
SWEP.Primary.Delay = 0.05
SWEP.Primary.DefaultClip = 21
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IronSightsPos = Vector(4.5114, -2.3929, 3.1386)
SWEP.IronSightsAng = Vector(0.3528, -0.0235, 0)

