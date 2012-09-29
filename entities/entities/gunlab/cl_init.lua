include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	local owner = self.dt.owning_ent
	owner = (IsValid(owner) and owner:Nick()) or "Unknown"

	surface.SetFont("HUDNumber5")
	local TextWidth = surface.GetTextSize("Gunlab!")
	local TextWidth2 = surface.GetTextSize("Price: $"..self.dt.price)

	Ang:RotateAroundAxis(Ang:Forward(), 90)
	local TextAng = Ang

	TextAng:RotateAroundAxis(TextAng:Right(), CurTime() * -180)

	cam.Start3D2D(Pos + Ang:Right() * -30, TextAng, 0.2)
		draw.WordBox(2, -TextWidth*0.5 + 5, -30, "Gunlab!", "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
		draw.WordBox(2, -TextWidth2*0.5 + 5, 18, "Price: $"..self.dt.price, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
end