if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Arrest Baton"
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to arrest\nRight click to switch batons"
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
		self:SetColor(Color(255,0,0,255))
		self:SetMaterial("models/shiny")
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		vm:ResetSequence(vm:LookupSequence("idle01"))
	end
	return true
end

function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetColor(Color(255,0,0,255))
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

	self.Owner:LagCompensation(true)
	local trace = util.QuickTrace(self.Owner:EyePos(), self.Owner:GetAimVector() * 90, {self.Owner})
	self.Owner:LagCompensation(false)
	if IsValid(trace.Entity) and trace.Entity.onArrestStickUsed then
		trace.Entity:onArrestStickUsed(self.Owner)
		return
	end

	local ent = self.Owner:getEyeSightHitEntity(nil, nil, function(p) return p ~= self.Owner and p:IsPlayer() and p:Alive() end)

	if not IsValid(ent) or (self.Owner:EyePos():Distance(ent:GetPos()) > 90) or (not ent:IsPlayer() and not ent:IsNPC()) then
		return
	end

	if IsValid(ent) and ent:IsPlayer() and ent:isCP() and not GAMEMODE.Config.cpcanarrestcp then
		DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("cant_arrest_other_cp"))
		return
	end

	if ent:GetClass() == "prop_ragdoll" then
		for k,v in pairs(player.GetAll()) do
			if ent.OwnerINT and ent.OwnerINT == v:EntIndex() and GAMEMODE.KnockoutToggle then
				DarkRP.toggleSleep(v, true)
				return
			end
		end
	end

	if not GAMEMODE.Config.npcarrest and ent:IsNPC() then
		return
	end

	if GAMEMODE.Config.needwantedforarrest and not ent:IsNPC() and not ent:getDarkRPVar("wanted") then
		DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("must_be_wanted_for_arrest"))
		return
	end

	if FAdmin and ent:IsPlayer() and ent:FAdmin_GetGlobal("fadmin_jailed") then
		DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("cant_arrest_fadmin_jailed"))
		return
	end

	local jpc = DarkRP.jailPosCount()

	if not jpc or jpc == 0 then
		DarkRP.notify(self.Owner, 1, 4, DarkRP.getPhrase("cant_arrest_no_jail_pos"))
	else
		-- Send NPCs to Jail
		if ent:IsNPC() then
			ent:SetPos(DarkRP.retrieveJailPos())
		else
			if not ent.Babygod then
				ent:arrest(nil, self.Owner)
				DarkRP.notify(ent, 0, 20, DarkRP.getPhrase("youre_arrested_by", self.Owner:Nick()))

				if self.Owner.SteamName then
					DarkRP.log(self.Owner:Nick().." ("..self.Owner:SteamID()..") arrested "..ent:Nick(), Color(0, 255, 255))
				end
			else
				DarkRP.notify(self.Owner, 1, 4, DarkRP.getPhrase("cant_arrest_spawning_players"))
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	if self.Owner:HasWeapon("unarrest_stick") then
		self.Owner:SelectWeapon("unarrest_stick")
	end
end
