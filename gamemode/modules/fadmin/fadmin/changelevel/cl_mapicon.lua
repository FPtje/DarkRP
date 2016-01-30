local PANEL = {}

function PANEL:Init()
    self.BaseClass.Init(self)
    self:SetPaintBackground(true)
    self:SetIsToggle(true)
    self:SetSize(96, 110)
end

function PANEL:Paint(w, h)
    if self.m_bToggle then
        surface.SetDrawColor(255, 155, 20, 255)
        surface.DrawRect(0, 0, w, h)
    end
    return false
end

function PANEL:UpdateColours(skin)
    return self:SetTextStyleColor(skin.Colours.Button.Normal)
end

function PANEL:OnToggled(selected)
    self:InvalidateLayout(true)
end

function PANEL:OnMousePressed(code)
    DButton.OnMousePressed(self, code)
end

function PANEL:OnMouseReleased(code)
    DButton.OnMouseReleased(self, code)
end

function PANEL:PerformLayout()
    self.m_Image:SetPos(0, 0)
    local w,h = self:GetSize()
    h = h - 14
    self.m_Image:SetSize(w, h)
    self:SetTextInset(5, w / 2)
    DLabel.PerformLayout(self)
end

vgui.Register("FAdmin_MapIcon", PANEL, "DImageButton")
