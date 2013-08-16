FAdmin.StartHooks["Ragdoll"] = function()
	FAdmin.Access.AddPrivilege("Ragdoll", 2)
	FAdmin.Commands.AddCommand("Ragdoll", nil, "<Player>", "[normal/hang/kick]")
	FAdmin.Commands.AddCommand("UnRagdoll", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
		if ply:FAdmin_GetGlobal("fadmin_ragdolled") then return "Unragdoll" end
		return "Ragdoll"
	end,
	function(ply)
		if ply:FAdmin_GetGlobal("fadmin_ragdolled") then return "FAdmin/icons/ragdoll", "FAdmin/icons/disable" end
		return "FAdmin/icons/ragdoll"
	end,
	Color(255, 130, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Ragdoll", ply) end,
	function(ply, button)
		if ply:FAdmin_GetGlobal("fadmin_ragdolled") then
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "unragdoll", ply:Nick())
			else
				RunConsoleCommand("_FAdmin", "unragdoll", ply:SteamID())
			end
			button:SetImage2("null")
			button:SetText("Ragdoll")
			button:GetParent():InvalidateLayout()
		return end

		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Ragdoll Type:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)

		menu:AddPanel(Title)

		for k,v in pairs(FAdmin.PlayerActions.RagdollTypes) do
			if v == "Unragdoll" then continue end
			FAdmin.PlayerActions.addTimeSubmenu(menu, v,
				function()
					if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
						RunConsoleCommand("_FAdmin", "Ragdoll", ply:Nick(), k)
					else
						RunConsoleCommand("_FAdmin", "Ragdoll", ply:SteamID(), k)
					end
					button:SetImage2("FAdmin/icons/disable")
					button:SetText("Unragdoll")
					button:GetParent():InvalidateLayout()
				end,
				function(secs)
					if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
						RunConsoleCommand("_FAdmin", "Ragdoll", ply:Nick(), k, secs)
					else
						RunConsoleCommand("_FAdmin", "Ragdoll", ply:SteamID(), k, secs)
					end
					button:SetImage2("FAdmin/icons/disable")
					button:SetText("Unragdoll")
					button:GetParent():InvalidateLayout()
				end
			)
		end

		menu:Open()
	end)
end
