local PANEL = {}

function PANEL:Init()
	//self:SetBackgroundColor(Color(0, 0, 0, 0))
	self:SetVerticalScrollbarEnabled(true)
end

function PANEL:fillLabels(tbl)
	self:Clear()
	for i, cmd in ipairs(tbl) do
		local lbl = vgui.Create("F1ChatCommandLabel", self)
		lbl:setChatCommand(cmd)
		lbl:Dock(TOP)
	end
end

derma.DefineControl("F1ChatCommandPanel", "", PANEL, "DPanel")
