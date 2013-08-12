local function EnableDisableNoclip(ply)
	return ply:FAdmin_GetGlobal("FADmin_CanNoclip") or
		((FAdmin.Access.PlayerHasPrivilege(ply, "Noclip") or util.tobool(GetConVarNumber("sbox_noclip")))
			and not ply:FAdmin_GetGlobal("FADmin_DisableNoclip"))
end

FAdmin.StartHooks["zz_Noclip"] = function()
	FAdmin.Access.AddPrivilege("Noclip", 2)
	FAdmin.Access.AddPrivilege("SetNoclip", 2)

	FAdmin.Commands.AddCommand("SetNoclip", nil, "<Player>", "<Toggle 1/0>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
		if EnableDisableNoclip(ply) then
			return "Disable noclip"
		end
		return "Enable noclip"
	end, function(ply) return "FAdmin/icons/Noclip", (EnableDisableNoclip(ply) and "FAdmin/icons/disable") end, Color(0, 200, 0, 255),

	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetNoclip") end, function(ply, button)
		if EnableDisableNoclip(ply) then
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "SetNoclip", ply:Nick(), 0)
			else
				RunConsoleCommand("_FAdmin", "SetNoclip", ply:SteamID(), 0)
			end
		else
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "SetNoclip", ply:Nick(), 1)
			else
				RunConsoleCommand("_FAdmin", "SetNoclip", ply:SteamID(), 1)
			end
		end

		if EnableDisableNoclip(ply) then
			button:SetText("Enable noclip")
			button:SetImage2("null")
			button:GetParent():InvalidateLayout()
			return
		end
		button:SetText("Disable noclip")
		button:SetImage2("FAdmin/icons/disable")
		button:GetParent():InvalidateLayout()
	end)
end