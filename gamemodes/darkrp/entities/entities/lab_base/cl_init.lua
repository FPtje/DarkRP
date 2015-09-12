include("shared.lua")

function ENT:Initialize()
    self:initVars()
end

function ENT:Draw()
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
        draw.WordBox(2, -TextWidth * 0.5 + 5, -30, text, "HUDNumber5", Color(140, 0, 0, 100), Color(255, 255, 255, 255))
        draw.WordBox(2, -TextWidth2 * 0.5 + 5, 18, text2, "HUDNumber5", Color(140, 0, 0, 100), Color(255, 255, 255, 255))
    cam.End3D2D()
end
