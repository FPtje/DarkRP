AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include('shared.lua')

function ENT:Initialize()
	self.dt.radius = 300
	self:SetModel("models/props_phx/construct/metal_plate4x4.mdl")

	self:SetUseType(SIMPLE_USE)

	//self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self.PhysgunPickup = false
	self.OnPhysgunReload = false
	self.OnPhysgunFreeze = false
	self.GravGunPickup = false
	self.GravGunPunt = false
	self.CanTool = false

	self.StartRace = ents.Create("bdr_button")
	self.StartRace:SetBase(self, 0)
	self.StartRace:SetText("Start race")
	self.StartRace:Spawn()
	self.StartRace:Activate()

	self.CancelRace = ents.Create("bdr_button")
	self.CancelRace:SetBase(self, 1)
	self.CancelRace:SetText("Cancel race")
	self.CancelRace:Spawn()
	self.CancelRace:Activate()
	self.CancelRace:SetUseFunction(function()
		self.dt.manager:Remove()
	end)

	self.StartRace:SetUseFunction(function()
		self.StartRace:SetDisabled(true)
		self.CancelRace:SetDisabled(true)

		self.dt.manager:startRace()
	end)

	self.BaseClass.Initialize(self)
end

function ENT:setHasPassed(ply, bool)
	if bool then
		--GAME:SetInPosition(ply)
	end
	self.Passed[ply] = bool
end

function ENT:Use(ply)
	self.dt.manager:addParticipant(ply)
end

function ENT:OnRemove()
	SafeRemoveEntity(self.StartRace)
	SafeRemoveEntity(self.CancelRace)
end