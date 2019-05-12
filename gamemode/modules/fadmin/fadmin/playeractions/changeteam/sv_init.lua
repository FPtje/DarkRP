local function checkDarkRP(ply, target, t)
    if not DarkRP then return true end

    local TEAM = RPExtraTeams[t]
    if not TEAM then return true end

    if TEAM.customCheck then
        local ret = TEAM.customCheck(target)
        if ret ~= nil and not (ply:IsAdmin() and GAMEMODE.Config.adminBypassJobRestrictions) then return ret end
    end

    local hookValue = hook.Call("playerCanChangeTeam", nil, target, t, true)
    if hookValue == false then return false end

    local a = TEAM.admin
    if a > 0 and not target:IsAdmin()
    or a > 1 and not target:IsSuperAdmin()
    then return false end

    return true
end

local function SetTeam(ply, cmd, args)
    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    local targetsSet = {}
    for k, v in pairs(team.GetAllTeams()) do
        if k == tonumber(args[2]) or string.lower(v.Name) == string.lower(args[2] or "") then
            for _, target in pairs(targets) do
                if not FAdmin.Access.PlayerHasPrivilege(ply, "SetTeam", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
                local setTeam = target.changeTeam or target.SetTeam -- DarkRP compatibility
                if IsValid(target) and checkDarkRP(ply, target, k) then
                    setTeam(target, k, true)
                    table.insert(targetsSet, target)
                end
            end

            if not table.IsEmpty(targetsSet) then
                FAdmin.Messages.FireNotification("setteam", ply, targetsSet, {k})
            else
                FAdmin.Messages.SendMessage(ply, 1, "Could not set team")
            end

            break
        end
    end

    return true, targets
end

FAdmin.StartHooks["zzSetTeam"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "setteam",
        hasTarget = true,
        receivers = "everyone",
        writeExtraInfo = function(info) net.WriteUInt(info[1], 16) end,
        message = {"instigator", " set the team of ", "targets", " to ", "extraInfo.1"},
    }

    FAdmin.Commands.AddCommand("SetTeam", SetTeam)

    FAdmin.Access.AddPrivilege("SetTeam", 2)
end
