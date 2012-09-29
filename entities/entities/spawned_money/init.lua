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
	local amount = self.dt.amount

	activator:AddMoney(amount or 0)
	GAMEMODE:Notify(activator, 0, 4, "You have found " .. CUR .. (self.dt.amount or 0) .. "!")
	self:Remove()
end

function DarkRPCreateMoneyBag(pos, amount)
	local moneybag = ents.Create("spawned_money")
	moneybag:SetPos(pos)
	moneybag.dt.amount = amount
	moneybag:Spawn()
	moneybag:Activate()
	return moneybag
end

function ENT:Touch(ent)
	if ent:GetClass( ) ~= "spawned_money" or self.hasMerged or ent.hasMerged then return end

	ent.hasMerged = true

	ent:Remove()
	self.dt.amount = self.dt.amount + ent.dt.amount
end