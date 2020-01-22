util.AddNetworkString("FAdmin_Notification")

function FAdmin.Messages.SendMessage(ply, MsgType, text)
    if ply:EntIndex() == 0 then
        ServerLog("FAdmin: " .. text .. "\n")
        print("FAdmin: " .. text)

        return
    end

    umsg.Start("FAdmin_SendMessage", ply)
        umsg.Short(MsgType)
        umsg.String(text)
    umsg.End()
    ply:PrintMessage(HUD_PRINTCONSOLE, text)
end

function FAdmin.Messages.SendMessageAll(text, MsgType)
    FAdmin.Log("FAdmin message to everyone: " .. text)
    umsg.Start("FAdmin_SendMessage")
        umsg.Short(MsgType)
        umsg.String(text)
    umsg.End()

    for _, ply in ipairs(player.GetAll()) do
        ply:PrintMessage(HUD_PRINTCONSOLE, text)
    end
end

function FAdmin.Messages.ConsoleNotify(ply, message)
    umsg.Start("FAdmin_ConsoleMessage", ply)
        umsg.String(message)
    umsg.End()
end

function FAdmin.Messages.ActionMessage(ply, target, messageToPly, MessageToTarget, LogMSG)
    if not target then return end
    local Targets = (target.IsPlayer and target:IsPlayer() and target:Nick()) or ""

    local plyNick = IsValid(ply) and ply:IsPlayer() and ply:Nick() or "Console"
    local plySteamID = IsValid(ply) and ply:IsPlayer() and ply:SteamID() or "Console"
    local bad = false

    if ply ~= target then
        if istable(target) then
            if table.IsEmpty(target) then Targets = "no one" bad = true end
            for k, v in pairs(target) do
                local suffix = ((k == #target-1) and " and ") or (k ~= #target and ", ") or ""
                local Name = (v == ply and "yourself") or v:Nick()

                if v ~= ply then FAdmin.Messages.SendMessage(v, 2, string.format(MessageToTarget, plyNick)) end
                Targets = Targets .. Name .. suffix
            end
        else
            FAdmin.Messages.SendMessage(target, 2, string.format(MessageToTarget, plyNick))
        end

        FAdmin.Messages.SendMessage(ply, bad and 1 or 4, string.format(messageToPly, Targets))

    else
        FAdmin.Messages.SendMessage(ply, bad and 1 or 4, string.format(messageToPly, "yourself"))
    end

    local action = plyNick .. " (" .. plySteamID .. ") " .. string.format(LogMSG, Targets:gsub("yourself", "themselves"))
    FAdmin.Log("FAdmin Action: " .. action)

    local haspriv = fn.Partial(fn.Flip(FAdmin.Access.PlayerHasPrivilege), "SeeAdmins")
    local plys = fn.Filter(haspriv, player.GetAll())
    if table.IsEmpty(plys) then return end
    FAdmin.Messages.ConsoleNotify(plys, action)
end


local function logNotification(notification, instigator, targets, extraInfo)
    local msgs = table.Copy(notification.message)

    local function replace(val)
        if val == "instigator" then return FAdmin.PlayerName(instigator) end
        if val == "targets" then return FAdmin.TargetsToString(targets) end
        if string.sub(val, 1, 10) == "extraInfo." then return tostring(extraInfo[tonumber(string.sub(val, 11))]) end

        return val
    end

    fn.Map(replace, msgs)

    FAdmin.Log(table.concat(msgs))
end

local receiversToPlayers -- allows usage of variable inside
receiversToPlayers = {
    everyone = player.GetAll,
    admins = function() return table.ClearKeys(fn.Filter(tc.player.IsAdmin, player.GetAll())) end,
    superadmins = function() return table.ClearKeys(fn.Filter(tc.player.IsSuperAdmin, player.GetAll())) end,
    self = fn.Id,
    targets = function(_, t) return t end,
    involved = function(i, t) local res = table.Copy(istable(t) and t or {t}) table.insert(res, i) return res end,
    ["involved+admins"] = function(i, t) return table.Add(receiversToPlayers.admins(i, t), receiversToPlayers.involved(i, t)) end,
    ["involved+superadmins"] = function(i, t) return table.Add(receiversToPlayers.superadmins(i, t), receiversToPlayers.involved(i, t)) end,
}
function FAdmin.Messages.FireNotification(name, instigator, targets, extraInfo)
    local notId = FAdmin.NotificationNames[name]

    if not notId then
        error(string.format("Notification '%s' does not exist!", name), 2)
    end

    local notification = FAdmin.Notifications[notId]
    local receivers = receiversToPlayers[notification.receivers]
    receivers = receivers and receivers(instigator, targets) or notification.receivers(instigator, targets)

    local targetCount = istable(targets) and #targets or not IsValid(targets) and 0 or 1

    net.Start("FAdmin_Notification")
        net.WriteUInt(notId, 16)

        net.WriteEntity(instigator)

        if notification.hasTarget then
            net.WriteUInt(targetCount, 8)

            if istable(targets) then
                for _, t in pairs(targets) do
                    net.WriteEntity(t)
                end
            else
                net.WriteEntity(targets)
            end
        end

        if notification.writeExtraInfo then notification.writeExtraInfo(extraInfo) end
    net.Send(receivers)

    if notification.logging then
        logNotification(notification, instigator, targets, extraInfo)
    end
end
