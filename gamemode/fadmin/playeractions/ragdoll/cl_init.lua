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
			RunConsoleCommand("_FAdmin", "unragdoll", ply:UserID())
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
			if v ~= "Unragdoll" then
				menu:AddOption(v, function() RunConsoleCommand("_FAdmin", "Ragdoll", ply:UserID(), k) 
					if v ~= "Kick him in the nuts" then
						button:SetImage2("FAdmin/icons/disable")
						button:SetText("Unragdoll")
						button:GetParent():InvalidateLayout()
					end
				end)
			end
		end
		
		menu:Open()
	end)
end