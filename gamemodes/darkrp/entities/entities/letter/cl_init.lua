include("shared.lua")

local frame
local SignButton

function ENT:Draw()
    self:DrawModel()
end

local function KillLetter(msg)
    hook.Remove("HUDPaint", "ShowLetter")
    frame:Remove()
end
usermessage.Hook("KillLetter", KillLetter)

local function ShowLetter(msg)
    if frame then
        frame:Remove()
    end

    local LetterMsg = ""
    local Letter = msg:ReadEntity()
    local LetterType = msg:ReadShort()
    local LetterPos = msg:ReadVector()
    local sectionCount = msg:ReadShort()
    local LetterY = ScrH() / 2 - 300
    local LetterAlpha = 255

    Letter:CallOnRemove("Kill letter HUD on remove", KillLetter)

    for k = 1, sectionCount, 1 do
        LetterMsg = LetterMsg .. msg:ReadString()
    end

    frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:ShowCloseButton(false)

    SignButton = vgui.Create("DButton", frame)
    SignButton:SetText(DarkRP.getPhrase("sign_this_letter"))
    frame:SetPos(ScrW() - 256, ScrH() - 256)
    SignButton:SetSize(256, 256)
    frame:SetSize(256, 256)
    SignButton:SetSkin(GAMEMODE.Config.DarkRPSkin)
    frame:SizeToContents()
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false)

    function SignButton:DoClick()
        RunConsoleCommand("_DarkRP_SignLetter", Letter:EntIndex())
        SignButton:SetDisabled(true)
    end
    SignButton:SetDisabled(IsValid(Letter:Getsigned()))

    hook.Add("HUDPaint", "ShowLetter", function()
        if not Letter.dt then KillLetter() return end
        if LetterAlpha < 255 then
            LetterAlpha = math.Clamp(LetterAlpha + 400 * FrameTime(), 0, 255)
        end

        local font = (LetterType == 1 and "AckBarWriting") or "Default"

        draw.RoundedBox(2, ScrW() * .2, LetterY, ScrW() * .8 - (ScrW() * .2), ScrH(), Color(255, 255, 255, math.Clamp(LetterAlpha, 0, 200)))
        draw.DrawNonParsedText(LetterMsg .. "\n\n\n" .. DarkRP.getPhrase("signed", IsValid(Letter:Getsigned()) and Letter:Getsigned():Nick() or DarkRP.getPhrase("no_one")), font, ScrW() * .25 + 20, LetterY + 80, Color(0, 0, 0, LetterAlpha), 0)

        if LocalPlayer():GetPos():DistToSqr(LetterPos) > 10000 then
            LetterY = Lerp(0.1, LetterY, ScrH())
            LetterAlpha = Lerp(0.1, LetterAlpha, 0)
            if frame and frame.Close then frame:Close() end
            if math.Round(LetterAlpha) <= 10 then
                KillLetter()
            end
        end
    end)
end
usermessage.Hook("ShowLetter", ShowLetter)
