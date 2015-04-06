/*---------------------------------------------------------------------------
Loading
---------------------------------------------------------------------------*/
local teamSpawns = {}
local jailPos = {}
local function onDBInitialized()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	MySQLite.query("SELECT * FROM fprp_position NATURAL JOIN fprp_jobspawn WHERE map = "..map..";", function(data)
		teamSpawns = data or {}
	end)

	MySQLite.query([[SELECT * FROM fprp_position WHERE type = 'J' AND map = ]] .. map .. [[;]], function(data)
		for k, v in pairs(data or {}) do
			table.insert(jailPos, Vector(v.x, v.y, v.z))
		end
	end)
end
hook.Add("fprpDBInitialized", "GetPositions", onDBInitialized)


local JailIndex = 1 -- Used to circulate through the jailpos table

-- Function for backwards compatibility
function fprp.storeJailPos(ply, addingPos)
	local pos = ply:GetPos()

	if addingPos then
		fprp.addJailPos(pos)
		fprp.notify(ply, 0, 4, fprp.getPhrase("added_jailpos"))
	else
		fprp.setJailPos(pos)
		fprp.notify(ply, 0, 4, fprp.getPhrase("reset_add_jailpos"))
	end
end

function fprp.setJailPos(pos)
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	local strPos = string.Explode(" ", tostring(pos))

	jailPos = {pos}

	local remQuery = "DELETE FROM fprp_position WHERE type = 'J' AND map = %s;"
	local insQuery = "INSERT INTO fprp_position(map, type, x, y, z) VALUES(%s, 'J', %s, %s, %s);"

	print("new setjailpos")
	remQuery = string.format(remQuery, map)
	insQuery = string.format(insQuery, map, strPos[1], strPos[2], strPos[3])

	MySQLite.begin()
	MySQLite.queueQuery(remQuery)
	MySQLite.queueQuery(insQuery)
	MySQLite.commit()

	JailIndex = 1
end

function fprp.addJailPos(pos)
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	local strPos = string.Explode(" ", tostring(pos))

	table.insert(jailPos, pos)

	local insQuery = "INSERT INTO fprp_position(map, type, x, y, z) VALUES(%s, 'J', %s, %s, %s);"
	insQuery = string.format(insQuery, map, strPos[1], strPos[2], strPos[3])

	MySQLite.query(insQuery)

	JailIndex = 1
end

function fprp.retrieveJailPos(index)
	if not jailPos then return Vector(0, 0, 0) end
	if index then
		return jailPos[index]
	end
	-- Retrieve the least recently used jail position
	local oldestPos = jailPos[JailIndex]
	JailIndex = JailIndex % #jailPos + 1

	return oldestPos
end

function fprp.jailPosCount()
	return table.Count(jailPos or {})
end

function fprp.storeTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	MySQLite.query([[DELETE FROM fprp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND id IN (SELECT id FROM fprp_jobspawn WHERE team = ]] .. t .. [[)]])

	MySQLite.query([[INSERT INTO fprp_position(map, type, x, y, z) VALUES(]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		MySQLite.queryValue([[SELECT MAX(id) FROM fprp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if not id then return end
			MySQLite.query([[INSERT INTO fprp_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)

	print(fprp.getPhrase("created_spawnpos", team.GetName(t)))
end

function fprp.addTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	MySQLite.query([[INSERT INTO fprp_position(map, type, x, y, z) VALUES(]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		MySQLite.queryValue([[SELECT MAX(id) FROM fprp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if type(id) == "boolean" then return end
			MySQLite.query([[INSERT INTO fprp_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)
end

function fprp.removeTeamSpawnPos(t, callback)
	local map = string.lower(game.GetMap())
	MySQLite.query([[SELECT fprp_position.id FROM fprp_position
		NATURAL JOIN fprp_jobspawn
		WHERE map = ]] .. MySQLite.SQLStr(map) .. [[
		AND team = ]].. t ..[[;]], function(data)

		MySQLite.begin()
		for k,v in pairs(data or {}) do
			-- The trigger will make sure the values get deleted from the jobspawn as well
			MySQLite.query([[DELETE FROM fprp_position WHERE id = ]]..v.id..[[;]])
		end
		MySQLite.commit()
	end)

	for k,v in pairs(teamSpawns) do
		if tonumber(v.team) == t then
			teamSpawns[k] = nil
		end
	end

	if callback then callback() end
end

function fprp.retrieveTeamSpawnPos(t)
	local isTeam = fn.Compose{fn.Curry(fn.Eq, 2)(t), tonumber, fn.Curry(fn.GetValue, 2)("team")}
	local getPos = function(tbl) return Vector(tonumber(tbl.x), tonumber(tbl.y), tonumber(tbl.z)) end

	return table.ClearKeys(fn.Map(getPos, fn.Filter(isTeam, teamSpawns)))
end
