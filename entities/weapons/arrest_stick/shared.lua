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
SWEP.Instructions = "Left or right click to arrest"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "stunstick"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

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
	end
end

function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetColor(Color(255,0,0,255))
	self.Owner:GetViewModel():SetMaterial("models/shiny")
end

function SWEP:Holster()
	if SEVER then
		self:SetColor(Color(255,255,255,255))
		self:SetMaterial("")
	elseif CLIENT and IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():SetColor(Color(255,255,255,255))
		self.Owner:GetViewModel():SetMaterial("")
	end
	return true
end

function SWEP:OnRemove()
	if SEVER then
		self:SetColor(Color(255,255,255,255))
		self:SetMaterial("")
	elseif CLIENT and IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():SetColor(Color(255,255,255,255))
		self.Owner:GetViewModel():SetMaterial("")
	end
end

function SWEP:PrimaryAttack()
	if CurTime() < self.NextStrike then return end

	self:NewSetWeaponHoldType("melee")
	timer.Simple(0.3, function() if self:IsValid() then self:NewSetWeaponHoldType("normal") end end)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

	self.NextStrike = CurTime() + .4

	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:IsCP() and not GAMEMODE.Config.cpcanarrestcp then
		DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("cant_arrest_other_cp"))
		return
	end

	if trace.Entity:GetClass() == "prop_ragdoll" then
		for k,v in pairs(player.GetAll()) do
			if trace.Entity.OwnerINT and trace.Entity.OwnerINT == v:EntIndex() and GAMEMODE.KnockoutToggle then
				GAMEMODE:KnockoutToggle(v, true)
				return
			end
		end
	end

	if not IsValid(trace.Entity) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 115) or (not trace.Entity:IsPlayer() and not trace.Entity:IsNPC()) then
		return
	end

	if not GAMEMODE.Config.npcarrest and trace.Entity:IsNPC() then
		return
	end

	if GAMEMODE.Config.needwantedforarrest and not trace.Entity:IsNPC() and not trace.Entity:getDarkRPVar("wanted") then
		DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("must_be_wanted_for_arrest"))
		return
	end

	if FAdmin and trace.Entity:IsPlayer() and trace.Entity:FAdmin_GetGlobal("fadmin_jailed") then
		DarkRP.notify(self.Owner, 1, 5, DarkRP.getPhrase("cant_arrest_fadmin_jailed"))
		return
	end

	local jpc = DarkRP.jailPosCount()

	if not jpc or jpc == 0 then
		DarkRP.notify(self.Owner, 1, 4, DarkRP.getPhrase("cant_arrest_no_jail_pos"))
	else
		-- Send NPCs to Jail
		if trace.Entity:IsNPC() then
			trace.Entity:SetPos(DarkRP.retrieveJailPos())
		else
			if not trace.Entity.Babygod then
				trace.Entity:arrest(nil, self.Owner)
				DarkRP.notify(trace.Entity, 0, 20, DarkRP.getPhrase("youre_arrested_by", self.Owner:Nick()))

				if self.Owner.SteamName then
					DarkRP.log(self.Owner:Nick().." ("..self.Owner:SteamID()..") arrested "..trace.Entity:Nick(), Color(0, 255, 255))
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
