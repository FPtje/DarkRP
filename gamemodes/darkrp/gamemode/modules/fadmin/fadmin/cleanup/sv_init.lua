local function ClearDecals(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "CleanUp") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	for k,v in pairs(player.GetAll()) do
		v:ConCommand("r_cleardecals")
	end
	FAdmin.Messages.ActionMessage(ply, player.GetAll(), "You have removed all decals", "All decals have been removed", "Removed all decals")
end

local function StopSounds(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "CleanUp") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	umsg.Start("FAdmin_StopSounds")
	umsg.End()

	FAdmin.Messages.ActionMessage(ply, player.GetAll(), "You have stopped all sounds", "All sounds have been stopped", "Stopped all sounds")
end

local function CleanUp(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "CleanUp") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	local List = cleanup.GetList()
	for k, ply in pairs(List) do
		for _, cleanupType in pairs(ply) do
			for _, ent in pairs(cleanupType) do
				if not IsValid(ent) then continue end
				ent:Remove()
			end
		end
		List[k] = nil
	end
	FAdmin.Messages.ActionMessage(ply, player.GetAll(), "You have cleaned up the map", "The map has been cleaned up", "Cleaned up the map")
end

FAdmin.StartHooks["CleanUp"] = function()
	FAdmin.Commands.AddCommand("ClearDecals", ClearDecals)
	FAdmin.Commands.AddCommand("StopSounds", StopSounds)
	FAdmin.Commands.AddCommand("CleanUp", CleanUp)

	FAdmin.Access.AddPrivilege("CleanUp", 2)
end