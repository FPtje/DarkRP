AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()

	phys:Wake()
end

function ENT:OnTakeDamage(dmg)
	SafeRemoveEntity(self)
end

function ENT:Use(activator, caller)
	local override = self.foodItem.onEaten and self.foodItem.onEaten(self, activator, self.foodItem)

	if override then
		SafeRemoveEntity(self)
		return
	end

	activator:setSelfDarkRPVar("Energy", math.Clamp((activator:getDarkRPVar("Energy") or 100) + (self.FoodEnergy or 1), 0, GAMEMODE.Config.maxhunger))
	umsg.Start("AteFoodIcon", activator)
	umsg.End()
	activator:EmitSound("vo/sandwicheat09.mp3", 100, 100)
	SafeRemoveEntity(self)
end
