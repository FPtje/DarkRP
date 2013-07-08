local function MuteVoice(ply, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	local time = tonumber(args[2] or 0)
	local timeText = time == 0 and FAdmin.PlayerActions.commonTimes[time] or string.format("for %s", FAdmin.PlayerActions.commonTimes[time] or (time .. " seconds"))

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "Voicemute", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
		if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_voicemuted") then
			target:FAdmin_SetGlobal("FAdmin_voicemuted", true)

			FAdmin.Messages.ActionMessage(ply, target, "Voice muted %s " .. timeText, "Your voice was muted by %s " .. timeText, "Muted the voice of %s " .. timeText)
			if time == 0 then continue end

			timer.Simple(time, function()
				if not IsValid(target) or not target:FAdmin_GetGlobal("FAdmin_voicemuted") then return end
				target:FAdmin_SetGlobal("FAdmin_voicemuted", false)
			end)
		end
	end
end

local function UnMuteVoice(ply, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "Voicemute", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
		if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_voicemuted") then
			target:FAdmin_SetGlobal("FAdmin_voicemuted", false)

			FAdmin.Messages.ActionMessage(ply, target, "You have voice unmuted %s", "Your voice was unmuted by %s", "Unmuted the voice of %s")
		end
	end
end

FAdmin.StartHooks["VoiceMute"] = function()
	FAdmin.Commands.AddCommand("Voicemute", MuteVoice)
	FAdmin.Commands.AddCommand("UnVoicemute", UnMuteVoice)

	FAdmin.Access.AddPrivilege("Voicemute", 2)
end

hook.Add("PlayerCanHearPlayersVoice", "FAdmin_Voicemute", function(Listener, Talker)
	if Talker:FAdmin_GetGlobal("FAdmin_voicemuted") then return false end
end)
