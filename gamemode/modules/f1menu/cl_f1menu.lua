local chatCommands

local function searchChatCommand(str)
	if not str or str == "" then return chatCommands end
	-- Fuzzy search regex string
	str = ".*" .. str:gsub("[a-zA-Z0-9]", function(a) return a:lower() .. ".*" end)
	local condition = fn.Compose{fn.Curry(fn.Flip(string.match), 2)(str), fn.Curry(fn.GetValue, 2)("command")}
	return fn.Compose{table.ClearKeys, fn.Curry(fn.Filter, 2)(condition)}(chatCommands)
end

local SLEEKF1MENU
function fprp.openSLEEKF1MENU()
	chatCommands = chatCommands or fprp.getSortedChatCommands()

	SLEEKF1MENU = SLEEKF1MENU or vgui.Create("SLEEKF1MENUPanel")
	SLEEKF1MENU:SetSkin(GAMEMODE.Config.fprpSkin)
	SLEEKF1MENU:setSearchAlgorithm(searchChatCommand)
	SLEEKF1MENU:refresh()
	SLEEKF1MENU:slideIn()
end

function fprp.closeSLEEKF1MENU()
	SLEEKF1MENU:slideOut()
end

function GM:ShowHelp()
	if not SLEEKF1MENU or not SLEEKF1MENU.toggled then
		fprp.openSLEEKF1MENU()
	else
		fprp.closeSLEEKF1MENU()
	end
end
