local function GetTextHeight(font, str)
	surface.SetFont(font)
	local w, h = surface.GetTextSize(str)
	return h
end

local HelpPanel = {}

function HelpPanel:Init()
	self.StartHelpX = -ScrW()
	self.HelpX = self.StartHelpX

	self.title = vgui.Create("DLabel", self)
	self.title:SetText(GAMEMODE.Name)

	self.scrolltext = vgui.Create("DLabel", self)
	self.scrolltext:SetText(DarkRP.getPhrase("mouse_wheel_to_scroll"))

	self.HelpInfo = vgui.Create("Panel", self)

	self.vguiHelpCategories = {}
	self.vguiHelpLabels = {}
	self.Scroll = 0
end

function HelpPanel:FillHelpInfo()
	local LabelIndex = 0
	local yoffset = 0

	self.HelpInfo:Clear()
	for k, v in pairs(GAMEMODE:getHelpCategories()) do
		self.vguiHelpCategories[k] = vgui.Create("DLabel", self.HelpInfo)
		self.vguiHelpCategories[k]:SetText(v.name)
		self.vguiHelpCategories[k].OrigY = yoffset
		self.vguiHelpCategories[k]:SetPos(5, yoffset)
		self.vguiHelpCategories[k]:SetFont("GModToolSubtitle")
		self.vguiHelpCategories[k]:SetColor(Color(140, 0, 0, 200))
		self.vguiHelpCategories[k]:SetExpensiveShadow(2, Color(0,0,0,255))
		self.vguiHelpCategories[k]:SizeToContents()

		surface.SetFont("ChatFont")

		local labelh = GetTextHeight("ChatFont", "A")
		local index = 0
		local labelCount = table.Count(v.labels)
		for i, label in pairs(v.labels) do
			local labelw = surface.GetTextSize(label)
			LabelIndex = LabelIndex + 1

			self.vguiHelpLabels[LabelIndex] = vgui.Create("DLabel", self.HelpInfo)
			self.vguiHelpLabels[LabelIndex]:SetFont("ChatFont")
			self.vguiHelpLabels[LabelIndex]:SetText(label)
			self.vguiHelpLabels[LabelIndex]:SetWidth(labelw)
			self.vguiHelpLabels[LabelIndex].OrigY = yoffset + 25 + index * labelh
			self.vguiHelpLabels[LabelIndex]:SetPos(5, yoffset + 25 + index * labelh)
			self.vguiHelpLabels[LabelIndex]:SetColor(Color(255, 255, 255, 200))

			index = index + 1
		end

		local cath = GetTextHeight("GModToolSubtitle", "A")

		yoffset = yoffset + (cath + 15) + labelCount * labelh
	end

	self.ScrollSize = yoffset
end

function HelpPanel:PerformLayout()
	self:SetSize(-self.StartHelpX, ScrH() - 70)

	for k, v in pairs(self.vguiHelpCategories) do
		if not ValidPanel(v) then self.vguiHelpCategories[k] = nil continue end

		v:SetPos(5, v.OrigY - self.Scroll)
		v:SizeToContents()
	end

	for k, v in pairs(self.vguiHelpLabels) do
		if not ValidPanel(v) then self.vguiHelpLabels[k] = nil continue end

		v:SetPos(5, v.OrigY - self.Scroll)
		v:SizeToContents()
	end

	self.HelpInfo:SetPos(5, 70)
	self.HelpInfo:SetSize(self:GetWide() - 5, self:GetTall() - 5)

	self.title:SetPos(5, 5)
	self.title:SizeToContents()

	self.scrolltext:SetPos(250, 25)
	self.scrolltext:SizeToContents()
end

function HelpPanel:ApplySchemeSettings()
	self.title:SetFont("GModToolName")
	self.title:SetFGColor(Color(255, 255, 255, 255))

	self.scrolltext:SetFont("GModToolSubtitle")
	self.scrolltext:SetFGColor(Color(150, 50, 50, 255))
end

function HelpPanel:OnMouseWheeled(delta)
	local scroll = math.Max(self.Scroll - delta * FrameTime() * 2000, 0)
	scroll = math.Min(scroll, self.ScrollSize)
	self.Scroll = scroll
	self:InvalidateLayout()
end

function HelpPanel:Paint()
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 150))
end

function HelpPanel:Think()
	if self.HelpX < 0 then
		self.HelpX = self.HelpX + 2400 * FrameTime()
	end

	if self.HelpX > 0 then
		self.HelpX = 0
	end

	self:SetPos(self.HelpX, 20)
end

vgui.Register("HelpVGUI", HelpPanel, "Panel")
