FAdmin.StartHooks["Ignite"] = function()
	FAdmin.Access.AddPrivilege("Ignite", 2)
	FAdmin.Commands.AddCommand("Ignite", nil, "<Player>", "[time]")
	FAdmin.Commands.AddCommand("unignite", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply) return (ply:FAdmin_GetGlobal("FAdmin_ignited") and "Extinguish") or "Ignite" end,
	function(ply) local disabled = (ply:FAdmin_GetGlobal("FAdmin_ignited") and "FAdmin/icons/disable") or nil return "FAdmin/icons/ignite", disabled end,
	Color(255, 130, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Ignite", ply) end,
	function(ply, button)
		if not ply:FAdmin_GetGlobal("FAdmin_ignited") then
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "ignite", ply:Nick())
			else
				RunConsoleCommand("_FAdmin", "ignite", ply:SteamID())
			end
			button:SetImage2("FAdmin/icons/disable")
			button:SetText("Extinguish")
			button:GetParent():InvalidateLayout()
		else
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "unignite", ply:Nick())
			else
				RunConsoleCommand("_FAdmin", "unignite", ply:SteamID())
			end
			button:SetImage2("null")
			button:SetText("Ignite")
			button:GetParent():InvalidateLayout()
		end
	end)
end