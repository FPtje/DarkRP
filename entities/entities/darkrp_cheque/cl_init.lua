include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if not IsValid(self:Getowning_ent()) or not IsValid(self:Getrecipient()) then return end

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	local amount = tostring(self:Getamount()) or "0"
	local owner = (IsValid(self:Getowning_ent()) and self:Getowning_ent().Name and self:Getowning_ent():Name()) or "N/A"
	local recipient = (self:Getrecipient().Name and self:Getrecipient():Name()) or "N/A"

	surface.SetFont("ChatFont")
	local TextWidth = surface.GetTextSize("Pay: " .. recipient .. "\n$" .. amount .. "\nSigned: " .. owner)

	cam.Start3D2D(Pos + Ang:Up() * 0.9, Ang, 0.1)
		draw.DrawText("Pay: " .. recipient .. "\n$" .. amount .. "\nSigned: " .. owner, "ChatFont", -TextWidth*0.5, -25, Color(255,255,255,255), 0)
	cam.End3D2D()
end