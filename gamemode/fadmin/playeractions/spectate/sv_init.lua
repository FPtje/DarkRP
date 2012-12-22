local function Spectate(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "Spectate") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	local target = FAdmin.FindPlayer(args[1])
	target = target and target[1] or nil
	target = IsValid(target) and target ~= ply and target or nil

	ply.FAdminSpectatingEnt = target
	ply.FAdminSpectating = true

	ply:ExitVehicle()

	umsg.Start("FAdminSpectate", ply)
		umsg.Bool(target == nil) -- Is the player roaming?
		umsg.Entity(ply.FAdminSpectatingEnt)
	umsg.End()


	local targetText = IsValid(target) and (target:Nick() .. " ("..target:SteamID()..")") or ""
	FAdmin.Messages.SendMessage(ply, 4, "You are now spectating "..targetText)
end

local function SpectateVisibility(ply, viewEnt)
	if not ply.FAdminSpectating then return end

	if IsValid(ply.FAdminSpectatingEnt) then
		AddOriginToPVS(ply.FAdminSpectatingEnt:GetShootPos())
	end

	if ply.FAdminSpectatePos then
		AddOriginToPVS(ply.FAdminSpectatePos)
	end
end
hook.Add("SetupPlayerVisibility", "FAdminSpectate", SpectateVisibility)

local function setSpectatePos(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "Spectate") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end

	if not ply.FAdminSpectating or not args[3] then return end
	local x, y, z = tonumber(args[1] or 0), tonumber(args[2] or 0), tonumber(args[3] or 0)

	ply.FAdminSpectatePos = Vector(x, y, z)
end
concommand.Add("_FAdmin_SpectatePosUpdate", setSpectatePos)

local function endSpectate(ply, cmd, args)
	ply.FAdminSpectatingEnt = nil
	ply.FAdminSpectating = nil
	ply.FAdminSpectatePos = nil
end
concommand.Add("_FAdmin_StopSpectating", endSpectate)

local function playerVoice(listener, talker)
	local canhear, surround = GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)
	for k,v in pairs(player.GetAll()) do
		if (v.FAdminSpectatingEnt == listener and canhear) or v.FAdminSpectatingEnt == talker then
			return true, surround
		end
	end
end
hook.Add("PlayerCanHearPlayersVoice", "FAdminSpectate", playerVoice)

FAdmin.StartHooks["Spectate"] = function()
	FAdmin.Commands.AddCommand("Spectate", Spectate)

	FAdmin.Access.AddPrivilege("Spectate", 2)
end