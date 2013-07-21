if (SERVER) then
	AddCSLuaFile("shared.lua")
end

if (CLIENT) then
	SWEP.PrintName = "Pump Shotgun"
	SWEP.Author = "Rickster"
	SWEP.Slot = 2
	SWEP.SlotPos = 0
	SWEP.IconLetter = "k"

	killicon.AddFont("weapon_pumpshotgun", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base = "weapon_cs_base2"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.HoldType = "ar2"

SWEP.Primary.Sound = Sound("Weapon_M3.Single")
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = 20
SWEP.Primary.NumShots = 8
SWEP.Primary.Cone = 0.08
SWEP.Primary.ClipSize = 8
SWEP.Primary.Delay = 0.95
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "buckshot"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IronSightsPos = Vector(-7.64, -8, 3.56)
SWEP.IronSightsAng = Vector(-0.1, 0.02, 0)


function SWEP:Reload()
	-- if (CLIENT) then return end

	self:SetIronsights(false)

	-- Already reloading
	if self.Weapon.reloading then return end

	-- Start reloading if we can
	if (self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) then
		self.Weapon.reloading = true
		self.Weapon:SetVar("reloadtimer", CurTime() + 0.3)
		self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
		self.Owner:SetAnimation(PLAYER_RELOAD)
	end
end

function SWEP:Think()
	if self.Weapon.reloading then
		if (self.Weapon:GetVar("reloadtimer", 0) < CurTime()) then
			-- Finsished reload -
			if (self.Weapon:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
				self.Weapon.reloading = false
				return
			end

			if self.queueattack then
				self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
				self.Weapon.reloading = false
				self.Weapon.queueattack = false
				timer.Simple( 0.8, function()
					if not IsValid( self ) then return end
					self:PrimaryAttack()
				end )
				return
			end

			-- Next cycle
			self.Weapon:SetVar("reloadtimer", CurTime() + 0.3)
			self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)

			-- Add ammo
			self.Owner:RemoveAmmo(1, self.Primary.Ammo, false)
			self.Weapon:SetClip1(self.Weapon:Clip1() + 1)

			-- Finish filling, final pump
			if (self.Weapon:Clip1() >= self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
				self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
			end
		end
	end
	self.BaseClass.Think(self)
end

function SWEP:PrimaryAttack()
	if self.queueattack then return end

	if self.Weapon.reloading then

		self.queueattack = true -- this way it doesn't interupt the reload animation
		return
	end

	self.BaseClass.PrimaryAttack(self)
end