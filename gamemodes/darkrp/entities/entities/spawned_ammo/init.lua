AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
end

function ENT:Use(activator, caller)
    local canUse, reason = hook.Call("canDarkRPUse", nil, activator, self)
    if canUse == false then
      if reason then DarkRP.notify(activator, 1, 4, reason) end
      return
    end

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
