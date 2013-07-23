local PANEL = {}

AccessorFunc(PANEL, "m_bgColor", "BackgroundColor")
function PANEL:Init()
	self:SetFocusTopLevel(true)
	self:SetSize(ScrW() * 0.9, ScrH() * 0.9)
	self:SetBackgroundColor(Color(0, 0, 0, 220))

	self:SetPos(-self:GetWide(), ScrH() * 0.05)

	self.slideInTime = self.slideInTime or 0.3
	self.toggled = false

	self.lblChatCommands = vgui.Create("F1MenuTitleLabel", self)
	self.lblChatCommands:SetText(DarkRP.getPhrase("f1ChatCommandTitle"))

	self.txtChatCommandSearch = vgui.Create("F1SearchBox", self)
	self.txtChatCommandSearch.OnChange = fn.Curry(self.refresh, 2)(self)

	self.pnlChatCommands = vgui.Create("F1ChatCommandPanel", self)
	self.pnlChatCommands.DoClick = fprint

	self.lblWiki = vgui.Create("F1MenuTitleLabel", self)
	self.lblWiki:SetText(DarkRP.getPhrase("f1WikiTitle"))

	self.htmlWikiControls = vgui.Create("DHTMLControls", self)
	self.htmlWikiControls.HomeURL = GAMEMODE.Config.F1MenuHelpPage

	self.htmlWiki = vgui.Create("HTML", self)
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
	self.animationStart = RealTime()
	self.slideRight = true
	self.toggled = true
	self:MakePopup()
	self.txtChatCommandSearch:RequestFocus()
end

function PANEL:slideOut()
	self.txtChatCommandSearch.F1Down = true
	self.animationStart = RealTime()
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
	local realtime = RealTime()
	if (self.animationStart or 0) < (realtime - self.slideInTime) then return end

	local progress = (realtime - self.animationStart) / self.slideInTime * math.pi / 2
	progress = math.sin(progress)
	progress = self.slideRight and 1 - progress or progress

	local x, y = self:GetPos()
	self:SetPos(-self:GetWide() * progress, y)
end

function PANEL:Paint()
	local x, y = self:GetPos()
	local w, h = self:GetSize()
	draw.RoundedBox(4, 0, 0, w, h, self:GetBackgroundColor())
end

derma.DefineControl("F1MenuPanel", "", PANEL, "EditablePanel")
