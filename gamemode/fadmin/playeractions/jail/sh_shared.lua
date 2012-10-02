FAdmin.PlayerActions.JailTypes = {}
FAdmin.PlayerActions.JailTypes[1] = "Small"
FAdmin.PlayerActions.JailTypes[2] = "Normal"
FAdmin.PlayerActions.JailTypes[3] = "Big"
FAdmin.PlayerActions.JailTypes[4] = "Unjail"

FAdmin.PlayerActions.JailTimes = {}
FAdmin.PlayerActions.JailTimes[0] = "Indefinitely"
FAdmin.PlayerActions.JailTimes[10] = "10 seconds"
FAdmin.PlayerActions.JailTimes[30] = "30 seconds"
FAdmin.PlayerActions.JailTimes[60] = "1 minute"
FAdmin.PlayerActions.JailTimes[300] = "5 minutes"
FAdmin.PlayerActions.JailTimes[600] = "10 minutes"

hook.Add("CanTool", "FAdmin_jailed", function(ply) -- shared so it doesn't look like you can use tool
	if ply:FAdmin_GetGlobal("fadmin_jailed") then
		return false
	end
end)