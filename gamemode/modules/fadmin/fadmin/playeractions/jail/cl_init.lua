FAdmin.StartHooks["Jail"] = function()
	FAdmin.Access.AddPrivilege("Jail", 2)
	FAdmin.Commands.AddCommand("Jail", nil, "<Player>", "[Small/Normal/Big]", "[Time]")
	FAdmin.Commands.AddCommand("UnJail", nil, "<Player>")

	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Jail", function(ply)
		RunConsoleCommand("_FAdmin", "jail", ply:SteamID())
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
		if ply:FAdmin_GetGlobal("fadmin_jailed") then RunConsoleCommand("_FAdmin", "unjail", ply:SteamID()) button:SetImage2("null") button:SetText("Jail") button:GetParent():InvalidateLayout() return end

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
					RunConsoleCommand("_FAdmin", "Jail", ply:SteamID(), k)
					button:SetText("Unjail") button:GetParent():InvalidateLayout()
					button:SetImage2("FAdmin/icons/disable")
				end,
				function(secs)
					RunConsoleCommand("_FAdmin", "Jail", ply:SteamID(), k, secs)
					button:SetText("Unjail")
					button:GetParent():InvalidateLayout()
					button:SetImage2("FAdmin/icons/disable")
				end
			)
		end

		menu:Open()
	end)
end
