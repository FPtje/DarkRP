include("shared.lua")

ENT.TextColors = {
    OtherToSelf = Color(0, 255, 0, 255),
    SelfToSelf = Color(255, 255, 0, 255),
    SelfToOther = Color(0, 0, 255, 255),
    OtherToOther = Color(255, 0, 0, 255)
}

function ENT:Draw()
    self:DrawModel()

    local owner = self:Getowning_ent()
    local recipient = self:Getrecipient()
    local ownerplayer = owner:IsPlayer()
    local recipientplayer = recipient:IsPlayer()
    local localplayer = LocalPlayer()

    local Pos = self:GetPos()
    local Ang = self:GetAngles()
    local Up = Ang:Up()
    Up:Mul(0.9)
    Pos:Add(Up)

    surface.SetFont("ChatFont")
    local text = DarkRP.getPhrase("cheque_pay", recipientplayer and recipient:Nick() or DarkRP.getPhrase("unknown")) .. "\n" .. DarkRP.formatMoney(self:Getamount()) .. "\n" .. DarkRP.getPhrase("signed", ownerplayer and owner:Nick() or DarkRP.getPhrase("unknown"))

    cam.Start3D2D(Pos, Ang, 0.1)
        draw.DrawNonParsedText(text, "ChatFont", surface.GetTextSize(text) * -0.5, -25, localplayer:IsValid() and (ownerplayer and localplayer == owner and (recipientplayer and localplayer == recipient and self.TextColors.SelfToSelf or self.TextColors.SelfToOther) or recipientplayer and localplayer == recipient and self.TextColors.OtherToSelf) or self.TextColors.OtherToOther, 0)
    cam.End3D2D()
end