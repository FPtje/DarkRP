local TextColor = Color(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
local function AFKHUDPaint()
	if not LocalPlayer():getfprpVar("AFK") then return end

	draw.DrawNonParsedSimpleText(fprp.getPhrase("afk_mode"), "fprpHUD2", ScrW()/2, (ScrH()/2) - 100, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.DrawNonParsedSimpleText(fprp.getPhrase("salary_frozen"), "fprpHUD2", ScrW()/2, (ScrH()/2) -60, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if not LocalPlayer():getfprpVar("AFKDemoted") then
		draw.DrawNonParsedSimpleText(fprp.getPhrase("no_auto_demote"), "fprpHUD2", ScrW()/2, (ScrH()/2) - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.DrawNonParsedSimpleText(fprp.getPhrase("youre_afk_demoted"), "fprpHUD2", ScrW()/2, (ScrH()/2) - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	draw.DrawNonParsedSimpleText(fprp.getPhrase("afk_cmd_to_exit"), "fprpHUD2", ScrW()/2, (ScrH()/2) + 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
hook.Add("HUDPaint", "AFK_HUD", AFKHUDPaint)
