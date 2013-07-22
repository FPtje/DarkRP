local PANEL = {}

function PANEL:Init()
	self:SetFont("GModToolSubtitle")
end

derma.DefineControl("F1MenuLabel", "DarkRP F1 menu title label", PANEL, "DLabel")
