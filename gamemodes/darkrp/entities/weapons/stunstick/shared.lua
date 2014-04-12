if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Stun Stick"
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to discipline\nRight click to kill"
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
	self:SetWeaponHoldType("normal")

	self.Hit = {
		Sound("weapons/stunstick/stunstick_impact1.wav"),
		Sound("weapons/stunstick/stunstick_impact2.wav")
	}

	self.FleshHit = {
		Sound("weapons/stunstick/stunstick_fleshhit1.wav"),
		Sound("weapons/stunstick/stunstick_fleshhit2.wav")
	}
end

function SWEP:Deploy()
	if SERVER then
		self:SetColor(Color(0,0,255,255))
		self:SetMaterial("models/shiny")
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		vm:ResetSequence(vm:LookupSequence("idle01"))
	end
	return true
end

function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetColor(Color(0,0,255,255))
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

function SWEP:DoFlash(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	
	ply:ScreenFade(SCREENFADE.IN, color_white, 1.2, 0)
end

function SWEP:PrimaryAttack()
	if CurTime() < self.NextStrike then return end

	self:NewSetWeaponHoldType("melee")
	timer.Simple(0.3, function() if self:IsValid() then self:NewSetWeaponHoldType("normal") end end)

	self.NextStrike = CurTime() + 0.51 -- Actual delay is set later.

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

	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100) then return end

	if not trace.Entity:isDoor() then
		trace.Entity:SetVelocity((trace.Entity:GetPos() - self.Owner:GetPos()) * 7)
	end

	if trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:IsVehicle() then
		self.DoFlash(self, trace.Entity)
		self.Owner:EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
	else
		self.Owner:EmitSound(self.Hit[math.random(1,#self.Hit)])
		if FPP and FPP.PlayerCanTouchEnt(self.Owner, self, "EntityDamage1", "FPP_ENTITYDAMAGE1") then
			if trace.Entity.SeizeReward and not trace.Entity.burningup and self.Owner:isCP() and trace.Entity.Getowning_ent and self.Owner != trace.Entity:Getowning_ent() then
				self.Owner:addMoney( trace.Entity.SeizeReward )
				DarkRP.notify( self.Owner, 1, 4, DarkRP.getPhrase("you_received_x", DarkRP.formatMoney(trace.Entity.SeizeReward), DarkRP.getPhrase("bonus_destroying_entity")))
			end
			trace.Entity:TakeDamage(1000, self.Owner, self) -- for illegal entities
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self.NextStrike then return end

	self:NewSetWeaponHoldType("melee")
	timer.Simple(0.3, function() if self:IsValid() then self:NewSetWeaponHoldType("normal") end end)

	self.NextStrike = CurTime() + 0.51 -- Actual delay is set later.

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

	local trace = self.Owner:GetEyeTrace()

	if (not IsValid(trace.Entity) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100)) then return end

	if SERVER then
		if not trace.Entity:isDoor() then
			trace.Entity:SetVelocity((trace.Entity:GetPos() - self.Owner:GetPos()) * 7)
		end

		trace.Entity:TakeDamage(10, self.Owner, self)

		if trace.Entity:IsPlayer() or trace.Entity:IsVehicle() then
			self.DoFlash(self, trace.Entity)
			self.Owner:EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
		elseif trace.Entity:IsNPC() then
			self.Owner:EmitSound(self.FleshHit[math.random(1,#self.FleshHit)])
		else
			self.Owner:EmitSound(self.Hit[math.random(1,#self.Hit)])
			if FPP and FPP.PlayerCanTouchEnt(ply, self, "EntityDamage1", "FPP_ENTITYDAMAGE1") then
				if trace.Entity.Getowning_ent and trace.Entity.SeizeReward and trace.Entity:Getowning_ent() != self.Owner then
					self.Owner:addMoney( trace.Entity.SeizeReward )
					DarkRP.notify( self.Owner, 1, 4, DarkRP.getPhrase("you_received_x", DarkRP.formatMoney(trace.Entity.SeizeReward), DarkRP.getPhrase("bonus_destroying_entity")))
				end
				trace.Entity:TakeDamage(990, self.Owner, self)
			end
		end
	end
end

function SWEP:Reload()
	self:NewSetWeaponHoldType("melee")
	timer.Destroy("rp_stunstick_threaten")
	timer.Create("rp_stunstick_threaten", 1, 1, function()
		if not IsValid(self) then return end
		self:NewSetWeaponHoldType("normal")
	end)

	if not SERVER then return end

	if self.LastReload and self.LastReload > CurTime() - 0.1 then self.LastReload = CurTime() return end
	self.LastReload = CurTime()
	self.Owner:EmitSound("weapons/stunstick/spark"..math.random(1,3)..".wav")
end