local cvars = cvars
local draw = draw
local hook = hook
local math = math
local table = table
local timer = timer
local Color = Color
local ColorAlpha = ColorAlpha
local CreateClientConVar = CreateClientConVar
local GetConVar = GetConVar
local ipairs = ipairs
local pairs = pairs
local unpack = unpack

local ConVars = {
        HungerBackground = {0, 0, 0, 255},
        HungerForeground = {30, 30, 120, 255},
        HungerPercentageText = {255, 255, 255, 255},
        StarvingText = {200, 0, 0, 255},
        FoodEatenBackground = {0, 0, 0}, -- No alpha
        FoodEatenForeground = {20, 100, 20} -- No alpha
    }
local HUDWidth = 0

local FoodAteAlpha = -1
local FoodAteY = 0

surface.CreateFont("HungerPlus", {
    size = 70,
    weight = 500,
    antialias = true,
    shadow = false,
    font = "ChatFont",
    extended = true,
})

local function ReloadConVars()
    for name, Colour in pairs(ConVars) do
        ConVars[name] = {}
        for num, rgb in ipairs(Colour) do
            local ConVarName = name .. num
            local CVar = GetConVar(ConVarName) or CreateClientConVar(ConVarName, rgb, true, false)
            table.insert(ConVars[name], CVar:GetInt())

            if not cvars.GetConVarCallbacks(ConVarName, false) then
                cvars.AddChangeCallback(ConVarName, function() timer.Simple(0, ReloadConVars) end)
            end
        end
        ConVars[name] = Color(unpack(ConVars[name]))
    end

    if HUDWidth == 0 then
        HUDWidth = 240
        cvars.AddChangeCallback("HudW", function() timer.Simple(0, ReloadConVars) end)
    end

    HUDWidth = GetConVar("HudW") and GetConVar("HudW"):GetInt() or 240
end
timer.Simple(0, ReloadConVars)

local function HMHUD()
    local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_Hungermod")
    if shouldDraw == false then return end

    local energy = math.ceil(LocalPlayer():getDarkRPVar("Energy") or 0)

    local x = 5
    local y = ScrH() - 9

    local cornerRadius = 4
    if energy > 0 then
        cornerRadius = math.Min(4, (HUDWidth - 9) * (energy / 100) / 3 * 2 - (HUDWidth - 9) * (energy / 100) / 3 * 2 % 2)
    end

    draw.RoundedBox(cornerRadius, x - 1, y - 1, HUDWidth - 8, 9, ConVars.HungerBackground)

    if energy > 0 then
        draw.RoundedBox(cornerRadius, x, y, (HUDWidth - 9) * (energy / 100), 7, ConVars.HungerForeground)
        draw.DrawNonParsedSimpleText(energy .. "%", "DefaultSmall", HUDWidth / 2, y - 3, ConVars.HungerPercentageText, 1)
    else
        draw.DrawNonParsedSimpleText(DarkRP.getPhrase("starving"), "ChatFont", HUDWidth / 2, y - 5, ConVars.StarvingText, 1)
    end

    if FoodAteAlpha > -1 then
        local mul = 1
        if FoodAteY <= ScrH() - 100 then
            mul = -.5
        end

        draw.DrawNonParsedSimpleText("++", "HungerPlus", 208, FoodAteY + 1, ColorAlpha(ConVars.FoodEatenBackground, FoodAteAlpha), 0)
        draw.DrawNonParsedSimpleText("++", "HungerPlus", 207, FoodAteY, ColorAlpha(ConVars.FoodEatenForeground, FoodAteAlpha), 0)

        FoodAteAlpha = math.Clamp(FoodAteAlpha + 4 * FrameTime() * mul, -1, 1) --ColorAlpha works with 0-1 alpha
        FoodAteY = FoodAteY - 150 * FrameTime()
    end
end
hook.Add("HUDDrawTargetID", "HMHUD", HMHUD) --HUDDrawTargetID is called after DarkRP HUD is drawn in HUDPaint

local function AteFoodIcon(msg)
    FoodAteAlpha = 1
    FoodAteY = ScrH() - 8
end
usermessage.Hook("AteFoodIcon", AteFoodIcon)
