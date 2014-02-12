if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_menu.lua")
end

if CLIENT then
	SWEP.PrintName = "Keys"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false

	include("cl_menu.lua")
end

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to lock\nRight click to unlock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModel = Model("models/weapons/v_hands.mdl")
SWEP.WorldModel	= ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"
SWEP.Sound = "doors/door_latch3.wav"
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
	if CLIENT or not IsValid(self.Owner) then return true end
	self.Owner:DrawWorldModel(false)
	return true
end

function SWEP:PreDrawViewModel()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetMaterial("debug/hsv")
end

function SWEP:Holster()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return true end
	self.Owner:GetViewModel():SetMaterial("")
	return true
end

function SWEP:OnRemove()
	if SERVER or not IsValid(self.Owner) or not IsValid(self.Owner:GetViewModel()) then return end
	self.Owner:GetViewModel():SetMaterial("")
end

local function lookingAtLockable(ply, ent)
	local eyepos = ply:EyePos()
	return IsValid(ent) 			and
		ent:isKeysOwnable() 		and
		not ent:getKeysNonOwnable()	and
		(
			ent:isDoor() 	and eyepos:Distance(ent:GetPos()) < 65
			or
			ent:IsVehicle() and eyepos:Distance(ent:NearestPoint(eyepos)) < 100
		)

end

local function lockUnlockAnimation(ply, snd)
	ply:EmitSound("npc/metropolice/gear" .. math.floor(math.Rand(1,7)) .. ".wav")
	timer.Simple(0.9, function() if IsValid(ply) then ply:EmitSound(snd) end end)

	local RP = RecipientFilter()
	RP:AddAllPlayers()

	umsg.Start("anim_keys", RP)
		umsg.Entity(ply)
		umsg.String("usekeys")
	umsg.End()

	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
end

local function doKnock(ply, sound)
	ply:EmitSound(sound, 100, math.random(90, 110))
	umsg.Start("anim_keys", RP)
		umsg.Entity(ply)
		umsg.String("knocking")
	umsg.End()

	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
end

function SWEP:PrimaryAttack()
	local trace = self.Owner:GetEyeTrace()

	if not lookingAtLockable(self.Owner, trace.Entity) then
		if CLIENT then RunConsoleCommand("_DarkRP_AnimationMenu") end
		return
	end

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)

	if CLIENT then return end

	if self.Owner:canKeysLock(trace.Entity) then
		trace.Entity:keysLock() -- Lock the door immediately so it won't annoy people
		lockUnlockAnimation(self.Owner, self.Sound)
	elseif trace.Entity:IsVehicle() then
		DarkRP.notify(self.Owner, 1, 3, DarkRP.getPhrase("do_not_own_ent"))
	else
		doKnock(self.Owner, "physics/wood/wood_crate_impact_hard2.wav")
	end
end

function SWEP:SecondaryAttack()
	local trace = self.Owner:GetEyeTrace()

	if not lookingAtLockable(self.Owner, trace.Entity) then
		if CLIENT then RunConsoleCommand("_DarkRP_AnimationMenu") end
		return
	end

	self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)

	if CLIENT then return end

	if self.Owner:canKeysUnlock(trace.Entity) then
		trace.Entity:keysUnLock() -- Unlock the door immediately so it won't annoy people
		lockUnlockAnimation(self.Owner, self.Sound)
	elseif trace.Entity:IsVehicle() then
		DarkRP.notify(self.Owner, 1, 3, DarkRP.getPhrase("do_not_own_ent"))
	else
		doKnock(self.Owner, "physics/wood/wood_crate_impact_hard3.wav")
	end
end

SWEP.OnceReload = false
function SWEP:Reload()
	local trace = self.Owner:GetEyeTrace()
	if not IsValid(trace.Entity) or (IsValid(trace.Entity) and ((not trace.Entity:isDoor() and not trace.Entity:IsVehicle()) or self.Owner:EyePos():Distance(trace.HitPos) > 200)) then
		if not self.OnceReload then
			if SERVER then DarkRP.notify(self.Owner, 1, 3, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle"))) end
			self.OnceReload = true
			timer.Simple(3, function() self.OnceReload = false end)
		end
		return
	end
	if SERVER then
		umsg.Start("KeysMenu", self.Owner)
		umsg.End()
	end
end
