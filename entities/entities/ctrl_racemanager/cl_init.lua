include('shared.lua')

function ENT:Initialize()
self.Visual = ents.Create("prop_physics")
	self.Visual:SetModel("models/XQM/Rails/gumball_1.mdl")
	self.Visual:SetPos(self:GetPos())
	self.Visual:SetParent(self)
	self.Visual:Spawn()
	self.Visual:Activate()
end

usermessage.Hook("raceParticipate", function(um)
	local ent = um:ReadEntity()
	ent:setParticipating(um:ReadBool())
end)

function ENT:setParticipating(bool)
	self.participating = bool
end