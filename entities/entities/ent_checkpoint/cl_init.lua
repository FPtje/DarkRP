include('shared.lua')

--[[
public attributes
]]
ENT.Passed = false
ENT.Visual = NULL
ENT.Arrow = NULL
ENT.Radius = 0

--[[
Methods
]]
function ENT:Initialize()
	self:createVisuals()
end

function ENT:createVisuals()
	self.Visual = ents.Create("prop_physics")
	self.Visual:SetModel("models/XQM/Rails/gumball_1.mdl")
	self.Visual:SetPos(self:GetPos())
	self.Visual:SetParent(self)
	self.Visual:Spawn()
	self.Visual:Activate()

	self.Visual:SetMaterial("models/debug/debugwhite")

	self.Radius = self.dt.radius
	local size = self.Radius / 15 -- 15 is the radius of the ball.
	self.Visual:SetModelScale(Vector(size, size, size))

	self.Arrow = ents.Create("prop_physics")
	self.Arrow:SetModel("models/props_junk/harpoon002a.mdl")
	self.Arrow:SetMaterial("models/debug/debugwhite")
	self.Arrow:SetColor(Color(0,0,255,255))
	self.Arrow:SetPos(self:GetPos())
	self.Arrow:SetParent(self)
	self.Arrow:SetModelScale(Vector(2,2,10))
	self.Arrow:Spawn()
	self.Arrow:Activate()
	self.Arrow:SetNoDraw(true)

	self:setPassed(false)
end

function ENT:Draw()
	render.SuppressEngineLighting(true)
	render.SetBlend(0.3)
	render.SetColorModulation(1, self.Passed and 0 or 1, 0)
	if IsValid(self.Visual) then
		self.Visual:DrawModel()
	end

	if IsValid(self.Arrow) then

		render.SetBlend(self.Arrow:GetColor().a/255)
		render.SetColorModulation(0,0,255)
		self.Arrow:DrawModel()
	end
	render.SuppressEngineLighting(false)
end

function ENT:setPassed(bool)
	self.Passed = bool
	self.Visual:SetColor(255, bool and 0 or 255, 0, 80)
end

function ENT:Think()
	if IsValid(LocalPlayer():GetNWEntity("SurfProp")) and LocalPlayer():GetNWEntity("SurfProp").dt.lastCheckpoint == self then
		self:setPassed(true)
	end

	if self.Radius ~= self.dt.radius and self:GetClass() == "ent_checkpoint" then -- making sure not to call SetModelScale every frame
		self.Radius = self.dt.radius
		local size = self.Radius / 15 -- 15 is the radius of the ball.
		self.Visual:SetModelScale(Vector(size, size, size))
	end

	if not IsValid(self.dt.nextCheckpoint) and IsValid(self.Arrow) then
		self.Arrow:SetNoDraw(true)
		self.Arrow:SetColor(0,0,255,0)
	elseif IsValid(self.Arrow) then
		--self.Arrow:SetNoDraw(false)
		self.Arrow:SetColor(0,0,255,255)
		local ang = (self.dt.nextCheckpoint:GetPos() - self:GetPos()):Angle()
		self.Arrow:SetAngles(ang)
	end
end

function ENT:OnRemove()
	SafeRemoveEntity(self.Visual)
	SafeRemoveEntity(self.Arrow)
end
