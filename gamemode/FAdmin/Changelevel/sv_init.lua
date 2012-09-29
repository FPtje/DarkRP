local function ChangeLevel(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "changelevel") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	
	local map = args[2] or args[1] -- Changelevel gamemode map OR changelevel map
	local GameMode = args[2] and args[1]
	
	if GameMode then
		RunConsoleCommand("Changegamemode", map, GameMode)
	else
		RunConsoleCommand("Changelevel", map)
	end
end

FAdmin.StartHooks["ChangeLevel"] = function()
	FAdmin.Commands.AddCommand("changelevel", ChangeLevel)
	
	FAdmin.Access.AddPrivilege("changelevel", 2)
end