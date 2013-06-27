FAdmin.StartHooks["CleanUp"] = function()
	FAdmin.Access.AddPrivilege("CleanUp", 2)
	FAdmin.Commands.AddCommand("ClearDecals", nil)
	FAdmin.Commands.AddCommand("StopSounds", nil)
	FAdmin.Commands.AddCommand("CleanUp", nil)
	
	FAdmin.ScoreBoard.Server:AddServerAction("Clear decals", "FAdmin/icons/CleanUp", Color(155, 0, 0, 255), true, function(ply, button)
		RunConsoleCommand("_FAdmin", "ClearDecals")
	end)
	
	FAdmin.ScoreBoard.Server:AddServerAction("Stop all sounds", "FAdmin/icons/CleanUp", Color(155, 0, 0, 255), true, function(ply, button)
		RunConsoleCommand("_FAdmin", "StopSounds")
	end)

	usermessage.Hook("FAdmin_StopSounds", function()
		RunConsoleCommand("stopsound") -- bypass for ConCommand blocking it
	end)
	
	FAdmin.ScoreBoard.Server:AddServerAction("Clean up server", "FAdmin/icons/CleanUp", Color(155, 0, 0, 255), true, function(ply, button)
		RunConsoleCommand("_FAdmin", "CleanUp")
	end)
end