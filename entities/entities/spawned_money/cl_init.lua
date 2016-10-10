include("shared.lua")

function ENT:Initialize()
end

local vector_up = Vector(0,0,1)
function ENT:Draw()
    self:DrawModel()
    local offset = (self:OBBMaxs() - self:OBBCenter())*vector_up

    local Pos = self:OBBCenter() 
    local Ang = self:GetAngles()

    surface.SetFont("ChatFont")
    local text = DarkRP.formatMoney(self:Getamount())
    local TextWidth = surface.GetTextSize(text)

    cam.Start3D2D(self:LocalToWorld(Pos+offset), Ang, 0.1)
        draw.WordBox(2, -TextWidth * 0.5, -10, text, "ChatFont", Color(140, 0, 0, 100), Color(255, 255, 255, 255))
    cam.End3D2D()

    Ang:RotateAroundAxis(Ang:Right(), 180)

    cam.Start3D2D(self:LocalToWorld(Pos-offset), Ang, 0.1)
        draw.WordBox(2, -TextWidth * 0.5, -10, text, "ChatFont", Color(140, 0, 0, 100), Color(255, 255, 255, 255))
    cam.End3D2D()
end

function ENT:Think()
end
