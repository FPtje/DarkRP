local function Spectate(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "Spectate") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[1] then return end

	local target = FAdmin.FindPlayer(args[1])
	target = target and target[1] or nil
	if not IsValid(target) or target == ply then return end

	ply.FAdminSpectating = target

	umsg.Start("FAdminSpectate", ply)
		umsg.Entity(ply.FAdminSpectating)
	umsg.End()

	FAdmin.Messages.SendMessage(ply, 4, "You are now spectating "..target:Nick() .. " ("..target:SteamID()..")")
end

local function SpectateVisibility(ply, viewEnt)
	if IsValid(ply.FAdminSpectating) then
		AddOriginToPVS(ply.FAdminSpectating:GetShootPos())
	end
end
hook.Add("SetupPlayerVisibility", "FAdminSpectate", SpectateVisibility)

local function endSpectate(ply, cmd, args)
	ply.FAdminSpectating = nil
end
concommand.Add("_FAdmin_StopSpectating", endSpectate)

local function playerVoice(listener, talker)
	local canhear, surround = GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)
	for k,v in pairs(player.GetAll()) do
		if (v.FAdminSpectating == listener and canhear) or v.FAdminSpectating == talker then
			return true, surround
		end
	end
end
hook.Add("PlayerCanHearPlayersVoice", "FAdminSpectate", playerVoice)

FAdmin.StartHooks["Spectate"] = function()
	FAdmin.Commands.AddCommand("Spectate", Spectate)

	FAdmin.Access.AddPrivilege("Spectate", 2)
end