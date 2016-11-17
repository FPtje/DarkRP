//=============================================================================//
//  ___  ___   _   _   _    __   _   ___ ___ __ __
// |_ _|| __| / \ | \_/ |  / _| / \ | o \ o \\ V /
//  | | | _| | o || \_/ | ( |_n| o ||   /   / \ /
//  |_| |___||_n_||_| |_|  \__/|_n_||_|\\_|\\ |_|  2007
//
//=============================================================================//
-- Edited for FAdmin by FPtje. Original credits to team Garry.

language.Add("GameModeChoice", "Gamemode Choice")
local PANEL = {}

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Init()
	self:EnableVerticalScrollbar( true )
	self:SetSpacing(10)
	self:SetPadding(10)
end

function PANEL:SetupSinglePlayer()

	local GameModes = GetGamemodes()

	local GameModeSettings = vgui.Create("DForm", self )
		GameModeSettings:SetName("#GameModeChoice")

		local MapListOptions = self
		// Gamemode Override
		local mc = GameModeSettings:ComboBox("Gamemode:", "sv_gamemodeoverride")
		mc:AddChoice("")
		for k, v in ipairs( GameModes ) do
			mc:AddChoice( v.Name )
			function mc:OnSelect(index, value, data)
				MapListOptions.Controller.CurrentGamemode = value
			end
		end

		GameModeSettings:Help("If it's blank, it will changelevel to the current gamemode. If you enter a different gamemode, it will changelevel to that.")

	self:AddItem(GameModeSettings)
end
vgui.Register("FAdmin_MapListOptions", PANEL, "DPanelList")