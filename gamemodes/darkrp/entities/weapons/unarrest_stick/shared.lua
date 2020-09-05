AddCSLuaFile()

if CLIENT then
    SWEP.Slot = 1
    SWEP.SlotPos = 3
end

DEFINE_BASECLASS("stick_base")

SWEP.Instructions = "Left click to unarrest\nRight click to switch batons"
SWEP.IsDarkRPUnarrestStick = true

SWEP.PrintName = "Unarrest Baton"
SWEP.Spawnable = true
SWEP.Category = "DarkRP (Utility)"

SWEP.StickColor = Color(0, 255, 0)

DarkRP.hookStub{
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

function SWEP:Deploy()
    self.Switched = true
    return BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    BaseClass.PrimaryAttack(self)

    if CLIENT then return end

    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    Owner:LagCompensation(true)
    local trace = util.QuickTrace(Owner:EyePos(), Owner:GetAimVector() * 90, {Owner})
    Owner:LagCompensation(false)

    local ent = trace.Entity
    if IsValid(ent) and ent.onUnArrestStickUsed then
        ent:onUnArrestStickUsed(Owner)
        return
    end

    ent = Owner:getEyeSightHitEntity(nil, nil, function(p) return p ~= Owner and p:IsPlayer() and p:Alive() and p:IsSolid() end)
    if not ent then return end

    local stickRange = self.stickRange * self.stickRange
    if not IsValid(ent) or not ent:IsPlayer() or (Owner:EyePos():DistToSqr(ent:GetPos()) > stickRange) or not ent:getDarkRPVar("Arrested") then
        return
    end

    local canUnarrest, message = hook.Call("canUnarrest", hookCanUnarrest, Owner, ent)
    if not canUnarrest then
        if message then DarkRP.notify(Owner, 1, 5, message) end
        return
    end

    ent:unArrest(Owner)
    DarkRP.notify(ent, 0, 4, DarkRP.getPhrase("youre_unarrested_by", Owner:Nick()))

    if Owner.SteamName then
        DarkRP.log(Owner:Nick() .. " (" .. Owner:SteamID() .. ") unarrested " .. ent:Nick(), Color(0, 255, 255))
    end
end

function SWEP:startDarkRPCommand(usrcmd)
    if game.SinglePlayer() and CLIENT then return end
    if usrcmd:KeyDown(IN_ATTACK2) then
        if not self.Switched and self:GetOwner():HasWeapon("arrest_stick") then
            usrcmd:SelectWeapon(self:GetOwner():GetWeapon("arrest_stick"))
        end
    else
        self.Switched = false
    end
end
