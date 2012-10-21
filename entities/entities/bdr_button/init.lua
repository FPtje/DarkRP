AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.manager = NULL

function ENT:Initialize()
	self:SetModel("models/props_c17/door02_double.mdl")

	self:SetUseType(SIMPLE_USE)

	//self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self.PhysgunPickup = false
	self.OnPhysgunReload = false
	self.OnPhysgunFreeze = false
	self.GravGunPickup = false
	self.GravGunPunt = false
	self.CanTool = false
end

function ENT:SetBase(ent_start, BtnNumber)
	local pos = ent_start:GetPos()
	local ang = ent_start:GetAngles()

	pos = pos + Vector(0,0,120) -- raise position of first button
	pos = pos - BtnNumber * Vector(0,0,38) -- This button is below the previous one

	ang:RotateAroundAxis(ang:Forward(), 90) -- Rotate it correctly

	self:SetPos(pos)
	self:SetAngles(ang)
	self:SetParent(ent_start)

	self.dt.owner = ent_start.dt.manager.Player
end

function ENT:SetDisabled(bool)
	self.Disabled = bool
	self:SetColor(Color(255,255,255, bool and 0 or 255))
end

function ENT:SetText(text)
	self:SetNWString("text", text) -- there is no String DataTable
end

function ENT:SetUseFunction(func)
	self.UseFunc = func
end

function ENT:Use(activator, caller)
	if self.UseFunc and caller == self.dt.owner and not self.Disabled then
		self:UseFunc()
	end
end