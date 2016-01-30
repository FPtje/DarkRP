local PANEL = {}

function PANEL:Init()
    self:SetBackgroundColor(Color(0, 0, 0, 0))
    self:EnableVerticalScrollbar()
    self:SetSpacing(10)
    self.VBar.Paint = fn.Id
    self.VBar.btnUp.Paint = fn.Id
    self.VBar.btnDown.Paint = fn.Id
end

function PANEL:fillLabels(tbl)
    self:Clear()
    for i, cmd in ipairs(tbl) do
        local lbl = vgui.Create("F1ChatCommandLabel")
        lbl:setChatCommand(cmd)
        lbl.OnMousePressed = self.OnMousePressed
        self:AddItem(lbl)
    end
end

derma.DefineControl("F1ChatCommandPanel", "", PANEL, "DPanelList")
