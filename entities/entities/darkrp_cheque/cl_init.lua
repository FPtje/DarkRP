include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if not IsValid(self.dt.owning_ent) or not IsValid(self.dt.recipient) then return end

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	local amount = tostring(self.dt.amount) or "0"
	local owner = (IsValid(self.dt.owning_ent) and self.dt.owning_ent.Name and self.dt.owning_ent:Name()) or "N/A"
	local recipient = (self.dt.recipient.Name and self.dt.recipient:Name()) or "N/A"

	surface.SetFont("ChatFont")
	local TextWidth = surface.GetTextSize("Pay: " .. recipient .. "\n$" .. amount .. "\nSigned: " .. owner)

	cam.Start3D2D(Pos + Ang:Up() * 0.9, Ang, 0.1)
		draw.DrawText("Pay: " .. recipient .. "\n$" .. amount .. "\nSigned: " .. owner, "ChatFont", -TextWidth*0.5, -25, Color(255,255,255,255), 0)
	cam.End3D2D()
end