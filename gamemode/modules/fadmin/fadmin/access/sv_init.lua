--Immunity
cvars.AddChangeCallback("_FAdmin_immunity", function(Cvar, Previous, New)
    FAdmin.SetGlobalSetting("Immunity", (tonumber(New) == 1 and true) or false)
    FAdmin.SaveSetting("_FAdmin_immunity", tonumber(New))
end)

hook.Add("DatabaseInitialized", "InitializeFAdminGroups", function()
    MySQLite.query("CREATE TABLE IF NOT EXISTS FADMIN_GROUPS(NAME VARCHAR(40) NOT NULL PRIMARY KEY, ADMIN_ACCESS INTEGER NOT NULL);")
    MySQLite.query("CREATE TABLE IF NOT EXISTS FAdmin_PlayerGroup(steamid VARCHAR(40) NOT NULL, groupname VARCHAR(40) NOT NULL, PRIMARY KEY(steamid));")
    MySQLite.query("CREATE TABLE IF NOT EXISTS FAdmin_Immunity(groupname VARCHAR(40) NOT NULL, immunity INTEGER NOT NULL, PRIMARY KEY(groupname));")
    MySQLite.query("CREATE TABLE IF NOT EXISTS FAdmin_CAMIPrivileges(privname VARCHAR(255) NOT NULL PRIMARY KEY);")
    MySQLite.query("CREATE TABLE IF NOT EXISTS FADMIN_GROUPS_SRC(NAME VARCHAR(40) NOT NULL PRIMARY KEY REFERENCES FADMIN_GROUPS(NAME) ON DELETE CASCADE, SRC VARCHAR(40));")
    MySQLite.query([[CREATE TABLE IF NOT EXISTS FADMIN_PRIVILEGES(
        NAME VARCHAR(40),
        PRIVILEGE VARCHAR(100),
        PRIMARY KEY(NAME, PRIVILEGE),
        FOREIGN KEY(NAME) REFERENCES FADMIN_GROUPS(NAME)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );]], function()

        -- Remove SetAccess workaround
        MySQLite.query([[DELETE FROM FADMIN_PRIVILEGES WHERE NAME = "user" AND PRIVILEGE = "SetAccess";]])

        MySQLite.query("SELECT g.NAME, g.ADMIN_ACCESS, p.PRIVILEGE, i.immunity, s.src FROM FADMIN_GROUPS g LEFT OUTER JOIN FADMIN_PRIVILEGES p ON g.NAME = p.NAME LEFT OUTER JOIN FAdmin_Immunity i ON g.NAME = i.groupname LEFT OUTER JOIN FADMIN_GROUPS_SRC s ON g.NAME = s.NAME;", function(data)
            if not data then return end

            for _, v in pairs(data) do
                FAdmin.Access.Groups[v.NAME] = FAdmin.Access.Groups[v.NAME] or
                    {ADMIN = tonumber(v.ADMIN_ACCESS), PRIVS = {}}

                if v.PRIVILEGE and v.PRIVILEGE ~= "NULL" then
                    FAdmin.Access.Groups[v.NAME].PRIVS[v.PRIVILEGE] = true
                end

                if v.immunity and v.immunity ~= "NULL" then
                    FAdmin.Access.Groups[v.NAME].immunity = tonumber(v.immunity)
                end

                if CAMI.GetUsergroup(v.NAME) then continue end

                CAMI.RegisterUsergroup({
                    Name = v.NAME,
                    Inherits = FAdmin.Access.ADMIN[v.ADMIN_ACCESS] or "user"
                }, v.SRC)
            end

            -- Send groups to early joiners and listen server hosts
            for _, v in ipairs(player.GetAll()) do
                FAdmin.Access.SendGroups(v)
            end

            -- See if there are any CAMI usergroups that FAdmin doesn't know about yet.
            -- FAdmin doesn't start listening immediately because the database might not have initialised.
            -- Besides, other admin mods might add usergroups before FAdmin's Lua files are even run
            for _, v in pairs(CAMI.GetUsergroups()) do
                if FAdmin.Access.Groups[v.Name] then continue end

                FAdmin.Access.OnUsergroupRegistered(v,"")
            end

            -- Start listening for CAMI usergroup registrations.
            hook.Add("CAMI.OnUsergroupRegistered", "FAdmin", FAdmin.Access.OnUsergroupRegistered)
            hook.Add("CAMI.OnUsergroupUnregistered", "FAdmin", FAdmin.Access.OnUsergroupUnregistered)

            FAdmin.Access.RegisterCAMIPrivileges()
        end)

        local function createGroups(privs)
            FAdmin.Access.AddGroup("superadmin", 2, privs.superadmin, 100)
            FAdmin.Access.AddGroup("admin", 1, privs.admin, 50)
            FAdmin.Access.AddGroup("user", 0, privs.user, 10)
            FAdmin.Access.AddGroup("noaccess", 0, privs.noaccess, 0)
        end

        MySQLite.query("SELECT DISTINCT PRIVILEGE FROM FADMIN_PRIVILEGES;", function(privTbl)
            local privs = {}
            local hasPrivs = {"noaccess", "user", "admin", "superadmin"}

            -- No privileges registered to anyone. Reset everything
            if not privTbl or table.IsEmpty(privTbl) then
                for priv, access in pairs(FAdmin.Access.Privileges) do
                    for i = access + 1, #hasPrivs, 1 do
                        privs[hasPrivs[i]] = privs[hasPrivs[i]] or {}
                        privs[hasPrivs[i]][priv] = true
                    end
                end

                createGroups(privs)

                return
            end

            -- Check for newly created privileges and assign them to the default usergroups
            -- No privilege can be revoke from every group
            local privSet = {}
            for _, priv in ipairs(privTbl) do
                privSet[priv.PRIVILEGE] = true
            end

            for priv, access in pairs(FAdmin.Access.Privileges) do
                if privSet[priv] then continue end

                for i = access + 1, #hasPrivs do
                    MySQLite.query(("REPLACE INTO FADMIN_PRIVILEGES VALUES(%s, %s);"):format(MySQLite.SQLStr(hasPrivs[i]), MySQLite.SQLStr(priv)))
                end
            end

            createGroups(privs)
        end)
    end)
end)

-- Assign a privilege to its respective usergroups when they are seen for the first time
function FAdmin.Access.RegisterCAMIPrivilege(priv)
    -- Privileges haven't been loaded yet or has already been seen
    if not FAdmin.CAMIPrivs or FAdmin.CAMIPrivs[priv.Name] then return end

    FAdmin.CAMIPrivs[priv.Name] = true

    for groupName, groupdata in pairs(FAdmin.Access.Groups) do
        if FAdmin.Access.Privileges[priv.Name] - 1 > groupdata.ADMIN then continue end
        groupdata.PRIVS[priv.Name] = true

        MySQLite.query(string.format([[REPLACE INTO FADMIN_PRIVILEGES VALUES(%s, %s);]], MySQLite.SQLStr(groupName), MySQLite.SQLStr(priv.Name)))
    end

    MySQLite.query(string.format([[REPLACE INTO FAdmin_CAMIPrivileges VALUES(%s);]], MySQLite.SQLStr(priv.Name)))
end

-- Assign privileges to their respective usergroups when they are seen for the first time
function FAdmin.Access.RegisterCAMIPrivileges()
    MySQLite.query([[SELECT privname FROM FAdmin_CAMIPrivileges]], function(data)
        FAdmin.CAMIPrivs = {}

        for _, row in ipairs(data or {}) do
            FAdmin.CAMIPrivs[row.privname] = true
        end


        for privName, _ in pairs(CAMI.GetPrivileges()) do
            if FAdmin.CAMIPrivs[privName] then continue end
            FAdmin.CAMIPrivs[privName] = true

            for groupName, groupdata in pairs(FAdmin.Access.Groups) do
                if FAdmin.Access.Privileges[privName] - 1 > groupdata.ADMIN then continue end
                groupdata.PRIVS[privName] = true

                MySQLite.query(string.format([[REPLACE INTO FADMIN_PRIVILEGES VALUES(%s, %s);]], MySQLite.SQLStr(groupName), MySQLite.SQLStr(privName)))
            end

            MySQLite.query(string.format([[REPLACE INTO FAdmin_CAMIPrivileges VALUES(%s);]], MySQLite.SQLStr(privName)))
        end
    end)
end

function FAdmin.Access.PlayerSetGroup(ply, group)
    if not FAdmin.Access.Groups[group] then return end
    ply = isstring(ply) and FAdmin.FindPlayer(ply) and FAdmin.FindPlayer(ply)[1] or ply

    if not isstring(ply) and IsValid(ply) then
        ply:SetUserGroup(group)
    end
end

hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn") -- Remove Garry's usergroup setter.

-- Update the database only when an end users indicates that a player's usergroup is to be changed.
hook.Add("CAMI.PlayerUsergroupChanged", "FAdmin", function(ply, old, new, source)
    MySQLite.query("REPLACE INTO FAdmin_PlayerGroup VALUES(" .. MySQLite.SQLStr(ply:SteamID()) .. ", " .. MySQLite.SQLStr(new) .. ");")
end)

hook.Add("CAMI.SteamIDUsergroupChanged", "FAdmin", function(steamId, old, new, source)
    MySQLite.query("REPLACE INTO FAdmin_PlayerGroup VALUES(" .. MySQLite.SQLStr(steamId) .. ", " .. MySQLite.SQLStr(new) .. ");")
end)

function FAdmin.Access.SetRoot(ply, cmd, args) -- FAdmin setroot player. Sets the player to superadmin
    if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then
        FAdmin.Messages.SendMessage(ply, 5, "No access!")
        FAdmin.Messages.SendMessage(ply, 5, "Please use RCon to set yourself to superadmin if you are the owner of the server")
        return false
    end

    local group = FAdmin.Access.Groups["superadmin"]
    local plyGroup = FAdmin.Access.Groups[ply:EntIndex() == 0 and "superadmin" or ply:GetUserGroup()]

    -- Setting a group with a higher rank than one's own
    if (not plyGroup or group.immunity > plyGroup.immunity) and not FAdmin.Access.PlayerIsHost(ply) then
        FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to assign anyone a usergroup with a higher rank than your own")
        FAdmin.Messages.SendMessage(ply, 5, "Please use RCon to set yourself to superadmin if you are the owner of the server")
        return false
    end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if not IsValid(target) then continue end

        local target_previous_group = target:GetUserGroup()
        FAdmin.Access.PlayerSetGroup(target, "superadmin")

        -- An end user changed the usergroup. Register with CAMI
        CAMI.SignalUserGroupChanged(target, target_previous_group, "superadmin", "FAdmin")

        FAdmin.Messages.SendMessage(ply, 2, "User set to superadmin!")
    end

    FAdmin.Messages.FireNotification("setaccess", ply, targets, {"superadmin"})
    return true, targets, "superadmin"
end

-- AddGroup <Groupname> <Adminstatus> <Privileges>
local function AddGroup(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "ManageGroups") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    local admin = tonumber(args[2])
    if not args[1] or not admin then FAdmin.Messages.SendMessage(ply, 5, "Incorrect arguments!") return false end
    local privs = {}

    for priv, am in SortedPairs(FAdmin.Access.Privileges) do
        -- The user cannot create groups with privileges they don't have
        if not FAdmin.Access.PlayerHasPrivilege(ply, priv) then continue end
        if am <= admin + 1 then privs[priv] = true end
    end

    local immunity = FAdmin.Access.Groups[FAdmin.Access.ADMIN[admin + 1]].immunity

    local plyGroup = FAdmin.Access.Groups[ply:EntIndex() == 0 and "superadmin" or ply:GetUserGroup()]

    if (not plyGroup or immunity > plyGroup.immunity) and not FAdmin.Access.PlayerIsHost(ply) then
        FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to create usergroups with a higher rank than your own")
        return false
    end

    FAdmin.Access.AddGroup(args[1], admin, privs, immunity) -- Add new group
    FAdmin.Messages.SendMessage(ply, 4, "Group created")
    FAdmin.Access.SendGroups()

    return true, args[1]
end

local function AddPrivilege(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "ManagePrivileges") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local group, priv = args[1], args[2]

    if not FAdmin.Access.Groups[group] or not FAdmin.Access.Privileges[priv] then
        FAdmin.Messages.SendMessage(ply, 5, "Invalid arguments")
        return false
    end

    -- The player cannot add privileges that they themselves do not have
    if not FAdmin.Access.PlayerHasPrivilege(ply, priv) then
        FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to assign privileges that you don't have yourself")
        return false
    end

    local plyGroup = FAdmin.Access.Groups[ply:EntIndex() == 0 and "superadmin" or ply:GetUserGroup()]

    -- Setting a group with a higher rank than one's own
    if (not plyGroup or FAdmin.Access.Groups[group].immunity > plyGroup.immunity) and not FAdmin.Access.PlayerIsHost(ply) then
        FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to manage the privileges of a usergroup with a higher rank than your own")
        return false
    end

    FAdmin.Access.Groups[group].PRIVS[priv] = true

    MySQLite.query("REPLACE INTO FADMIN_PRIVILEGES VALUES(" .. MySQLite.SQLStr(group) .. ", " .. MySQLite.SQLStr(priv) .. ");")
    SendUserMessage("FAdmin_AddPriv", player.GetAll(), group, priv)
    FAdmin.Messages.SendMessage(ply, 4, "Privilege Added!")

    return true, group, priv
end

local function RemovePrivilege(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "ManagePrivileges") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local group, priv = args[1], args[2]
    if not FAdmin.Access.Groups[group] or not FAdmin.Access.Privileges[priv] then
        FAdmin.Messages.SendMessage(ply, 5, "Invalid arguments")
        return false
    end

    local plyGroup = FAdmin.Access.Groups[ply:EntIndex() == 0 and "superadmin" or ply:GetUserGroup()]

    -- Setting a group with a higher rank than one's own
    if (not plyGroup or FAdmin.Access.Groups[group].immunity > plyGroup.immunity) and not FAdmin.Access.PlayerIsHost(ply) then
        FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to manage the privileges of a usergroup with a higher rank than your own")
        return false
    end

    FAdmin.Access.Groups[group].PRIVS[priv] = nil

    MySQLite.query("DELETE FROM FADMIN_PRIVILEGES WHERE NAME = " .. MySQLite.SQLStr(group) .. " AND PRIVILEGE = " .. MySQLite.SQLStr(priv) .. ";")
    SendUserMessage("FAdmin_RemovePriv", player.GetAll(), group, priv)
    FAdmin.Messages.SendMessage(ply, 4, "Privilege Removed!")

    return true, group, priv
end

function FAdmin.Access.SendGroups(ply)
    if not FAdmin.Access.Groups then return end

    net.Start("FADMIN_SendGroups")
        net.WriteTable(FAdmin.Access.Groups)
    net.Send(IsValid(ply) and ply or player.GetAll())
end

-- FAdmin SetAccess <player> <groupname> [new_groupadmin, new_groupprivs]
function FAdmin.Access.SetAccess(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "SetAccess") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local targets = FAdmin.FindPlayer(args[1])
    local admin = tonumber(args[3])
    local group = FAdmin.Access.Groups[args[2]]
    local plyGroup = FAdmin.Access.Groups[ply:EntIndex() == 0 and "superadmin" or ply:GetUserGroup()]

    if not args[2] or not group and not admin then
        FAdmin.Messages.SendMessage(ply, 1, "Group not found")
        return false
    elseif args[2] and not group and admin then
        local privs = {}
        for priv, am in SortedPairs(FAdmin.Access.Privileges) do
            if am <= admin + 1 then privs[priv] = true end
        end

        local immunity = FAdmin.Access.Groups[FAdmin.Access.ADMIN[admin + 1]].immunity
        -- Creating and setting a group with a higher rank than one's own
        if (not plyGroup or immunity > plyGroup.immunity) and not FAdmin.Access.PlayerIsHost(ply) then
            FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to assign anyone a usergroup with a higher rank than your own")
            return false
        end

        FAdmin.Access.AddGroup(args[2], tonumber(args[3]), privs, immunity) -- Add new group
        FAdmin.Messages.SendMessage(ply, 4, "Group created")
        FAdmin.Access.SendGroups()
    end

    -- Setting a group with a higher rank than one's own
    if group and (not plyGroup or group.immunity > plyGroup.immunity) and not FAdmin.Access.PlayerIsHost(ply) then
        FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to assign anyone a usergroup with a higher rank than your own")
        return false
    end

    if not targets and (string.find(args[1], "^STEAM_[0-9]:[01]:[0-9]+$") or args[1] == "BOT" or (string.find(args[1], "STEAM_") and #args == 6)) then
        local target, groupname = args[1], args[2]
        -- The console splits arguments on colons. Very annoying.
        if args[1] == "STEAM_0" then
            target = table.concat(args, "", 1, 5)
            groupname = args[6]
        end
        FAdmin.Access.PlayerSetGroup(target, groupname)

        MySQLite.queryValue(string.format("SELECT groupname FROM FAdmin_PlayerGroup WHERE steamid = %s", MySQLite.SQLStr(target)), function(val)
            CAMI.SignalSteamIDUserGroupChanged(target, val or "user", groupname, "FAdmin")
        end)
        FAdmin.Messages.SendMessage(ply, 4, "User access set!")
        return true, target, groupname
    elseif not targets then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if not IsValid(target) then continue end

        local target_previous_group = target:GetUserGroup()
        FAdmin.Access.PlayerSetGroup(target, args[2])

        -- An end user changed the usergroup. Register with CAMI
        CAMI.SignalUserGroupChanged(target, target_previous_group, args[2], "FAdmin")
    end

    FAdmin.Messages.SendMessage(ply, 4, "User access set!")
    FAdmin.Messages.FireNotification("setaccess", ply, targets, {args[2]})
    return true, targets, args[2]
end

--hooks and stuff

hook.Add("PlayerInitialSpawn", "FAdmin_SetAccess", function(ply)
    MySQLite.queryValue("SELECT groupname FROM FAdmin_PlayerGroup WHERE steamid = " .. MySQLite.SQLStr(ply:SteamID()) .. ";", function(Group)
        if not Group then return end
        ply:SetUserGroup(Group)

        if FAdmin.Access.Groups[Group] then
            ply:FAdmin_SetGlobal("FAdmin_admin", FAdmin.Access.Groups[Group].ADMIN_ACCESS)
        end
    end, function(err) ErrorNoHalt(err) MsgN() end)
    FAdmin.Access.SendGroups(ply)
end)

local function toggleImmunity(ply, cmd, args)
    -- ManageGroups privilege because they can handle immunity settings
    if not FAdmin.Access.PlayerHasPrivilege(ply, "ManageGroups") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    if not args[1] then FAdmin.Messages.SendMessage(ply, 5, "Invalid argument!") return false end
    RunConsoleCommand("_FAdmin_immunity", args[1])
    local OnOff = (tonumber(args[1]) == 1 and "on") or "off"
    FAdmin.Messages.ActionMessage(ply, player.GetAll(), ply:Nick() .. " turned " .. OnOff .. " admin immunity!", "Admin immunity has been turned " .. OnOff, "Turned admin immunity " .. OnOff)

    return true, OnOff
end


local function setImmunity(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "ManageGroups") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    local group, immunity = args[1], tonumber(args[2])

    if not FAdmin.Access.Groups[group] or not immunity then return false end

    local plyGroup = FAdmin.Access.Groups[ply:EntIndex() == 0 and "superadmin" or ply:GetUserGroup()]

    -- Setting a group with a higher rank than one's own
    if (not plyGroup or FAdmin.Access.Groups[group].immunity > plyGroup.immunity) and not FAdmin.Access.PlayerIsHost(ply) then
        FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to change the immunity of a group with a higher rank than your")
        return false
    end

    if immunity > plyGroup.immunity and not FAdmin.Access.PlayerIsHost(ply) then
        FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to set the immunity to any value higher than your own group's immunity")
        return false
    end

    FAdmin.Access.Groups[group].immunity = immunity
    MySQLite.query("REPLACE INTO FAdmin_Immunity VALUES(" .. MySQLite.SQLStr(group) .. ", " .. tonumber(immunity) .. ");")

    FAdmin.Access.SendGroups(ply)

    return true, group, immunity
end

FAdmin.StartHooks["Access"] = function() --Run all functions that depend on other plugins
    FAdmin.Commands.AddCommand("setroot", FAdmin.Access.SetRoot)
    FAdmin.Commands.AddCommand("setaccess", FAdmin.Access.SetAccess)

    FAdmin.Commands.AddCommand("AddGroup", AddGroup)

    FAdmin.Commands.AddCommand("AddPrivilege", AddPrivilege)
    FAdmin.Commands.AddCommand("RemovePrivilege", RemovePrivilege)

    FAdmin.Commands.AddCommand("immunity", toggleImmunity)
    FAdmin.Commands.AddCommand("SetImmunity", setImmunity)

    FAdmin.SetGlobalSetting("Immunity", GetConVar("_FAdmin_immunity"):GetBool())
end
