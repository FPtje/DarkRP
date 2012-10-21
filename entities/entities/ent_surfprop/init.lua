AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.surfer = NULL

function ENT:Initialize()
	self:SetModel("models/props_junk/TrashDumpster02b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	phys:Wake()
	phys:EnableMotion(false)

	self:SetMaterial("phoenix_storms/wire/pcb_blue")
	self:SetColor(Color(math.random(0,255), math.random(0,255), math.random(0,255), 255)) -- Nice random colour per contestant

	self.GravGunPickup = false
	self.GravGunPunt = false
	self.CanTool = false

	self.StartingTime = 0
	self.EndingTime = 0
end

function ENT:setSurfer(ply)
	self.surfer = ply
	self.Owner = ply
	ply:SetNWEntity("SurfProp", self)
end

function ENT:setLastCheckpoint(checkpoint)
	self.dt.lastCheckpoint = checkpoint
end

function ENT:SpawnPlayer(pos, ang)
	local found = false
	repeat
		found = false
		local find = ents.FindInSphere(pos, 20)
		for k,v in pairs(find) do
			if IsValid(v) and (v:IsPlayer() or v:GetClass() == ent_surfprop) and v ~= self and v ~= self.surfer then
				pos = pos + Vector(0,0,100)
				found = true
				break
			end
		end
	until found == false

	self:SetPos(pos)
	self:SetAngles(Angle(0, ang.y + 90, 0))-- we don't want the prop to be tilted
	self.surfer:SetEyeAngles(ang)

	self.surfer:SetPos(pos + Vector(0,0,5))

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end

function ENT:Think()
	if not IsValid(self.surfer) then return end
	local ground = self.surfer:GetGroundEntity()
	if ground ~= self and self.surfer:IsOnGround() and IsValid(self.raceGame) and not self.raceGame:HasFinished(self.surfer) then -- if not on the prop and not on something else
		-- reset to last checkpoint :)
		local checkpoint = self.dt.lastCheckpoint
		local pos = checkpoint:GetPos() + Vector(0,0,20)
		local ang = IsValid(checkpoint.dt.nextCheckpoint) and (checkpoint.dt.nextCheckpoint:GetPos() - checkpoint:GetPos()):Angle() or self:GetAngles()

		self:SpawnPlayer(pos, ang)
	end
end