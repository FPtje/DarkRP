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
	self.Visual:SetPos(self:GetPos() + Vector(0,0,68))
	self.Visual:SetAngles(self:GetAngles())
	self.Visual:SetParent(self)
	self.Visual:Spawn()
	self.Visual:Activate()

	self:setPassed(false)
end

function ENT:setPassed(bool)
	self.Passed = bool
	self.Visual:SetColor(255,255,255,255)
end

function ENT:Draw()
	if not ValidEntity(self.dt.manager) or self.dt.manager.dt.stage ~= 2 then return end

	local color = Color(self.dt.manager.participating and 0 or 255,self.dt.manager.participating and 255 or 0,0,80)
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90)
	cam.Start3D2D(self:GetPos() + ang:Up() * 6, ang, 0.5)
		draw.WordBox(16, -130, 0, "Enter the race", "HUDNumber5", color, Color(255,255,255,255))
	cam.End3D2D()
end