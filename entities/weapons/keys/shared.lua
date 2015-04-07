AddCSLuaFile();

if SERVER then
	AddCSLuaFile("cl_menu.lua");
end

if CLIENT then
	SWEP.PrintName = "Keys"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false

	include("cl_menu.lua");
end

SWEP.Author = "fprp Developers"
SWEP.Instructions = "Left click to lock\nRight click to unlock\nReload for door settings or animation menu"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.WorldModel	= ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "fprp (Utility)"
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
	self:SetHoldType("normal");
end

function SWEP:Deploy()
	if CLIENT or not IsValid(self.Owner) then return true end
	self.Owner:DrawWorldModel(false);
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:PreDrawViewModel()
	return true
end

local function lookingAtLockable(ply, ent)
	local eyepos = ply:EyePos();
	return IsValid(ent) 			and
		ent:isKeysOwnable() 		and
		not ent:getKeysNonOwnable()	and
		(
			ent:isDoor() 	and eyepos:Distance(ent:GetPos()) < 65
			or
			ent:IsVehicle() and eyepos:Distance(ent:NearestPoint(eyepos)) < 100
		);

end

local function lockUnlockAnimation(ply, snd)
	ply:EmitSound("npc/metropolice/gear" .. math.floor(math.Rand(1,7)) .. ".wav");
	timer.Simple(0.9, function() if IsValid(ply) then ply:EmitSound(snd) end end)

	local RP = RecipientFilter();
	RP:AddAllPlayers();

	umsg.Start("anim_keys", RP);
		umsg.Entity(ply);
		umsg.String("usekeys");
	umsg.End();

	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true);
end

local function doKnock(ply, sound)
	ply:EmitSound(sound, 100, math.random(90, 110));
	umsg.Start("anim_keys", RP);
		umsg.Entity(ply);
		umsg.String("knocking");
	umsg.End();

	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true);
end

function SWEP:PrimaryAttack()
	local trace = self.Owner:GetEyeTrace();

	if not lookingAtLockable(self.Owner, trace.Entity) then return end

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.3);

	if CLIENT then return end

	if self.Owner:canKeysLock(trace.Entity) then
		trace.Entity:keysLock() -- Lock the door immediately so it won't annoy people
		lockUnlockAnimation(self.Owner, self.Sound);
	elseif trace.Entity:IsVehicle() then
		fprp.notify(self.Owner, 1, 3, fprp.getPhrase("do_not_own_ent"));
	else
		doKnock(self.Owner, "physics/wood/wood_crate_impact_hard2.wav");
	end
end

function SWEP:SecondaryAttack()
	local trace = self.Owner:GetEyeTrace();

	if not lookingAtLockable(self.Owner, trace.Entity) then return end

	self.Weapon:SetNextSecondaryFire(CurTime() + 0.3);

	if CLIENT then return end

	if self.Owner:canKeysUnlock(trace.Entity) then
		trace.Entity:keysUnLock() -- Unlock the door immediately so it won't annoy people
		lockUnlockAnimation(self.Owner, self.Sound);
	elseif trace.Entity:IsVehicle() then
		fprp.notify(self.Owner, 1, 3, fprp.getPhrase("do_not_own_ent"));
	else
		doKnock(self.Owner, "physics/wood/wood_crate_impact_hard3.wav");
	end
end

SWEP.OnceReload = false
function SWEP:Reload()
	local trace = self.Owner:GetEyeTrace();
	if not IsValid(trace.Entity) or (IsValid(trace.Entity) and ((not trace.Entity:isDoor() and not trace.Entity:IsVehicle()) or self.Owner:EyePos():Distance(trace.HitPos) > 200)) then
		if CLIENT then RunConsoleCommand("_fprp_AnimationMenu") end
		return
	end
	if SERVER then
		umsg.Start("KeysMenu", self.Owner);
		umsg.End();
	end
end
