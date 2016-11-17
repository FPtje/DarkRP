local PANEL = {}

AccessorFunc(PANEL, "m_bgColor", "BackgroundColor")
function PANEL:Init()
    self:SetFocusTopLevel(true)
    self:SetSize(ScrW() * 0.9, ScrH() * 0.9)
    self:SetBackgroundColor(Color(0, 0, 0, 220))

    self:SetPos(-self:GetWide(), ScrH() * 0.05)

    -- Can be removed once https://github.com/garrynewman/garrysmod/pull/1141 is merged.
    -- It is here so it is set BEFORE the following panels are created.
    -- Normally, it is set in DarkRP.openF1Menu().
    self:SetSkin(GAMEMODE.Config.DarkRPSkin)

    self.slideInTime = self.slideInTime or 0.3
    self.toggled = false

    self.lblChatCommands = vgui.Create("F1MenuTitleLabel", self)
    self.lblChatCommands:SetText(DarkRP.getPhrase("f1ChatCommandTitle"))

    self.txtChatCommandSearch = vgui.Create("F1SearchBox", self)
    self.txtChatCommandSearch.OnChange = fn.Curry(self.refresh, 2)(self)
    self.txtChatCommandSearch.OnMousePressed = fn.Curry(self.OnMousePressed, 2)(self)

    self.pnlChatCommands = vgui.Create("F1ChatCommandPanel", self)
    self.pnlChatCommands.OnMousePressed = fn.Curry(self.OnMousePressed, 2)(self)

    self.lblWiki = vgui.Create("F1MenuTitleLabel", self)
    self.lblWiki:SetText(GAMEMODE.Config.F1MenuHelpPageTitle)

    self.htmlWikiControls = vgui.Create("F1HTMLControls", self)
    self.htmlWikiControls.HomeURL = GAMEMODE.Config.F1MenuHelpPage

    self.htmlWiki = vgui.Create("F1HTML", self)
    self.htmlWiki:OpenURL(GAMEMODE.Config.F1MenuHelpPage)
    self.htmlWikiControls:SetHTML(self.htmlWiki)
end

function PANEL:PerformLayout()
    self.lblChatCommands:SetPos(20, 20)
    self.lblChatCommands:SizeToContents()

    self.txtChatCommandSearch:SetPos(20, 80)

    self.pnlChatCommands:StretchToParent(20, 120, nil, 20)
    self.pnlChatCommands:SetWide(self:GetWide() * 0.4 - 20)

    self.htmlWikiControls:StretchToParent(self:GetWide() * 0.4 + 20, 80, 20, nil)
    self.htmlWiki:StretchToParent(self:GetWide() * 0.4 + 20, 120, 20, 20)

    self.lblWiki:SetPos(self:GetWide() * 0.4 + 20, 20)
    self.lblWiki:SizeToContents()
end

function PANEL:OnMousePressed()
    self:SetKeyboardInputEnabled(true)
    self.txtChatCommandSearch:RequestFocus()
end

function PANEL:slideIn()
    self:SetVisible(true)
    self.slideRight = true
    self.toggled = true
    self:MakePopup()
    self.txtChatCommandSearch:RequestFocus()
end

function PANEL:slideOut()
    self.txtChatCommandSearch.F1Down = true
    self.progress = 1
    self.slideRight = false
    self.toggled = false
    self:SetVisible(false)
end

function PANEL:refresh()
    local commands = self.searchAlg(self.txtChatCommandSearch:GetText())
    self.pnlChatCommands:fillLabels(commands)
end

function PANEL:setSlideInTime(time)
    self.slideInTime = time
end

function PANEL:setSearchAlgorithm(func)
    self.searchAlg = func
end

function PANEL:AnimationThink()
    self.progress = self.progress or 1
    self.progress = self.slideRight and math.max(0, self.progress - FrameTime() / self.slideInTime) or math.min(1, self.progress + FrameTime())

    local _, y = self:GetPos()
    self:SetPos(-self:GetWide() * self.progress, y)
end

function PANEL:Paint()
    local w, h = self:GetSize()
    draw.RoundedBoxEx(4, 0, 0, w, h, self:GetBackgroundColor(), false, true, false, true)
end

derma.DefineControl("F1MenuPanel", "", PANEL, "EditablePanel")
