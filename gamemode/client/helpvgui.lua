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

	self.modinfo = vgui.Create("DLabel", self)
	self.modinfo:SetText(LANGUAGE.get_mod)

	self.scrolltext = vgui.Create("DLabel", self)
	self.scrolltext:SetText(LANGUAGE.mouse_wheel_to_scroll)

	self.HelpInfo = vgui.Create("Panel", self)

	self.vguiHelpCategories = {}
	self.vguiHelpLabels = {}
	self.Scroll = 0
end

function HelpPanel:FillHelpInfo(force)
	self.Filled = true
	local maxpertable = 11
	local helptable = 1
	local yoffset = 0

	if force then
		for k, v in pairs(self.vguiHelpCategories) do
			v:Remove()
			self.vguiHelpCategories[k] = nil
		end
		for k, v in pairs(self.vguiHelpLabels) do
			v:Remove()
			self.vguiHelpLabels[k] = nil
		end
	end

	for k, v in SortedPairsByMemberValue(GAMEMODE:getHelpCategories(), "id") do
		if not self.vguiHelpCategories[v.id] or force then
			local helptext = ""
			local Labels = {}

			self.vguiHelpCategories[v.id] = vgui.Create("DLabel", self.HelpInfo)
			self.vguiHelpCategories[v.id]:SetText(v.name)
			self.vguiHelpCategories[v.id].OrigY = yoffset
			self.vguiHelpCategories[v.id]:SetPos(5, yoffset)
			self.vguiHelpCategories[v.id]:SetFont("GModToolSubtitle")
			self.vguiHelpCategories[v.id]:SetColor(Color(140, 0, 0, 200))
			self.vguiHelpCategories[v.id]:SetExpensiveShadow(2, Color(0,0,0,255))

			for n, m in pairs(GAMEMODE:getHelpLabels()) do
				if m.category == v.id then
					table.insert(Labels, m.text)
				end
			end

			local index = 1
			local HelpText = {}

			for i = 1, math.ceil(#Labels / maxpertable) do
				for n = index, maxpertable * i do
					if n > #Labels then break end
					if not HelpText[i] then HelpText[i] = "" end
					HelpText[i] = HelpText[i] .. Labels[n] .. "\n"
				end

				index = index + maxpertable
			end

			local labelh = GetTextHeight("ChatFont", "A")

			for i = 1, #HelpText do
				self.vguiHelpLabels[i + v.id * 100] = vgui.Create("DLabel", self.HelpInfo)
				self.vguiHelpLabels[i + v.id * 100]:SetText(HelpText[i])
				self.vguiHelpLabels[i + v.id * 100].OrigY = yoffset + 25 + (i - 1) * (maxpertable * labelh)
				self.vguiHelpLabels[i + v.id * 100]:SetPos(5, yoffset + 25 + (i - 1) * (maxpertable * labelh))
				self.vguiHelpLabels[i + v.id * 100]:SetFont("ChatFont")
				self.vguiHelpLabels[i + v.id * 100]:SetColor(Color(255, 255, 255, 200))
			end

			local cath = GetTextHeight("GModToolSubtitle", "A")

			yoffset = yoffset + (cath + 15) + #Labels * labelh
		end
	end
end

function HelpPanel:PerformLayout()
	if not self.Filled then self:FillHelpInfo() end
	self:SetSize(-self.StartHelpX, ScrH() - 70)

	for k, v in pairs(self.vguiHelpCategories) do
		v:SetPos(5, v.OrigY - self.Scroll)
		v:SizeToContents()
	end

	for k, v in pairs(self.vguiHelpLabels) do
		v:SetPos(5, v.OrigY - self.Scroll)
		v:SizeToContents()
	end

	self.HelpInfo:SetPos(5, 70)
	self.HelpInfo:SetSize(self:GetWide() - 5, self:GetTall() - 5)

	self.title:SetPos(5, 5)
	self.title:SizeToContents()

	self.modinfo:SetPos(5, 50)
	self.modinfo:SizeToContents()

	self.scrolltext:SetPos(250, 25)
	self.scrolltext:SizeToContents()
end

function HelpPanel:ApplySchemeSettings()
	self.title:SetFont("GModToolName")
	self.title:SetFGColor(Color(255, 255, 255, 255))

	self.modinfo:SetFont("TargetID")
	self.modinfo:SetFGColor(Color(255, 255, 255, 255))

	self.scrolltext:SetFont("GModToolSubtitle")
	self.scrolltext:SetFGColor(Color(150, 50, 50, 255))
end

function HelpPanel:OnMouseWheeled(delta)
	local scroll = math.Max(self.Scroll - delta * FrameTime() * 2000, 0)
	scroll = math.Min(scroll, #GAMEMODE:getHelpCategories() * 20 + #GAMEMODE:getHelpLabels() * 17)
	self.Scroll = scroll
	self:InvalidateLayout()
end

function HelpPanel:Paint()
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 150))
end

function HelpPanel:Think()
	if self.HelpX < 0 then
		self.HelpX = self.HelpX + 600 * FrameTime()
	end

	if self.HelpX > 0 then
		self.HelpX = 0
	end

	self:SetPos(self.HelpX, 20)
end

vgui.Register("HelpVGUI", HelpPanel, "Panel")