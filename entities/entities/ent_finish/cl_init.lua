include('shared.lua')

--[[
public attributes
]]
ENT.Passed = false
ENT.Visual = NULL

--[[
Methods
]]
function ENT:createVisuals() -- Overriding CreateVisuals
	self.Visual = ClientsideModel("models/props_c17/truss02a.mdl", RENDERGROUP_OPAQUE)
	self.Visual:SetPos(self:GetPos())
	self.Visual:SetAngles(self:GetAngles())
	self.Visual:SetParent(self)
	self.Visual:Spawn()
	self.Visual:Activate()
end

function ENT:SetPassed() end
function ENT:Draw() self.Visual:DrawModel() end