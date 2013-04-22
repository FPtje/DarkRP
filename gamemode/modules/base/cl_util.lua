/*---------------------------------------------------------------------------
Show a black screen
---------------------------------------------------------------------------*/
local function blackScreen(um)
	local toggle = um:ReadBool()
	if toggle then
		local black = Color(0, 0, 0)
		local w, h = ScrW(), ScrH()
		hook.Add("HUDPaintBackground", "BlackScreen", function()
			surface.SetDrawColor(black)
			surface.DrawRect(0, 0, w, h)
		end)
	else
		hook.Remove("HUDPaintBackground", "BlackScreen")
	end
end
usermessage.Hook("blackScreen", blackScreen)

/*---------------------------------------------------------------------------
Wrap strings to not become wider than the given amount of pixels
---------------------------------------------------------------------------*/
function GM:TextWrap(text, font, pxWidth)
	local total = 0

	surface.SetFont(font)
	text = text:gsub(".", function(char)
		if char == "\n" then
			total = 0
		end

		total = total + surface.GetTextSize(char)

		-- Wrap around when the max width is reached
		if total >= pxWidth then
			total = 0
			return "\n" .. char
		end

		return char
	end)

	return text
end