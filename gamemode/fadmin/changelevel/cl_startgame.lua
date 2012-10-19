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

---------------------------------------------------------*/
function PANEL:Init()
	self.StartGame = vgui.Create("DButton", self )
	self.StartGame:SetText("Change level!")
	self.StartGame:SetSize( 100, 20 )
	self.StartGame.DoClick = function() self:LaunchGame() end
	self.StartGame:SetDisabled( true )
	
	self.Help = vgui.Create("DLabel", self )
	self.Help:SetText("Click on the map you want to change the level to.\nClick Change level! to actually change level")
	self.Help:SetTextColor( Color( 0, 0, 0, 230 ) )
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Paint()
	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 190, 190, 190, 255 ) )
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.StartGame:SetPos( self:GetWide() - self.StartGame:GetWide() - 10, self:GetTall() - self.StartGame:GetTall() - 10 )
	
	self.Help:SetPos( 10, 10 )
	self.Help:SizeToContents()
	
end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetMap( strMap )
	self.Map = strMap
	self.StartGame:SetDisabled( false )
end

/*--------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetMultiplayer()
	self.Multiplayer = true
end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:LaunchGame()

	if (!self.Map) then return end
	RunConsoleCommand("_Fadmin", "Changelevel", self.CurrentGamemode or self.Map, self.CurrentGamemode and self.Map)
	self:GetParent():Close()
end
vgui.Register("FAdmin_StartGame", PANEL, "Panel")
