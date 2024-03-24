--[[
CAMI - Common Admin Mod Interface.
Copyright 2020 CAMI Contributors

Makes admin mods intercompatible and provides an abstract privilege interface
for third party addons.

Follows the specification on this page:
https://github.com/glua/CAMI/blob/master/README.md

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- Version number in YearMonthDay format.
local version = 20211019

if CAMI and CAMI.Version >= version then return end

CAMI = CAMI or {}
CAMI.Version = version


--- @class CAMI_USERGROUP
--- defines the charactaristics of a usergroup
--- @field Name string @The name of the usergroup
--- @field Inherits string @The name of the usergroup this usergroup inherits from
--- @field CAMI_Source string @The source specified by the admin mod which registered this usergroup (if any, converted to a string)

--- @class CAMI_PRIVILEGE
--- defines the charactaristics of a privilege
--- @field Name string @The name of the privilege
--- @field MinAccess "'user'" | "'admin'" | "'superadmin'" @Default group that should have this privilege
--- @field Description string | nil @Optional text describing the purpose of the privilege
local CAMI_PRIVILEGE = {}
--- Optional function to check if a player has access to this privilege
--- (and optionally execute it on another player)
---
--- ⚠ **Warning**: This function may not be called by all admin mods
--- @param actor GPlayer @The player
--- @param target GPlayer | nil @Optional - the target
--- @return boolean @If they can or not
--- @return string | nil @Optional reason
function CAMI_PRIVILEGE:HasAccess(actor, target)
end

--- Contains the registered CAMI_USERGROUP usergroup structures.
--- Indexed by usergroup name.
--- @type CAMI_USERGROUP[]
local usergroups = CAMI.GetUsergroups and CAMI.GetUsergroups() or {
    user = {
        Name = "user",
        Inherits = "user",
        CAMI_Source = "Garry's Mod",
    },
    admin = {
        Name = "admin",
        Inherits = "user",
        CAMI_Source = "Garry's Mod",
    },
    superadmin = {
        Name = "superadmin",
        Inherits = "admin",
        CAMI_Source = "Garry's Mod",
    }
}

--- Contains the registered CAMI_PRIVILEGE privilege structures.
--- Indexed by privilege name.
--- @type CAMI_PRIVILEGE[]
local privileges = CAMI.GetPrivileges and CAMI.GetPrivileges() or {}

--- Registers a usergroup with CAMI.
---
--- Use the source parameter to make sure CAMI.RegisterUsergroup function and
--- the CAMI.OnUsergroupRegistered hook don't cause an infinite loop
--- @param usergroup CAMI_USERGROUP @The structure for the usergroup you want to register
--- @param source any @Identifier for your own admin mod. Can be anything.
--- @return CAMI_USERGROUP @The usergroup given as an argument
function CAMI.RegisterUsergroup(usergroup, source)
    if source then
        usergroup.CAMI_Source = tostring(source)
    end
    usergroups[usergroup.Name] = usergroup

    hook.Call("CAMI.OnUsergroupRegistered", nil, usergroup, source)
    return usergroup
end

--- Unregisters a usergroup from CAMI. This will call a hook that will notify
--- all other admin mods of the removal.
---
--- ⚠ **Warning**: Call only when the usergroup is to be permanently removed.
---
--- Use the source parameter to make sure CAMI.UnregisterUsergroup function and
--- the CAMI.OnUsergroupUnregistered hook don't cause an infinite loop
--- @param usergroupName string @The name of the usergroup.
--- @param source any @Identifier for your own admin mod. Can be anything.
--- @return boolean @Whether the unregistering succeeded.
function CAMI.UnregisterUsergroup(usergroupName, source)
    if not usergroups[usergroupName] then return false end

    local usergroup = usergroups[usergroupName]
    usergroups[usergroupName] = nil

    hook.Call("CAMI.OnUsergroupUnregistered", nil, usergroup, source)

    return true
end

--- Retrieves all registered usergroups.
--- @return CAMI_USERGROUP[] @Usergroups indexed by their names.
function CAMI.GetUsergroups()
    return usergroups
end

--- Receives information about a usergroup.
--- @param usergroupName string
--- @return CAMI_USERGROUP | nil @Returns nil when the usergroup does not exist.
function CAMI.GetUsergroup(usergroupName)
    return usergroups[usergroupName]
end

--- Checks to see if potentialAncestor is an ancestor of usergroupName.
--- All usergroups are ancestors of themselves.
---
--- Examples:
--- * `user` is an ancestor of `admin` and also `superadmin`
--- * `admin` is an ancestor of `superadmin`, but not `user`
--- @param usergroupName string @The usergroup to query
--- @param potentialAncestor string @The ancestor to query
--- @return boolean @Whether usergroupName inherits potentialAncestor.
function CAMI.UsergroupInherits(usergroupName, potentialAncestor)
    repeat
        if usergroupName == potentialAncestor then return true end

        usergroupName = usergroups[usergroupName] and
                         usergroups[usergroupName].Inherits or
                         usergroupName
    until not usergroups[usergroupName] or
          usergroups[usergroupName].Inherits == usergroupName

    -- One can only be sure the usergroup inherits from user if the
    -- usergroup isn't registered.
    return usergroupName == potentialAncestor or potentialAncestor == "user"
end

--- Find the base group a usergroup inherits from.
---
--- This function traverses down the inheritence chain, so for example if you have
--- `user` -> `group1` -> `group2`
--- this function will return `user` if you pass it `group2`.
---
--- ℹ **NOTE**: All usergroups must eventually inherit either user, admin or superadmin.
--- @param usergroupName string @The name of the usergroup
--- @return "'user'" | "'admin'" | "'superadmin'" @The name of the root usergroup
function CAMI.InheritanceRoot(usergroupName)
    if not usergroups[usergroupName] then return end

    local inherits = usergroups[usergroupName].Inherits
    while inherits ~= usergroups[usergroupName].Inherits do
        usergroupName = usergroups[usergroupName].Inherits
    end

    return usergroupName
end

--- Registers an addon privilege with CAMI.
---
--- ⚠ **Warning**: This should only be used by addons. Admin mods must *NOT*
---  register their privileges using this function.
--- @param privilege CAMI_PRIVILEGE
--- @return CAMI_PRIVILEGE @The privilege given as argument.
function CAMI.RegisterPrivilege(privilege)
    privileges[privilege.Name] = privilege

    hook.Call("CAMI.OnPrivilegeRegistered", nil, privilege)

    return privilege
end

--- Unregisters a privilege from CAMI.
--- This will call a hook that will notify any admin mods of the removal.
---
--- ⚠ **Warning**: Call only when the privilege is to be permanently removed.
--- @param privilegeName string @The name of the privilege.
--- @return boolean @Whether the unregistering succeeded.
function CAMI.UnregisterPrivilege(privilegeName)
    if not privileges[privilegeName] then return false end

    local privilege = privileges[privilegeName]
    privileges[privilegeName] = nil

    hook.Call("CAMI.OnPrivilegeUnregistered", nil, privilege)

    return true
end

--- Retrieves all registered privileges.
--- @return CAMI_PRIVILEGE[] @All privileges indexed by their names.
function CAMI.GetPrivileges()
    return privileges
end

--- Receives information about a privilege.
--- @param privilegeName string
--- @return CAMI_PRIVILEGE | nil
function CAMI.GetPrivilege(privilegeName)
    return privileges[privilegeName]
end

-- Default access handler
local defaultAccessHandler = {["CAMI.PlayerHasAccess"] =
    function(_, actorPly, privilegeName, callback, targetPly, extraInfoTbl)
        -- The server always has access in the fallback
        if not IsValid(actorPly) then return callback(true, "Fallback.") end

        local priv = privileges[privilegeName]

        local fallback = extraInfoTbl and (
            not extraInfoTbl.Fallback and actorPly:IsAdmin() or
            extraInfoTbl.Fallback == "user" and true or
            extraInfoTbl.Fallback == "admin" and actorPly:IsAdmin() or
            extraInfoTbl.Fallback == "superadmin" and actorPly:IsSuperAdmin())


        if not priv then return callback(fallback, "Fallback.") end

        local hasAccess =
            priv.MinAccess == "user" or
            priv.MinAccess == "admin" and actorPly:IsAdmin() or
            priv.MinAccess == "superadmin" and actorPly:IsSuperAdmin()

        if hasAccess and priv.HasAccess then
            hasAccess = priv:HasAccess(actorPly, targetPly)
        end

        callback(hasAccess, "Fallback.")
    end,
    ["CAMI.SteamIDHasAccess"] =
    function(_, _, _, callback)
        callback(false, "No information available.")
    end
}

--- @class CAMI_ACCESS_EXTRA_INFO
--- @field Fallback "'user'" | "'admin'" | "'superadmin'" @Fallback status for if the privilege doesn't exist. Defaults to `admin`.
--- @field IgnoreImmunity boolean @Ignore any immunity mechanisms an admin mod might have.
--- @field CommandArguments table @Extra arguments that were given to the privilege command.

--- Checks if a player has access to a privilege
--- (and optionally can execute it on targetPly)
---
--- This function is designed to be asynchronous but will be invoked
---  synchronously if no callback is passed.
---
--- ⚠ **Warning**: If the currently installed admin mod does not support
---                 synchronous queries, this function will throw an error!
--- @param actorPly GPlayer @The player to query
--- @param privilegeName string @The privilege to query
--- @param callback fun(hasAccess: boolean, reason: string|nil) @Callback to receive the answer, or nil for synchronous
--- @param targetPly GPlayer | nil @Optional - target for if the privilege effects another player (eg kick/ban)
--- @param extraInfoTbl CAMI_ACCESS_EXTRA_INFO | nil @Table of extra information for the admin mod
--- @return boolean | nil @Synchronous only - if the player has the privilege
--- @return string | nil @Synchronous only - optional reason from admin mod
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

--- Get all the players on the server with a certain privilege
--- (and optionally who can execute it on targetPly)
---
--- ℹ **NOTE**: This is an asynchronous function!
--- @param privilegeName string @The privilege to query
--- @param callback fun(players: GPlayer[]) @Callback to receive the answer
--- @param targetPly GPlayer | nil @Optional - target for if the privilege effects another player (eg kick/ban)
--- @param extraInfoTbl CAMI_ACCESS_EXTRA_INFO | nil @Table of extra information for the admin mod
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

--- @class CAMI_STEAM_ACCESS_EXTRA_INFO
--- @field IgnoreImmunity boolean @Ignore any immunity mechanisms an admin mod might have.
--- @field CommandArguments table @Extra arguments that were given to the privilege command.

--- Checks if a (potentially offline) SteamID has access to a privilege
--- (and optionally if they can execute it on a target SteamID)
---
--- ℹ **NOTE**: This is an asynchronous function!
--- @param actorSteam string | nil @The SteamID to query
--- @param privilegeName string @The privilege to query
--- @param callback fun(hasAccess: boolean, reason: string|nil) @Callback to receive  the answer
--- @param targetSteam string | nil @Optional - target SteamID for if the privilege effects another player (eg kick/ban)
--- @param extraInfoTbl CAMI_STEAM_ACCESS_EXTRA_INFO | nil @Table of extra information for the admin mod
function CAMI.SteamIDHasAccess(actorSteam, privilegeName, callback,
targetSteam, extraInfoTbl)
    hook.Call("CAMI.SteamIDHasAccess", defaultAccessHandler, actorSteam,
        privilegeName, callback, targetSteam, extraInfoTbl)
end

--- Signify that your admin mod has changed the usergroup of a player. This
--- function communicates to other admin mods what it thinks the usergroup
--- of a player should be.
---
--- Listen to the hook to receive the usergroup changes of other admin mods.
--- @param ply GPlayer @The player for which the usergroup is changed
--- @param old string @The previous usergroup of the player.
--- @param new string @The new usergroup of the player.
--- @param source any @Identifier for your own admin mod. Can be anything.
function CAMI.SignalUserGroupChanged(ply, old, new, source)
    hook.Call("CAMI.PlayerUsergroupChanged", nil, ply, old, new, source)
end

--- Signify that your admin mod has changed the usergroup of a disconnected
--- player. This communicates to other admin mods what it thinks the usergroup
--- of a player should be.
---
--- Listen to the hook to receive the usergroup changes of other admin mods.
--- @param steamId string @The steam ID of the player for which the usergroup is changed
--- @param old string @The previous usergroup of the player.
--- @param new string @The new usergroup of the player.
--- @param source any @Identifier for your own admin mod. Can be anything.
function CAMI.SignalSteamIDUserGroupChanged(steamId, old, new, source)
    hook.Call("CAMI.SteamIDUsergroupChanged", nil, steamId, old, new, source)
end
