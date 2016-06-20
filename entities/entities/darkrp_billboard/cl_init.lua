include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local DrawPos = self:LocalToWorld(Vector(1, -111, 58))

    local DrawAngles = self:GetAngles()
    DrawAngles:RotateAroundAxis(self:GetAngles():Forward(), 90)
    DrawAngles:RotateAroundAxis(self:GetAngles():Up(), 90)

    local backgroundColor = self:GetBackgroundColor() * 255
    local barColor = self:GetBarColor() * 255
    local topText = DarkRP.textWrap(self:GetTopText(), "Trebuchet48", 548)

    local bottomText = string.gsub(string.gsub(self:GetBottomText() or "", "//", "\n"), "\\n", "\n")
    bottomText = DarkRP.textWrap(string.Replace(bottomText, "\\n", "\n"), "DermaLarge", 548)

    local barHeight = 0
    for _ in string.gmatch(topText, "\n") do barHeight = barHeight + 1 end
    barHeight = 70 + barHeight * 48


    render.EnableClipping(true)
    local normal = self:GetUp()
    render.PushCustomClipPlane(normal, normal:Dot(DrawPos - normal * 290 * 0.4))

    cam.Start3D2D(DrawPos, DrawAngles, 0.4)

        surface.SetDrawColor(backgroundColor.x, backgroundColor.y, backgroundColor.z, 255)
        surface.DrawRect(0, 0, 558, 290)

        draw.RoundedBox(4, 0, 0, 558, barHeight, Color(barColor.x, barColor.y, barColor.z))

        draw.DrawText(topText, "Trebuchet48", 279, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.DrawText(bottomText, "DermaLarge", 279, barHeight + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)

    cam.End3D2D()

    render.PopCustomClipPlane()
    render.EnableClipping(false)
end

language.Add("Cleanup_advert_billboards", "Advert Billboards")
language.Add("Undone_advert_billboard", "Undone Advert Billboard")
