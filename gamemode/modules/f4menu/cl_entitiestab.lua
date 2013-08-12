local PANEL = {}

function PANEL:Rebuild()
	self:GetCanvas():StretchToParent(0, 0, 0, 0)
	local height = 0
	for i, item in pairs(self.Items) do
		item:SetWide(self:GetWide() / 2 - 10)
		local goRight = i % 2 == 0
		local x = goRight and self:GetWide() / 2 - 10 + 2 or 0
		item:SetPos(x, height)

		if goRight then
			height = height + math.Max(item:GetTall(), self.Items[i - 1]:GetTall()) + 2
		end
	end
end

function PANEL:generateButtons()
	// override dis shit
end

derma.DefineControl("F4MenuEntitiesBase", "", PANEL, "DPanelList")
