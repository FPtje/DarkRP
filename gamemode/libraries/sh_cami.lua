--[[
CAMI - Common Admin Mod Interface.
Makes admin mods intercompatible and provides an abstract privilege interface
for third party addons.

Follows the specification on this page:
https://docs.google.com/document/d/1QIRVcAgZfAYf1aBl_dNV_ewR6P25wze2KmUVzlbFgMI

Structures:
    CAMI_USERGROUP, defines the charactaristics of a usergroup:
    {
        Name
            string
            The name of the usergroup
        Inherits
            string
            The name of the usergroup this usergroup inherits from
    }

    CAMI_PRIVILEGE, defines the charactaristics of a privilege:
    {
        Name
            string
            The name of the privilege
        MinAccess
            string
            One of the following three: user/admin/superadmin
        Description
            string
            optional
            A text describing the purpose of the privilege
        HasAccess
            function(
                privilege :: CAMI_PRIVILEGE,
                actor     :: Player,
                target    :: Player
            ) :: bool
            optional
            Function that decides whether a player can execute this privilege,
            optionally on another player (target).
    }
]]

-- Version number in YearMonthDay format.
local version = 20190102

if CAMI and CAMI.Version >= version then return end

CAMI = CAMI or {}
CAMI.Version = version

--[[
usergroups
    Contains the registered CAMI_USERGROUP usergroup structures.
    Indexed by usergroup name.
]]
local usergroups = CAMI.GetUsergroups and CAMI.GetUsergroups() or {
    user = {
        Name = "user",
        Inherits = "user"
    },
    admin = {
        Name = "admin",
        Inherits = "user"
    },
    superadmin = {
        Name = "superadmin",
        Inherits = "admin"
    }
}

--[[
privileges
    Contains the registered CAMI_PRIVILEGE privilege structures.
    Indexed by privilege name.
]]
local privileges = CAMI.GetPrivileges and CAMI.GetPrivileges() or {}

--[[
CAMI.RegisterUsergroup
    Registers a usergroup with CAMI.

    Parameters:
        usergroup
            CAMI_USERGROUP
            (see CAMI_USERGROUP structure)
        source
            any
            Identifier for your own admin mod. Can be anything.
            Use this to make sure CAMI.RegisterUsergroup function and the
            CAMI.OnUsergroupRegistered hook don't cause an infinite loop



    Return value:
        CAMI_USERGROUP
            The usergroup given as argument.
]]
function CAMI.RegisterUsergroup(usergroup, source)
    usergroups[usergroup.Name] = usergroup

    hook.Call("CAMI.OnUsergroupRegistered", nil, usergroup, source)
    return usergroup
end

--[[
CAMI.UnregisterUsergroup
    Unregisters a usergroup from CAMI. This will call a hook that will notify
    all other admin mods of the removal.

    Call only when the usergroup is to be permanently removed.

    Parameters:
        usergroupName
            string
            The name of the usergroup.
        source
            any
            Identifier for your own admin mod. Can be anything.
            Use this to make sure CAMI.UnregisterUsergroup function and the
            CAMI.OnUsergroupUnregistered hook don't cause an infinite loop

    Return value:
        bool
            Whether the unregistering succeeded.
]]
function CAMI.UnregisterUsergroup(usergroupName, source)
    if not usergroups[usergroupName] then return false end

    local usergroup = usergroups[usergroupName]
    usergroups[usergroupName] = nil

    hook.Call("CAMI.OnUsergroupUnregistered", nil, usergroup, source)

    return true
end

--[[
CAMI.GetUsergroups
    Retrieves all registered usergroups.

    Return value:
        Table of CAMI_USERGROUP, indexed by their names.
]]
function CAMI.GetUsergroups()
    return usergroups
end

--[[
CAMI.GetUsergroup
    Receives information about a usergroup.

    Return value:
        CAMI_USERGROUP
            Returns nil when the usergroup does not exist.
]]
function CAMI.GetUsergroup(usergroupName)
    return usergroups[usergroupName]
end

--[[
CAMI.UsergroupInherits
    Returns true when usergroupName1 inherits usergroupName2.
    Note that usergroupName1 does not need to be a direct child.
    Every usergroup trivially inherits itself.

    Parameters:
        usergroupName1
            string
            The name of the usergroup that is queried.
        usergroupName2
            string
            The name of the usergroup of which is queried whether usergroupName
            inherits from.

    Return value:
        bool
            Whether usergroupName1 inherits usergroupName2.
]]
function CAMI.UsergroupInherits(usergroupName1, usergroupName2)
    repeat
        if usergroupName1 == usergroupName2 then return true end

        usergroupName1 = usergroups[usergroupName1] and
                         usergroups[usergroupName1].Inherits or
                         usergroupName1
    until not usergroups[usergroupName1] or
          usergroups[usergroupName1].Inherits == usergroupName1

    -- One can only be sure the usergroup inherits from user if the
    -- usergroup isn't registered.
    return usergroupName1 == usergroupName2 or usergroupName2 == "user"
end

--[[
CAMI.InheritanceRoot
    All usergroups must eventually inherit either user, admin or superadmin.
    Regardless of what inheritance mechism an admin may or may not have, this
    always applies.

    This method always returns either user, admin or superadmin, based on what
    usergroups eventually inherit.

    Parameters:
        usergroupName
            string
            The name of the usergroup of which the root of inheritance is
            requested

    Return value:
        string
            The name of the root usergroup (either user, admin or superadmin)
]]
function CAMI.InheritanceRoot(usergroupName)
    if not usergroups[usergroupName] then return end

    local inherits = usergroups[usergroupName].Inherits
    while inherits ~= usergroups[usergroupName].Inherits do
        usergroupName = usergroups[usergroupName].Inherits
    end

    return usergroupName
end

--[[
CAMI.RegisterPrivilege
    Registers a privilege with CAMI.
    Note: do NOT register all your admin mod's privileges with this function!
    This function is for third party addons to register privileges
    with admin mods, not for admin mods sharing the privileges amongst one
    another.

    Parameters:
        privilege
            CAMI_PRIVILEGE
            See CAMI_PRIVILEGE structure.

    Return value:
        CAMI_PRIVILEGE
            The privilege given as argument.
]]
function CAMI.RegisterPrivilege(privilege)
    privileges[privilege.Name] = privilege

    hook.Call("CAMI.OnPrivilegeRegistered", nil, privilege)

    return privilege
end

--[[
CAMI.UnregisterPrivilege
    Unregisters a privilege from CAMI. This will call a hook that will notify
    all other admin mods of the removal.

    Call only when the privilege is to be permanently removed.

    Parameters:
        privilegeName
            string
            The name of the privilege.

    Return value:
        bool
            Whether the unregistering succeeded.
]]
function CAMI.UnregisterPrivilege(privilegeName)
    if not privileges[privilegeName] then return false end

    local privilege = privileges[privilegeName]
    privileges[privilegeName] = nil

    hook.Call("CAMI.OnPrivilegeUnregistered", nil, privilege)

    return true
end

--[[
CAMI.GetPrivileges
    Retrieves all registered privileges.

    Return value:
        Table of CAMI_PRIVILEGE, indexed by their names.
]]
function CAMI.GetPrivileges()
    return privileges
end

--[[
CAMI.GetPrivilege
    Receives information about a privilege.

    Return value:
        CAMI_PRIVILEGE when the privilege exists.
            nil when the privilege does not exist.
]]
function CAMI.GetPrivilege(privilegeName)
    return privileges[privilegeName]
end

--[[
CAMI.PlayerHasAccess
    Queries whether a certain player has the right to perform a certain action.

    Parameters:
        actorPly
            Player
            The player of which is requested whether they have the privilege.
        privilegeName
            string
            The name of the privilege.
        callback
            function(bool, string) or nil
            This function will be called with the answer. The bool signifies the
            yes or no answer as to whether the player is allowed. The string
            will optionally give a reason.

            Give an explicit nil here to get an answer immediately
                Important note: May throw an error when the admin mod doesn't
                give an answer immediately!
        targetPly
            Optional.
            The player on which the privilege is executed.
        extraInfoTbl
            Optional.
            Table containing extra information.
            Officially supported members:
                Fallback
                    string
                    Either of user/admin/superadmin. When no admin mod replies,
                    the decision is based on the admin status of the user.
                    Defaults to admin if not given.
                IgnoreImmunity
                    bool
                    Ignore any immunity mechanisms an admin mod might have.
                CommandArguments
                    table
                    Extra arguments that were given to the privilege command.

    Return value:
        If callback is specified:
            None
        Otherwise:
            hasAccess
                bool
                Whether the player has access
            reason
                Optional.
                The reason why a player does or does not have access.
]]
-- Default access handler
local defaultAccessHandler = {["CAMI.PlayerHasAccess"] =
    function(_, actorPly, privilegeName, callback, _, extraInfoTbl)
        -- The server always has access in the fallback
        if not IsValid(actorPly) then return callback(true, "Fallback.") end

        local priv = privileges[privilegeName]

        local fallback = extraInfoTbl and (
            not extraInfoTbl.Fallback and actorPly:IsAdmin() or
            extraInfoTbl.Fallback == "user" and true or
            extraInfoTbl.Fallback == "admin" and actorPly:IsAdmin() or
            extraInfoTbl.Fallback == "superadmin" and actorPly:IsSuperAdmin())


        if not priv then return callback(fallback, "Fallback.") end

        callback(
            priv.MinAccess == "user" or
            priv.MinAccess == "admin" and actorPly:IsAdmin() or
            priv.MinAccess == "superadmin" and actorPly:IsSuperAdmin()
            , "Fallback.")
    end,
    ["CAMI.SteamIDHasAccess"] =
    function(_, _, _, callback)
        callback(false, "No information available.")
    end
}
function CAMI.PlayerHasAccess(actorPly, privilegeName, callback, targetPly,
extraInfoTbl)
    local hasAccess, reason = nil, nil
    local callback_ = callback or function(hA, r) hasAccess, reason = hA, r end

    hook.Call("CAMI.PlayerHasAccess", defaultAccessHandler, actorPly,
        privilegeName, callback_, targetPly, extraInfoTbl)

    if callback ~= nil then return end

    if hasAccess == nil then
        local err = [[The function CAMI.PlayerHasAccess was used to find out
        whether Player %s has privilege "%s", but an admin mod did not give an
        immediate answer!]]
        error(string.format(err,
            actorPly:IsPlayer() and actorPly:Nick() or tostring(actorPly),
            privilegeName))
    end

    return hasAccess, reason
end

--[[
CAMI.GetPlayersWithAccess
    Finds the list of currently joined players who have the right to perform a
    certain action.
    NOTE: this function will NOT return an immediate result!
    The result is in the callback!

    Parameters:
        privilegeName
            string
            The name of the privilege.
        callback
            function(players)
            This function will be called with the list of players with access.
        targetPly
            Optional.
            The player on which the privilege is executed.
        extraInfoTbl
            Optional.
            Table containing extra information.
            Officially supported members:
                Fallback
                    string
                    Either of user/admin/superadmin. When no admin mod replies,
                    the decision is based on the admin status of the user.
                    Defaults to admin if not given.
                IgnoreImmunity
                    bool
                    Ignore any immunity mechanisms an admin mod might have.
                CommandArguments
                    table
                    Extra arguments that were given to the privilege command.
]]
function CAMI.GetPlayersWithAccess(privilegeName, callback, targetPly,
extraInfoTbl)
    local allowedPlys = {}
    local allPlys = player.GetAll()
    local countdown = #allPlys

    local function onResult(ply, hasAccess, _)
        countdown = countdown - 1

        if hasAccess then table.insert(allowedPlys, ply) end
        if countdown == 0 then callback(allowedPlys) end
    end

    for _, ply in ipairs(allPlys) do
        CAMI.PlayerHasAccess(ply, privilegeName,
            function(...) onResult(ply, ...) end,
            targetPly, extraInfoTbl)
    end
end

--[[
CAMI.SteamIDHasAccess
    Queries whether a player with a steam ID has the right to perform a certain
    action.
    Note: the player does not need to be in the server for this to
    work.

    Note: this function does NOT return an immediate result!
    The result is in the callback!

    Parameters:
        actorSteam
            Player
            The SteamID of the player of which is requested whether they have
            the privilege.
        privilegeName
            string
            The name of the privilege.
        callback
            function(bool, string)
            This function will be called with the answer. The bool signifies the
            yes or no answer as to whether the player is allowed. The string
            will optionally give a reason.
        targetSteam
            Optional.
            The SteamID of the player on which the privilege is executed.
        extraInfoTbl
            Optional.
            Table containing extra information.
            Officially supported members:
                IgnoreImmunity
                    bool
                    Ignore any immunity mechanisms an admin mod might have.
                CommandArguments
                    table
                    Extra arguments that were given to the privilege command.

    Return value:
        None, the answer is given in the callback function in order to allow
        for the admin mod to perform e.g. a database lookup.
]]
function CAMI.SteamIDHasAccess(actorSteam, privilegeName, callback,
targetSteam, extraInfoTbl)
    hook.Call("CAMI.SteamIDHasAccess", defaultAccessHandler, actorSteam,
        privilegeName, callback, targetSteam, extraInfoTbl)
end

--[[
CAMI.SignalUserGroupChanged
    Signify that your admin mod has changed the usergroup of a player. This
    function communicates to other admin mods what it thinks the usergroup
    of a player should be.

    Listen to the hook to receive the usergroup changes of other admin mods.

    Parameters:
        ply
            Player
            The player for which the usergroup is changed
        old
            string
            The previous usergroup of the player.
        new
            string
            The new usergroup of the player.
        source
            any
            Identifier for your own admin mod. Can be anything.
]]
function CAMI.SignalUserGroupChanged(ply, old, new, source)
    hook.Call("CAMI.PlayerUsergroupChanged", nil, ply, old, new, source)
end

--[[
CAMI.SignalSteamIDUserGroupChanged
    Signify that your admin mod has changed the usergroup of a disconnected
    player. This communicates to other admin mods what it thinks the usergroup
    of a player should be.

    Listen to the hook to receive the usergroup changes of other admin mods.

    Parameters:
        ply
            string
            The steam ID of the player for which the usergroup is changed
        old
            string
            The previous usergroup of the player.
        new
            string
            The new usergroup of the player.
        source
            any
            Identifier for your own admin mod. Can be anything.
]]
function CAMI.SignalSteamIDUserGroupChanged(steamId, old, new, source)
    hook.Call("CAMI.SteamIDUsergroupChanged", nil, steamId, old, new, source)
end
