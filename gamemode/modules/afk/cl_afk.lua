local TextColor = Color(GetConVar("Healthforeground1"):GetFloat(), GetConVar("Healthforeground2"):GetFloat(), GetConVar("Healthforeground3"):GetFloat(), GetConVar("Healthforeground4"):GetFloat())

local function AFKHUDPaint()
    if not LocalPlayer():getDarkRPVar("AFK") then return end
    draw.DrawNonParsedSimpleText(DarkRP.getPhrase("afk_mode"), "DarkRPHUD2", ScrW() / 2, (ScrH() / 2) - 100, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.DrawNonParsedSimpleText(DarkRP.getPhrase("salary_frozen"), "DarkRPHUD2", ScrW() / 2, (ScrH() / 2) - 60, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if not LocalPlayer():getDarkRPVar("AFKDemoted") then
        draw.DrawNonParsedSimpleText(DarkRP.getPhrase("no_auto_demote"), "DarkRPHUD2", ScrW() / 2, (ScrH() / 2) - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        draw.DrawNonParsedSimpleText(DarkRP.getPhrase("youre_afk_demoted"), "DarkRPHUD2", ScrW() / 2, (ScrH() / 2) - 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    draw.DrawNonParsedSimpleText(DarkRP.getPhrase("afk_cmd_to_exit"), "DarkRPHUD2", ScrW() / 2, (ScrH() / 2) + 20, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "AFK_HUD", AFKHUDPaint)
