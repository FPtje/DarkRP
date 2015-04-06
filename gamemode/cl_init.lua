hook.Run("fprpStartedLoading")

GM.Version = "3.0"
GM.Name = "fprp"
GM.Author = "By FPtje Falco et al."

DeriveGamemode("sandbox")
local function LoadModules()
	local root = GM.FolderName.."/gamemode/modules/"

	local _, folders = file.Find(root.."*", "LUA")

	for _, folder in SortedPairs(folders, true) do
		if fprp.disabledDefaults["modules"][folder] then continue end

		for _, File in SortedPairs(file.Find(root .. folder .."/sh_*.lua", "LUA"), true) do
			if File == "sh_interface.lua" then continue end
			include(root.. folder .. "/" ..File)
		end
		for _, File in SortedPairs(file.Find(root .. folder .."/cl_*.lua", "LUA"), true) do
			if File == "cl_interface.lua" then continue end
			include(root.. folder .. "/" ..File)
		end
	end
end

GM.Config = {} -- config table
GM.NoLicense = GM.NoLicense or {}

include("config/config.lua")
include("libraries/simplerr.lua")
include("libraries/fn.lua")
include("libraries/interfaceloader.lua")
include("libraries/disjointset.lua")

include("libraries/modificationloader.lua")
LoadModules()

fprp.fprp_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")
fprp.fprp_LOADING = nil

fprp.finish()

hook.Call("fprpFinishedLoading", GM)

hook.Add("InitPostEntity", "InformTheCitizens", function()
	local delay = LocalPLayer():IsAdmin() and 30 or 60
	local pink = Color(255, 0, 255)
	timer.Create("InformTheCitizens" .. os.time(), delay, 0, function()
		chat.AddText(pink, "To enjoy a superior roleplay experience™, please purchase a package from http://cloudsixteen.com")
	end)
end)
