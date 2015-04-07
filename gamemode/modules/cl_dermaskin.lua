if SERVER then return end

local SKIN		= {}

SKIN.PrintName	= 'fprp'
SKIN.Author		= 'aStonedPenguin'



g_panel = Material("materials/fprp/panel_bg.png");
g_button = Material("materials/fprp/button.png");
g_close = Material("materials/fprp/close.png");

----------------------------------------------------------------
-- Frames
----------------------------------------------------------------
function SKIN:PaintFrame(self, w, h)
	surface.SetDrawColor(255,255,255,255);
	surface.SetMaterial(g_panel);
	surface.DrawTexturedRect(0, 0, w, h);
	
end

function SKIN:PaintPanel(self, w, h)
	if not (self.m_bBackground) then return end

	surface.SetDrawColor(255,255,255,255);
	surface.SetMaterial(g_panel);
	surface.DrawTexturedRect(0, 0, w, h);
end

function SKIN:PaintShadow() end

function SKIN:PaintTabListPanel(self, w, h)
	surface.SetDrawColor(255,255,255,255);
	surface.SetMaterial(g_panel);
	surface.DrawTexturedRect(0, 0, w, h);
end


function SKIN:PaintButton(self, w, h)
	surface.SetDrawColor(255,255,255,255);
	surface.SetMaterial(g_button);
	surface.DrawTexturedRect(0, 0, 20, 20);
end


function SKIN:PaintWindowCloseButton(panel, w, h)
	if not (panel.m_bBackground) then return end

	surface.SetDrawColor(255,255,255,255);
	surface.SetMaterial(g_close);
	surface.DrawTexturedRect(0, 0, w, h);
end

derma.DefineSkin(SKIN.PrintName, 'fprp derma skin', SKIN);



function GM:ForceDermaSkin()
	return SKIN.PrintName
end