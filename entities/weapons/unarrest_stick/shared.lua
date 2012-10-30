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

SWEP.Author = "Rick Darkaliono, philxyz"
SWEP.Instructions = "Left or right click to unarrest"
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
	self:SetWeaponHoldType("normal")
end

function SWEP:Deploy()
	if CLIENT or not IsValid(self:GetOwner()) then return end
	self:SetColor(Color(0,255,0,255))
	self:SetMaterial("models/shiny")
	SendUserMessage("StunStickColour", self:GetOwner(), 0,255,0, "models/shiny")
	return true
end

function SWEP:Holster()
	if CLIENT or not IsValid(self:GetOwner()) then return end
	SendUserMessage("StunStickColour", self:GetOwner(), 255, 255, 255, "")
	return true
end

function SWEP:OnRemove()
	if SERVER and IsValid(self:GetOwner()) then
		SendUserMessage("StunStickColour", self:GetOwner(), 255, 255, 255, "")
	end
end

usermessage.Hook("StunStickColour", function(um)
	local viewmodel = LocalPlayer():GetViewModel()
	if not IsValid(viewmodel) then return end
	local r,g,b,a = um:ReadLong(), um:ReadLong(), um:ReadLong(), 255
	viewmodel:SetColor(Color(r,g,b,a))
	viewmodel:SetMaterial(um:ReadString())
end)

function SWEP:PrimaryAttack()
	if CurTime() < self.NextStrike then return end

	self:SetWeaponHoldType("melee")
	timer.Simple(0.3, function() if self:IsValid() then self:SetWeaponHoldType("normal") end end)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

	self.NextStrike = CurTime() + .4

	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 115) or not trace.Entity.DarkRPVars.Arrested then
		return
	end

	trace.Entity:Unarrest()
	GAMEMODE:Notify(trace.Entity, 0, 4, "You were unarrested by " .. self.Owner:Nick())

	if self.Owner.SteamName then
		DB.Log(self.Owner:SteamName().." ("..self.Owner:SteamID()..") unarrested "..trace.Entity:Nick(), nil, Color(0, 255, 255))
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end
