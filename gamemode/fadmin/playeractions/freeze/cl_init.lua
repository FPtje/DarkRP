FAdmin.StartHooks["Freeze"] = function()
	FAdmin.Access.AddPrivilege("Freeze", 2)
	FAdmin.Commands.AddCommand("freeze", nil, "<Player>")
	FAdmin.Commands.AddCommand("unfreeze", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
		if ply:FAdmin_GetGlobal("FAdmin_frozen") then return "Unfreeze" end
		return "Freeze"
	end, function(ply)
		if ply:FAdmin_GetGlobal("FAdmin_frozen") then return "FAdmin/icons/freeze", "FAdmin/icons/disable" end
		return "FAdmin/icons/freeze"
	end, Color(255, 130, 0, 255),

	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Freeze", ply) end, function(ply, button)
		if not ply:FAdmin_GetGlobal("FAdmin_frozen") then
			FAdmin.PlayerActions.addTimeMenu(function(secs)
				if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
					RunConsoleCommand("_FAdmin", "freeze", ply:Nick(), secs)
				else
					RunConsoleCommand("_FAdmin", "freeze", ply:SteamID(), secs)
				end
				button:SetImage2("FAdmin/icons/disable")
				button:SetText("Unfreeze")
				button:GetParent():InvalidateLayout()
			end)
		else
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "unfreeze", ply:Nick())
			else
				RunConsoleCommand("_FAdmin", "unfreeze", ply:SteamID())
			end
		end

		button:SetImage2("null")
		button:SetText("Freeze")
		button:GetParent():InvalidateLayout()
	end)
end
