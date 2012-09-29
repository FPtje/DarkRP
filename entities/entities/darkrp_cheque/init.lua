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
	self.nodupe = true
	self.ShareGravgun = true

	phys:Wake()
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
end


function ENT:Use(activator, caller)
	local owner = self.dt.owning_ent
	local recipient = self.dt.recipient
	local amount = self.dt.amount or 0

	if (IsValid(activator) and IsValid(recipient)) and activator == recipient then
		owner = (IsValid(owner) and owner:Nick()) or "Disconnected player"
		GAMEMODE:Notify(activator, 0, 4, "You have found " .. CUR .. amount .. " in a cheque made out to you from " .. owner .. ".")
		activator:AddMoney(amount)
		self:Remove()
	elseif (IsValid(owner) and IsValid(recipient)) and owner ~= activator then
		GAMEMODE:Notify(activator, 0, 4, "This cheque is made out to " .. recipient:Name() .. ".")
	elseif IsValid(owner) and owner == activator then
		GAMEMODE:Notify(activator, 0, 4, "You have torn up the cheque.")
		owner:AddMoney(self.dt.amount) -- return the money on the cheque to the owner.
		self:Remove()
	elseif not IsValid(recipient) then self:Remove()
	end
end