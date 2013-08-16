FAdmin.StartHooks["StripWeapons"] = function()
	FAdmin.Access.AddPrivilege("StripWeapons", 2)
	FAdmin.Commands.AddCommand("StripWeapons", nil, "<Player>")
	FAdmin.Commands.AddCommand("Strip", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton("Strip weapons", {"FAdmin/icons/weapon", "FAdmin/icons/disable"}, Color(255, 130, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "StripWeapons", ply) end, function(ply, button)
		if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
			RunConsoleCommand("_FAdmin", "StripWeapons", ply:Nick())
		else
			RunConsoleCommand("_FAdmin", "StripWeapons", ply:SteamID())
		end
	end)
end