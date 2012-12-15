AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()

	self.dt.price = 200
	phys:Wake()

	self.sparking = false
	self.damage = 100
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()
	if (self.damage <= 0) then
		self:Destruct()
		self:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:SalePrice(activator)
	local owner = self.dt.owning_ent
	local discounted = math.ceil(185 * 0.88)

	if activator == owner and IsValid(owner) then
		if activator:Team() == TEAM_GUN then
			return discounted
		else
			return 185
		end
	else
		return self.dt.price
	end
end

ENT.Once = false
function ENT:Use(activator)
	local owner = self.dt.owning_ent
	local discounted = math.ceil(185 * 0.88)
	local cash = self:SalePrice(activator)

	if self.Once then return end

	if not activator:CanAfford(self:SalePrice(activator)) then
		GAMEMODE:Notify(activator, 1, 3, "You do not have enough money to purchase this gun.")
		return ""
	end
	local diff = (self:SalePrice(activator) - self:SalePrice(owner))
	if diff < 0 and not owner:CanAfford(math.abs(diff)) then
		GAMEMODE:Notify(activator, 2, 3, "Gun Lab owner is too poor to subsidize this sale!")
		return ""
	end
	self.sparking = true


	activator:AddMoney(cash * -1)
	GAMEMODE:Notify(activator, 0, 3, "You purchased a P228 for " .. CUR .. tostring(cash) .. "!")

	if activator ~= owner and IsValid(owner) then
		local gain = 0
		if owner:Team() == TEAM_GUN then
			gain = math.floor(self.dt.price - discounted)
		else
			gain = math.floor(self.dt.price - 185)
		end
		if gain == 0 then
			GAMEMODE:Notify(owner, 3, 3, "You sold a P228 but made no profit!")
		else
			owner:AddMoney(gain)
			local word = "profit"
			if gain < 0 then word = "loss" end
			GAMEMODE:Notify(owner, 0, 3, "You made a " .. word .. " of " .. CUR .. tostring(math.abs(gain)) .. " by selling a P228 from a Gun Lab!")
		end
	end

	self.Once = true
	timer.Create(self:EntIndex() .. "spawned_weapon", 1, 1, function()
		if not IsValid(self) then return end
		self:createGun()
	end)
end

function ENT:createGun()
	self.Once = false
	local gun = ents.Create("spawned_weapon")
	gun = ents.Create("spawned_weapon")
	gun:SetModel("models/weapons/w_pist_p228.mdl")
	gun.weaponclass = "weapon_p2282"
	local gunPos = self:GetPos()
	gun:SetPos(Vector(gunPos.x, gunPos.y, gunPos.z + 27))
	gun.ShareGravgun = true
	gun.nodupe = true
	gun:Spawn()
	self.sparking = false
end

function ENT:Think()
	if self.sparking then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end

function ENT:OnRemove()
	if not IsValid(self) then return end
	timer.Destroy(self:EntIndex() .. "spawned_weapon")
end