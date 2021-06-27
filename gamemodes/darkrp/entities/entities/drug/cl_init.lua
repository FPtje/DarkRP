include("shared.lua")

function ENT:Initialize()
end

local color_red = Color(140, 0, 0, 100)
local color_white = color_white

function ENT:Draw()
    self:DrawModel()

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    local owner = self:Getowning_ent()
    owner = (IsValid(owner) and owner:Nick()) or DarkRP.getPhrase("unknown")

    surface.SetFont("HUDNumber5")
    local text = DarkRP.getPhrase("drugs")
    local text2 = DarkRP.getPhrase("priceTag", DarkRP.formatMoney(self:Getprice()), "")
    local TextWidth = surface.GetTextSize(text)
    local TextWidth2 = surface.GetTextSize(text2)

    Ang:RotateAroundAxis(Ang:Forward(), 90)
    local TextAng = Ang

    TextAng:RotateAroundAxis(TextAng:Right(), CurTime() * -180)

    cam.Start3D2D(Pos + Ang:Right() * -15, TextAng, 0.1)
        draw.WordBox(2, -TextWidth * 0.5 + 5, -30, text, "HUDNumber5", color_red, color_white)
        draw.WordBox(2, -TextWidth2 * 0.5 + 5, 18, text2, "HUDNumber5", color_red, color_white)
    cam.End3D2D()
end

function ENT:Think()
end

local function drugEffects(um)
    local toggle = um:ReadBool()

    LocalPlayer().isDrugged = toggle

    if toggle then
        hook.Add("RenderScreenspaceEffects", "drugged", function()
            DrawSharpen(-1, 2)
            DrawMaterialOverlay("models/props_lab/Tank_Glass001", 0)
            DrawMotionBlur(0.13, 1, 0.00)
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "drugged")
    end
end
usermessage.Hook("DrugEffects", drugEffects)
