surface.CreateFont("SleekF1MenuTitle", {
		size = 50,
		weight = 500,
		antialias = true,
		shadow = false,
		font = "coolvetica"})

local PANEL = {}

function PANEL:Init()
	self:SetFont("SleekF1MenuTitle")
end

derma.DefineControl("SleekF1MenuTitleLabel", "fprp SleekF1 menu title label", PANEL, "DLabel")
