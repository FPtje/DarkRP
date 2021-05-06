include("shared.lua")

function ENT:Initialize()
    self:initVars()
end

local color_red = Color(140, 0, 0, 100)
local color_white = color_white

function ENT:DrawTranslucent()
    self:DrawModel()

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    local owner = self:Getowning_ent()
    owner = (IsValid(owner) and owner:Nick()) or DarkRP.getPhrase("unknown")

    surface.SetFont("HUDNumber5")
    local text = self.labPhrase
    local text2 = DarkRP.getPhrase("priceTag", DarkRP.formatMoney(self:Getprice()), "")
    local TextWidth = surface.GetTextSize(text)
    local TextWidth2 = surface.GetTextSize(text2)

    Ang:RotateAroundAxis(Ang:Forward(), 90)
    local TextAng = Ang

    TextAng:RotateAroundAxis(TextAng:Right(), CurTime() * -180)

    cam.Start3D2D(Pos + Ang:Right() * self.camMul, TextAng, 0.2)
        draw.WordBox(2, -TextWidth * 0.5 + 5, -30, text, "HUDNumber5", color_red, color_white)
        draw.WordBox(2, -TextWidth2 * 0.5 + 5, 18, text2, "HUDNumber5", color_red, color_white)
    cam.End3D2D()
end
