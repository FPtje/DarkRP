AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    if(self:Getamount() < 101)then
        self:SetModel("models/props/cs_assault/Dollar.mdl")
    elseif(self:Getamount() < 1001)then
        self:SetModel("models/props_junk/garbage_bag001a.mdl")
    elseif(self:Getamount() < 5001)then
        self:SetModel("models/props_c17/BriefCase001a.mdl")
    elseif(self:Getamount() < 10001)then
        self:SetModel("models/props_c17/SuitCase_Passenger_Physics.mdl")
    elseif(self:Getamount() < 20001 )then
        self:SetModel("models/props_c17/SuitCase001a.mdl")
    elseif(self:Getamount() < 999999 ) then
        self:SetModel("models/props/cs_office/Cardboard_box01.mdl")
    elseif(self:Getamount() > 1000000)then
        self:SetModel("models/items/cs_gift.mdl")
    end
    self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	self.nodupe = true
	self.ShareGravgun = true
    if(IsValid(phys))then
        phys:Wake()
    end
end

function ENT:Use(activator,caller)
	if self.USED or self.hasMerged then return end
	local amount = self:Getamount()
	activator:addMoney(amount or 0)
	DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("found_money", DarkRP.formatMoney(self:Getamount())))
	self:Remove()
end

function ENT:Touch(ent)
	if ent:GetClass() ~= "spawned_money" or self.USED or ent.USED or self.hasMerged or ent.hasMerged then return end
	ent.USED = true
	ent.hasMerged = true
	ent:Remove()
	self:Setamount(self:Getamount() + ent:Getamount())
end

DarkRP.hookStub{
    name = "playerPickedUpMoney",
    description = "Called when a player picked up money.",
    parameters = {
        {
            name = "player",
            description = "The player who picked up the money.",
            type = "Player"
        },
        {
            name = "amount",
            description = "The amount of money picked up.",
            type = "number"
        },
        {
            name = "entity",
            description = "The entity of the money picked up itself.",
            type = "Entity"
        }
    },
    returns = {
    },
    realm = "Server"
}

DarkRP.hookStub{
    name = "canDarkRPUse",
    description = "When a player uses an entity.",
    parameters = {
        {
            name = "ply",
            description = "The player who tries to use the entity.",
            type = "Player"
        },
        {
            name = "entity",
            description = "The actual entity the player attempts to use.",
            type = "Entity"
        },
    },
    returns = {
        {
            name = "canUse",
            description = "Whether the entity should be used or not.",
            type = "boolean"
        },
        {
            name = "reason",
            description = "Why the entity cannot be used.",
            optional = true,
            type = "string"
        },
    },
}
