local plyMeta = FindMetaTable("Player")

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
function DarkRP.textWrap(text, font, pxWidth)
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

/*---------------------------------------------------------------------------
Decides whether a given player is in the same room as the local player
note: uses a heuristic
---------------------------------------------------------------------------*/
function plyMeta:isInRoom()
	local tracedata = {}
	tracedata.start = LocalPlayer():GetShootPos()
	tracedata.endpos = self:GetShootPos()
	local trace = util.TraceLine(tracedata)

	return not trace.HitWorld
end

/*---------------------------------------------------------------------------
Key name to key int mapping
---------------------------------------------------------------------------*/
local keyNames
function input.KeyNameToNumber(str)
	if not keyNames then
		keyNames = {}
		for i = 1, 107, 1 do
			keyNames[input.GetKeyName(i)] = i
		end
	end

	return keyNames[str]
end
