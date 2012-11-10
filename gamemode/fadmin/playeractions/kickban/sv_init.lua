-- Kicking
local function Kick(ply, cmd, args)
	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	local CanKick = hook.Call("FAdmin_CanKick", nil, ply, targets)

	if CanKick == false then return end

	local stage = args[2] or ""
	stage = string.lower(stage)
	local stages = {"start", "cancel", "update", "execute"}
	local Reason = args[3] or (not table.HasValue(stages, stage) and stage) or ply.FAdminKickReason

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "Kick", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!")  return end
		if IsValid(target) then
			if stage == "start" then
				SendUserMessage("FAdmin_kick_start", target) -- Tell him he's getting kicked
				target:Lock() -- Make sure he can't remove the hook clientside and keep minging.
				target:KillSilent()
			elseif stage == "cancel" then
				SendUserMessage("FAdmin_kick_cancel", target) -- No I changed my mind, you can stay
				target:UnLock()
				target:Spawn()
				ply.FAdminKickReason = nil
			elseif stage == "update" then -- Update reason text
				if not args[3] then return end
				ply.FAdminKickReason = args[3]
				SendUserMessage("FAdmin_kick_update", target, args[3])
			else//if stage == "execute" or stage == "" then--execute or no stage = kick instantly
				game.ConsoleCommand(string.format("kickid %s %s\n", target:UserID(), "Kicked by " .. ply:Nick() ..
					" (" .. (Reason or "No reason provided") .. ")"))
				ply.FAdminKickReason = nil
			end
		end
	end
end

local StartBannedUsers = {} -- Prevent rejoining before actual ban occurs
hook.Add("PlayerAuthed", "FAdmin_LeavingBeforeBan", function(ply, SteamID, ...)
	if table.HasValue(StartBannedUsers, SteamID) then
		game.ConsoleCommand(string.format("kickid %s %s\n", ply:UserID(), "Getting banned"))
	end
end)

-- Banning
FAdmin.BANS = FAdmin.BANS or {}

local function RequestBans(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "UnBan") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	net.Start("FAdmin_retrievebans")
		net.WriteTable(FAdmin.BANS)
	net.Send(ply)
end

timer.Create("FAdminCheckBans", 60, 0, function()
	local changed = false
	for k,v in pairs(FAdmin.BANS) do
		if v.time and type(v.time) ~= "string" and tonumber(v.time) < os.time() and v.time ~= 0 then
			FAdmin.BANS[k] = nil
			changed = true
		end
	end

	if changed then
		file.Write("FAdmin/Bans.txt", util.TableToKeyValues(FAdmin.BANS))
	end
end)

local function SaveBan(SteamID, Nick, Duration, Reason, AdminName, Admin_steam)
	local StoreBans = hook.Call("FAdmin_StoreBan", nil, SteamID, Nick, Duration, Reason, AdminName, Admin_steam)

	if tonumber(Duration) == 0 then
		FAdmin.BANS[SteamID] = {}
		FAdmin.BANS[SteamID].time = 0
		FAdmin.BANS[SteamID].name = Nick
		FAdmin.BANS[SteamID].reason = Reason
		FAdmin.BANS[SteamID].adminname = AdminName
		FAdmin.BANS[SteamID].adminsteam = Admin_steam
	else
		FAdmin.BANS[SteamID] = {}
		FAdmin.BANS[SteamID].time = os.time() + Duration*60--in minutes, so *60
		FAdmin.BANS[SteamID].name = Nick
		FAdmin.BANS[SteamID].reason = Reason
		FAdmin.BANS[SteamID].adminname = AdminName
		FAdmin.BANS[SteamID].adminsteam = Admin_steam
	end

	if StoreBans == true then return end
	file.Write("FAdmin/Bans.txt", util.TableToKeyValues(FAdmin.BANS))
end

local function Ban(ply, cmd, args)
	if not args[2] then return end
	--start cancel update execute

	local targets = FAdmin.FindPlayer(args[1])

	if not targets and string.find(args[1], "STEAM_") ~= 1 and string.find(args[2], "STEAM_") ~= 1 then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	elseif not targets and (string.find(args[1], "STEAM_") == 1 or string.find(args[2], "STEAM_") == 1) then
		targets = {(args[1] ~= "execute" and args[1]) or args[2]}
	end

	local CanBan = hook.Call("FAdmin_CanBan", nil, ply, targets)

	if CanBan == false then return end

	local stage = string.lower(args[2])
	local Reason = args[4] or ply.FAdminKickReason or ""
	for _, target in pairs(targets) do
		if (type(target) == "string" and not FAdmin.Access.PlayerHasPrivilege(ply, "Ban")) or
		not FAdmin.Access.PlayerHasPrivilege(ply, "Ban", target) then
			FAdmin.Messages.SendMessage(ply, 5, "No access!")
			return
		end
		if stage == "start" and type(target) ~= "string" and IsValid(target) then
			SendUserMessage("FAdmin_ban_start", target) -- Tell him he's getting banned
			target:Lock() -- Make sure he can't remove the hook clientside and keep minging.
			target:KillSilent()
			table.insert(StartBannedUsers, target:SteamID())

		elseif stage == "cancel" then
			if type(target) ~= "string" and IsValid(target) then
				SendUserMessage("FAdmin_ban_cancel", target) -- No I changed my mind, you can stay
				target:UnLock()
				target:Spawn()
				for k,v in pairs(StartBannedUsers) do
					if v == target:SteamID() then
						table.remove(StartBannedUsers, k)
					end
				end
			else -- If he left and you want to cancel
				for k,v in pairs(StartBannedUsers) do
					if v == args[1] then
						table.remove(StartBannedUsers, k)
					end
				end
			end
		elseif stage == "update" then -- Update reason text
			if not args[4] or type(target) == "string" or not IsValid(target) then return end
			ply.FAdminKickReason = args[4]
			umsg.Start("FAdmin_ban_update", target)
				umsg.Long(tonumber(args[3]))
				umsg.String(tostring(args[4]))
			umsg.End()
		else
			local time, Reason = tonumber(args[2]) or 0, (Reason ~= "" and Reason) or args[3] or ""
			if stage == "execute" then
				time = tonumber(args[3]) or 60 --Default to one hour, not permanent.
				Reason = args[4] or ""
			end

			local TimeText = FAdmin.PlayerActions.ConvertBanTime(time)
			if type(target) ~= "string" and  IsValid(target) then
				for k,v in pairs(StartBannedUsers) do
					if v == target:SteamID() then
						table.remove(StartBannedUsers, k)
						break
					end
				end
				local nick = ply.Nick and ply:Nick() or "console"
				SaveBan(target:SteamID(), target:Nick(), time, Reason, nick, ply.SteamID and ply:SteamID() or "Console")
				game.ConsoleCommand("banid " .. time.." ".. target:SteamID().."\n") -- Don't use banid in combination with RunConsoleCommand
				game.ConsoleCommand(string.format("kickid %s %s\n", target:UserID(), " banned by "..nick.." for "..TimeText.." ("..Reason .. ")" ))
			else
				for k,v in pairs(StartBannedUsers) do
					if v == args[1] then
						table.remove(StartBannedUsers, k)
						break
					end
				end

				SaveBan(target, nil, time, Reason ~= "" and Reason, ply.Nick and ply:Nick() or "console", ply.SteamID and ply:SteamID() or "Console") -- Again default to one hour
				game.ConsoleCommand("banid ".. time.." ".. target.."\n")
				FAdmin.Messages.SendMessage(ply, 4, "Ban successful")
			end
			ply.FAdminKickReason = nil
		end
	end
end

-- Unbanning
local function UnBan(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "UnBan") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[1] then return end
	local SteamID = string.upper(args[1])

	hook.Call("FAdmin_UnBan", nil, ply, SteamID)

	for k,v in pairs(FAdmin.BANS) do
		if string.upper(k) == SteamID then
			FAdmin.BANS[string.upper(k)] = nil
			break
		end
	end

	for k,v in pairs(StartBannedUsers) do
		if string.upper(v) == SteamID then
			StartBannedUsers[k] = nil
			break
		end
	end

	file.Write("FAdmin/Bans.txt", util.TableToKeyValues(FAdmin.BANS))
	game.ConsoleCommand("removeid ".. SteamID .. "\n")
	FAdmin.Messages.SendMessage(ply, 4, "Unban successful!")
end

-- Commands and privileges
FAdmin.StartHooks["KickBan"] = function()
	FAdmin.Commands.AddCommand("kick", Kick)
	FAdmin.Commands.AddCommand("ban", Ban)
	FAdmin.Commands.AddCommand("unban", UnBan)
	FAdmin.Commands.AddCommand("RequestBans", RequestBans)

	FAdmin.Access.AddPrivilege("Kick", 2)
	FAdmin.Access.AddPrivilege("Ban", 2)
	FAdmin.Access.AddPrivilege("UnBan", 2)
end

hook.Add("InitPostEntity", "FAdmin_Retrievebans", function()
	local RetrieveBans = hook.Call("FAdmin_RetrieveBans", nil)
	file.CreateDir("FAdmin")

	if RetrieveBans then
		for k,v in pairs(RetrieveBans) do
			FAdmin.BANS[string.upper(k)] = v
		end
		return
	end
	if file.Exists("FAdmin/Bans.txt", "DATA") then
		local bans = util.KeyValuesToTable(file.Read("FAdmin/bans.txt", "DATA") or {})
		for k,v in pairs(bans) do
			FAdmin.BANS[string.upper(k)] = v
		end

		for k,v in pairs(FAdmin.BANS) do
			if tonumber(v.time) and tonumber(v.time) < os.time() then
				FAdmin.BANS[string.upper(k)] = nil
			end
			if v.time == 0 then
				game.ConsoleCommand("banid 0 "..k.. "\n")
			else
				game.ConsoleCommand("banid ".. (v.time - os.time())/60 .." " .. k.. "\n")
			end
		end
		file.Write("FAdmin/Bans.txt", util.TableToKeyValues(FAdmin.BANS))
	end
end)