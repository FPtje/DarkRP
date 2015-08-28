CreateConVar("AdminsCanPickUpPlayers", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
CreateConVar("PlayersCanPickUpPlayers", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

FAdmin.StartHooks["PickUpPlayers"] = function()
	FAdmin.Access.AddPrivilege("PickUpPlayers", 2)
	FAdmin.ScoreBoard.Server:AddPlayerAction(function() return (GetConVar("AdminsCanPickUpPlayers"):GetBool() and "Disable" or "Enable").." Admin>Player pickup" end,
	function() return "fadmin/icons/pickup", GetConVar("AdminsCanPickUpPlayers"):GetBool() and "fadmin/icons/disable" end, Color(0, 155, 0, 255), true, function(button)
		button:SetImage2((not GetConVar("AdminsCanPickUpPlayers"):GetBool() and "fadmin/icons/disable") or "null")
		button:SetText((not GetConVar("AdminsCanPickUpPlayers"):GetBool() and "Disable" or "Enable").." Admin>Player pickup")
		button:GetParent():InvalidateLayout()
		RunConsoleCommand("_FAdmin", "AdminsCanPickUpPlayers", (GetConVar("AdminsCanPickUpPlayers"):GetBool() and "0") or "1")
	end)

	FAdmin.ScoreBoard.Server:AddPlayerAction(function() return (GetConVar("PlayersCanPickUpPlayers"):GetBool() and "Disable" or "Enable").." Player>Player pickup" end,
	function() return "fadmin/icons/pickup", GetConVar("PlayersCanPickUpPlayers"):GetBool() and "fadmin/icons/disable" end, Color(0, 155, 0, 255), true, function(button)
		button:SetImage2((not GetConVar("PlayersCanPickUpPlayers"):GetBool() and "fadmin/icons/disable") or "null")
		button:SetText((not GetConVar("PlayersCanPickUpPlayers"):GetBool() and "Disable" or "Enable").." Player>Player pickup")
		button:GetParent():InvalidateLayout()
		RunConsoleCommand("_FAdmin", "PlayersCanPickUpPlayers", (GetConVar("PlayersCanPickUpPlayers"):GetBool() and "0") or "1")
	end)
end
