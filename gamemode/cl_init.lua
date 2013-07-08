GM.Version = "2.5.0"
GM.Name = "DarkRP"
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco, Eusion, Drakehawke"

DeriveGamemode("sandbox")
util.PrecacheSound("earthquake.mp3")

/*---------------------------------------------------------------------------
Names
---------------------------------------------------------------------------*/
-- Make sure the client sees the RP name where they expect to see the name
local pmeta = FindMetaTable("Player")

pmeta.SteamName = pmeta.SteamName or pmeta.Name
function pmeta:Name()
	return GAMEMODE.Config.allowrpnames and self.DarkRPVars and self:getDarkRPVar("rpname")
		or self:SteamName()
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
-- End

local function LoadModules()
	local root = GM.FolderName.."/gamemode/modules/"

	local _, folders = file.Find(root.."*", "LUA")

	for _, folder in SortedPairs(folders, true) do
		if GM.Config.DisabledModules[folder] then continue end

		for _, File in SortedPairs(file.Find(root .. folder .."/sh_*.lua", "LUA"), true) do
			if File == "sh_interface.lua" then continue end
			include(root.. folder .. "/" ..File)
		end
		for _, File in SortedPairs(file.Find(root .. folder .."/cl_*.lua", "LUA"), true) do
			if File == "cl_interface.lua" then continue end
			include(root.. folder .. "/" ..File)
		end
	end
end

GM.Config = {} -- config table

include("config/config.lua")
include("sh_interfaceloader.lua")
include("client/help.lua")

include("client/DRPDermaSkin.lua")
include("client/helpvgui.lua")
include("client/showteamtabs.lua")
include("client/vgui.lua")

include("shared/player_class.lua")
include("shared/animations.lua")
include("shared/commands.lua")
include("shared/entity.lua")
include("shared/MakeThings.lua")
include("shared/Workarounds.lua")

include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")

LoadModules()

DarkRP.finish()

local GUIToggled = false
local HelpToggled = false

local HelpVGUI
function GM:ShowHelp()
	if not HelpVGUI then
		HelpVGUI = vgui.Create("HelpVGUI")
	end

	HelpToggled = not HelpToggled

	HelpVGUI.HelpX = HelpVGUI.StartHelpX
	HelpVGUI:FillHelpInfo()
	HelpVGUI:SetVisible(HelpToggled)
	gui.EnableScreenClicker(HelpToggled)
end

local mouseX, mouseY = ScrW() / 2, ScrH() / 2
function GM:ShowSpare1()
	GUIToggled = not GUIToggled

	if GUIToggled then
		gui.SetMousePos(mouseX, mouseY)
	else
		mouseX, mouseY = gui.MousePos()
	end
	gui.EnableScreenClicker(GUIToggled)
end

function GM:PlayerStartVoice(ply)
	if ply == LocalPlayer() then
		ply.DRPIsTalking = true
		return -- Not the original rectangle for yourself! ugh!
	end
	self.BaseClass:PlayerStartVoice(ply)
end

function GM:PlayerEndVoice(ply)
	if ply == LocalPlayer() then
		ply.DRPIsTalking = false
		return
	end

	self.BaseClass:PlayerEndVoice(ply)
end

function GM:OnPlayerChat()
end

local FKeyBinds = {
	["gm_showhelp"] = "ShowHelp",
	["gm_showteam"] = "ShowTeam",
	["gm_showspare1"] = "ShowSpare1",
	["gm_showspare2"] = "ShowSpare2"
}

function GM:PlayerBindPress(ply, bind, pressed)
	self.BaseClass:PlayerBindPress(ply, bind, pressed)

	local bnd = string.match(string.lower(bind), "gm_[a-z]+[12]?")
	if bnd and FKeyBinds[bnd] and GAMEMODE[FKeyBinds[bnd]] then
		GAMEMODE[FKeyBinds[bnd]](GAMEMODE)
	end

	return
end


function GM:InitPostEntity()
	hook.Call("TeamChanged", GAMEMODE, 1, 1)
end

function GM:TeamChanged(before, after)
	self:RemoveHelpCategory(0)
	if RPExtraTeams[after] and RPExtraTeams[after].help then
		self:AddHelpCategory(0, RPExtraTeams[after].name .. " help")
		self:AddHelpLabels(0, RPExtraTeams[after].help)
	end
end

local function OnChangedTeam(um)
	hook.Call("TeamChanged", GAMEMODE, um:ReadShort(), um:ReadShort())
end
usermessage.Hook("OnChangedTeam", OnChangedTeam)
