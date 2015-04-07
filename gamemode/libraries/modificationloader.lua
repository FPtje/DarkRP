-- Modification loader.
-- Dependencies:
--     - fn
--     - simplerr

/*---------------------------------------------------------------------------
Disabled defaults
---------------------------------------------------------------------------*/
fprp.disabledDefaults = {}
fprp.disabledDefaults["modules"] = {
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

fprp.disabledDefaults["agendas"]    		= {}
fprp.disabledDefaults["ammo"]       		= {}
fprp.disabledDefaults["demotegroups"]		= {}
fprp.disabledDefaults["doorgroups"] 		= {}
fprp.disabledDefaults["entities"]   		= {}
fprp.disabledDefaults["food"]       		= {}
fprp.disabledDefaults["groupchat"]  		= {}
fprp.disabledDefaults["hitmen"]     		= {}
fprp.disabledDefaults["jobs"]       		= {}
fprp.disabledDefaults["shipments"]  		= {}
fprp.disabledDefaults["vehicles"]   		= {}

-- The client cannot use simplerr.runLuaFile because of restrictions in GMod.
local doInclude = CLIENT and include or fc{simplerr.wrapError, simplerr.wrapLog, simplerr.runFile}

if file.Exists("fprp_config/disabled_defaults.lua", "LUA") then
	if SERVER then AddCSLuaFile("fprp_config/disabled_defaults.lua") end
	doInclude("fprp_config/disabled_defaults.lua");
end

/*---------------------------------------------------------------------------
Config
---------------------------------------------------------------------------*/
local configFiles = {
	"fprp_config/settings.lua",
	"fprp_config/licenseweapons.lua",
}

for _, File in pairs(configFiles) do
	if not file.Exists(File, "LUA") then continue end

	if SERVER then AddCSLuaFile(File) end
	doInclude(File);
end
if SERVER and file.Exists("fprp_config/mysql.lua", "LUA") then doInclude("fprp_config/mysql.lua") end

/*---------------------------------------------------------------------------
Modules
---------------------------------------------------------------------------*/
local function loadModules()
	local fol = "fprp_modules/"

	local files, folders = file.Find(fol .. "*", "LUA");

	for _, folder in SortedPairs(folders, true) do
		if folder == "." or folder == ".." or GAMEMODE.Config.DisabledCustomModules[folder] then continue end
		-- Sound but incomplete way of detecting the error of putting addons in the fprpmod folder
		if file.Exists(fol .. folder .. "/addon.txt", "LUA") or file.Exists(fol .. folder .. "/addon.json", "LUA") then
			fprp.errorNoHalt("Addon detected in the fprp_modules folder.", 2, {
				"This addon is not supposed to be in the fprp_modules folder.",
				"It is supposed to be in garrysmod/addons/ instead.",
				"Whether a mod is to be installed in fprp_modules or addons is the author's decision.",
				"Please read the readme of the addons you're installing next time."
			},
			"<fprpmod addon>/lua/fprp_modules/" .. folder, -1);
			continue
		end

		for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA"), true) do
			if SERVER then AddCSLuaFile(fol..folder .. "/" ..File) end

			if File == "sh_interface.lua" then continue end
			doInclude(fol.. folder .. "/" ..File);
		end

		if SERVER then
			for _, File in SortedPairs(file.Find(fol .. folder .."/sv_*.lua", "LUA"), true) do
				if File == "sv_interface.lua" then continue end
				doInclude(fol.. folder .. "/" ..File);
			end
		end

		for _, File in SortedPairs(file.Find(fol .. folder .."/cl_*.lua", "LUA"), true) do
			if File == "cl_interface.lua" then continue end
			if SERVER then AddCSLuaFile(fol.. folder .. "/" ..File);
			else doInclude(fol.. folder .. "/" ..File)  end
		end
	end
end

local function loadLanguages()
	local fol = "fprp_language/"

	local files, folders = file.Find(fol .. "*", "LUA");
	for _, File in pairs(files) do
		if SERVER then AddCSLuaFile(fol .. File) end
		doInclude(fol .. File);
	end
end

local customFiles = {
	"fprp_customthings/jobs.lua",
	"fprp_customthings/shipments.lua",
	"fprp_customthings/entities.lua",
	"fprp_customthings/vehicles.lua",
	"fprp_customthings/food.lua",
	"fprp_customthings/ammo.lua",
	"fprp_customthings/groupchats.lua",
	"fprp_customthings/categories.lua",
	"fprp_customthings/agendas.lua", -- has to be run after jobs.lua
	"fprp_customthings/doorgroups.lua", -- has to be run after jobs.lua
	"fprp_customthings/demotegroups.lua", -- has to be run after jobs.lua
}
local function loadCustomfprpItems()
	for _, File in pairs(customFiles) do
		if not file.Exists(File, "LUA") then continue end
		if File == "fprp_customthings/food.lua" and fprp.disabledDefaults["modules"]["hungermod"] then continue end

		if SERVER then AddCSLuaFile(File) end
		doInclude(File);
	end
end


function GM:fprpFinishedLoading()
	-- GAMEMODE gets set after the last statement in the gamemode files is run. That is not the case in this hook
	GAMEMODE = GAMEMODE or GM

	loadLanguages();
	loadModules();
	loadCustomfprpItems();
	hook.Run("loadCustomfprpItems", GAMEMODE);
end
