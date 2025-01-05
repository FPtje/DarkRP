-- Kicking
local function Kick(ply, cmd, args)
    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    local CanKick = hook.Call("FAdmin_CanKick", nil, ply, targets)

    if CanKick == false then return false end

    local stage = args[2] or ""
    stage = string.lower(stage)
    local stages = {"start", "cancel", "update", "execute"}
    local Reason = (not table.HasValue(stages, stage) and table.concat(args, ' ', 2)) or table.concat(args, ' ', 3) or ply.FAdminKickReason

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Kick", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
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
                if not args[3] then return false end
                ply.FAdminKickReason = args[3]
                SendUserMessage("FAdmin_kick_update", target, args[3])
            else
                local name = IsValid(ply) and ply:IsPlayer() and ply:Nick() or "Console"

                Reason = Reason and string.gsub(Reason, ";", " ") or "No reason provided"

                hook.Call("FAdmin_Kick", nil, ply, target, Reason)
                game.ConsoleCommand(string.format("kickid %s %s\n", target:UserID(), "Kicked by " .. name ..
                    " (" .. Reason .. ")"))
                ply.FAdminKickReason = nil
            end
        end
    end

    if stage ~= "start" and stage ~= "cancel" and stage ~= "update" then
        FAdmin.Messages.FireNotification("kick", ply, nil, {FAdmin.TargetsToString(targets), Reason})
    end

    return true, targets, stage, Reason
end

local StartBannedUsers = {} -- Prevent rejoining before actual ban occurs
hook.Add("PlayerAuthed", "FAdmin_LeavingBeforeBan", function(ply, SteamID, ...)
    if not StartBannedUsers[SteamID] then return end
    if not IsValid(StartBannedUsers[SteamID].author) then
        StartBannedUsers[SteamID] = nil
        return
    end

    game.ConsoleCommand(string.format("kickid %s %s\n", ply:UserID(), "Getting banned"))
end)

-- Banning
FAdmin.BANS = FAdmin.BANS or {}

local function RequestBans(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "UnBan") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    net.Start("FAdmin_retrievebans")
        net.WriteUInt(table.Count(FAdmin.BANS), 32)

        for k, v in pairs(FAdmin.BANS) do
            net.WriteString(k or "") -- SteamID
            net.WriteUInt(v.time or 0, 32)
            net.WriteString(v.name or "")
            net.WriteString(v.reason or "")
            net.WriteString(v.adminname or "")
            net.WriteString(v.adminsteam or "")
        end
    net.Send(ply)

    return true, FAdmin.BANS
end

timer.Create("FAdminCheckBans", 60, 0, function()
    for k, v in pairs(FAdmin.BANS) do
        if v.time and not isstring(v.time) and tonumber(v.time) < os.time() and v.time ~= 0 then
            FAdmin.BANS[k] = nil
        end
    end
end)

local function SaveBan(SteamID, Nick, Duration, Reason, AdminName, Admin_steam)
    local StoreBans = hook.Call("FAdmin_StoreBan", nil, SteamID, Nick, Duration, Reason, AdminName, Admin_steam)
    if StoreBans == true then return end

    if tonumber(Duration) == 0 then
        FAdmin.BANS[SteamID] = {}
        FAdmin.BANS[SteamID].time = 0
        FAdmin.BANS[SteamID].name = Nick
        FAdmin.BANS[SteamID].reason = Reason
        FAdmin.BANS[SteamID].adminname = AdminName
        FAdmin.BANS[SteamID].adminsteam = Admin_steam
    else
        FAdmin.BANS[SteamID] = {}
        FAdmin.BANS[SteamID].time = os.time() + Duration * 60 --in minutes, so *60
        FAdmin.BANS[SteamID].name = Nick
        FAdmin.BANS[SteamID].reason = Reason
        FAdmin.BANS[SteamID].adminname = AdminName
        FAdmin.BANS[SteamID].adminsteam = Admin_steam
    end
end

local function Ban(ply, cmd, args)
    if not args[2] then return false end
    --start cancel update execute

    local targets = FAdmin.FindPlayer(args[1])

    if not targets and string.find(args[1], "STEAM_") ~= 1 and string.find(args[2], "STEAM_") ~= 1 then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    elseif not targets and (string.find(args[1], "STEAM_") == 1 or string.find(args[2], "STEAM_") == 1) then
        targets = {(args[1] ~= "execute" and args[1]) or args[2]}
        if args[1] == "STEAM_0" then
            targets[1] = table.concat(args, "", 1, 5)
            args[1] = targets[1]
            args[2] = args[6]
            args[3] = args[7]
            targets = FAdmin.FindPlayer(targets[1]) or targets
            for i = 2, #args do
                if i >= 4 then args[i] = nil end
            end
        end
    end

    local CanBan = hook.Call("FAdmin_CanBan", nil, ply, targets)

    if CanBan == false then return false end

    local stage = string.lower(args[2])
    local stages = {"start", "cancel", "update", "execute"}
    local Reason = (not table.HasValue(stages, stage) and table.concat(args, ' ', 3)) or table.concat(args, ' ', 4) or ply.FAdminKickReason
    local time

    for _, target in pairs(targets) do
        if (isstring(target) and not FAdmin.Access.PlayerHasPrivilege(ply, "Ban")) or
        not FAdmin.Access.PlayerHasPrivilege(ply, "Ban", target) then
            FAdmin.Messages.SendMessage(ply, 5, "No access!")
            return false
        end
        if stage == "start" and not isstring(target) and IsValid(target) then
            SendUserMessage("FAdmin_ban_start", target) -- Tell him he's getting banned
            target:Lock() -- Make sure he can't remove the hook clientside and keep minging.
            target:KillSilent()
            StartBannedUsers[target:SteamID()] = {author = ply}

        elseif stage == "cancel" then
            if not isstring(target) and IsValid(target) then
                SendUserMessage("FAdmin_ban_cancel", target) -- No I changed my mind, you can stay
                target:UnLock()
                target:Spawn()
                StartBannedUsers[target:SteamID()] = nil
            else -- If he left and you want to cancel
                StartBannedUsers[args[1]] = nil
            end
        elseif stage == "update" then -- Update reason text
            if not args[4] or isstring(target) or not IsValid(target) then return false end
            ply.FAdminKickReason = args[4]
            umsg.Start("FAdmin_ban_update", target)
                umsg.Long(tonumber(args[3]))
                umsg.String(tostring(args[4]))
            umsg.End()
        else
            time = tonumber(args[2]) or 0
            Reason = (Reason ~= "" and Reason) or args[3] or ""

            if stage == "execute" then
                time = tonumber(args[3]) or 60 --Default to one hour, not permanent.
                Reason = args[4] or ""
            end

            local TimeText = FAdmin.PlayerActions.ConvertBanTime(time)

            if not isstring(target) and IsValid(target) then
                StartBannedUsers[target:SteamID()] = nil
                local nick = ply.Nick and ply:Nick() or "console"
                SaveBan(target:SteamID(), target:Nick(), time, Reason, nick, ply.SteamID and ply:SteamID() or "Console")

                Reason = string.gsub(Reason, ";", " ")
                target:Kick("banned by " .. nick .. " for " .. TimeText .. " (" .. Reason .. ")")
            else
                StartBannedUsers[args[1]] = nil

                SaveBan(target, nil, time, Reason ~= "" and Reason, ply.Nick and ply:Nick() or "console", ply.SteamID and ply:SteamID() or "Console") -- Again default to one hour
            end
            ply.FAdminKickReason = nil
        end
    end

    if stage ~= "start" and stage ~= "cancel" and stage ~= "update" then
        FAdmin.Messages.FireNotification("ban", ply, nil, {FAdmin.TargetsToString(targets), time, Reason})
    end

    return true, targets, stage, Reason
end

-- Input validation: verify that a steam id is valid
local function isValidSteamId(steamId)
    if steamId == "STEAM_ID_PENDING" then return true end
    if steamId == "UNKNOWN" then return true end
    if string.match(steamId, "^STEAM_[0-9]:[0-9]:[0-9]+$") then return true end
    if string.match(steamId, "^[0-9]+$") then return true end
    return false
end

-- Unbanning
local function UnBan(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "UnBan") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    if not args[1] then return false end
    local steamID = string.upper(args[1])

    if not isValidSteamId(steamID) then
        FAdmin.Messages.SendMessage(ply, 5, "Player not found")
        return false
    end
    local nick = "Unknown"

    hook.Call("FAdmin_UnBan", nil, ply, steamID)

    for k, v in pairs(FAdmin.BANS) do
        if string.upper(k) == steamID then
            nick = FAdmin.BANS[k].name or nick
            FAdmin.BANS[k] = nil
            break
        end
    end

    StartBannedUsers[steamID] = nil

    game.ConsoleCommand("removeid " .. steamID .. "\n")
    FAdmin.Messages.FireNotification("unban", ply, nil, {nick, steamID})

    return true, steamID
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

hook.Add("DarkRPDBInitialized", "FAdmin_Retrievebans", function()
    timer.Simple(2, function()
        local RetrieveBans = hook.Call("FAdmin_RetrieveBans", nil)

        if RetrieveBans then
            for k, v in pairs(RetrieveBans) do
                FAdmin.BANS[string.upper(k)] = v
            end
            return
        end
    end)

    if file.Exists("FAdmin/Bans.txt", "DATA") then
        local bans = util.KeyValuesToTable(file.Read("FAdmin/bans.txt", "DATA") or {})
        for k, v in pairs(bans) do
            FAdmin.BANS[string.upper(k)] = v
        end

        for k, v in pairs(FAdmin.BANS) do
            v.time = tonumber(v.time)
            if v.time and v.time < os.time() then
                FAdmin.BANS[string.upper(k)] = nil
                continue
            elseif not v.time then
                continue
            end

            hook.Call("FAdmin_StoreBan", nil, string.upper(k), v.name, (v.time - os.time()) / 60, v.reason, v.adminname, v.adminsteam)
        end
        file.Delete("FAdmin/Bans.txt", "DATA")
    end
end)

local function canJoin(steamID)
    local ban = FAdmin.BANS[string.upper(steamID)]

    if not ban then return end

    if ban.time ~= 0 and ban.time < os.time() then
        FAdmin.BANS[string.upper(steamID)] = nil
        return
    end

    local timeText = FAdmin.PlayerActions.ConvertBanTime((ban.time - os.time()) / 60)

    return false, "banned by " .. (ban.adminname or "<Unknown>") .. " for " .. timeText .. " (" .. (ban.reason or "no reason") .. ")"
end
hook.Add("CheckPassword", "FAdmin_Bans", fc{canJoin, util.SteamIDFrom64})

-- When the bans haven't loaded yet, or when the player passes
-- CheckPassword when banned, they'll be caught on InitialSpawn
hook.Add("PlayerInitialSpawn", "FAdmin_Bans", function(ply)
    local allowedIn, reason = canJoin(ply:SteamID())
    if allowedIn == false then
        ply:Kick(reason)
    end
end)

hook.Add("PlayerDisconnected", "FAdmin bans", function(ply)
    for k,v in pairs(StartBannedUsers) do
        if v.author ~= ply then continue end
        StartBannedUsers[k] = nil
        local target = player.GetBySteamID(k)
        if not IsValid(target) then continue end
        SendUserMessage("FAdmin_ban_cancel", target)
        target:UnLock()
        target:Spawn()
    end
end)
