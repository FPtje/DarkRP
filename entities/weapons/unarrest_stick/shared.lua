if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Unarrest Baton"
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to unarrest\nRight click to switch batons"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "stunstick"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"

SWEP.NextStrike = 0

SWEP.ViewModel = Model("models/weapons/v_stunbaton.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")

SWEP.Sound = Sound("weapons/stunstick/stunstick_swing1.wav")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:NewSetWeaponHoldType("normal")
end

function SWEP:Deploy()
	if SERVER then
		self:SetColor(Color(0,255,0,255))
		self:SetMaterial("models/shiny")
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		vm:ResetSequence(vm:LookupSequence("idle01"))
	end
	return true
end

function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetColor(Color(0,255,0,255))
	self.Owner:GetViewModel():SetMaterial("models/shiny")
end

function SWEP:Holster()
	if SERVER then
		self:SetColor(Color(255,255,255,255))
		self:SetMaterial("")
		timer.Stop(self:GetClass() .. "_idle" .. self:EntIndex())
	elseif CLIENT and IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():SetColor(Color(255,255,255,255))
		self.Owner:GetViewModel():SetMaterial("")
	end
	return true
end

function SWEP:OnRemove()
	if SERVER then
		self:SetColor(Color(255,255,255,255))
		self:SetMaterial("")
		timer.Stop(self:GetClass() .. "_idle" .. self:EntIndex())
	elseif CLIENT and IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():SetColor(Color(255,255,255,255))
		self.Owner:GetViewModel():SetMaterial("")
	end
end

function SWEP:PrimaryAttack()
	if CurTime() < self.NextStrike then return end

	self:NewSetWeaponHoldType("melee")
	timer.Simple(0.3, function() if self:IsValid() then self:NewSetWeaponHoldType("normal") end end)

	self.NextStrike = CurTime() + 0.51 -- Actual delay is set later

	if CLIENT then return end

	timer.Stop(self:GetClass() .. "_idle" .. self:EntIndex())
	local vm = self.Owner:GetViewModel()
	if IsValid(vm) then
		vm:ResetSequence(vm:LookupSequence("idle01"))
		timer.Simple(0, function()
			if not IsValid(self) or not IsValid(self.Owner) or not IsValid(self.Owner:GetActiveWeapon()) or self.Owner:GetActiveWeapon() ~= self then return end
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			if IsValid(self.Weapon) then
				self.Weapon:EmitSound(self.Sound)
			end

			local vm = self.Owner:GetViewModel()
			if not IsValid(vm) then return end
			vm:ResetSequence(vm:LookupSequence("attackch"))
			vm:SetPlaybackRate(1 + 1/3)
			local duration = vm:SequenceDuration() / vm:GetPlaybackRate()
			timer.Create(self:GetClass() .. "_idle" .. self:EntIndex(), duration, 1, function()
				if not IsValid(self) or not IsValid(self.Owner) then return end
				local vm = self.Owner:GetViewModel()
				if not IsValid(vm) then return end
				vm:ResetSequence(vm:LookupSequence("idle01"))
			end)
			self.NextStrike = CurTime() + duration
		end)
	end

	local trace = util.QuickTrace(self.Owner:EyePos(), self.Owner:GetAimVector() * 90, {self.Owner})
	if IsValid(trace.Entity) and trace.Entity.onUnArrestStickUsed then
		trace.Entity:onUnArrestStickUsed(self.Owner)
		return
	end

	local ent = self.Owner:getEyeSightHitEntity(nil, nil, function(p) return p ~= self.Owner and p:IsPlayer() and p:Alive() end)
	if not ent then return end

	if not IsValid(ent) or not ent:IsPlayer() or (self.Owner:EyePos():Distance(ent:GetPos()) > 115) or not ent:getDarkRPVar("Arrested") then
		return
	end

	ent:unArrest(self.Owner)
	DarkRP.notify(ent, 0, 4, DarkRP.getPhrase("youre_unarrested_by", self.Owner:Nick()))

	if self.Owner.SteamName then
		DarkRP.log(self.Owner:Nick().." ("..self.Owner:SteamID()..") unarrested "..ent:Nick(), Color(0, 255, 255))
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	if self.Owner:HasWeapon("arrest_stick") then
		self.Owner:SelectWeapon("arrest_stick")
	end
end
