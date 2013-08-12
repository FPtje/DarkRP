FAdmin.StartHooks["Slay"] = function()
	FAdmin.Access.AddPrivilege("Slay", 2)
	FAdmin.Commands.AddCommand("Slay", nil, "<Player>", "[Normal/Silent/Explode/Rocket]")

	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Slay", function(ply)
		if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
			RunConsoleCommand("_FAdmin", "slay", ply:Nick())
		else
			RunConsoleCommand("_FAdmin", "slay", ply:SteamID())
		end
	end)

	FAdmin.ScoreBoard.Player:AddActionButton("Slay", "FAdmin/icons/slay", Color(255, 130, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Slay", ply) end,
	function(ply)
		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Kill Type:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)

		menu:AddPanel(Title)

		for k,v in pairs(FAdmin.PlayerActions.SlayTypes) do
			menu:AddOption(v, function()
				if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
					RunConsoleCommand("_FAdmin", "slay", ply:Nick(), k)
				else
					RunConsoleCommand("_FAdmin", "slay", ply:SteamID(), k)
				end
			end)
		end

		menu:Open()
	end)
end