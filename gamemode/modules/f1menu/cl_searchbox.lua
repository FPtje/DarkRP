local PANEL = {}

function PANEL:Init()
	self:SetWide(100)
end

derma.DefineControl("F1SearchBox", "The search box to search chat commands", PANEL, "DTextEntry")
