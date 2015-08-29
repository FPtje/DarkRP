-----------------------------------------------------------------------------[[
/*---------------------------------------------------------------------------
The fonts that DarkRP uses
---------------------------------------------------------------------------*/
-----------------------------------------------------------------------------]]
local function loadFonts()
    local tahoma = system.IsLinux() and "DejaVu Sans" or "Tahoma"
    local tahomaSize = system.IsLinux() and fp{fn.Flip(fn.Add), 1} or fn.Id

    surface.CreateFont("DarkRPHUD1", {
        size = tahomaSize(16),
        weight = 600,
        antialias = true,
        shadow = true,
        font = tahoma})

    surface.CreateFont("DarkRPHUD2", {
        size = 23,
        weight = 400,
        antialias = true,
        shadow = false,
        font = "Coolvetica"})

    surface.CreateFont("Trebuchet18", {
        size = 18,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Trebuchet MS"})

    surface.CreateFont("Trebuchet20", {
        size = 20,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Trebuchet MS"})

    surface.CreateFont("Trebuchet24", {
        size = 24,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Trebuchet MS"})

    surface.CreateFont("TabLarge", {
        size = tahomaSize(15),
        weight = 700,
        antialias = true,
        shadow = false,
        font = tahoma})

    surface.CreateFont("UiBold", {
        size = 16,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Default"})

    surface.CreateFont("HUDNumber5", {
        size = 30,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Default"})

    surface.CreateFont("ScoreboardHeader", {
        size = 32,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Coolvetica"})

    surface.CreateFont("ScoreboardSubtitle", {
        size = 22,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Coolvetica"})

    surface.CreateFont("ScoreboardPlayerName", {
        size = 19,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Coolvetica"})

    surface.CreateFont("ScoreboardPlayerName2", {
        size = 15,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Coolvetica"})

    surface.CreateFont("ScoreboardPlayerNameBig", {
        size = 22,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Coolvetica"})

    surface.CreateFont("AckBarWriting", {
        size = 20,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Akbar"})
end
loadFonts()
-- Load twice because apparently once is not enough
hook.Add("InitPostEntity", "DarkRP_LoadFonts", loadFonts)
