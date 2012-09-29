AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()

	phys:Wake()
end

function ENT:OnTakeDamage(dmg)
	self:Remove()
end

function ENT:Use(activator,caller)
	activator.DarkRPVars = activator.DarkRPVars or {}
	activator:SetSelfDarkRPVar("Energy", math.Clamp((activator.DarkRPVars.Energy or 100) + (self:GetTable().FoodEnergy or 1), 0, 100))
	umsg.Start("AteFoodIcon", activator)
	umsg.End()
	self:Remove()
	activator:EmitSound("vo/sandwicheat09.wav", 100, 100)
end
