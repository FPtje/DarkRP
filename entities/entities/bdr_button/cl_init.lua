include('shared.lua')

function ENT:Draw()
	if self.dt.owner ~= LocalPlayer() or self:GetColor().a == 0 then return end

	surface.SetFont("HUDNumber5")
	local w,h = surface.GetTextSize(self:GetNWString("text"))

	local pos = self:GetPos()
	pos = pos + Vector(0,0,30)

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 90)

	cam.Start3D2D(pos, ang, 0.5)
		draw.WordBox(16, -1 * w/2, 0, self:GetNWString("text"), "HUDNumber5", Color(255,0,0,80), Color(255,255,255,255))
	cam.End3D2D()
end