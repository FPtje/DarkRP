AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
end

function ENT:Use(activator, caller)
    activator:GiveAmmo(self.amountGiven, self.ammoType)
    self:Remove()
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)
end
