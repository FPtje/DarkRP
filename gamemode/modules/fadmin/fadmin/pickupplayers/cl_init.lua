CreateConVar("AdminsCanPickUpPlayers", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
CreateConVar("PlayersCanPickUpPlayers", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

FAdmin.StartHooks["PickUpPlayers"] = function()
	FAdmin.Access.AddPrivilege("PickUpPlayers", 2)
	FAdmin.ScoreBoard.Server:AddPlayerAction(function() return (tobool(GetConVarNumber("AdminsCanPickUpPlayers")) and "Disable" or "Enable").." Admin>Player pickup" end,
	function() return "FAdmin/icons/PickUp", tobool(GetConVarNumber("AdminsCanPickUpPlayers")) and "FAdmin/icons/disable" end, Color(0, 155, 0, 255), true, function(button)
		button:SetImage2((not tobool(GetConVarNumber("AdminsCanPickUpPlayers")) and "FAdmin/icons/disable") or "null")
		button:SetText((not tobool(GetConVarNumber("AdminsCanPickUpPlayers")) and "Disable" or "Enable").." Admin>Player pickup")
		button:GetParent():InvalidateLayout()
		RunConsoleCommand("_FAdmin", "AdminsCanPickUpPlayers", (tobool(GetConVarNumber("AdminsCanPickUpPlayers")) and "0") or "1")
	end)

	FAdmin.ScoreBoard.Server:AddPlayerAction(function() return (tobool(GetConVarNumber("PlayersCanPickUpPlayers")) and "Disable" or "Enable").." Player>Player pickup" end,
	function() return "FAdmin/icons/PickUp", tobool(GetConVarNumber("PlayersCanPickUpPlayers")) and "FAdmin/icons/disable" end, Color(0, 155, 0, 255), true, function(button)
		button:SetImage2((not tobool(GetConVarNumber("PlayersCanPickUpPlayers")) and "FAdmin/icons/disable") or "null")
		button:SetText((not tobool(GetConVarNumber("PlayersCanPickUpPlayers")) and "Disable" or "Enable").." Player>Player pickup")
		button:GetParent():InvalidateLayout()
		RunConsoleCommand("_FAdmin", "PlayersCanPickUpPlayers", (tobool(GetConVarNumber("PlayersCanPickUpPlayers")) and "0") or "1")
	end)
end