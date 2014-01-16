-- concatenate a space to avoid the text being parsed as valve string
local function safeText(text)
	return string.match(text, "^#([a-zA-Z_]+)$") and text .. " " or text
end

function draw.DrawNonParsedText(text, font, x, y, color, xAlign)
	return draw.DrawText(safeText(text), font, x, y, color, xAlign)
end

function surface.DrawNonParsedText(text)
	return surface.DrawText(safeText(text))
end