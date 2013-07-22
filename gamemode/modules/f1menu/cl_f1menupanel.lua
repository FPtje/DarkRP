local PANEL = {}

function PANEL:Init()
	self:SetFocusTopLevel(true)
	self:SetSize(ScrW() * 0.9, ScrH() * 0.9)
	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)
	self:SetBackgroundColor(Color(0, 0, 0, 200))

	self:SetPos(-self:GetWide(), ScrH() * 0.05)


	self.slideInTime = self.slideInTime or 0.3
	self.toggled = false

	self.lblChatCommands = vgui.Create("F1MenuTitleLabel", self)
	self.lblChatCommands:SetText(DarkRP.getPhrase("f1ChatCommandTitle"))

	self.txtChatCommandSearch = vgui.Create("F1SearchBox", self)
	self.txtChatCommandSearch:RequestFocus()

	self.pnlChatCommands = vgui.Create("F1ChatCommandPanel", self)
end

function PANEL:PerformLayout()
	self.lblChatCommands:SetPos(20, 20)
	self.lblChatCommands:SizeToContents()

	self.txtChatCommandSearch:SetPos(20, 80)

	self.pnlChatCommands:StretchToParent(20, 120, 10, 20)
end

function PANEL:slideIn()
	self.animationStart = RealTime()
	self.slideRight = true
	self.toggled = true
	self:MakePopup()
end

function PANEL:slideOut()
	self.animationStart = RealTime()
	self.slideRight = false
	self.toggled = false
end

function PANEL:refresh()

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

derma.DefineControl("F1MenuPanel", "", PANEL, "DPanel")
