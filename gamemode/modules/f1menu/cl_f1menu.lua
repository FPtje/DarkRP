local chatCommands

local function searchChatCommand(str)
	if not str or str == "" then return chatCommands end
	-- Fuzzy search regex string
	str = ".*" .. str:gsub("[a-zA-Z0-9]", function(a) return a:lower() .. ".*" end)
	local condition = fn.Compose{fn.Curry(fn.Flip(string.match), 2)(str), fn.Curry(fn.GetValue, 2)("command")}
	return fn.Compose{table.ClearKeys, fn.Curry(fn.Filter, 2)(condition)}(chatCommands)
end

local F1Menu
function fprp.openF1Menu()
	chatCommands = chatCommands or fprp.getSortedChatCommands()

	F1Menu = F1Menu or vgui.Create("F1MenuPanel")
	F1Menu:SetSkin(GAMEMODE.Config.fprpSkin)
	F1Menu:setSearchAlgorithm(searchChatCommand)
	F1Menu:refresh()
	F1Menu:slideIn()
end

function fprp.closeF1Menu()
	F1Menu:slideOut()
end

function GM:ShowHelp()
	if not F1Menu or not F1Menu.toggled then
		fprp.openF1Menu()
	else
		fprp.closeF1Menu()
	end
end
