local plyMeta = FindMetaTable("Player")

--[[---------------------------------------------------------------------------
Show a black screen
---------------------------------------------------------------------------]]
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

--[[---------------------------------------------------------------------------
Wrap strings to not become wider than the given amount of pixels
---------------------------------------------------------------------------]]
local function charWrap(text, pxWidth)
    local total = 0
    local newText = ""

    for i = 1, #text do
        local char = text:sub(i, i)
        total = total + surface.GetTextSize(char)

        if total >= pxWidth then
            newText = newText .. ("\n" .. char)
            -- total needs to include the character size
            total = surface.GetTextSize(char)
        else
            newText = newText .. char
        end
    end

    return newText, total
end

function DarkRP.textWrap(text, font, pxWidth)
    local total = 0

    surface.SetFont(font)

    local spaceSize = surface.GetTextSize(' ')
    local newText = ""

    for word in text:gmatch("(%s?[%S]+)") do
        local char = word:sub(1, 1)
        if char == "\n" or char == "\t" then
            total = 0
        end

        local wordlen = surface.GetTextSize(word)
        total = total + wordlen

        -- Wrap around when the max width is reached
        if wordlen >= pxWidth then -- Split the word if the word is too big
            local splitWord, splitPoint = charWrap(word, pxWidth - (total - wordlen))
            total = splitPoint
            newText = newText .. splitWord
        elseif total < pxWidth then
            newText = newText .. word
        elseif char == ' ' then -- Split before the word
            total = wordlen - spaceSize
            newText = newText .. ('\n' .. word:sub(2))
        else
            total = wordlen
            newText = newText .. ('\n' .. word)
        end
    end

    return newText
end

--[[---------------------------------------------------------------------------
Decides whether a given player is in the same room as the local player
note: uses a heuristic
---------------------------------------------------------------------------]]
function plyMeta:isInRoom()
    local tracedata = {}
    tracedata.start = LocalPlayer():GetShootPos()
    tracedata.endpos = self:GetShootPos()
    local trace = util.TraceLine(tracedata)

    return not trace.HitWorld
end

--[[---------------------------------------------------------------------------
Key name to key int mapping
---------------------------------------------------------------------------]]
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
