AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/clipboard.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    phys:Wake()

    self.nodupe = true

    hook.Add("PlayerDisconnected", self, self.onPlayerDisconnected)
end


function ENT:Use(activator, caller)
    local owner = self:Getowning_ent()
    local recipient = self:Getrecipient()
    local amount = self:Getamount() or 0

    if (IsValid(activator) and IsValid(recipient)) and activator == recipient then
        owner = (IsValid(owner) and owner:Nick()) or DarkRP.getPhrase("disconnected_player")
        DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("found_cheque", DarkRP.formatMoney(amount), "", owner))
        activator:addMoney(amount)
        self:Remove()
    elseif (IsValid(owner) and IsValid(recipient)) and owner ~= activator then
        DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("cheque_details", recipient:Name()))
    elseif IsValid(owner) and owner == activator then
        DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("cheque_torn"))
        owner:addMoney(self:Getamount()) -- return the money on the cheque to the owner.
        self:Remove()
    elseif not IsValid(recipient) then self:Remove()
    end
end

function ENT:Touch(ent)
    -- the .USED var is also used in other mods for the same purpose
    if ent:GetClass() ~= "darkrp_cheque" or self.USED or ent.USED or self.hasMerged or ent.hasMerged then return end
    if ent.dt.owning_ent ~= self.dt.owning_ent then return end
    if ent.dt.recipient ~= self.dt.recipient then return end

    -- Both hasMerged and USED are used by third party mods. Keep both in.
    ent.USED = true
    ent.hasMerged = true

    ent:Remove()
    self:Setamount(self:Getamount() + ent:Getamount())
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)

    local typ = dmg:GetDamageType()
    if bit.band(typ, DMG_BULLET) ~= DMG_BULLET then return end

    self.USED = true
    self.hasMerged = true
    self:Remove()
end

function ENT:onPlayerDisconnected(ply)
    if self.dt.owning_ent == ply or self.dt.recipient == ply then
        self:Remove()
    end
end
