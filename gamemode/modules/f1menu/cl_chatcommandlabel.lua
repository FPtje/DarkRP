local PANEL = {}

local green = Color(0, 150, 0)
local red = Color(140, 0, 0)

function PANEL:Init()
	self:SetFont("DarkRPHUD2")
	self:SetColor(green)
end

function PANEL:setChatCommand(command)
	self.chatCommand = command
	self:SetText(command.command)
	self:refresh()
end

function PANEL:refresh()
	local color = self.command.condition and not self.command.condition(LocalPlayer()) and red or green
	self:SetColor(color)
end

derma.DefineControl("F1ChatCommandLabel", "Chat command label", PANEL, "DLabel")
