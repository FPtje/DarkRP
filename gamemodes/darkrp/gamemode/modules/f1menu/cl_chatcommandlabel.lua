local PANEL = {}

local green = Color(0, 150, 0)
local red = Color(160, 20, 20)

function PANEL:Init()
    self:SetFont("DarkRPHUD2")
    self:SetColor(green)
    self:DockMargin(0, 5, 0, 0)
end

function PANEL:setChatCommand(command)
    self.chatCommand = command
    local text = string.format("%s%s - %s", GAMEMODE.Config.chatCommandPrefix, command.command, DarkRP.getChatCommandDescription(command.command))
    self:SetAutoStretchVertical(true)
    self:SetWrap(true)
    self:SetText(text)
    self:refresh()
end

local chatCommandError = [[ERROR
The condition of chat command "%s" threw an error:
%s

If this is the command of a custom job, you probably did something wrong when making it.
]]
function PANEL:refresh()
    local condition = self.chatCommand.condition
    if not condition then
        self:SetColor(green)
        return
    end

    local succeeded, returnValue = pcall(self.chatCommand.condition, LocalPlayer())
    if not succeeded then ErrorNoHalt(string.format(chatCommandError, self.chatCommand.command, returnValue)) end

    self:SetColor(succeeded and not returnValue and red or green)
end

derma.DefineControl("F1ChatCommandLabel", "Chat command label", PANEL, "DLabel")
