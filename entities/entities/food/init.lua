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
		SafeRemoveEntity(self)
	end
end

function ENT:Use(activator,caller)
	local override = self.foodItem and self.foodItem.onEaten and self.foodItem.onEaten(self, activator, self.foodItem) or isfunction(self.onEaten) and self.onEaten(self, activator, self.foodItem)

	if override then
		SafeRemoveEntity(self)
		return
	end
	
	caller:setSelfDarkRPVar("Energy", GAMEMODE.Config.maxhunger)
	umsg.Start("AteFoodIcon", caller)
	umsg.End()

	activator:EmitSound("vo/sandwicheat09.mp3", 100, 100)
	SafeRemoveEntity(self)
end

function ENT:OnRemove()
	local ply = self:Getowning_ent()
	ply.maxFoods = ply.maxFoods and ply.maxFoods - 1 or 0
end
