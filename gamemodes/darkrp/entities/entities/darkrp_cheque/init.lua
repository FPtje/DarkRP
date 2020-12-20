AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/clipboard.mdl")
    DarkRP.ValidatedPhysicsInit(self, SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self.nodupe = true

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    hook.Add("PlayerDisconnected", self, self.onPlayerDisconnected)
end

function ENT:Use(activator, caller)
    local canUse, reason = hook.Call("canDarkRPUse", nil, activator, self, caller)
    if canUse == false then
        if reason then DarkRP.notify(activator, 1, 4, reason) end
        return
    end

    local owner = self:Getowning_ent()
    local recipient = self:Getrecipient()
    local amount = self:Getamount() or 0

    if (IsValid(activator) and IsValid(recipient)) and activator == recipient then
        owner = (IsValid(owner) and owner:Nick()) or DarkRP.getPhrase("disconnected_player")
        DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("found_cheque", DarkRP.formatMoney(amount), "", owner))
        activator:addMoney(amount)
        hook.Call("playerPickedUpCheque", nil, activator, recipient, amount or 0, true, self)
        self:Remove()
    elseif (IsValid(owner) and IsValid(recipient)) and owner ~= activator then
        DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("cheque_details", recipient:Nick()))
        hook.Call("playerPickedUpCheque", nil, activator, recipient, amount or 0, false, self)
    elseif IsValid(owner) and owner == activator then
        DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("cheque_torn"))
        owner:addMoney(self:Getamount()) -- return the money on the cheque to the owner.
        hook.Call("playerToreUpCheque", nil, activator, recipient, amount, self)
        self:Remove()
    elseif not IsValid(recipient) then self:Remove()
    end
end

function ENT:StartTouch(ent)
    -- the .USED var is also used in other mods for the same purpose
    if ent:GetClass() ~= "darkrp_cheque" or self.USED or ent.USED or self.hasMerged or ent.hasMerged then return end
    if ent:Getowning_ent() ~= self:Getowning_ent() then return end
    if ent:Getrecipient() ~= self:Getrecipient() then return end

    -- Both hasMerged and USED are used by third party mods. Keep both in.
    ent.USED = true
    ent.hasMerged = true

    ent:Remove()
    self:Setamount(self:Getamount() + ent:Getamount())
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)

    local typ = dmg:GetDamageType()
    if bit.band(typ, bit.bor(DMG_FALL, DMG_VEHICLE, DMG_DROWN, DMG_RADIATION, DMG_PHYSGUN)) > 0 then return end

    self.USED = true
    self.hasMerged = true
    self:Remove()
end

function ENT:onPlayerDisconnected(ply)
    if self:Getowning_ent() == ply or self:Getrecipient() == ply then
        self:Remove()
    end
end

DarkRP.hookStub{
    name = "playerPickedUpCheque",
    description = "Called when a player picks up a cheque.",
    parameters = {
        {
            name = "player",
            description = "The player who attempted to pick up the cheque.",
            type = "Player"
        },
        {
            name = "player",
            description = "The player who the cheque was written to.",
            type = "Player"
        },
        {
            name = "amount",
            description = "The amount of money the cheque has.",
            type = "number"
        },
        {
            name = "success",
            description = "Whether the player was allowed to cash the cheque.",
            type = "bool"
        },
        {
            name = "entity",
            description = "The entity of the cheque.",
            type = "Entity"
        }
    },
    returns = {
    },
    realm = "Server"
}

DarkRP.hookStub{
    name = "playerToreUpCheque",
    description = "Called when a player tears up a cheque.",
    parameters = {
        {
            name = "player",
            description = "The player who tore up the cheque.",
            type = "Player"
        },
        {
            name = "player",
            description = "The player who the cheque was written to.",
            type = "Player"
        },
        {
            name = "amount",
            description = "The amount of money the cheque has.",
            type = "number"
        },
        {
            name = "entity",
            description = "The entity of the cheque.",
            type = "Entity"
        }
    },
    returns = {
    },
    realm = "Server"
}
