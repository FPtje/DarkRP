if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Silenced Sniper"
	SWEP.Author = "Rickster"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.IconLetter = "n"

	killicon.AddFont("ls_sniper", "CSKillIcons", "n", Color(200, 200, 200, 255))
end

SWEP.Base = "ls_snip_base"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"

SWEP.Weight = 3

SWEP.HoldType = "smg"

SWEP.Primary.Sound = Sound("Weapon_M4A1.Silenced")
SWEP.Primary.Damage = 100
SWEP.Primary.Recoil = 0.03
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.0001
SWEP.Primary.UnscopedCone = 0.25
SWEP.Primary.ClipSize = 25
SWEP.Primary.Delay = 0.7
SWEP.Primary.DefaultClip = 75
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "smg1"
SWEP.IronSightsPos = Vector(0, 0, -15) -- this is just to make it disappear so it doesn't show up whilst scoped