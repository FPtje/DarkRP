AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

--[[
Public attributes
]]
ENT.Passed = {}

--[[
Methods
]]
function ENT:Initialize()
	self.Passed = {}
	self.dt.radius = 150
end

function ENT:setRadius(radius)
	self.dt.radius = radius
end

function ENT:setNextCheckpoint(Checkpoint)
	self.dt.nextCheckpoint = Checkpoint
end

function ENT:setPreviousCheckpoint(Checkpoint)
	self.dt.previousCheckpoint = Checkpoint
end

function ENT:getHasPassed(ply)
	return self.Passed[ply] == true -- Won't return nil
end

function ENT:setHasPassed(ply, bool) -- This function is going to be overridden in subclasses
	if bool and not self.Passed[ply] then
		self:EmitSound("hl1/fvox/bell.wav", 100, 100)
	end
	ply:GetNWEntity("SurfProp").dt.lastCheckpoint = self
	self.Passed[ply] = bool
end

function ENT:Think()
	if not IsValid(self.dt.manager) or not self.dt.manager:getParticipants() or self.dt.manager.dt.stage ~= 3 then return end

	for _, ply in pairs(self.dt.manager:getParticipants()) do
		if not IsValid(ply) then
			for k,v in pairs(self.dt.manager.Participants) do
				if v == ply then
					self.dt.manager.Participants[k] = nil
				end
			end
			continue
		end
		if ply:GetPos():Distance(self:GetPos()) < self.dt.radius then
			if IsValid(self.dt.previousCheckpoint) and not self.dt.previousCheckpoint:getHasPassed(ply) then
				-- You haven't passed the previous one yet!
				return
			end
			self:setHasPassed(ply, true)
		end
	end
end