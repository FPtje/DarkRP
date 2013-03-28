util.AddNetworkString("FAdmin_retrievebans")
util.AddNetworkString("FADMIN_SendGroups")

local function AddDir(dir) // recursively adds everything in a directory to be downloaded by client
	local files, folders = file.Find(dir.."/*", "GAME")

	for _, fdir in pairs(folders) do
		if fdir != ".svn" then // don't spam people with useless .svn folders
			AddDir(dir.."/"..fdir)
		end
	end

	for k,v in pairs(files) do
		resource.AddFile(dir.."/"..v)
	end
end

AddDir("materials/fadmin")

local function AddCSLuaFolder(fol)
	fol = string.lower(fol)

	local _, folders = file.Find(fol.."*", "LUA")
	for _, folder in SortedPairs(folders, true) do
		if folder ~= "." and folder ~= ".." then
			for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA")) do
				AddCSLuaFile(fol..folder .. "/" ..File)
				include(fol.. folder .. "/" ..File)
			end

			for _, File in SortedPairs(file.Find(fol .. folder .."/sv_*.lua", "LUA"), true) do
				include(fol.. folder .. "/" ..File)
			end

			for _, File in SortedPairs(file.Find(fol .. folder .."/cl_*.lua", "LUA"), true) do
				AddCSLuaFile(fol.. folder .. "/" ..File)
			end
		end
	end
end
AddCSLuaFolder(GM.FolderName.."/gamemode/modules/fadmin/fadmin/")
AddCSLuaFolder(GM.FolderName.."/gamemode/modules/fadmin/fadmin/playeractions/")

/*---------------------------------------------------------------------------
FAdmin global settings
---------------------------------------------------------------------------*/
local SetTypes = {Angle = "Angle",
boolean = "Bool",
Entity = "Entity",
number = "Float",
Player = "Entity",
string = "String",
Vector = "Vector"}

function FAdmin.SetGlobalSetting(setting, value)
	if FAdmin.GlobalSetting[setting] == value then return end -- If the value didn't change, we don't need to resend it.
	FAdmin.GlobalSetting[setting] = value
	umsg.Start("FAdmin_GlobalSetting")
		umsg.String(setting)
		umsg.String(type(value))

		umsg[SetTypes[type(value)]](value)
	umsg.End()
end

getmetatable(Player(0)).FAdmin_SetGlobal = function(self, setting, value)
	self.GlobalSetting = self.GlobalSetting or {}
	if self.GlobalSetting[setting] == value then return end -- If the value didn't change, we don't need to resend it.
	self.GlobalSetting[setting] = value
	umsg.Start("FAdmin_PlayerSetting")
		umsg.Entity(self)
		umsg.String(setting)
		umsg.String(type(value))
		umsg[SetTypes[type(value)]](value)
	umsg.End()
end

hook.Add("PlayerInitialSpawn", "FAdmin_GlobalSettings", function(ply)
	for k, v in pairs(FAdmin.GlobalSetting) do
		umsg.Start("FAdmin_GlobalSetting")
			umsg.String(k)
			umsg.String(type(v))
			umsg[SetTypes[type(v)]](v)
		umsg.End()
	end
	for _, ply in pairs(player.GetAll()) do
		for k,v in pairs(ply.GlobalSetting or {}) do
			umsg.Start("FAdmin_PlayerSetting")
				umsg.Entity(ply)
				umsg.String(k)
				umsg.String(type(v))
				umsg[SetTypes[type(v)]](v)
			umsg.End()
		end
	end
end)
FAdmin.SetGlobalSetting("FAdmin", true)