include("shared.lua")
local defaultHTML

-- I love the garry's mod wiki!
-- Credits to whoever made this function!
local function WorldToScreen(vWorldPos, vPos, vScale, aRot)
    vWorldPos = vWorldPos - vPos
    vWorldPos:Rotate(Angle(0, -aRot.y, 0))
    vWorldPos:Rotate(Angle(-aRot.p, 0, 0))
    vWorldPos:Rotate(Angle(0, 0, -aRot.r))

    return vWorldPos.x / vScale, (-vWorldPos.y) / vScale
end

function ENT:LoadPage()
    local Page = self.MOTDPage:GetString()
    if string.lower(Page) == "data/fadmin/motd.txt" or string.lower(Page) == "default" then
        self.HTML:SetHTML(defaultHTML)
    elseif string.lower(string.sub(Page, -4)) == ".txt" and string.lower(string.sub(Page, 1, 5)) == "data/" then -- If it's a text file somewhere in data...
        Page = string.sub(Page, 6)
        self.HTML:SetHTML(file.Read(Page, "DATA") or "")
    else
        self.HTML:OpenURL(Page)
    end
end

function ENT:Initialize()
    self.MOTDPage = GetConVar("_FAdmin_MOTDPage")
    self.Disabled = true
    self.LastDrawn = CurTime()
    self.HTML = self.HTMLControl or vgui.Create("HTML")
    self.HTML:SetPaintedManually(false)
    self.HTML:SetPos(-512, -256)
    self.HTMLWidth = 1448
    self.HTMLHeight = 724
    self.HTML:SetSize(self.HTMLWidth, self.HTMLHeight)
    self:LoadPage()

    self.HTML:SetVisible(false)
    self.HTML:SetKeyboardInputEnabled(false)
    timer.Simple(0, function() -- Fix areas of the FAdmin scoreboard coming unclickable
        self.HTML:SetPaintedManually(true)
    end)
end

function ENT:Think()
    if not self.HTML or self.Disabled or self.HTMLCloseButton then
        self.HTMLMat = nil
    else
        self.HTML:UpdateHTMLTexture()
        self.HTMLMat = self.HTML:GetHTMLMaterial()
    end
    self:NextThink(CurTime() + 0.1)
end

local gripTexture = surface.GetTextureID("sprites/grip")
local ArrowTexture = surface.GetTextureID("gui/arrow")
local color_white = color_white
local color_darkgrey = Color(100, 100, 100, 255)

function ENT:Draw()
    self:DrawModel()

    local pos = self:GetPos()
    local ply = LocalPlayer()
    if pos:DistToSqr(ply:GetShootPos()) > 90000 then return end

    if CurTime() - self.LastDrawn > 0.5 then
        self.Disabled = true --Disable it again when you stop looking at it
    end

    self.LastDrawn = CurTime()
    local IsAdmin = ply:IsAdmin()
    local HasPhysgun = ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == "weapon_physgun"
    local isUsing = (HasPhysgun and ply:KeyDown(IN_ATTACK)) or ply:KeyDown(IN_USE)

    surface.SetFont("Roboto20")
    local TextPosX = surface.GetTextSize("Physgun/use the button to see the MOTD!") * (-0.5)

    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 90)

    local posX, posY = WorldToScreen(ply:GetEyeTrace().HitPos, self:GetPos() + ang:Up() * 3, 0.25, ang)
    render.SuppressEngineLighting(true)
    cam.Start3D2D(self:GetPos() + ang:Up() * 3, ang, 0.25)

        if self.Disabled then
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(-512, 256, 1024, -512)
            surface.SetTextColor( 255, 255, 255, 255 )
            surface.SetTextPos( TextPosX, 0 )
            surface.DrawNonParsedText("Physgun/use the button to see the MOTD!")

            draw.WordBox(4, -16, 24, "Click!", "default", color_darkgrey, color_white)

            surface.SetDrawColor(255, 255, 255, 255)
            if IsAdmin and HasPhysgun then
                surface.SetTexture(gripTexture)
                surface.DrawTexturedRect(-10, 240, 16, 16)
            end
            if isUsing then

                posX, posY = math.Clamp(posX, -506, 506), math.Clamp(posY, -250, 250)
                surface.SetTexture(ArrowTexture)
                surface.DrawTexturedRectRotated(posX + 5, posY + 5, 16, 16, 45)

                -- Clicking button
                if posX > -16 and posX < 16 and posY > 24 and posY < 48 then
                    self:LoadPage()
                    self.Disabled = false
                    self.CanClickAgain = CurTime() + 1
                end
            end
        elseif not self.HTMLMat then
            self.HTML:SetVisible(true)
            self.HTML:SetKeyboardInputEnabled(true)
            self.HTML:SetPaintedManually(false)
            self.HTML:UpdateHTMLTexture()

            timer.Simple(0, function() -- Fix HTML material
                self.HTML:SetPaintedManually(true)
                self.HTML:SetVisible(false)
                self.HTML:SetKeyboardInputEnabled(false)
            end)

        else
            surface.SetMaterial(self.HTMLMat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(-512, -256, self.HTMLWidth, self.HTMLHeight)
        end

    cam.End3D2D()
    render.SuppressEngineLighting(false)
    if self.HTMLCloseButton then return end

    --Drawing the actual HTML panel:

    if isUsing and posX > -500 and posX < 500 and posY < 250 and posY > -250 and
    not self.Disabled and self.HTML and self.HTML:IsValid() and self.CanClickAgain and CurTime() > self.CanClickAgain then
        self.CanClickAgain = CurTime() + 1
        self.HTML:SetPaintedManually(false)
        self.HTML:SetPos(0, 100)
        self.HTML:SetSize(ScrW(), ScrH() - 100)
        gui.EnableScreenClicker(true)
        -- gui.SetMousePos(posX/1024*ScrW(), posY/512*(ScrH() - 100) + 100)
        self.HTMLCloseButton = self.HTMLCloseButton or vgui.Create("DButton")
        self.HTMLCloseButton:SetPos(ScrW() - 100, 0)
        self.HTMLCloseButton:SetSize(100, 100)
        self.HTMLCloseButton:SetText("X")
        self.HTMLCloseButton:SetVisible(true)
        self.HTML:SetVisible(true)
        self.HTML:RequestFocus()
        self.HTML:SetKeyboardInputEnabled(true)
        self.HTML:MakePopup()

        function self.HTMLCloseButton.DoClick() -- Revert to drawing on the prop
            self.HTML:SetPos(-512, -256)
            self.HTML:SetSize(self.HTMLWidth, self.HTMLHeight)
            self.HTML:SetPaintedManually(true)
            self.HTML:SetKeyboardInputEnabled(false)
            self.HTML:SetVisible(false)
            gui.EnableScreenClicker(false)
            self.HTMLCloseButton:Remove()
            self.HTMLCloseButton = nil
        end
    end
end

defaultHTML = [[
<html>
<title>MOTD!</title>
<body bgcolor="888888">
<center><h1>Example MOTD/Instructions on how to set a proper MOTD</h1></center>
<h2>Of course you have to be superadmin or owner.</h2>
<ol>
<li>Copy the website URL to the clipboard<br></li>
<li>Enter the command: FAdmin MOTDPage "your website here"<br><br></li>
<i>Example:</i><br>
FAdmin MOTDPage "www.facepunch.com"
</body>
</html>]]
