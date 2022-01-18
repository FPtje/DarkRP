include("shared.lua")

function ENT:Initialize()
    self:initVars()
    self:initVarsClient()
end

function ENT:initVarsClient()
    self.colorBackground = Color(140, 0, 0, 100)
    self.colorText = color_white
    self.donateAnimColor = Color(20, 100, 20)

    self.rotationSpeed = 130
    self.rotationOffset = 0
    self:InitCsModel()

    self.firstDonateAnimation = nil
    self.lastDonateAnimation = nil
    self.donateAnimSpeed = 0.3
end

function ENT:InitCsModel()
    self.csModel = ClientsideModel(self.model)
    self.csModel:SetPos(self:GetPos())
    self.csModel:SetParent(self)
    self.csModel:SetModelScale(1.5, 0)
    self.csModel:SetNoDraw(true)
    self:CallOnRemove("csModel", fp{SafeRemoveEntity, self.csModel})
end

function ENT:Draw()
    local Pos = self:GetPos()
    local Ang = self:GetAngles()
    local sysTime = SysTime()
    local eyepos = EyePos()
    local planeNormal = Ang:Up()

    local rotAng = Angle(Ang)
    self.rotationOffset = sysTime % 360 * self.rotationSpeed
    rotAng:RotateAroundAxis(planeNormal, self.rotationOffset)

    -- Something about cs models getting removed on their own...
    if not IsValid(self.csModel) then
        self:InitCsModel()
    end
    self.csModel:SetPos(Pos)
    self.csModel:SetAngles(rotAng)
    if not self:IsDormant() then
        self.csModel:DrawModel()
    end


    local owner = self:Getowning_ent()
    owner = (IsValid(owner) and owner:Nick()) or DarkRP.getPhrase("unknown")
    local title = DarkRP.getPhrase("tip_jar")

    surface.SetFont("HUDNumber5")
    local titleTextWidth, titleTextHeight = surface.GetTextSize(title)
    local ownerTextWidth = surface.GetTextSize(owner)

    Ang:RotateAroundAxis(Ang:Forward(), 90)

    -- The text can be considered to be "standing" on a plane with normal =
    -- Ang:Up(). The vector towards the player's EyePos is projected onto that
    -- plane, normalised and rotated to have the text face the user.
    local relativeEye = eyepos - Pos
    local relativeEyeOnPlane = relativeEye - planeNormal * relativeEye:Dot(planeNormal)
    local textAng = relativeEyeOnPlane:AngleEx(planeNormal)

    textAng:RotateAroundAxis(textAng:Up(), 90)
    textAng:RotateAroundAxis(textAng:Forward(), 90)


    cam.Start3D2D(Pos - Ang:Right() * 11.5 , textAng, 0.2)
        draw.WordBox(2, -titleTextWidth * 0.5, -72                      , title, "HUDNumber5", self.colorBackground, self.colorText)
        draw.WordBox(2, -ownerTextWidth * 0.5, -72 + titleTextHeight + 4, owner, "HUDNumber5", self.colorBackground, self.colorText)

        self:DrawAnims(sysTime)
    cam.End3D2D()
end

function ENT:DrawAnims(sysTime)
    local anim = self.firstDonateAnimation

    while anim do
        if anim.progress > 1 then
            anim = anim.nextDonateAnimation
            self.firstDonateAnimation = anim

            continue
        end

        draw.SimpleText(
            anim.amount,
            "DarkRP_tipjar",
            -anim.textWidth / 2,
            -100 - anim.progress * 200,
            ColorAlpha(self.donateAnimColor, Lerp(anim.progress, 1024, 0)),
            0
        )

        anim.progress = (sysTime - anim.start) * self.donateAnimSpeed

        anim = anim.nextDonateAnimation
    end

    if not self.firstDonateAnimation then
        self.lastDonateAnimation = nil
    end
end

function ENT:Donated(ply, amount)
    local txtAmount = DarkRP.formatMoney(amount)

    surface.SetFont("DarkRP_tipjar")

    local anim = {
        amount = txtAmount,
        start = SysTime(),
        textWidth = surface.GetTextSize(txtAmount),
        progress = 0,
        nextDonateAnimation = nil,
    }

    if self.lastDonateAnimation then
        self.lastDonateAnimation.nextDonateAnimation = anim
    else
        self.firstDonateAnimation = anim
    end

    self.lastDonateAnimation = anim

    self:AddDonation(ply:Nick(), amount)
end

-- Disable halos
function ENT:Think() end
