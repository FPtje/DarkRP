--[[---------------------------------------------------------------------------
Loading
---------------------------------------------------------------------------]]
local teamSpawns = {}
local jailPos = {}
local function onDBInitialized()
    local map = MySQLite.SQLStr(string.lower(game.GetMap()))
    MySQLite.query("SELECT * FROM darkrp_position NATURAL JOIN darkrp_jobspawn WHERE map = " .. map .. ";", function(data)
        teamSpawns = data or {}
    end)

    MySQLite.query([[SELECT * FROM darkrp_position WHERE type = 'J' AND map = ]] .. map .. [[;]], function(data)
        for _, v in ipairs(data or {}) do
            table.insert(jailPos, Vector(v.x, v.y, v.z))
        end
    end)
end
hook.Add("DarkRPDBInitialized", "GetPositions", onDBInitialized)


local JailIndex = 1 -- Used to circulate through the jailpos table

-- Function for backwards compatibility
function DarkRP.storeJailPos(ply, addingPos)
    local pos = ply:GetPos()

    if addingPos then
        DarkRP.addJailPos(pos)
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("added_jailpos"))
    else
        DarkRP.setJailPos(pos)
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("reset_add_jailpos"))
    end
end

function DarkRP.setJailPos(pos)
    local map = MySQLite.SQLStr(string.lower(game.GetMap()))

    jailPos = {pos}

    local remQuery = "DELETE FROM darkrp_position WHERE type = 'J' AND map = %s;"
    local insQuery = "INSERT INTO darkrp_position(map, type, x, y, z) VALUES(%s, 'J', %s, %s, %s);"

    remQuery = string.format(remQuery, map)
    insQuery = string.format(insQuery, map, pos.x, pos.y, pos.z)

    MySQLite.begin()
    MySQLite.queueQuery(remQuery)
    MySQLite.queueQuery(insQuery)
    MySQLite.commit()

    JailIndex = 1
end

function DarkRP.addJailPos(pos)
    local map = MySQLite.SQLStr(string.lower(game.GetMap()))

    table.insert(jailPos, pos)

    local insQuery = "INSERT INTO darkrp_position(map, type, x, y, z) VALUES(%s, 'J', %s, %s, %s);"
    insQuery = string.format(insQuery, map, pos.x, pos.y, pos.z)

    MySQLite.query(insQuery)

    JailIndex = 1
end

function DarkRP.retrieveJailPos(index)
    if not jailPos then return Vector(0, 0, 0) end
    if index then
        return jailPos[index]
    end
    -- Retrieve the least recently used jail position
    local oldestPos = jailPos[JailIndex]
    JailIndex = JailIndex % #jailPos + 1

    return oldestPos
end

function DarkRP.jailPosCount()
    return table.Count(jailPos or {})
end

function DarkRP.storeTeamSpawnPos(t, pos)
    local map = string.lower(game.GetMap())
    local teamcmd = RPExtraTeams[t].command


    DarkRP.removeTeamSpawnPos(t, function()
        MySQLite.query([[INSERT INTO darkrp_position(map, type, x, y, z) VALUES(]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
            , function()
            MySQLite.queryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
                if not id then return end
                MySQLite.query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. MySQLite.SQLStr(teamcmd) .. [[);]])
                table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], teamcmd = teamcmd})
            end)
        end)
    end)
end

function DarkRP.addTeamSpawnPos(t, pos)
    local map = string.lower(game.GetMap())
    local teamcmd = RPExtraTeams[t].command

    MySQLite.query([[INSERT INTO darkrp_position(map, type, x, y, z) VALUES(]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
        , function()
        MySQLite.queryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
            if isbool(id) then return end
            MySQLite.query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. MySQLite.SQLStr(teamcmd) .. [[);]])
            table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], teamcmd = teamcmd})
        end)
    end)
end

function DarkRP.removeTeamSpawnPos(t, callback)
    local map = string.lower(game.GetMap())
    local teamcmd = RPExtraTeams[tonumber(t)].command

    for k, v in pairs(teamSpawns) do
        if v.teamcmd == teamcmd then
            teamSpawns[k] = nil
        end
    end

    MySQLite.query([[SELECT darkrp_position.id FROM darkrp_position
        NATURAL JOIN darkrp_jobspawn
        WHERE map = ]] .. MySQLite.SQLStr(map) .. [[
        AND teamcmd = ]] .. MySQLite.SQLStr(teamcmd) .. [[;]], function(data)

        MySQLite.begin()
        for _, v in ipairs(data or {}) do
            MySQLite.query([[DELETE FROM darkrp_position WHERE id = ]] .. v.id .. [[;]])
            MySQLite.query([[DELETE FROM darkrp_jobspawn WHERE id = ]] .. v.id .. [[;]])
        end
        MySQLite.commit(callback)
    end)
end

function DarkRP.retrieveTeamSpawnPos(t)
    local isTeam = function(tbl) return RPExtraTeams[t].command == tbl.teamcmd end
    local getPos = function(tbl) return Vector(tonumber(tbl.x), tonumber(tbl.y), tonumber(tbl.z)) end

    return table.ClearKeys(fn.Map(getPos, fn.Filter(isTeam, teamSpawns)))
end
