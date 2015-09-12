include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if not IsValid(self:Getowning_ent()) or not IsValid(self:Getrecipient()) then return end

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    local amount = self:Getamount()
    local owner = (IsValid(self:Getowning_ent()) and self:Getowning_ent().Name and self:Getowning_ent():Name()) or DarkRP.getPhrase("unknown")
    local recipient = (self:Getrecipient().Name and self:Getrecipient():Name()) or DarkRP.getPhrase("unknown")

    surface.SetFont("ChatFont")
    local text = DarkRP.getPhrase("cheque_pay", recipient) .. "\n" .. DarkRP.formatMoney(amount) .. "\n" .. DarkRP.getPhrase("signed", owner)
    local TextWidth = surface.GetTextSize(text)

    cam.Start3D2D(Pos + Ang:Up() * 0.9, Ang, 0.1)
    if recipient == LocalPlayer():Name() and owner ~= LocalPlayer():Name() then
        draw.DrawNonParsedText(text, "ChatFont", -TextWidth * 0.5, -25, Color(0, 255, 0, 255), 0)
    elseif recipient == LocalPlayer():Name() and owner == LocalPlayer():Name() then
        draw.DrawNonParsedText(text, "ChatFont", -TextWidth * 0.5, -25, Color(255, 255, 0, 255), 0)
    elseif recipient ~= LocalPlayer():Name() and owner == LocalPlayer():Name() then
        draw.DrawNonParsedText(text, "ChatFont", -TextWidth * 0.5, -25, Color(0, 0, 255, 255), 0)
    elseif recipient ~= LocalPlayer():Name() and owner ~= LocalPlayer():Name() then
        draw.DrawNonParsedText(text, "ChatFont", -TextWidth * 0.5, -25, Color(255, 0, 0, 255), 0)
    else
        draw.DrawNonParsedText(text, "ChatFont", -TextWidth * 0.5, -25, Color(255, 255, 255, 255), 0)
    end
    cam.End3D2D()
end
