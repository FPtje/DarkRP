AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    DarkRP.ValidatedPhysicsInit(self, SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    phys:Wake()
end

function ENT:Use(activator, caller)
    local canUse, reason = hook.Call("canDarkRPUse", nil, activator, self, caller)
    if canUse == false then
        if reason then DarkRP.notify(activator, 1, 4, reason) end
        return
    end

    hook.Call("playerPickedUpAmmo", nil, activator, self.amountGiven, self.ammoType, self)

    activator:GiveAmmo(self.amountGiven, self.ammoType)
    self:Remove()
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)
end

function ENT:StartTouch(ent)
    -- the .USED var is also used in other mods for the same purpose
    if ent.IsSpawnedAmmo ~= true or
        self.ammoType ~= ent.ammoType or
        self.hasMerged or ent.hasMerged then return end

    ent.hasMerged = true
    ent.USED = true

    local selfAmount, entAmount = self.amountGiven, ent.amountGiven
    local totalAmount = selfAmount + entAmount
    self.amountGiven = totalAmount

    ent:Remove()
end

DarkRP.hookStub{
    name = "playerPickedUpAmmo",
    description = "When a player picks up ammo.",
    parameters = {
        {
            name = "ply",
            description = "The player who picked up ammo.",
            type = "Player"
        },
        {
            name = "amount",
            description = "Ammo amount.",
            type = "number"
        },
        {
            name = "type",
            description = "Ammo type.",
            type = "number"
        },
        {
            name = "spawnedAmmo",
            description = "Entity of spawned ammo.",
            type = "Entity"
        }
    },
    returns = {
    },
}
