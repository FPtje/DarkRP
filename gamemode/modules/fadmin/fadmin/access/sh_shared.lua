CreateConVar("_FAdmin_immunity", 1, {FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE})

FAdmin.Access = FAdmin.Access or {}
FAdmin.Access.ADMIN = {"user", "admin", "superadmin"}
FAdmin.Access.ADMIN[0] = "user"

FAdmin.Access.Groups = FAdmin.Access.Groups or {}
FAdmin.Access.Privileges = FAdmin.Access.Privileges or {}

function FAdmin.Access.AddGroup(name, admin_access --[[0 = not admin, 1 = admin, 2 = superadmin]], privs, immunity, fromCAMI, CAMIsrc)
    FAdmin.Access.Groups[name] = FAdmin.Access.Groups[name] or {ADMIN = admin_access, PRIVS = privs or {}, immunity = immunity}

    --Make sure things that come from CAMI come with a CAMIsrc
    assert((fromCAMI and CAMIsrc ~= nil) or ((not fromCAMI) and CAMIsrc == nil))
    --If the CAMIsrc is a string, save it, otherwise save an empty string
    if not isstring(CAMIsrc) then
        CAMIsrc = ""
    end

    -- Register custom usergroups with CAMI
    if name ~= "user" and name ~= "admin" and name ~= "superadmin" and not fromCAMI then
        CAMI.RegisterUsergroup({
            Name = name,
            Inherits = FAdmin.Access.ADMIN[admin_access]
        }, "FAdmin")
    end

    -- Add newly created privileges on server reload
    for p, _ in pairs(privs or {}) do
        FAdmin.Access.Groups[name].PRIVS[p] = true
    end

    if not SERVER then return end

    MySQLite.queryValue("SELECT COUNT(*) FROM FADMIN_GROUPS WHERE NAME = " .. MySQLite.SQLStr(name) .. ";", function(val)
        if tonumber(val or 0) > 0 then return end

        MySQLite.query("REPLACE INTO FADMIN_GROUPS VALUES(" .. MySQLite.SQLStr(name) .. ", " .. tonumber(admin_access) .. ");", function()
            for priv, _ in pairs(privs or {}) do
                MySQLite.query("REPLACE INTO FADMIN_PRIVILEGES VALUES(" .. MySQLite.SQLStr(name) .. ", " .. MySQLite.SQLStr(priv) .. ");")
            end
            if fromCAMI then
                MySQLite.query("REPLACE INTO FADMIN_GROUPS_SRC VALUES(" .. MySQLite.SQLStr(name) .. ", " .. MySQLite.SQLStr(CAMIsrc) .. ");")
            end
        end)
    end)

    if immunity then
        MySQLite.query("REPLACE INTO FAdmin_Immunity VALUES(" .. MySQLite.SQLStr(name) .. ", " .. tonumber(immunity) .. ");")
    end

    if FAdmin.Access.SendGroups and privs then
        for _, v in ipairs(player.GetAll()) do
            FAdmin.Access.SendGroups(v)
        end
    end
end

function FAdmin.Access.OnUsergroupRegistered(usergroup, source)
    -- Don't re-add usergroups coming from FAdmin itself
    if source == "FAdmin" then return end

    local inheritRoot = CAMI.InheritanceRoot(usergroup.Inherits)
    local admin_access = table.KeyFromValue(FAdmin.Access.ADMIN, inheritRoot) or 1

    -- Add groups registered to CAMI to FAdmin. Assume privileges from either the usergroup it inherits or its inheritance root.
    -- Immunity is unknown and can be set by the user later. FAdmin immunity only applies to FAdmin anyway.
    local parent = FAdmin.Access.Groups[usergroup.Inherits] or FAdmin.Access.Groups[inheritRoot] or {}
    FAdmin.Access.AddGroup(usergroup.Name, admin_access - 1, table.Copy(parent.PRIVS) or {}, parent.immunity or 10, true, source)
end


function FAdmin.Access.OnUsergroupUnregistered(usergroup, source)
    if table.HasValue({"superadmin", "admin", "user", "noaccess"}, usergroup.Name) then return end

    FAdmin.Access.Groups[usergroup.Name] = nil

    if not SERVER then return end

    MySQLite.query("DELETE FROM FADMIN_GROUPS WHERE NAME = " .. MySQLite.SQLStr(usergroup.Name) .. ";")

    for _, v in ipairs(player.GetAll()) do
        FAdmin.Access.SendGroups(v)
    end
end

function FAdmin.Access.RemoveGroup(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "ManageGroups") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    if not args[1] then return false end

    local plyGroup = FAdmin.Access.Groups[ply:EntIndex() == 0 and "superadmin" or ply:GetUserGroup()]

    if not FAdmin.Access.Groups[args[1]] or table.HasValue({"superadmin", "admin", "user"}, string.lower(args[1])) then return true, args[1] end

    -- Setting a group with a higher rank than one's own
    if (not plyGroup or FAdmin.Access.Groups[args[1]].immunity > plyGroup.immunity) and not FAdmin.Access.PlayerIsHost(ply) then
        FAdmin.Messages.SendMessage(ply, 5, "You're not allowed to remove usergroups with a higher rank than your own")
        return false
    end

    CAMI.UnregisterUsergroup(args[1], "FAdmin")

    FAdmin.Messages.SendMessage(ply, 4, "Group succesfully removed")
end

local PLAYER = FindMetaTable("Player")

local oldplyIsAdmin = PLAYER.IsAdmin
function PLAYER:IsAdmin(...)
    local usergroup = self:GetUserGroup()

    if not FAdmin or not FAdmin.Access or not FAdmin.Access.Groups or not FAdmin.Access.Groups[usergroup] then return oldplyIsAdmin(self, ...) or game.SinglePlayer() end

    if (FAdmin.Access.Groups[usergroup] and FAdmin.Access.Groups[usergroup].ADMIN >= 1 --[[1 = admin]]) or (self.IsListenServerHost and self:IsListenServerHost()) then
        return true
    end

    if CLIENT and tonumber(self:FAdmin_GetGlobal("FAdmin_admin")) and self:FAdmin_GetGlobal("FAdmin_admin") >= 1 then return true end

    return oldplyIsAdmin(self, ...) or game.SinglePlayer()
end

local oldplyIsSuperAdmin = PLAYER.IsSuperAdmin
function PLAYER:IsSuperAdmin(...)
    local usergroup = self:GetUserGroup()
    if not FAdmin or not FAdmin.Access or not FAdmin.Access.Groups or not FAdmin.Access.Groups[usergroup] then return oldplyIsSuperAdmin(self, ...) or game.SinglePlayer() end
    if (FAdmin.Access.Groups[usergroup] and FAdmin.Access.Groups[usergroup].ADMIN >= 2 --[[2 = superadmin]]) or (self.IsListenServerHost and self:IsListenServerHost()) then
        return true
    end
    if CLIENT and tonumber(self:FAdmin_GetGlobal("FAdmin_admin")) and self:FAdmin_GetGlobal("FAdmin_admin") >= 2 then return true end
    return oldplyIsSuperAdmin(self, ...) or game.SinglePlayer()
end

--Privileges
function FAdmin.Access.AddPrivilege(Name, admin_access)
    FAdmin.Access.Privileges[Name] = admin_access
end

hook.Add("CAMI.OnPrivilegeRegistered", "FAdmin", function(privilege)
    FAdmin.Access.AddPrivilege(privilege.Name, table.KeyFromValue(FAdmin.Access.ADMIN, CAMI.InheritanceRoot(privilege.MinAccess)) or 3)

    -- Register privilege and add to respective usergroups
    if SERVER then FAdmin.Access.RegisterCAMIPrivilege(privilege) end
end)

for _, camipriv in pairs(CAMI.GetPrivileges()) do
    FAdmin.Access.AddPrivilege(camipriv.Name, table.KeyFromValue(FAdmin.Access.ADMIN, CAMI.InheritanceRoot(camipriv.MinAccess)) or 3)
    -- Register if the database has already loaded
    if SERVER and FAdmin.Access.RegisterCAMIPrivilege then FAdmin.Access.RegisterCAMIPrivilege(camipriv) end
end

hook.Add("CAMI.OnPrivilegeUnregistered", "FAdmin", function(privilege)
    FAdmin.Access.Privileges[privilege.Name] = nil
end)

function FAdmin.Access.PlayerIsHost(ply)
    return ply:EntIndex() == 0 or game.SinglePlayer() or (ply.IsListenServerHost and ply:IsListenServerHost())
end

function FAdmin.Access.PlayerHasPrivilege(ply, priv, target, ignoreImmunity)
    -- This is the server console
    if FAdmin.Access.PlayerIsHost(ply) then return true end
    -- Privilege does not exist
    if not FAdmin.Access.Privileges[priv] then return ply:IsAdmin() end

    local Usergroup = ply:GetUserGroup()

    local canTarget = hook.Call("FAdmin_CanTarget", nil, ply, priv, target)
    if canTarget ~= nil then
        return canTarget
    end

    if FAdmin.GlobalSetting.Immunity and
        not ignoreImmunity and
        not isstring(target) and IsValid(target) and target ~= ply and
        FAdmin.Access.Groups[Usergroup] and FAdmin.Access.Groups[target:GetUserGroup()] and
        FAdmin.Access.Groups[Usergroup].immunity and FAdmin.Access.Groups[target:GetUserGroup()].immunity and
        FAdmin.Access.Groups[target:GetUserGroup()].immunity >= FAdmin.Access.Groups[Usergroup].immunity then
        return false
    end

    -- Defer answer when usergroup is unknown
    if not FAdmin.Access.Groups[Usergroup] then return end

    if FAdmin.Access.Groups[Usergroup].PRIVS[priv] then
        return true
    end

    if CLIENT and ply.FADMIN_PRIVS and ply.FADMIN_PRIVS[priv] then return true end

    return false
end

hook.Add("CAMI.PlayerHasAccess", "FAdmin", function(actor, privilegeName, callback, target, extraInfo)
    -- FAdmin doesn't know. Defer answer.
    if not FAdmin.Access.Privileges[privilegeName] then return end

    local res = FAdmin.Access.PlayerHasPrivilege(actor, privilegeName, target, extraInfo and extraInfo.IgnoreImmunity)

    -- Defer again
    if res == nil then return end

    -- Publish the answer
    callback(res, "FAdmin")

    -- FAdmin knows the answer. Prevent other hooks from running.
    return true
end)

hook.Add("CAMI.SteamIDHasAccess", "FAdmin", function(actorSteam, privilegeName, callback, targetSteam, extraInfo)
    -- The client just doesn't know
    if CLIENT then return end

    if not targetSteam or extraInfo and extraInfo.IgnoreImmunity then
        MySQLite.query(string.format(
            [[SELECT COUNT(*) AS c
            FROM FAdmin_PlayerGroup l
            JOIN FADMIN_PRIVILEGES r ON l.groupname = r.NAME
            WHERE l.steamid = %s AND r.PRIVILEGE = %s]],
            MySQLite.SQLStr(actorSteam),
            MySQLite.SQLStr(privilegeName)
        ), function(res) callback(tonumber(res[1].c) > 0) end)

        return true
    end

    MySQLite.query(string.format(
        [[SELECT ll.i AND rr.c AS res
        FROM (SELECT li.immunity >= ri.immunity AS i
              FROM FAdmin_PlayerGroup lg
              JOIN FAdmin_Immunity li ON lg.groupname = li.groupname
              JOIN FAdmin_PlayerGroup rg
              JOIN FAdmin_Immunity ri ON rg.groupname = ri.groupname
              WHERE lg.steamid = %s AND rg.steamid = %s) AS ll
        JOIN (SELECT COUNT(*) AS c
            FROM FAdmin_PlayerGroup l
            JOIN FADMIN_PRIVILEGES r ON l.groupname = r.NAME
            WHERE l.steamid = %s AND r.PRIVILEGE = %s) AS rr]],
        MySQLite.SQLStr(actorSteam),
        MySQLite.SQLStr(targetSteam),
        MySQLite.SQLStr(actorSteam),
        MySQLite.SQLStr(privilegeName)
    ), function(res) callback(res and res[1] and tobool(res[1].res) or false) end)

    return true
end)

FAdmin.StartHooks["AccessFunctions"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "setaccess",
        hasTarget = true,
        message = {"instigator", " set the usergroup of ", "targets", " to ", "extraInfo.1"},
        receivers = "everyone",
        writeExtraInfo = function(i) net.WriteString(i[1]) end,
        readExtraInfo = function() return {net.ReadString()} end,
        extraInfoColors = {Color(255, 102, 0)}
    }

    FAdmin.Access.AddPrivilege("SetAccess", 3) -- AddPrivilege is shared, run on both client and server
    FAdmin.Access.AddPrivilege("ManagePrivileges", 3)
    FAdmin.Access.AddPrivilege("ManageGroups", 3)
    FAdmin.Access.AddPrivilege("SeeAdmins", 1)
    FAdmin.Commands.AddCommand("RemoveGroup", FAdmin.Access.RemoveGroup)

    FAdmin.Commands.AddCommand("Admins", function(ply)
        if not FAdmin.Access.PlayerHasPrivilege(ply, "SeeAdmins") then return false end
        for _, v in ipairs(player.GetAll()) do
            ply:PrintMessage(HUD_PRINTCONSOLE, v:Nick() .. "\t|\t" .. v:GetUserGroup())
        end
        return true
    end
    )
end
