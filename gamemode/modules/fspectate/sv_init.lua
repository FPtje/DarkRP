local OnPlayerSay

local function Spectate(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "Spectate") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

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

    hook.Add("PlayerSay", ply, OnPlayerSay)

    local targetText = IsValid(target) and (target:Nick() .. " (" .. target:SteamID() .. ")") or ""
    FAdmin.Messages.SendMessage(ply, 4, "You are now spectating " .. targetText)

    return true, target
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
    hook.Remove("PlayerSay", ply)
end
concommand.Add("_FAdmin_StopSpectating", endSpectate)

local function playerVoice(listener, talker)
    if not IsValid(listener.FAdminSpectatingEnt) then return end

    -- You can hear someone if your spectate target can hear them
    local canHear, surround = GAMEMODE:PlayerCanHearPlayersVoice(listener.FAdminSpectatingEnt, talker)
    local canHearLocal = GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)

    -- you can always hear the person you're spectating
    return canHear or canHearLocal or listener.FAdminSpectatingEnt == talker, surround
end
hook.Add("PlayerCanHearPlayersVoice", "FAdminSpectate", playerVoice)

OnPlayerSay = function(spectator, sender, message, isTeam)
    -- the person is saying it close to where you are roaming
    if spectator.FAdminSpectatePos and sender:GetShootPos():Distance(spectator.FAdminSpectatePos) <= 400 and
        sender:GetShootPos():Distance(spectator:GetShootPos()) > 250 then-- Make sure you don't get it twice

        DarkRP.talkToPerson(spectator, team.GetColor(sender:Team()), sender:Nick(), Color(255, 255, 255, 255), message, sender)
        return
    end

    -- The person you're spectating or someone near the person you're spectating is saying it
    if IsValid(spectator.FAdminSpectatingEnt) and
        sender:GetShootPos():Distance(spectator.FAdminSpectatingEnt:GetShootPos()) <= 300 and
        sender:GetShootPos():Distance(spectator:GetShootPos()) > 250 then
        DarkRP.talkToPerson(spectator, team.GetColor(sender:Team()), sender:Nick(), Color(255, 255, 255, 255), message, sender)
    end
end

FAdmin.StartHooks["Spectate"] = function()
    FAdmin.Commands.AddCommand("Spectate", Spectate)

    FAdmin.Access.AddPrivilege("Spectate", 2)
end
