AddCSLuaFile()

if SERVER then
    AddCSLuaFile("cl_menu.lua")
end

if CLIENT then
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false

    include("cl_menu.lua")
end

SWEP.PrintName = "Keys"
SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to lock\nRight click to unlock\nReload for door settings or animation menu"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IsDarkRPKeys = true

SWEP.WorldModel = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"
SWEP.Sound = "doors/door_latch3.wav"

SWEP.Primary.Delay = 0.3
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.Delay = 0.3
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    if CLIENT or not IsValid(self:GetOwner()) then return true end
    self:GetOwner():DrawWorldModel(false)
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:PreDrawViewModel()
    return true
end

local function lookingAtLockable(ply, ent, hitpos)
    local eyepos = ply:EyePos()
    return IsValid(ent)
        and ent:isKeysOwnable()
        and (
            ent:isDoor() and eyepos:DistToSqr(hitpos) < 2000
            or
            ent:IsVehicle() and eyepos:DistToSqr(hitpos) < 4000
        )
end

local function lockUnlockAnimation(ply, snd)
    ply:EmitSound("npc/metropolice/gear" .. math.random(1, 6) .. ".wav")
    timer.Simple(0.9, function() if IsValid(ply) then ply:EmitSound(snd) end end)

    umsg.Start("anim_keys")
        umsg.Entity(ply)
        umsg.String("usekeys")
    umsg.End()

    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
end

local function doKnock(ply, sound)
    ply:EmitSound(sound, 100, math.random(90, 110))

    umsg.Start("anim_keys")
        umsg.Entity(ply)
        umsg.String("knocking")
    umsg.End()

    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
end

function SWEP:PrimaryAttack()
    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    local trace = Owner:GetEyeTrace()

    if not lookingAtLockable(Owner, trace.Entity, trace.HitPos) then return end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if CLIENT then return end

    if Owner:canKeysLock(trace.Entity) then
        trace.Entity:keysLock() -- Lock the door immediately so it won't annoy people
        lockUnlockAnimation(Owner, self.Sound)
    elseif trace.Entity:IsVehicle() then
        DarkRP.notify(Owner, 1, 3, DarkRP.getPhrase("do_not_own_ent"))
    else
        doKnock(Owner, "physics/wood/wood_crate_impact_hard2.wav")
    end
end

function SWEP:SecondaryAttack()
    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    local trace = Owner:GetEyeTrace()

    if not lookingAtLockable(Owner, trace.Entity, trace.HitPos) then return end

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

    if CLIENT then return end

    if Owner:canKeysUnlock(trace.Entity) then
        trace.Entity:keysUnLock() -- Unlock the door immediately so it won't annoy people
        lockUnlockAnimation(Owner, self.Sound)
    elseif trace.Entity:IsVehicle() then
        DarkRP.notify(Owner, 1, 3, DarkRP.getPhrase("do_not_own_ent"))
    else
        doKnock(Owner, "physics/wood/wood_crate_impact_hard3.wav")
    end
end

function SWEP:Reload()
    local trace = self:GetOwner():GetEyeTrace()
    if not IsValid(trace.Entity) or ((not trace.Entity:isDoor() and not trace.Entity:IsVehicle()) or self:GetOwner():EyePos():DistToSqr(trace.HitPos) > 40000) then
        if CLIENT and not DarkRP.disabledDefaults["modules"]["animations"] then RunConsoleCommand("_DarkRP_AnimationMenu") end
        return
    end
    if SERVER then
        umsg.Start("KeysMenu", self:GetOwner())
        umsg.End()
    end
end
