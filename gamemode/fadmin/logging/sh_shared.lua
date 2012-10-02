CreateConVar("FAdmin_logging", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

if SERVER then return end
FAdmin.StartHooks["Logging"] = function()
	FAdmin.Access.AddPrivilege("Logging", 3)
	FAdmin.Commands.AddCommand("Logging", nil)
	
	FAdmin.ScoreBoard.Server:AddServerSetting(function() return (tobool(GetConVarNumber("FAdmin_logging")) and "Disable" or "Enable").." Logging" end, 
	function() return "FAdmin/icons/Message", tobool(GetConVarNumber("FAdmin_logging")) and "FAdmin/icons/disable" end, 
	Color(0, 0, 155, 255), true, function(button)
		button:SetImage2((not tobool(GetConVarNumber("FAdmin_logging")) and "FAdmin/icons/disable") or "null") 
		button:SetText((not tobool(GetConVarNumber("FAdmin_logging")) and "Disable" or "Enable").." Logging")
		button:GetParent():InvalidateLayout()
		
		RunConsoleCommand("_Fadmin", "Logging", (tobool(GetConVarNumber("FAdmin_logging")) and 0) or 1)
	end)
end