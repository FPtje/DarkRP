surface.CreateFont("F1MenuTitle", {
		size = 50,
		weight = 500,
		antialias = true,
		shadow = false,
		font = "coolvetica"})

local PANEL = {}

function PANEL:Init()
	self:SetFont("F1MenuTitle")
end

derma.DefineControl("F1MenuTitleLabel", "fprp F1 menu title label", PANEL, "DLabel")
