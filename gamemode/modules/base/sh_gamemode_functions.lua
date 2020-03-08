function GM:SetupMove(ply, mv, cmd)
    if ply:isArrested() then
        mv:SetMaxClientSpeed(self.Config.arrestspeed)
    end
    return self.Sandbox.SetupMove(self, ply, mv, cmd)
end

function GM:StartCommand(ply, usrcmd)
    -- Used in arrest_stick and unarrest_stick but addons can use it too!
    local wep = ply:GetActiveWeapon()
    if wep:IsValid() and isfunction(wep.startDarkRPCommand) then
        wep:startDarkRPCommand(usrcmd)
    end
end

function GM:OnPlayerChangedTeam(ply, oldTeam, newTeam)
    if RPExtraTeams[oldTeam] and RPExtraTeams[oldTeam].OnPlayerLeftTeam then
        RPExtraTeams[oldTeam].OnPlayerLeftTeam(ply, newTeam)
    end

    if RPExtraTeams[newTeam] and RPExtraTeams[newTeam].OnPlayerChangedTeam then
        RPExtraTeams[newTeam].OnPlayerChangedTeam(ply, oldTeam, newTeam)
    end

    if CLIENT then return end

    local agenda = ply:getAgendaTable()

    -- Remove agenda text when last manager left
    if agenda and agenda.ManagersByKey[oldTeam] then
        local found = false
        for man, _ in pairs(agenda.ManagersByKey) do
            if team.NumPlayers(man) > 0 then found = true break end
        end
        if not found then agenda.text = nil end
    end

    ply:setSelfDarkRPVar("agenda", agenda and agenda.text or nil)
end

hook.Add("loadCustomDarkRPItems", "CAMI privs", function()
    CAMI.RegisterPrivilege{
        Name = "DarkRP_SeeEvents",
        MinAccess = "admin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_GetAdminWeapons",
        MinAccess = "admin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_SetDoorOwner",
        MinAccess = "admin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_ChangeDoorSettings",
        MinAccess = "superadmin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_AdminCommands",
        MinAccess = "admin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_SetMoney",
        MinAccess = "superadmin"
    }

    CAMI.RegisterPrivilege{
        Name = "DarkRP_SetLicense",
        MinAccess = "superadmin"
    }

    for _, v in pairs(RPExtraTeams) do
        if not v.vote or v.admin and v.admin > 1 then continue end

        local toAdmin = {[0] = "admin", [1] = "superadmin"}
        CAMI.RegisterPrivilege{
            Name = "DarkRP_GetJob_" .. v.command,
            MinAccess = toAdmin[v.admin or 0]-- Add privileges for the teams that are voted for
        }
    end
end)
