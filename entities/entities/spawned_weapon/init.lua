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
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

	self:Setamount(1)
end

function ENT:DecreaseAmount()
	local amount = self.dt.amount

	self.dt.amount = amount - 1

	if self.dt.amount == 0 then
		self:Remove()
	end
end

function ENT:Use(activator, caller)
	if type(self.PlayerUse) == "function" then
		local val = self:PlayerUse(activator, caller)
		if val ~= nil then return val end
	elseif self.PlayerUse ~= nil then
		return self.PlayerUse
	end

	local class = self.weaponclass
	local weapon = ents.Create(class)

	if not weapon:IsValid() then return false end

	if not weapon:IsWeapon() then
		weapon:SetPos(self:GetPos())
		weapon:SetAngles(self:GetAngles())
		weapon:Spawn()
		weapon:Activate()
		self:DecreaseAmount()
		return
	end

	local CanPickup = hook.Call("PlayerCanPickupWeapon", GAMEMODE, activator, weapon)
	if not CanPickup then return end
	weapon:Remove()

	activator:Give(class)
	weapon = activator:GetWeapon(class)

	if self.clip1 then
		weapon:SetClip1(self.clip1)
		weapon:SetClip2(self.clip2 or -1)
	end

	activator:GiveAmmo(self.ammoadd or 0, weapon:GetPrimaryAmmoType())

	self:DecreaseAmount()
end
