local chatCommands

local function searchChatCommand(str)
    if not str or str == "" then return chatCommands end
    -- Fuzzy search regex string
    str = string.PatternSafe(str)
    str = ".*" .. str:gsub("[a-zA-Z0-9]", function(a) return a:lower() .. ".*" end)

    local condition = function(chatCommand) return string.match(chatCommand.command, str) end
    return table.ClearKeys(fn.Filter(condition, chatCommands))
end

local F1Menu
function DarkRP.openF1Menu()
    chatCommands = chatCommands or DarkRP.getSortedChatCommands()

    F1Menu = F1Menu or vgui.Create("F1MenuPanel")
    F1Menu:SetSkin(GAMEMODE.Config.DarkRPSkin)
    F1Menu:setSearchAlgorithm(searchChatCommand)
    F1Menu:refresh()
    F1Menu:slideIn()
end

function DarkRP.closeF1Menu()
    F1Menu:slideOut()
end

function GM:ShowHelp()
    if not F1Menu or not F1Menu.toggled then
        DarkRP.openF1Menu()
    else
        DarkRP.closeF1Menu()
    end
end
