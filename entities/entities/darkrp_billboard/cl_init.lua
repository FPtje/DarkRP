include("shared.lua")

ENT.DrawPos = Vector(1, -111, 58)

ENT.Width = 558
ENT.Height = 290

ENT.HeaderMargin = 10
ENT.BodyMargin = 10

ENT.HeaderFont = "Trebuchet48"
ENT.BodyFont = "DermaLarge"

function ENT:Draw()
    self:DrawModel()

    local DrawPos = self:LocalToWorld(self.DrawPos)

    local DrawAngles = self:GetAngles()
    DrawAngles:RotateAroundAxis(self:GetAngles():Forward(), 90)
    DrawAngles:RotateAroundAxis(self:GetAngles():Up(), 90)

    local backgroundColor = self:GetBackgroundColor() * 255
    local barColor = self:GetBarColor() * 255
    local topText = DarkRP.textWrap(self:GetTopText(), self.HeaderFont, self.Width - self.BodyMargin * 2)

    local bottomText = string.gsub(string.gsub(self:GetBottomText() or "", "//", "\n"), "\\n", "\n")
    bottomText = DarkRP.textWrap(string.Replace(bottomText, "\\n", "\n"), self.BodyFont, self.Width - self.BodyMargin * 2)

    if not self.HeaderFontHeight then self.HeaderFontHeight = draw.GetFontHeight(self.HeaderFont) end

    local barHeight = 1
    for _ in string.gmatch(topText, "\n") do barHeight = barHeight + 1 end
    barHeight = self.HeaderMargin * 2 + barHeight * self.HeaderFontHeight

    local centerX = self.Width / 2

    render.EnableClipping(true)
    local normal = self:GetUp()
    render.PushCustomClipPlane(normal, normal:Dot(DrawPos - normal * self.Height * 0.4))

    cam.Start3D2D(DrawPos, DrawAngles, 0.4)

        surface.SetDrawColor(backgroundColor.x, backgroundColor.y, backgroundColor.z, 255)
        surface.DrawRect(0, 0, self.Width, self.Height)

        draw.RoundedBox(0, 0, 0, self.Width, barHeight, Color(barColor.x, barColor.y, barColor.z))

        draw.DrawText(topText, self.HeaderFont, centerX, self.HeaderMargin, color_white, TEXT_ALIGN_CENTER)
        draw.DrawText(bottomText, self.BodyFont, centerX, barHeight + self.BodyMargin, color_white, TEXT_ALIGN_CENTER)

    cam.End3D2D()

    render.PopCustomClipPlane()
    render.EnableClipping(false)
end

language.Add("Cleaned_advert_billboards", "Cleaned up Advert Billboards")
language.Add("Cleanup_advert_billboards", "Advert Billboards")
language.Add("Undone_advert_billboard", "Undone Advert Billboard")
