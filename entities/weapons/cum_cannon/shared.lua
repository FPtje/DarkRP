AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "Cum Cannon"
	SWEP.Author = "fprp Developers"
	SWEP.Slot = 5
	SWEP.SlotPos = 0
	SWEP.IconLetter = "b"

	killicon.AddFont("weapon_ak472", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base = "weapon_cs_base2"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "fprp (Weapon)"

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "slam"

SWEP.Primary.Sound = Sound("Weapon_M3.Single")
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = math.pi 
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.002
SWEP.Primary.ClipSize = 69
SWEP.Primary.Delay = 0.03
SWEP.Primary.DefaultClip = 69
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IronSightsPos = Vector(-6.6, -15, 2.6)
SWEP.IronSightsAng = Vector(2.6, 0.02, 0)

SWEP.MultiMode = true
