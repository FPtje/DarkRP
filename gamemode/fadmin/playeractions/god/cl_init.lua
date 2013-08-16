FAdmin.StartHooks["God"] = function()
	FAdmin.Access.AddPrivilege("God", 2)
	FAdmin.Commands.AddCommand("god", nil, "<Player>")
	FAdmin.Commands.AddCommand("ungod", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
		if ply:FAdmin_GetGlobal("FAdmin_godded") then return "Ungod" end
		return "God"
	end, function(ply)
		if ply:FAdmin_GetGlobal("FAdmin_godded") then return "FAdmin/icons/god", "FAdmin/icons/disable" end
		return "FAdmin/icons/god"
	end, Color(255, 130, 0, 255),

	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "God") end, function(ply, button)
		if not ply:FAdmin_GetGlobal("FAdmin_godded") then
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "god", ply:Nick())
			else
				RunConsoleCommand("_FAdmin", "god", ply:SteamID())
			end
		else
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "ungod", ply:Nick())
			else
				RunConsoleCommand("_FAdmin", "ungod", ply:SteamID())
			end
		end

		if not ply:FAdmin_GetGlobal("FAdmin_godded") then button:SetImage2("FAdmin/icons/disable") button:SetText("Ungod") button:GetParent():InvalidateLayout() return end
		button:SetImage2("null")
		button:SetText("God")
		button:GetParent():InvalidateLayout()
	end)
end