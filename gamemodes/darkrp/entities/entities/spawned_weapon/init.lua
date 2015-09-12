AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()

    if not phys:IsValid() then
        self:SetModel("models/weapons/w_rif_ak47.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        phys = self:GetPhysicsObject()
    end

    phys:Wake()
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

    if self:Getamount() == 0 then
        self:Setamount(1)
    end
end

function ENT:DecreaseAmount()
    local amount = self.dt.amount

    self.dt.amount = amount - 1

    if self.dt.amount <= 0 then
        self:Remove()
        self.PlayerUse = false
        self.Removed = true -- because it is not removed immediately
    end
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)
end

function ENT:Use(activator, caller)
    if type(self.PlayerUse) == "function" then
        local val = self:PlayerUse(activator, caller)
        if val ~= nil then return val end
    elseif self.PlayerUse ~= nil then
        return self.PlayerUse
    end

    local class = self:GetWeaponClass()
    local weapon = ents.Create(class)

    if not weapon:IsValid() then return false end

    if not weapon:IsWeapon() then
        weapon:SetPos(self:GetPos())
        weapon:SetAngles(self:GetAngles())
        weapon:Spawn()
        weapon:Activate()
        self:DecreaseAmount()
        return
    end

    local ammoType = weapon:GetPrimaryAmmoType()
    local CanPickup = hook.Call("PlayerCanPickupWeapon", GAMEMODE, activator, weapon)
    local ShouldntContinue = hook.Call("PlayerPickupDarkRPWeapon", nil, activator, self, weapon)
    if not CanPickup or ShouldntContinue then return end

    local newAmmo = activator:GetAmmoCount(ammoType) -- Store ammo count before weapon pickup

    weapon:Remove()

    activator:Give(class)

    weapon = activator:GetWeapon(class)
    newAmmo = newAmmo + (self.ammoadd or 0) -- Gets rid of any ammo given during weapon pickup

    if self.clip1 then
        weapon:SetClip1(self.clip1)
        weapon:SetClip2(self.clip2 or -1)
    end

    activator:SetAmmo(newAmmo, ammoType)

    self:DecreaseAmount()

end
