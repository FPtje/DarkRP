local TextColor = Color(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
local function AFKHUDPaint()
	if not LocalPlayer():getDarkRPVar("AFK") then return end

	draw.SimpleText(DarkRP.getPhrase("afk_mode"), "DarkRPHUD2", ScrW()/2, (ScrH()/2) - 100, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(DarkRP.getPhrase("salary_frozen"), "DarkRPHUD2", ScrW()/2, (ScrH()/2) -60, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if not LocalPlayer():getDarkRPVar("AFKDemoted") then
		draw.SimpleText(DarkRP.getPhrase("no_auto_demote"), "DarkRPHUD2", ScrW()/2, (ScrH()/2) - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(DarkRP.getPhrase("youre_afk_demoted"), "DarkRPHUD2", ScrW()/2, (ScrH()/2) - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	draw.SimpleText(DarkRP.getPhrase("afk_cmd_to_exit"), "DarkRPHUD2", ScrW()/2, (ScrH()/2) + 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
hook.Add("HUDPaint", "AFK_HUD", AFKHUDPaint)
