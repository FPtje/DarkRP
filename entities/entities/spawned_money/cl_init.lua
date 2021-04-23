include("shared.lua")

local color_red = Color(140, 0, 0, 100)
local color_white = Color(255, 255, 255)

function ENT:Draw()
    self:DrawModel()

    -- Do not draw labels when a different model is used.
    -- If you want a different model with labels, make your own money entity and use GM.Config.MoneyClass.
    if self:GetModel() ~= "models/props/cs_assault/money.mdl" then return end

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    surface.SetFont("ChatFont")
    local text = DarkRP.formatMoney(self:Getamount())
    local TextWidth = surface.GetTextSize(text)

    cam.Start3D2D(Pos + Ang:Up() * 0.82, Ang, 0.1)
        draw.WordBox(2, -TextWidth * 0.5, -10, text, "ChatFont", color_red, color_white)
    cam.End3D2D()

    Ang:RotateAroundAxis(Ang:Right(), 180)

    cam.Start3D2D(Pos, Ang, 0.1)
        draw.WordBox(2, -TextWidth * 0.5, -10, text, "ChatFont", color_red, color_white)
    cam.End3D2D()
end

function ENT:Think()
end
