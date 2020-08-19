AddCSLuaFile()

if CLIENT then
    SWEP.Slot = 5
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server
DEFINE_BASECLASS("weapon_cs_base2")

SWEP.PrintName = "Battering Ram"
SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to break open doors/unfreeze props or get people out of their vehicles\nRight click to raise"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IsDarkRPDoorRam = true

SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_rpg.mdl")
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl")
SWEP.AnimPrefix = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = 0     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false     -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

--[[---------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------]]
function SWEP:Initialize()
    if CLIENT then self.LastIron = CurTime() end
    self:SetHoldType("normal")
end

function SWEP:Holster()
    self:SetIronsights(false)

    return true
end

-- Check whether an object of this player can be rammed
local function canRam(ply)
    return IsValid(ply) and (ply.warranted == true or ply:isWanted() or ply:isArrested())
end

-- Ram action when ramming a door
local function ramDoor(ply, trace, ent)
    if ply:EyePos():DistToSqr(trace.HitPos) > 2025 or (not GAMEMODE.Config.canforcedooropen and ent:getKeysNonOwnable()) then return false end

    local allowed = false

    -- if we need a warrant to get in
    if GAMEMODE.Config.doorwarrants and ent:isKeysOwned() and not ent:isKeysOwnedBy(ply) then
        -- if anyone who owns this door has a warrant for their arrest
        -- allow the police to smash the door in
        for _, v in ipairs(player.GetAll()) do
            if ent:isKeysOwnedBy(v) and canRam(v) then
                allowed = true
                break
            end
        end
    else
        -- door warrants not needed, allow warrantless entry
        allowed = true
    end

    -- Be able to open the door if any member of the door group is warranted
    local keysDoorGroup = ent:getKeysDoorGroup()
    if GAMEMODE.Config.doorwarrants and keysDoorGroup then
        local teamDoors = RPExtraTeamDoors[keysDoorGroup]
        if teamDoors then
            allowed = false
            for _, v in ipairs(player.GetAll()) do
                if table.HasValue(teamDoors, v:Team()) and canRam(v) then
                    allowed = true
                    break
                end
            end
        end
    end

    if CLIENT then return allowed end

    -- Do we have a warrant for this player?
    if not allowed then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("warrant_required"))

        return false
    end

    ent:keysUnLock()
    ent:Fire("open", "", .6)
    ent:Fire("setanimation", "open", .6)

    return true
end

-- Ram action when ramming a vehicle
local function ramVehicle(ply, trace, ent)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end

    if CLIENT then return false end -- Ideally this would return true after ent:GetDriver() check

    local driver = ent:GetDriver()
    if not IsValid(driver) or not driver.ExitVehicle then return false end

    driver:ExitVehicle()
    ent:keysLock()

    return true
end

-- Ram action when ramming a fading door
local function ramFadingDoor(ply, trace, ent)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end

    local Owner = ent:CPPIGetOwner()

    if CLIENT then return canRam(Owner) end

    if not canRam(Owner) then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("warrant_required"))
        return false
    end

    if not ent.fadeActive then
        ent:fadeActivate()
        timer.Simple(5, function() if IsValid(ent) and ent.fadeActive then ent:fadeDeactivate() end end)
    end

    return true
end

-- Ram action when ramming a frozen prop
local function ramProp(ply, trace, ent)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end
    if ent:GetClass() ~= "prop_physics" then return false end

    local Owner = ent:CPPIGetOwner()

    if CLIENT then return canRam(Owner) end

    if not canRam(Owner) then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase(GAMEMODE.Config.copscanunweld and "warrant_required_unweld" or "warrant_required_unfreeze"))
        return false
    end

    if GAMEMODE.Config.copscanunweld then
        constraint.RemoveConstraints(ent, "Weld")
    end

    if GAMEMODE.Config.copscanunfreeze then
        ent:GetPhysicsObject():EnableMotion(true)
    end

    return true
end

-- Decides the behaviour of the ram function for the given entity
local function getRamFunction(ply, trace)
    local ent = trace.Entity

    if not IsValid(ent) then return fp{fn.Id, false} end

    local override = hook.Call("canDoorRam", nil, ply, trace, ent)

    return
        override ~= nil     and fp{fn.Id, override}                                 or
        ent:isDoor()        and fp{ramDoor, ply, trace, ent}                        or
        ent:IsVehicle()     and fp{ramVehicle, ply, trace, ent}                     or
        ent.fadeActivate    and fp{ramFadingDoor, ply, trace, ent}                  or
        ent:GetPhysicsObject():IsValid() and not ent:GetPhysicsObject():IsMoveable()
                                         and fp{ramProp, ply, trace, ent}           or
        fp{fn.Id, false} -- no ramming was performed
end

--[[---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
    if not self:GetIronsights() then return end

    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    self:SetNextPrimaryFire(CurTime() + 0.1)

    Owner:LagCompensation(true)
    local trace = Owner:GetEyeTrace()
    Owner:LagCompensation(false)

    local hasRammed = getRamFunction(Owner, trace)()

    if SERVER then
        hook.Call("onDoorRamUsed", GAMEMODE, hasRammed, Owner, trace)
    end

    if not hasRammed then return end

    self:SetNextPrimaryFire(CurTime() + 2.5)

    self:SetTotalUsedMagCount(self:GetTotalUsedMagCount() + 1)

    Owner:SetAnimation(PLAYER_ATTACK1)
    Owner:EmitSound(self.Sound)
    Owner:ViewPunch(Angle(-10, math.Round(util.SharedRandom("DarkRP_DoorRam" .. self:EntIndex() .. "_" .. self:GetTotalUsedMagCount(), -5, 5)), 0))
end

function SWEP:SecondaryAttack()
    if CLIENT then self.LastIron = CurTime() end
    self:SetNextSecondaryFire(CurTime() + 0.30)
    self:SetIronsights(not self:GetIronsights())
    if self:GetIronsights() then
        self:SetHoldType("rpg")
    else
        self:SetHoldType("normal")
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    local Mul = 1

    if self.LastIron > CurTime() - 0.25 then
        Mul = math.Clamp((CurTime() - self.LastIron) / 0.25, 0, 1)
    end

    if self:GetIronsights() then
        Mul = 1-Mul
    end

    ang:RotateAroundAxis(ang:Right(), - 15 * Mul)
    return pos,ang
end

DarkRP.hookStub{
    name = "canDoorRam",
    description = "Called when a player attempts to ram something. Use this to override ram behaviour or to disallow ramming.",
    parameters = {
        {
            name = "ply",
            description = "The player using the door ram.",
            type = "Player"
        },
        {
            name = "trace",
            description = "The trace containing information about the hit position and ram entity.",
            type = "table"
        },
        {
            name = "ent",
            description = "Short for the entity that is about to be hit by the door ram.",
            type = "Entity"
        }
    },
    returns = {
        {
            name = "override",
            description = "Return true to override behaviour, false to disallow ramming and nil (or no value) to defer the decision.",
            type = "boolean"
        }
    },
    realm = "Shared"
}

if SERVER then
    DarkRP.hookStub{
        name = "onDoorRamUsed",
        description = "Called when the door ram has been used.",
        parameters = {
            {
                name = "success",
                description = "Whether the door ram has been successful in ramming.",
                type = "boolean"
            },
            {
                name = "ply",
                description = "The player that used the door ram.",
                type = "Player"
            },
            {
                name = "trace",
                description = "The trace containing information about the hit position and ram entity.",
                type = "table"
            }
        },
        returns = {

        }
    }
end

hook.Add("SetupMove", "DarkRP_DoorRamJump", function(ply, mv)
    local wep = ply:GetActiveWeapon()
    if not wep:IsValid() or wep:GetClass() ~= "door_ram" or not wep.GetIronsights or not wep:GetIronsights() then return end

    mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
end)
