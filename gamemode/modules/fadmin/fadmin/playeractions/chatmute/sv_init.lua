local function MuteChat(ply, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1]) or {}
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	local time = tonumber(args[2] or 0)
	local timeText = time == 0 and FAdmin.PlayerActions.commonTimes[time] or string.format("for %s", FAdmin.PlayerActions.commonTimes[time] or (time .. " seconds"))

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "Chatmute", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
		if IsValid(target) and not target:FAdmin_GetGlobal("FAdmin_chatmuted") then
			target:FAdmin_SetGlobal("FAdmin_chatmuted", true)

			if time == 0 then continue end

			timer.Simple(time, function()
				if not IsValid(target) or not target:FAdmin_GetGlobal("FAdmin_chatmuted") then return end
				target:FAdmin_SetGlobal("FAdmin_chatmuted", false)
			end)
		end
	end
	FAdmin.Messages.ActionMessage(ply, targets, "You have chat muted %s " .. timeText, "Your chat was muted by %s " .. timeText, "Chat muted %s " .. timeText)
end

local function UnMuteChat(ply, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "Chatmute", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
		if IsValid(target) and target:FAdmin_GetGlobal("FAdmin_chatmuted") then
			target:FAdmin_SetGlobal("FAdmin_chatmuted", false)
		end
	end
	FAdmin.Messages.ActionMessage(ply, targets, "You have chat unmuted %s", "Your chat was unmuted by %s", "Chat unmuted %s")
end

FAdmin.StartHooks["Chatmute"] = function()
	FAdmin.Commands.AddCommand("Chatmute", MuteChat)
	FAdmin.Commands.AddCommand("UnChatmute", UnMuteChat)

	FAdmin.Access.AddPrivilege("Chatmute", 2)
end

hook.Add("PlayerSay", "FAdmin_Chatmute", function(ply, text, Team, dead)
	if ply:FAdmin_GetGlobal("FAdmin_chatmuted") then return "" end
end)
