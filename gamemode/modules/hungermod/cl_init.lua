local FoodAteAlpha = -1
local FoodAteY = 0

surface.CreateFont("HungerPlus", {
	size = 70,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "ChatFont"})

local function HMHUDPaint()
	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_Hungermod")
	if shouldDraw == false then return end

	local energy = LocalPlayer():getDarkRPVar("Energy") or 0

	local x = 5
	local y = ScrH() - 9

	local cornerRadius = 4
	if energy > 0 then
		cornerRadius = math.Min(4, (GetConVarNumber("HudW")-9)*(math.Clamp(energy, 0, 100)/100)/3*2 - (GetConVarNumber("HudW")-9)*(math.Clamp(energy, 0, 100)/100)/3*2%2)
	end

	draw.RoundedBox(cornerRadius, x - 1, y - 1, GetConVarNumber("HudW") - 8, 9, Color(0, 0, 0, 255))

	if energy > 0 then
		draw.RoundedBox(cornerRadius, x, y, (GetConVarNumber("HudW") - 9) * (math.Clamp(energy, 0, 100) / 100), 7, Color(30, 30, 120, 255))
		draw.DrawText(math.ceil(energy) .. "%", "DefaultSmall", GetConVarNumber("HudW") / 2, y - 2, Color(255, 255, 255, 255), 1)
	else
		draw.DrawText(DarkRP.getPhrase("starving"), "ChatFont", GetConVarNumber("HudW") / 2, y - 4, Color(200, 0, 0, 255), 1)
	end

	if FoodAteAlpha > -1 then
		local mul = 1
		if FoodAteY <= ScrH() - 100 then
			mul = -.5
		end

		draw.DrawText("++", "HungerPlus", 208, FoodAteY + 1, Color(0, 0, 0, FoodAteAlpha), 0)
		draw.DrawText("++", "HungerPlus", 207, FoodAteY, Color(20, 100, 20, FoodAteAlpha), 0)

		FoodAteAlpha = math.Clamp(FoodAteAlpha + 1000 * FrameTime() * mul, -1, 255)
		FoodAteY = FoodAteY - 150 * FrameTime()
	end
end
hook.Add("HUDPaint", "HMHUDPaint", HMHUDPaint)

local function AteFoodIcon(msg)
	FoodAteAlpha = 1
	FoodAteY = ScrH() - 8
end
usermessage.Hook("AteFoodIcon", AteFoodIcon)
