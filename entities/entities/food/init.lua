AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/garbage_takeoutcarton001a.mdl")
    DarkRP.ValidatedPhysicsInit(self, SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    self.damage = 10
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)

    self.damage = self.damage - dmg:GetDamage()

    if (self.damage <= 0) then
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetMagnitude(2)
        effectdata:SetScale(2)
        effectdata:SetRadius(3)
        util.Effect("Sparks", effectdata)
        self:Remove()
    end
end

function ENT:Use(activator, caller)
    local canUse, reason = hook.Call("canDarkRPUse", nil, activator, self, caller)
    if canUse == false then
        if reason then DarkRP.notify(activator, 1, 4, reason) end
        return
    end

    caller:setSelfDarkRPVar("Energy", 100)
    umsg.Start("AteFoodIcon", caller)
    umsg.End()

    self:Remove()
    activator:EmitSound(self.EatSound, 100, 100)
end

function ENT:OnRemove()
    local ply = self:Getowning_ent()
    ply.maxFoods = ply.maxFoods and ply.maxFoods - 1 or 0
end
