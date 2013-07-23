local PANEL = {}

local green = Color(0, 150, 0)
local red = Color(140, 0, 0)

function PANEL:Init()
	self:SetFont("DarkRPHUD2")
	self:SetColor(green)
	self:DockMargin(0, 5, 0, 0)
end

function PANEL:setChatCommand(command)
	self.chatCommand = command
	local text = string.format("%s%s - %s", GAMEMODE.Config.chatCommandPrefix, command.command, command.description)
	self:SetAutoStretchVertical(true)
	self:SetWrap(true)
	self:SetText(text)
	self:refresh()
end

function PANEL:refresh()
	local color = self.chatCommand.condition and not self.chatCommand.condition(LocalPlayer()) and red or green
	self:SetColor(color)
end

derma.DefineControl("F1ChatCommandLabel", "Chat command label", PANEL, "DLabel")
