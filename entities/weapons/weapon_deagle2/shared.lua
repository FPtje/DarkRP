if SERVER then
	AddCSLuaFile("shared.lua")
end

if (CLIENT) then
	SWEP.PrintName = "Deagle"
	SWEP.Author = "Rickster"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.IconLetter = "f"

	killicon.AddFont("weapon_p228", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base = "weapon_cs_base2"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "pistol"

SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")
SWEP.Primary.Recoil = 1.1
SWEP.Primary.Damage = 25
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = 7
SWEP.Primary.Delay = 0.3
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IronSightsPos = Vector(5.1293, -2.1574, 2.5218)
SWEP.IronSightsAng = Vector(0.5756, -0.0499, 0)

