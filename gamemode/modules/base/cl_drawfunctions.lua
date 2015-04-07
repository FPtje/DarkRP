-- concatenate a space to avoid the text being parsed as valve string
local function safeText(text)
	return string.match(text, "^#([a-zA-Z_]+)$") and text .. " " or text
end

fprp.deLocalise = safeText

function draw.DrawNonParsedText(text, font, x, y, color, xAlign)
	return draw.DrawText(safeText(text), font, x, y, color, xAlign);
end

function draw.DrawNonParsedSimpleText(text, font, x, y, color, xAlign, yAlign)
	return draw.SimpleText(safeText(text), font, x, y, color, xAlign, yAlign);
end

function draw.DrawNonParsedSimpleTextOutlined(text, font, x, y, color, xAlign, yAlign, outlineWidth, outlineColor)
	return draw.SimpleTextOutlined(safeText(text), font, x, y, color, xAlign, yAlign, outlineWidth, outlineColor);
end

function surface.DrawNonParsedText(text)
	return surface.DrawText(safeText(text));
end

function chat.AddNonParsedText(...)
	local tbl = {...}
	for i = 2, #tbl, 2 do
		tbl[i] = safeText(tbl[i]);
	end
	return chat.AddText(unpack(tbl));
end






-- derma skin
--
--





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
	surface.DrawTexturedRect(0, 0, w, h);
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