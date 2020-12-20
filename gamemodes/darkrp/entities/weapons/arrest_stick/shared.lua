AddCSLuaFile()

if CLIENT then
    SWEP.Slot = 1
    SWEP.SlotPos = 3
end

DEFINE_BASECLASS("stick_base")

SWEP.Instructions = "Left click to arrest\nRight click to switch batons"
SWEP.IsDarkRPArrestStick = true

SWEP.PrintName = "Arrest Baton"
SWEP.Spawnable = true
SWEP.Category = "DarkRP (Utility)"

SWEP.StickColor = Color(255, 0, 0)

SWEP.Switched = true

DarkRP.hookStub{
    name = "canArrest",
    description = "Whether someone can arrest another player.",
    parameters = {
        {
            name = "arrester",
            description = "The player trying to arrest someone.",
            type = "Player"
        },
        {
            name = "arrestee",
            description = "The player being arrested.",
            type = "Player"
        }
    },
    returns = {
        {
            name = "canArrest",
            description = "A yes or no as to whether the arrester can arrest the arestee.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message that is shown when they can't arrest the player.",
            type = "string"
        }
    },
    realm = "Server"
}

DarkRP.hookStub{
    name = "setArrestStickTime",
    description = "Sets arrest time for an arrest made via the arrest stick",
    parameters = {
        {
            name = "arrest_stick",
            description = "The arrest strick weapon with which the arrestee was arrested.",
            type = "Weapon"
        },
        {
            name = "arrester",
            description = "The player trying to arrest someone.",
            type = "Player"
        },
        {
            name = "arrestee",
            description = "The player being arrested.",
            type = "Player"
        }
    },
    returns = {
        {
            name = "time",
            description = "The time to arrest the player.",
            type = "integer"
        }
    },
    realm = "Server"
}

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
    if IsValid(ent) and ent.onArrestStickUsed then
        ent:onArrestStickUsed(Owner)
        return
    end

    ent = Owner:getEyeSightHitEntity(nil, nil, function(p) return p ~= Owner and p:IsPlayer() and p:Alive() and p:IsSolid() end)

    local stickRange = self.stickRange * self.stickRange
    if not IsValid(ent) or (Owner:EyePos():DistToSqr(ent:GetPos()) > stickRange) or not ent:IsPlayer() then
        return
    end

    local canArrest, message = hook.Call("canArrest", DarkRP.hooks, Owner, ent)
    if not canArrest then
        if message then DarkRP.notify(Owner, 1, 5, message) end
        return
    end

    local time = hook.Call("setArrestStickTime", DarkRP.hooks, self, Owner, ent)
    ent:arrest(time, Owner)
    DarkRP.notify(ent, 0, 20, DarkRP.getPhrase("youre_arrested_by", Owner:Nick()))

    if Owner.SteamName then
        DarkRP.log(Owner:Nick() .. " (" .. Owner:SteamID() .. ") arrested " .. ent:Nick(), Color(0, 255, 255))
    end
end

function SWEP:startDarkRPCommand(usrcmd)
    local Owner = self:GetOwner()
    if not IsValid(Owner) then return end

    if game.SinglePlayer() and CLIENT then return end
    if usrcmd:KeyDown(IN_ATTACK2) then
        if not self.Switched and Owner:HasWeapon("unarrest_stick") then
            usrcmd:SelectWeapon(Owner:GetWeapon("unarrest_stick"))
        end
    else
        self.Switched = false
    end
end
