local SLEEKPANEL = {}

AccessorFunc(SLEEKPANEL, "m_bgColor", "BackgroundColor");
function SLEEKPANEL:Init()
	self:SetFocusTopLevel(true);
	self:SetSize(ScrW() * 0.9, ScrH() * 0.9);
	self:SetBackgroundColor(Color(0, 0, 0, 220));

	self:SetPos(-self:GetWide(), ScrH() * 0.05);

	self.slideInTime = self.slideInTime or 0.3
	self.toggled = false

	self.lblChatCommands = vgui.Create("SleekF1MenuTitleLabel", self);
	self.lblChatCommands:SetText(fprp.getPhrase("f1ChatCommandTitle"));

	self.txtChatCommandSearch = vgui.Create("SleekF1SearchBox", self);
	self.txtChatCommandSearch.OnChange = fn.Curry(self.refresh, 2)(self);
	self.txtChatCommandSearch.OnMousePressed = fn.Curry(self.OnMousePressed, 2)(self);

	self.pnlChatCommands = vgui.Create("SleekF1ChatCommandPanel", self);
	self.pnlChatCommands.OnMousePressed = fn.Curry(self.OnMousePressed, 2)(self);

	self.lblWiki = vgui.Create("SleekF1MenuTitleLabel", self);
	self.lblWiki:SetText(GAMEMODE.Config.SleekF1MenuHelpPageTitle);

	self.htmlWikiControls = vgui.Create("SleekF1HTMLControls", self);
	self.htmlWikiControls.HomeURL = GAMEMODE.Config.SleekF1MenuHelpPage

	self.htmlWiki = vgui.Create("SleekF1HTML", self);
	self.htmlWiki:OpenURL(GAMEMODE.Config.SleekF1MenuHelpPage);
	self.htmlWikiControls:SetHTML(self.htmlWiki);
end

function SLEEKPANEL:PerformLayout()
	self.lblChatCommands:SetPos(20, 20);
	self.lblChatCommands:SizeToContents();

	self.txtChatCommandSearch:SetPos(20, 80);

	self.pnlChatCommands:StretchToParent(20, 120, nil, 20);
	self.pnlChatCommands:SetWide(self:GetWide() * 0.4 - 20);

	self.htmlWikiControls:StretchToParent(self:GetWide() * 0.4 + 20, 80, 20, nil);
	self.htmlWiki:StretchToParent(self:GetWide() * 0.4 + 20, 120, 20, 20);

	self.lblWiki:SetPos(self:GetWide() * 0.4 + 20, 20);
	self.lblWiki:SizeToContents();
end

function SLEEKPANEL:OnMousePressed()
	self:SetKeyboardInputEnabled(true);
	self.txtChatCommandSearch:RequestFocus();
end

function SLEEKPANEL:slideIn()
	self:SetVisible(true);
	self.slideRight = true
	self.toggled = true
	self:MakePopup();
	self.txtChatCommandSearch:RequestFocus();
end

function SLEEKPANEL:slideOut()
	self.txtChatCommandSearch.F1Down = true
	self.progress = 1
	self.slideRight = false
	self.toggled = false
	self:SetVisible(false);
end

function SLEEKPANEL:refresh()
	local commands = self.searchAlg(self.txtChatCommandSearch:GetText());
	self.pnlChatCommands:fillLabels(commands);
end

function SLEEKPANEL:setSlideInTime(time)
	self.slideInTime = time
end

function SLEEKPANEL:setSearchAlgorithm(func)
	self.searchAlg = func
end

function SLEEKPANEL:AnimationThink()
	self.progress = self.progress or 1
	self.progress = self.slideRight and math.max(0, self.progress - FrameTime()/self.slideInTime) or math.min(1, self.progress + FrameTime());

	local x, y = self:GetPos();
	self:SetPos(-self:GetWide() * self.progress, y);
end

function SLEEKPANEL:Paint()
	local x, y = self:GetPos();
	local w, h = self:GetSize();
	draw.RoundedBoxEx(4, 0, 0, w, h, self:GetBackgroundColor(), false, true, false, true);
end

derma.DefineControl("SleekF1MenuPanel", "", SLEEKPANEL, "EditablePanel");
