AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include('shared.lua')

function ENT:Initialize()
	self.dt.radius = 300
end

function ENT:setHasPassed(ply, bool)
	if self.dt.manager then
		self.dt.manager.raceGame:Finish(ply)
	end
	
	if bool and not self.Passed[ply] then
		self:EmitSound("hl1/fvox/bell.wav", 100, 200)
	end
	self.BaseClass.setHasPassed(self, ply, bool) -- Call parent's setHasPassed
end