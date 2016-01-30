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
local function charWrap(text, pxWidth)
    local total = 0

    text = text:gsub(".", function(char)
        total = total + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if total >= pxWidth then
            total = 0
            return "\n" .. char
        end

        return char
    end)

    return text, total
end

function DarkRP.textWrap(text, font, pxWidth)
    local total = 0

    surface.SetFont(font)

    local spaceSize = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                total = 0
            end

            local wordlen = surface.GetTextSize(word)
            total = total + wordlen


            -- Wrap around when the max width is reached
            if wordlen >= pxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, pxWidth)
                total = splitPoint
                return splitWord
            elseif total < pxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                total = wordlen - spaceSize
                return '\n' .. string.sub(word, 2)
            end

            total = wordlen
            return '\n' .. word
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
