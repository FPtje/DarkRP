local function SetSpawnPos(ply, args)
    local pos = ply:GetPos()
    local t

    for k, v in pairs(RPExtraTeams) do
        if args == v.command then
            t = k
            DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("updated_spawnpos", v.name))
            break
        end
    end

    if t then
        DarkRP.storeTeamSpawnPos(t, {pos.x, pos.y, pos.z})
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
    end
end
DarkRP.definePrivilegedChatCommand("setspawn", "DarkRP_AdminCommands", SetSpawnPos)

local function AddSpawnPos(ply, args)
    local pos = ply:GetPos()
    local t

    for k, v in pairs(RPExtraTeams) do
        if args == v.command then
            t = k
            DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("created_spawnpos", v.name))
            break
        end
    end

    if t then
        DarkRP.addTeamSpawnPos(t, {pos.x, pos.y, pos.z})
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
    end
end
DarkRP.definePrivilegedChatCommand("addspawn", "DarkRP_AdminCommands", AddSpawnPos)

local function RemoveSpawnPos(ply, args)
    local t

    for k, v in pairs(RPExtraTeams) do
        if args == v.command then
            t = k
            DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("remove_spawnpos", v.name))
            break
        end
    end

    if t then
        DarkRP.removeTeamSpawnPos(t)
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
    end
end
DarkRP.definePrivilegedChatCommand("removespawn", "DarkRP_AdminCommands", RemoveSpawnPos)
