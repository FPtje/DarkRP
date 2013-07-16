AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_office/microwave.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	phys:Wake()
	self.sparking = false
	self.damage = 100
	self:Setprice(math.Clamp((GAMEMODE.Config.pricemin ~= 0 and GAMEMODE.Config.pricemin) or 30, (GAMEMODE.Config.pricecap ~= 0 and GAMEMODE.Config.pricecap) or 30))
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
	local owner = self:Getowning_ent()
	local discounted = math.ceil(GAMEMODE.Config.microwavefoodcost * 0.82)

	if activator == owner then
		-- If they are still a cook, sell them the food at the discounted rate
		if self.allowed and type(self.allowed) == "table" and table.HasValue(self.allowed, activator:Team()) then
			return discounted
		else -- Otherwise, sell it to them at full price
			return math.floor(GAMEMODE.Config.microwavefoodcost)
		end
	else
		return self:Getprice()
	end
end

ENT.Once = false
function ENT:Use(activator,caller)
	local owner = self:Getowning_ent()
	self.user = activator
	if not activator:CanAfford(self:SalePrice(activator)) then
		GAMEMODE:Notify(activator, 1, 3, "You do not have enough money to purchase food!")
		return ""
	end
	local diff = (self:SalePrice(activator) - self:SalePrice(owner))
	if diff < 0 and not owner:CanAfford(math.abs(diff)) then
		GAMEMODE:Notify(activator, 2, 3, "Microwave owner is too poor to subsidize this sale!")
		return ""
	end
	if activator.maxFoods and activator.maxFoods >= GAMEMODE.Config.maxfoods then
		GAMEMODE:Notify(activator, 1, 3, "You have reached the food limit.")
	elseif not self.Once then
		self.Once = true
		self.sparking = true

		local discounted = math.ceil(GAMEMODE.Config.microwavefoodcost * 0.82)
		local cash = self:SalePrice(activator)

		activator:AddMoney(cash * -1)
		GAMEMODE:Notify(activator, 0, 3, "You have purchased food for " .. GAMEMODE.Config.currency .. tostring(cash) .. "!")

		if activator ~= owner then
			local gain = 0
			if self.allowed and type(self.allowed) == "table" and table.HasValue(self.allowed, owner:Team()) then
				gain = math.floor(self:Getprice() - discounted)
			else
				gain = math.floor(self:Getprice() - GAMEMODE.Config.microwavefoodcost)
			end
			if gain == 0 then
				GAMEMODE:Notify(owner, 2, 3, "You sold some food but made no profit!")
			else
				owner:AddMoney(gain)
				local word = "profit"
				if gain < 0 then word = "loss" end
				GAMEMODE:Notify(owner, 0, 3, "You made a " .. word .. " of " .. GAMEMODE.Config.currency .. tostring(math.abs(gain)) .. " by selling food!")
			end
		end
		timer.Create(self:EntIndex() .. "food", 1, 1, function() self:createFood() end)
	end
end

function ENT:createFood()
	activator = self.user
	self.Once = false
	local foodPos = self:GetPos()
	food = ents.Create("food")
	food:SetPos(Vector(foodPos.x,foodPos.y,foodPos.z + 23))
	food:Setowning_ent(activator)
	food.ShareGravgun = true
	food.nodupe = true
	food:Spawn()
	if not activator.maxFoods then
		activator.maxFoods = 0
	end
	activator.maxFoods = activator.maxFoods + 1
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
	timer.Destroy(self:EntIndex())
	local ply = self:Getowning_ent()
	if not IsValid(ply) then return end
end