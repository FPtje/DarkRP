AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/money.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	self.nodupe = true
	self.ShareGravgun = true

	phys:Wake()
end


function ENT:Use(activator,caller)
	local amount = self:Getamount()

	activator:addMoney(amount or 0)
	DarkRP.notify(activator, 0, 4, DarkRP.getPhrase("found_cash", GAMEMODE.Config.currency, (self:Getamount() or 0)))
	self:Remove()
end

function ENT:Touch(ent)
	if ent:GetClass() ~= "spawned_money" or self.hasMerged or ent.hasMerged then return end

	ent.hasMerged = true

	ent:Remove()
	self:Setamount(self:Getamount() + ent:Getamount())
	if GAMEMODE.Config.moneyRemoveTime and  GAMEMODE.Config.moneyRemoveTime ~= 0 then
		timer.Adjust("RemoveEnt"..self:EntIndex(), GAMEMODE.Config.moneyRemoveTime, 1, fn.Partial(SafeRemoveEntity, self))
	end
end
