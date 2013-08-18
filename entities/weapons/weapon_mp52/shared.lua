if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "MP5"
	SWEP.Author = "Rickster"
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	SWEP.IconLetter = "x"

	killicon.AddFont("weapon_mp5", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base = "weapon_cs_base2"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "DarkRP (Weapon)"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "smg"

SWEP.Primary.Sound = Sound("Weapon_MP5Navy.Single")
SWEP.Primary.Recoil = 0.2
SWEP.Primary.Damage = 20
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.005
SWEP.Primary.ClipSize = 32
SWEP.Primary.Delay = 0.08
SWEP.Primary.DefaultClip = 32
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IronSightsPos = Vector(-5.3, -7, 2.1)
SWEP.IronSightsAng = Vector(0.9, 0.1, 0)
