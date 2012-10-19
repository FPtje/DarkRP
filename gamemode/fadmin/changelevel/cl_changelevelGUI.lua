//=============================================================================//
//  ___  ___   _   _   _    __   _   ___ ___ __ __
// |_ _|| __| / \ | \_/ |  / _| / \ | o \ o \\ V /
//  | | | _| | o || \_/ | ( |_n| o ||   /   / \ /
//  |_| |___||_n_||_| |_|  \__/|_n_||_|\\_|\\ |_|  2007
//
//=============================================================================//
-- Edited for FAdmin by FPtje. Original credits to team Garry.
local PANEL = {}

/*---------------------------------------------------------
	Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )

	self:SetDeleteOnClose( false )

	self:SetTitle("Change level")

	self:CreateControls()

end


/*---------------------------------------------------------
	CreateControls
---------------------------------------------------------*/
function PANEL:CreateControls()

	self.StartGame = vgui.Create("FAdmin_StartGame", self )
	self.MapSheet = vgui.Create("DPropertySheet", self )

	self.MapIcons = vgui.Create("MapListIcons")
	self.MapIcons:SetController( self.StartGame )
	self.MapIcons:Setup()

	local Options = vgui.Create("FAdmin_MapListOptions", self )
	Options.Controller = self.StartGame
	Options:SetupSinglePlayer()

	self.MapSheet:AddSheet("Icons", self.MapIcons, "icon16/application_view_tile.png")
	self.MapSheet:AddSheet("Options", Options, "icon16/application_view_detail.png")

end

/*---------------------------------------------------------
	PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( 450, ScrH() * 0.8 )

	self.MapSheet:SetPos( 8, 25 )
	self.MapSheet:SetSize( self:GetWide() - 16, self:GetTall() - 25 - 8 - 60 - 8 )
	self.MapSheet:InvalidateLayout()

	self.StartGame:SetPos( 8, self:GetTall() - 60 - 8 )
	self.StartGame:SetSize( self:GetWide() - 16, 60 )

	self.BaseClass.PerformLayout( self )

end

function PANEL:RebuildFavourites()

	self.MapIcons:RebuildFavourites()

end

vgui.Register("FAdmin_Changelevel", PANEL, "DFrame")