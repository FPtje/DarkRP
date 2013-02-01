AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/paper01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
	local phys = self:GetPhysicsObject()

	phys:Wake()
	hook.Add("PlayerDisconnected", self, self.onPlayerDisconnected)
end

function ENT:OnRemove()
	local ply = self:Getowning_ent()
	if not IsValid(ply) then return end
	if not ply.maxletters then
		ply.maxletters = 0
	end
	ply.maxletters = ply.maxletters - 1
end

function ENT:Use(ply)
	if not ply:KeyDown(IN_ATTACK) then
		umsg.Start("ShowLetter", ply)
			umsg.Entity(self)
			umsg.Short(self.type)
			umsg.Vector(self:GetPos())
			local numParts = self.numPts
			umsg.Short(numParts)
			for a,b in pairs(self.Parts) do umsg.String(b) end
		umsg.End()
	else
		umsg.Start("KillLetter", ply)
		umsg.End()
	end
end

function ENT:SignLetter(ply)
	self:Setsigned(ply)
end

function ENT:onPlayerDisconnected(ply)
	if self.dt.owning_ent == ply then
		self:Remove()
	end
end

concommand.Add("_DarkRP_SignLetter", function(ply, cmd, args)
	if not args[1] then return end
	local letter = ents.GetByIndex(tonumber(args[1]))

	letter:SignLetter(ply)
end)