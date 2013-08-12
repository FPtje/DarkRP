FAdmin.StartHooks["Jail"] = function()
	FAdmin.Access.AddPrivilege("Jail", 2)
	FAdmin.Commands.AddCommand("Jail", nil, "<Player>", "[Small/Normal/Big]", "[Time]")
	FAdmin.Commands.AddCommand("UnJail", nil, "<Player>")

	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Jail", function(ply)
		if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
			RunConsoleCommand("_FAdmin", "jail", ply:Nick())
		else
			RunConsoleCommand("_FAdmin", "jail", ply:SteamID())
		end
	end)

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
		if ply:FAdmin_GetGlobal("fadmin_jailed") then return "Unjail" end
		return "Jail"
	end,
	function(ply)
		if ply:FAdmin_GetGlobal("fadmin_jailed") then return "FAdmin/icons/jail", "FAdmin/icons/disable" end
		return "FAdmin/icons/jail"
	end,
	Color(255, 130, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Jail", ply) end,
	function(ply, button)
		if ply:FAdmin_GetGlobal("fadmin_jailed") then 
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then RunConsoleCommand("_FAdmin", "unjail", ply:Nick()) else RunConsoleCommand("_FAdmin", "unjail", ply:SteamID()) end button:SetImage2("null") button:SetText("Jail") button:GetParent():InvalidateLayout() return end
		-- I assume there is a good reason why this was all in one line. Figured I keep it that way.

		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Jail Type:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)

		menu:AddPanel(Title)

		for k,v in pairs(FAdmin.PlayerActions.JailTypes) do
			if v == "Unjail" then continue end
			FAdmin.PlayerActions.addTimeSubmenu(menu, v .. " jail",
				function()
					if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
						RunConsoleCommand("_FAdmin", "Jail", ply:Nick(), k)
					else
						RunConsoleCommand("_FAdmin", "Jail", ply:SteamID(), k)
					end
					button:SetText("Unjail") button:GetParent():InvalidateLayout()
					button:SetImage2("FAdmin/icons/disable")
				end,
				function(secs)
					if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
						RunConsoleCommand("_FAdmin", "Jail", ply:Nick(), k, secs)
					else
						RunConsoleCommand("_FAdmin", "Jail", ply:SteamID(), k, secs)
					end
					button:SetText("Unjail")
					button:GetParent():InvalidateLayout()
					button:SetImage2("FAdmin/icons/disable")
				end
			)
		end

		menu:Open()
	end)
end
