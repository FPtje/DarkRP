local TextColor = Color(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
local function AFKHUDPaint()
	if not LocalPlayer():getDarkRPVar("AFK") then return end

	draw.SimpleText("AFK MODE", "DarkRPHUD2", ScrW()/2, (ScrH()/2) - 100, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("Your salary has been frozen.", "DarkRPHUD2", ScrW()/2, (ScrH()/2) -60, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if not LocalPlayer():getDarkRPVar("AFKDemoted") then
		draw.SimpleText("You will not be auto-demoted.", "DarkRPHUD2", ScrW()/2, (ScrH()/2) - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("You were demoted for being AFK for too long, Next time use /afk.", "DarkRPHUD2", ScrW()/2, (ScrH()/2) - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	draw.SimpleText("Type /afk again to exit AFK mode.", "DarkRPHUD2", ScrW()/2, (ScrH()/2) + 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
hook.Add("HUDPaint", "AFK_HUD", AFKHUDPaint)
