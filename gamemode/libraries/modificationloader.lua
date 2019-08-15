-- Modification loader.
-- Dependencies:
--     - fn
--     - simplerr

--[[---------------------------------------------------------------------------
Disabled defaults
---------------------------------------------------------------------------]]
DarkRP.disabledDefaults = {}
DarkRP.disabledDefaults["modules"] = {
    ["afk"]              = true,
    ["chatsounds"]       = false,
    ["events"]           = false,
    ["fpp"]              = false,
    ["hitmenu"]          = false,
    ["hud"]              = false,
    ["hungermod"]        = true,
    ["playerscale"]      = false,
    ["sleep"]            = false,
}

DarkRP.disabledDefaults["agendas"]          = {}
DarkRP.disabledDefaults["ammo"]             = {}
DarkRP.disabledDefaults["demotegroups"]     = {}
DarkRP.disabledDefaults["doorgroups"]       = {}
DarkRP.disabledDefaults["entities"]         = {}
DarkRP.disabledDefaults["food"]             = {}
DarkRP.disabledDefaults["groupchat"]        = {}
DarkRP.disabledDefaults["hitmen"]           = {}
DarkRP.disabledDefaults["jobs"]             = {}
DarkRP.disabledDefaults["shipments"]        = {}
DarkRP.disabledDefaults["vehicles"]         = {}
DarkRP.disabledDefaults["workarounds"]      = {}

-- The client cannot use simplerr.runLuaFile because of restrictions in GMod.
local doInclude = CLIENT and include or fc{simplerr.wrapError, simplerr.wrapLog, simplerr.runFile}

if file.Exists("darkrp_config/disabled_defaults.lua", "LUA") then
    if SERVER then AddCSLuaFile("darkrp_config/disabled_defaults.lua") end
    doInclude("darkrp_config/disabled_defaults.lua")
end

--[[---------------------------------------------------------------------------
Config
---------------------------------------------------------------------------]]
local configFiles = {
    "darkrp_config/settings.lua",
    "darkrp_config/licenseweapons.lua",
}

for _, File in pairs(configFiles) do
    if not file.Exists(File, "LUA") then continue end

    if SERVER then AddCSLuaFile(File) end
    doInclude(File)
end
if SERVER and file.Exists("darkrp_config/mysql.lua", "LUA") then doInclude("darkrp_config/mysql.lua") end

--[[---------------------------------------------------------------------------
Modules
---------------------------------------------------------------------------]]
local function loadModules()
    local fol = "darkrp_modules/"

    local _, folders = file.Find(fol .. "*", "LUA")

    for _, folder in SortedPairs(folders, true) do
        if folder == "." or folder == ".." or GAMEMODE.Config.DisabledCustomModules[folder] then continue end
        -- Sound but incomplete way of detecting the error of putting addons in the darkrpmod folder
        if file.Exists(fol .. folder .. "/addon.txt", "LUA") or file.Exists(fol .. folder .. "/addon.json", "LUA") then
            DarkRP.errorNoHalt("Addon detected in the darkrp_modules folder.", 2, {
                "This addon is not supposed to be in the darkrp_modules folder.",
                "It is supposed to be in garrysmod/addons/ instead.",
                "Whether a mod is to be installed in darkrp_modules or addons is the author's decision.",
                "Please read the readme of the addons you're installing next time."
            },
            "<darkrpmod addon>/lua/darkrp_modules/" .. folder, -1)
            continue
        end

        for _, File in SortedPairs(file.Find(fol .. folder .. "/sh_*.lua", "LUA"), true) do
            if SERVER then
                AddCSLuaFile(fol .. folder .. "/" .. File)
            end

            if File == "sh_interface.lua" then continue end
            doInclude(fol .. folder .. "/" .. File)
        end

        if SERVER then
            for _, File in SortedPairs(file.Find(fol .. folder .. "/sv_*.lua", "LUA"), true) do
                if File == "sv_interface.lua" then continue end
                doInclude(fol .. folder .. "/" .. File)
            end
        end

        for _, File in SortedPairs(file.Find(fol .. folder .. "/cl_*.lua", "LUA"), true) do
            if File == "cl_interface.lua" then continue end

            if SERVER then
                AddCSLuaFile(fol .. folder .. "/" .. File)
            else
                doInclude(fol .. folder .. "/" .. File)
            end
        end
    end
end

local function loadLanguages()
    local fol = "darkrp_language/"

    local files, _ = file.Find(fol .. "*", "LUA")
    for _, File in pairs(files) do
        if SERVER then AddCSLuaFile(fol .. File) end
        doInclude(fol .. File)
    end
end

local customFiles = {
    "darkrp_customthings/jobs.lua",
    "darkrp_customthings/shipments.lua",
    "darkrp_customthings/entities.lua",
    "darkrp_customthings/vehicles.lua",
    "darkrp_customthings/food.lua",
    "darkrp_customthings/ammo.lua",
    "darkrp_customthings/groupchats.lua",
    "darkrp_customthings/categories.lua",
    "darkrp_customthings/agendas.lua", -- has to be run after jobs.lua
    "darkrp_customthings/doorgroups.lua", -- has to be run after jobs.lua
    "darkrp_customthings/demotegroups.lua", -- has to be run after jobs.lua
}
local function loadCustomDarkRPItems()
    for _, File in pairs(customFiles) do
        if not file.Exists(File, "LUA") then continue end
        if File == "darkrp_customthings/food.lua" and DarkRP.disabledDefaults["modules"]["hungermod"] then continue end

        if SERVER then AddCSLuaFile(File) end
        doInclude(File)
    end
end


function GM:DarkRPFinishedLoading()
    -- GAMEMODE gets set after the last statement in the gamemode files is run. That is not the case in this hook
    GAMEMODE = GAMEMODE or GM

    loadLanguages()
    loadModules()
    loadCustomDarkRPItems()
    hook.Call("loadCustomDarkRPItems", self)
    hook.Call("postLoadCustomDarkRPItems", self)
end
