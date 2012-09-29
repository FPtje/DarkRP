if (SERVER) then
	AddCSLuaFile("shared.lua")
end

if (CLIENT) then
	SWEP.PrintName = "Mac10"
	SWEP.Author = "Rickster"
	SWEP.Slot = 2
	SWEP.SlotPos = 4
	SWEP.IconLetter = "l"

	killicon.AddFont("weapon_mac10", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base = "weapon_cs_base2"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_smg_mac10.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false


SWEP.HoldType = "ar2"

SWEP.Primary.Sound = Sound("Weapon_mac10.Single")
SWEP.Primary.Recoil = .8
SWEP.Primary.Damage = 30
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.02
SWEP.Primary.ClipSize = 25
SWEP.Primary.Delay = 0.09
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IronSightsPos = Vector (7.1437, -2.6467, 3.0592)
SWEP.IronSightsAng = Vector (0.4833, 11.1981, 7.2364)

