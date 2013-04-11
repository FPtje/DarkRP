AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Destructed = false
	self:SetModel("models/Items/item_item_crate.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.locked = true
	timer.Simple(GAMEMODE.Config.shipmentspawntime, function() if IsValid(self) then self.locked = false end end)
	self.damage = 100
	self.ShareGravgun = true
	local phys = self:GetPhysicsObject()
	phys:Wake()

	local contents = CustomShipments[self:Getcontents() or ""]

	-- Create a serverside gun model
	-- it's required serverside to be able to get OBB information clientside
	self:SetgunModel(IsValid(self:GetgunModel()) and self:GetgunModel() or ents.Create("prop_physics"))
	self:GetgunModel():SetModel(contents.model)
	self:GetgunModel():SetPos(self:GetPos())
	self:GetgunModel():Spawn()
	self:GetgunModel():Activate()
	self:GetgunModel():SetSolid(SOLID_NONE)
	self:GetgunModel():SetParent(self)

	phys = self:GetgunModel():GetPhysicsObject()
	phys:EnableMotion(false)
end

function ENT:OnTakeDamage(dmg)
	if not self.locked then
		self.damage = self.damage - dmg:GetDamage()
		if self.damage <= 0 then
			self:Destruct()
		end
	end
end

function ENT:SetContents(s, c)
	self:Setcontents(s)
	self:Setcount(c)
end

function ENT:Use()
	if self.IsPocketed then return end
	if type(self.PlayerUse) == "function" then
		local val = self:PlayerUse(activator, caller)
		if val ~= nil then return val end
	elseif self.PlayerUse ~= nil then
		return self.PlayerUse
	end

	if not self.locked then
		self.locked = true -- One activation per second
		self.sparking = true
		self:Setgunspawn(CurTime() + 1)
		timer.Create(self:EntIndex() .. "crate", 1, 1, function()
			if not IsValid(self) then return end
			self.SpawnItem(self)
		end)
	end
end

function ENT:SpawnItem()
	if not IsValid(self) then return end
	timer.Destroy(self:EntIndex() .. "crate")
	self.sparking = false
	local count = self:Getcount()
	local pos = self:GetPos()
	if count <= 1 then self:Remove() end
	local contents = self:Getcontents()
	local weapon = ents.Create("spawned_weapon")

	local weaponAng = self:GetAngles()
	local weaponPos = self:GetAngles():Up() * 40 + weaponAng:Up() * (math.sin(CurTime() * 3) * 8)
	weaponAng:RotateAroundAxis(weaponAng:Up(), (CurTime() * 180) % 360)

	if CustomShipments[contents] then
		class = CustomShipments[contents].entity
		model = CustomShipments[contents].model
	else
		weapon:Remove()
		self:Remove()
		return
	end

	weapon.weaponclass = class
	weapon:SetModel(model)
	weapon.ammoadd = weapons.Get(class) and weapons.Get(class).Primary.DefaultClip
	weapon.ShareGravgun = true
	weapon:SetPos(self:GetPos() + weaponPos)
	weapon:SetAngles(weaponAng)
	weapon.nodupe = true
	weapon:Spawn()
	count = count - 1
	self:Setcount(count)
	self.locked = false
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

function ENT:Destruct()
	if self.Destructed then return end
	self.Destructed = true
	local vPoint = self:GetPos()
	local contents = self:Getcontents()
	local count = self:Getcount()
	local class = nil
	local model = nil

	if CustomShipments[contents] then
		class = CustomShipments[contents].entity
		model = CustomShipments[contents].model
	else
		self:Remove()
		return
	end


	local weapon = ents.Create("spawned_weapon")
	weapon:SetModel(model)
	weapon.weaponclass = class
	weapon.ShareGravgun = true
	weapon:SetPos(Vector(vPoint.x, vPoint.y, vPoint.z + 5))
	weapon.ammoadd = weapons.Get(class) and weapons.Get(class).Primary.DefaultClip
	weapon.nodupe = true
	weapon:Spawn()
	weapon.dt.amount = count

	self:Remove()
end

function ENT:Touch(ent)
	if ent:GetClass() ~= "spawned_shipment" or
		self:Getcontents() ~= ent:Getcontents() or
		self.locked or ent.locked or
		self.hasMerged or ent.hasMerged then return end

	ent.hasMerged = true

	self:Setcount(self:Getcount() + ent:Getcount())
	ent:Remove()
end