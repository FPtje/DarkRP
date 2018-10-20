local function ccDoorUnOwn(ply, args)
    if ply:EntIndex() == 0 then
        print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
        return
    end

    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or not ent:isKeysOwnable() or not ent:getDoorOwner() or ply:EyePos():DistToSqr(ent:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return
    end

    ent:Fire("unlock", "", 0)
    ent:keysUnOwn()
    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") force-unowned a door with forceunown", Color(30, 30, 30))
    DarkRP.notify(ply, 0, 4, "Forcefully unowned")
end
DarkRP.definePrivilegedChatCommand("forceunown", "DarkRP_SetDoorOwner", ccDoorUnOwn)

local function unownAll(ply, args)
    local target = DarkRP.findPlayer(args[1])

    if not IsValid(target) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args))
        return
    end
    target:keysUnOwnAll()

    if ply:EntIndex() == 0 then
        DarkRP.log("Console force-unowned all doors owned by " .. target:Nick(), Color(30, 30, 30))
    else
        DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") force-unowned all doors owned by " .. target:Nick(), Color(30, 30, 30))
    end

    DarkRP.notify(ply, 0, 4, "All doors of " .. target:Nick() .. " are now unowned")
end
DarkRP.definePrivilegedChatCommand("forceunownall", "DarkRP_SetDoorOwner", unownAll)

local function ccAddOwner(ply, args)
    if ply:EntIndex() == 0 then
        print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
        return
    end

    local trace = ply:GetEyeTrace()

    local ent = trace.Entity
    if not IsValid(ent) or not ent:isKeysOwnable() or ent:getKeysNonOwnable() or ent:getKeysDoorGroup() or ent:getKeysDoorTeams() or ply:EyePos():DistToSqr(ent:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return
    end

    local target = DarkRP.findPlayer(args)

    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args))
        return
    end

    if ent:isKeysOwned() then
        if not ent:isKeysOwnedBy(target) and not ent:isKeysAllowedToOwn(target) then
            ent:addKeysAllowedToOwn(target)
        else
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("rp_addowner_already_owns_door", target))
        end
        return
    end
    ent:keysOwn(target)

    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") force-added a door owner with forceown", Color(30, 30, 30))
    DarkRP.notify(ply, 0, 4, "Forcefully added " .. target:Nick())
end
DarkRP.definePrivilegedChatCommand("forceown", "DarkRP_SetDoorOwner", ccAddOwner)

local function ccRemoveOwner(ply, args)
    if ply:EntIndex() == 0 then
        print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
        return
    end

    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or not ent:isKeysOwnable() or ent:getKeysNonOwnable() or ent:getKeysDoorGroup() or ent:getKeysDoorTeams() or ply:EyePos():DistToSqr(ent:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return
    end

    local target = DarkRP.findPlayer(args)

    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args))
        return
    end

    if ent:isKeysAllowedToOwn(target) then
        ent:removeKeysAllowedToOwn(target)
    end

    if ent:isMasterOwner(target) then
        ent:keysUnOwn()
    elseif ent:isKeysOwnedBy(target) then
       ent:removeKeysDoorOwner(target)
    end

    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") force-removed a door owner with forceremoveowner", Color(30, 30, 30))
    DarkRP.notify(ply, 0, 4, "Forcefully removed " .. target:Nick())
end
DarkRP.definePrivilegedChatCommand("forceremoveowner", "DarkRP_SetDoorOwner", ccRemoveOwner)

local function ccLock(ply, args)
    if ply:EntIndex() == 0 then
        print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
        return
    end

    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or not ent:isKeysOwnable() or ply:EyePos():DistToSqr(ent:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return
    end

    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("locked"))

    ent:keysLock()

    if not ent:CreatedByMap() then return end
    MySQLite.query(string.format([[REPLACE INTO darkrp_door VALUES(%s, %s, %s, 1, %s);]],
        MySQLite.SQLStr(ent:doorIndex()),
        MySQLite.SQLStr(string.lower(game.GetMap())),
        MySQLite.SQLStr(ent:getKeysTitle() or ""),
        ent:getKeysNonOwnable() and 1 or 0
        ))

    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") force-locked a door with forcelock (locked door is saved)", Color(30, 30, 30))
    DarkRP.notify(ply, 0, 4, "Forcefully locked")
end
DarkRP.definePrivilegedChatCommand("forcelock", "DarkRP_ChangeDoorSettings", ccLock)

local function ccUnLock(ply, args)
    if ply:EntIndex() == 0 then
        print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
        return
    end

    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) or not ent:isKeysOwnable() or ply:EyePos():DistToSqr(ent:GetPos()) > 40000 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
        return
    end

    DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("unlocked"))
    ent:keysUnLock()

    if not ent:CreatedByMap() then return end
    MySQLite.query(string.format([[REPLACE INTO darkrp_door VALUES(%s, %s, %s, 0, %s);]],
        MySQLite.SQLStr(ent:doorIndex()),
        MySQLite.SQLStr(string.lower(game.GetMap())),
        MySQLite.SQLStr(ent:getKeysTitle() or ""),
        ent:getKeysNonOwnable() and 1 or 0
        ))

    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") force-unlocked a door with forcelock (unlocked door is saved)", Color(30, 30, 30))
    DarkRP.notify(ply, 0, 4, "Forcefully unlocked")
end
DarkRP.definePrivilegedChatCommand("forceunlock", "DarkRP_ChangeDoorSettings", ccUnLock)
