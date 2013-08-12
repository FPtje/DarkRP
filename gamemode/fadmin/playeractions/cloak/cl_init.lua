FAdmin.StartHooks["zz_Cloak"] = function()
	FAdmin.Access.AddPrivilege("Cloak", 2)
	FAdmin.Commands.AddCommand("Cloak", nil, "<Player>")
	FAdmin.Commands.AddCommand("Uncloak", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
		if ply:FAdmin_GetGlobal("FAdmin_cloaked") then return "Uncloak" end
		return "Cloak"
	end, function(ply)
		if ply:FAdmin_GetGlobal("FAdmin_cloaked") then return "FAdmin/icons/cloak", "FAdmin/icons/disable" end
		return "FAdmin/icons/cloak"
	end, Color(0, 200, 0, 255),

	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Cloak", ply) end, function(ply, button)
		if not ply:FAdmin_GetGlobal("FAdmin_cloaked") then
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "Cloak", ply:Nick())
			else
				RunConsoleCommand("_FAdmin", "Cloak", ply:SteamID())
			end
		else
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "Uncloak", ply:Nick())
			else
				RunConsoleCommand("_FAdmin", "Uncloak", ply:SteamID())
			end
		end

		if not ply:FAdmin_GetGlobal("FAdmin_cloaked") then button:SetImage2("FAdmin/icons/disable") button:SetText("Uncloak") button:GetParent():InvalidateLayout() return end
		button:SetImage2("null")
		button:SetText("Cloak")
		button:GetParent():InvalidateLayout()
	end)
end