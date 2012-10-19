AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/garbage_takeoutcarton001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()

	phys:Wake()

	self.damage = 10
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()

	if (self.damage <= 0) then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetMagnitude(2)
		effectdata:SetScale(2)
		effectdata:SetRadius(3)
		util.Effect("Sparks", effectdata)
		self:Remove()
	end
end

function ENT:Use(activator,caller)
	if GAMEMODE.Config.hungermod == 0 then
		caller:SetHealth(caller:Health() + (100 - caller:Health()))
	else
		caller:SetSelfDarkRPVar("Energy", math.Clamp(caller.DarkRPVars.Energy + 100, 0, 100))
		umsg.Start("AteFoodIcon", caller)
		umsg.End()
	end
	self:Remove()
end

function ENT:OnRemove()
	local ply = self.dt.owning_ent
	ply.maxFoods = ply.maxFoods and ply.maxFoods - 1 or 0
end