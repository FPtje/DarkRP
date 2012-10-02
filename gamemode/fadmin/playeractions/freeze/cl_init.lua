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
			RunConsoleCommand("_FAdmin", "freeze", ply:UserID())
		else
			RunConsoleCommand("_FAdmin", "unfreeze", ply:UserID())
		end
		
		if not ply:FAdmin_GetGlobal("FAdmin_frozen") then button:SetImage2("FAdmin/icons/disable") button:SetText("Unfreeze") button:GetParent():InvalidateLayout() return end
		button:SetImage2("null")
		button:SetText("Freeze")
		button:GetParent():InvalidateLayout()
	end)
end