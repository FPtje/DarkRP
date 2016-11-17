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

function ENT:StartTouch(ent)
    -- the .USED var is also used in other mods for the same purpose
    if ent.IsSpawnedWeapon ~= true or
        self:GetWeaponClass() ~= ent:GetWeaponClass() or
        self.hasMerged or ent.hasMerged then return end

    ent.hasMerged = true
    ent.USED = true

    local selfAmount, entAmount = self:Getamount(), ent:Getamount()
    local totalAmount = selfAmount + entAmount
    self.ammoadd, ent.ammoadd = self.ammoadd or 0, ent.ammoadd or 0

    -- ammoAdd will be the floored average of both weapons' ammoadd
    -- Some ammo might get lost there.
    self.ammoadd = math.floor((self.ammoadd * selfAmount + ent.ammoadd * entAmount) / totalAmount)

    -- If neither have a clip, use default clip, otherwise merge the two
    if self.clip1 or ent.clip1 then
        self.clip1 = math.floor(((self.clip1 or 0) * selfAmount + (ent.clip1 or 0) * entAmount) / totalAmount)
    end

    if self.clip2 or ent.clip2 then
        self.clip2 = math.floor(((self.clip2 or 0) * selfAmount + (ent.clip2 or 0) * entAmount) / totalAmount)
    end

    self:Setamount(totalAmount)
    ent:Remove()
end
