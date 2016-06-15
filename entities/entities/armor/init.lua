AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/Items/battery.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self.Entity:GetPhysicsObject()
	self.nodupe = true
	self.ShareGravgun = true

	if phys and phys:IsValid() then phys:Wake() end
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) 
end

function ENT:SpawnFunction(ply, tr)
   	if (!tr.Hit) then
	return end
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal

 	local ent = ents.Create("Armor")
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
 	 	 
	return ent 
end

function ENT:Use(plyUse)
	if plyUse:Armor() != 100 then
		self:EmitSound("items/battery_pickup.wav")
		self:Remove()
		plyUse:SetArmor(100)
	else return end
end

function ENT:OnRemove()
	self:Remove()
end