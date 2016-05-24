AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    phys:Wake()
end

function ENT:OnTakeDamage(dmg)
    self:Remove()
end

function ENT:Use(activator, caller)
    local canUse, reason = hook.Call("canDarkRPUse", nil, activator, self)
    if canUse == false then
      if reason then DarkRP.notify(activator, 1, 4, reason) end
      return
    end

    local override = self.foodItem.onEaten and self.foodItem.onEaten(self, activator, self.foodItem)

    if override then
        self:Remove()
        return
    end

    activator:setSelfDarkRPVar("Energy", math.Clamp((activator:getDarkRPVar("Energy") or 100) + (self:GetTable().FoodEnergy or 1), 0, 100))
    umsg.Start("AteFoodIcon", activator)
    umsg.End()
    self:Remove()
    activator:EmitSound("vo/sandwicheat09.mp3", 100, 100)
end
