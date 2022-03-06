--[[---------------------------------------------------------------------------
The fonts that DarkRP uses
---------------------------------------------------------------------------]]
local function loadFonts()
    surface.CreateFont("DarkRPHUD1", {
        size = 20,
        weight = 600,
        antialias = true,
        shadow = true,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("DarkRPHUD2", {
        size = 23,
        weight = 400,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("Roboto20", {
        size = 20,
        weight = 600,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("Trebuchet18", {
        size = 18,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Trebuchet MS",
        extended = true,
    })

    surface.CreateFont("Trebuchet20", {
        size = 20,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Trebuchet MS",
        extended = true,
    })

    surface.CreateFont("Trebuchet24", {
        size = 24,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Trebuchet MS",
        extended = true,
    })

    surface.CreateFont("Trebuchet48", {
        size = 48,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Trebuchet MS",
        extended = true,
    })

    surface.CreateFont("TabLarge", {
        size = 18,
        weight = 700,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("UiBold", {
        size = 16,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Verdana",
        extended = true,
    })

    surface.CreateFont("HUDNumber5", {
        size = 30,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Verdana",
        extended = true,
    })

    surface.CreateFont("ScoreboardHeader", {
        size = 32,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("ScoreboardSubtitle", {
        size = 22,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("ScoreboardPlayerName", {
        size = 19,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("ScoreboardPlayerName2", {
        size = 15,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("ScoreboardPlayerNameBig", {
        size = 22,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Roboto",
        extended = true,
    })

    surface.CreateFont("AckBarWriting", {
        size = 20,
        weight = 500,
        antialias = true,
        shadow = false,
        font = "Akbar",
        extended = true,
    })

    surface.CreateFont("DarkRP_tipjar", {
        size = 100,
        weight = 500,
        antialias = true,
        shadow = true,
        font = "Verdana",
        extended = true,
    })
end
loadFonts()