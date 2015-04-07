AddCSLuaFile();

if CLIENT then
	SWEP.PrintName = "Unarrest Baton"
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "fprp Developers"
SWEP.Instructions = "Left click to unarrest\nRight click to switch batons"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "stunstick"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "fprp (Utility)"

SWEP.NextStrike = 0

SWEP.ViewModel = Model("models/weapons/v_stunbaton.mdl");
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl");

SWEP.Sound = Sound("weapons/stunstick/stunstick_swing1.wav");

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:SetHoldType("normal");
end

function SWEP:Deploy()
	if SERVER then
		self:SetColor(Color(0,255,0,255));
		self:SetMaterial("models/shiny");
		local vm = self.Owner:GetViewModel();
		if not IsValid(vm) then return end
		vm:ResetSequence(vm:LookupSequence("idle01"));
	end
	return true
end

function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetColor(Color(0,255,0,255));
	self.Owner:GetViewModel():SetMaterial("models/shiny");
end

function SWEP:Holster()
	if SERVER then
		self:SetColor(Color(255,255,255,255));
		self:SetMaterial("");
		timer.Stop(self:GetClass() .. "_idle" .. self:EntIndex());
	elseif CLIENT and IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():SetColor(Color(255,255,255,255));
		self.Owner:GetViewModel():SetMaterial("");
	end
	return true
end

function SWEP:OnRemove()
	if SERVER then
		self:SetColor(Color(255,255,255,255));
		self:SetMaterial("");
		timer.Stop(self:GetClass() .. "_idle" .. self:EntIndex());
	elseif CLIENT and IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():SetColor(Color(255,255,255,255));
		self.Owner:GetViewModel():SetMaterial("");
	end
end

fprp.hookStub{
	name = "canUnarrest",
	description = "Whether someone can unarrest another player.",
	parameters = {
		{
			name = "unarrester",
			description = "The player trying to unarrest someone.",
			type = "Player"
		},
		{
			name = "unarrestee",
			description = "The player being unarrested.",
			type = "Player"
		}
	},
	returns = {
		{
			name = "canUnarrest",
			description = "A yes or no as to whether the player can unarrest the other player.",
			type = "boolean"
		},
		{
			name = "message",
			description = "The message that is shown when they can't unarrest the player.",
			type = "string"
		}
	},
	realm = "Server"
}

-- Default for canUnarrest hook
local hookCanUnarrest = {canUnarrest = fp{fn.Id, true}}

function SWEP:PrimaryAttack()
	if CurTime() < self.NextStrike then return end

	self:SetHoldType("melee");
	timer.Simple(0.3, function() if self:IsValid() then self:SetHoldType("normal") end end)

	self.NextStrike = CurTime() + 0.51 -- Actual delay is set later

	if CLIENT then return end

	timer.Stop(self:GetClass() .. "_idle" .. self:EntIndex());
	local vm = self.Owner:GetViewModel();
	if IsValid(vm) then
		vm:ResetSequence(vm:LookupSequence("idle01"));
		timer.Simple(0, function()
			if not IsValid(self) or not IsValid(self.Owner) or not IsValid(self.Owner:GetActiveWeapon()) or self.Owner:GetActiveWeapon() ~= self then return end
			self.Owner:SetAnimation(PLAYER_ATTACK1);

			if IsValid(self.Weapon) then
				self.Weapon:EmitSound(self.Sound);
			end

			local vm = self.Owner:GetViewModel();
			if not IsValid(vm) then return end
			vm:ResetSequence(vm:LookupSequence("attackch"));
			vm:SetPlaybackRate(1 + 1/3);
			local duration = vm:SequenceDuration() / vm:GetPlaybackRate();
			timer.Create(self:GetClass() .. "_idle" .. self:EntIndex(), duration, 1, function()
				if not IsValid(self) or not IsValid(self.Owner) then return end
				local vm = self.Owner:GetViewModel();
				if not IsValid(vm) then return end
				vm:ResetSequence(vm:LookupSequence("idle01"));
			end);
			self.NextStrike = CurTime() + duration
		end);
	end

	self.Owner:LagCompensation(true);
	local trace = util.QuickTrace(self.Owner:EyePos(), self.Owner:GetAimVector() * 90, {self.Owner});
	self.Owner:LagCompensation(false);
	if IsValid(trace.Entity) and trace.Entity.onUnArrestStickUsed then
		trace.Entity:onUnArrestStickUsed(self.Owner);
		return
	end

	local ent = self.Owner:getEyeSightHitEntity(nil, nil, function(p) return p ~= self.Owner and p:IsPlayer() and p:Alive() end)
	if not ent then return end

	if not IsValid(ent) or not ent:IsPlayer() or (self.Owner:EyePos():Distance(ent:GetPos()) > 90) or not ent:getfprpVar("Arrested") then
		return
	end

	local canUnarrest, message = hook.Call("canUnarrest", hookCanUnarrest, self.Owner, ent);
	if not canUnarrest then
		if message then fprp.notify(self.Owner, 1, 5, message) end
		return
	end

	ent:unArrest(self.Owner);
	fprp.notify(ent, 0, 4, fprp.getPhrase("youre_unarrested_by", self.Owner:Nick()));

	if self.Owner.SteamName then
		fprp.log(self.Owner:Nick().." ("..self.Owner:SteamID()..") unarrested "..ent:Nick(), Color(0, 255, 255));
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	if self.Owner:HasWeapon("arrest_stick") then
		self.Owner:SelectWeapon("arrest_stick");
	end
end
