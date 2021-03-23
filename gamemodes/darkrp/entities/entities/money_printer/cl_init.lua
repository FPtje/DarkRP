include("shared.lua")

function ENT:Initialize()
    self:initVars()
    if not self.DisplayName or self.DisplayName == "" then
        self.DisplayName = DarkRP.getPhrase("money_printer")
    end
end

local camStart3D2D = cam.Start3D2D
local camEnd3D2D = cam.End3D2D
local drawWordBox = draw.WordBox
local IsValid = IsValid

local color_red = Color(140,0,0,100)
local color_white = color_white

function ENT:Draw()
    self:DrawModel()

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    local owner = self:Getowning_ent()
    owner = (IsValid(owner) and owner:Nick()) or DarkRP.getPhrase("unknown")

    surface.SetFont("HUDNumber5")
    local text = self.DisplayName
    local TextWidth = surface.GetTextSize(text)
    local TextWidth2 = surface.GetTextSize(owner)

    Ang:RotateAroundAxis(Ang:Up(), 90)

    camStart3D2D(Pos + Ang:Up() * 11.5, Ang, 0.11)
        drawWordBox(2, -TextWidth * 0.5, -30, text, "HUDNumber5", color_red, color_white)
        drawWordBox(2, -TextWidth2 * 0.5, 18, owner, "HUDNumber5", color_red, color_white)
    camEnd3D2D()
end

function ENT:Think()
end
