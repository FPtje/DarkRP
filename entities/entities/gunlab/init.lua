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

	self:Setprice(200)
	phys:Wake()

	self.sparking = false
	self.damage = 100
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage()
	if self.damage <= 0 then
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

	if IsValid(owner) and activator == owner then
		if self.allowed and type(self.allowed) == "table" and table.HasValue(self.allowed, activator:Team()) then
			-- Hey, hey, hey! Get 20% off production costs of the award winning gun lab if you own the gun lab and are a gun dealer!
			return math.ceil(self:Getprice() * 0.80) -- 20% off
		else
			-- But we're not stopping there! If you are the owner of the Gun Lab 9000 but not a gun dealer, you still get a massive 10% off!
			return math.ceil(self:Getprice() * 0.90) -- 10% off
		end
	else
		-- If you don't own the gun lab, tough shit. No discount for you. Thank you, come again.
		return self:Getprice() -- 0% off
	end
end

ENT.Once = false
function ENT:Use(activator)
	local owner = self:Getowning_ent()
	local cash = self:SalePrice(activator)

	if self.Once then return end

	if not activator:canAfford(self:SalePrice(activator)) then
		DarkRP.notify(activator, 1, 3, DarkRP.getPhrase("cant_afford", DarkRP.getPhrase("gun")))
		return ""
	end
	local diff = self:SalePrice(activator) - self:SalePrice(owner)
	if diff < 0 and not owner:canAfford(math.abs(diff)) then
		DarkRP.notify(activator, 2, 3, DarkRP.getPhrase("owner_poor", DarkRP.getPhrase("gun_lab")))
		return ""
	end
	self.sparking = true


	activator:addMoney(-cash)
	DarkRP.notify(activator, 0, 3, "You purchased a P228 for " .. DarkRP.formatMoney(cash) .. "!")

	if IsValid(owner) and activator ~= owner then
		local gain = 0
		if self.allowed and type(self.allowed) == "table" and table.HasValue(self.allowed, owner:Team()) then
			gain = math.floor(self:Getprice() - math.ceil(self:Getprice() * 0.80))
		else
			gain = math.floor(self:Getprice() - math.ceil(self:Getprice() * 0.90))
		end
		if gain == 0 then
			DarkRP.notify(owner, 3, 3, DarkRP.getPhrase("you_received_x", DarkRP.formatMoney(0) .. " " .. DarkRP.getPhrase("profit"), "P228 (" .. DarkRP.getPhrase("gun_lab") .. ")"))
		else
			owner:addMoney(gain)
			local word = DarkRP.getPhrase("profit")
			if gain < 0 then word = DarkRP.getPhrase("loss") end
			DarkRP.notify(owner, 0, 3, DarkRP.getPhrase("you_received_x", DarkRP.formatMoney(math.abs(gain)) .. " " .. word, "P228 (" .. DarkRP.getPhrase("gun_lab") .. ")"))
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
	gun:SetModel("models/weapons/w_pist_p228.mdl")
	gun:SetWeaponClass("weapon_p2282")
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
