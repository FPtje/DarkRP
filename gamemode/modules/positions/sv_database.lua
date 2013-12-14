/*---------------------------------------------------------------------------
Loading
---------------------------------------------------------------------------*/
local teamSpawns = {}
local jailPos = {}
local function onDBInitialized()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	MySQLite.query("SELECT * FROM darkrp_position NATURAL JOIN darkrp_jobspawn WHERE map = "..map..";", function(data)
		teamSpawns = data or {}
	end)

	MySQLite.query([[SELECT * FROM darkrp_position WHERE type = 'J' AND map = ]] .. map .. [[;]], function(data)
		for k,v in pairs(data or {}) do
			table.insert(jailPos, v)
		end
	end)
end
hook.Add("DarkRPDBInitialized", "GetPositions", onDBInitialized)


local JailIndex = 1 -- Used to circulate through the jailpos table
function DarkRP.storeJailPos(ply, addingPos)
	local map = string.lower(game.GetMap())
	local pos = string.Explode(" ", tostring(ply:GetPos()))
	MySQLite.queryValue("SELECT COUNT(*) FROM darkrp_position WHERE type = 'J' AND map = " .. MySQLite.SQLStr(map) .. ";", function(already)
		if not already or already == 0 then
			MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")
			DarkRP.notify(ply, 0, 4,  DarkRP.getPhrase("created_first_jailpos"))

			return
		end

		if addingPos then
			MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")

			table.insert(jailPos, {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"})
			DarkRP.notify(ply, 0, 4,  DarkRP.getPhrase("added_jailpos"))
		else
			MySQLite.query("DELETE FROM darkrp_position WHERE type = 'J' AND map = " .. MySQLite.SQLStr(map) .. ";", function()
				MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")


				jailPos = {[1] = {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"}}
				DarkRP.notify(ply, 0, 5,  DarkRP.getPhrase("reset_add_jailpos"))
			end)
		end
	end)

	JailIndex = 1
end

function DarkRP.retrieveJailPos()
	local map = string.lower(game.GetMap())
	if not jailPos then return Vector(0,0,0) end

	-- Retrieve the least recently used jail position
	local oldestPos = jailPos[JailIndex]
	JailIndex = JailIndex % #jailPos + 1

	return oldestPos and Vector(oldestPos.x, oldestPos.y, oldestPos.z)
end

function DarkRP.jailPosCount()
	return table.Count(jailPos or {})
end

function DarkRP.storeTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	MySQLite.query([[DELETE FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND id IN (SELECT id FROM darkrp_jobspawn WHERE team = ]] .. t .. [[)]])

	MySQLite.query([[INSERT INTO darkrp_position VALUES(NULL, ]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		MySQLite.queryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if not id then return end
			MySQLite.query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)

	print(DarkRP.getPhrase("created_spawnpos", team.GetName(t)))
end

function DarkRP.addTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	MySQLite.query([[INSERT INTO darkrp_position VALUES(NULL, ]] .. MySQLite.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		MySQLite.queryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. MySQLite.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if type(id) == "boolean" then return end
			MySQLite.query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(teamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)
end

function DarkRP.removeTeamSpawnPos(t, callback)
	local map = string.lower(game.GetMap())
	MySQLite.query([[SELECT darkrp_position.id FROM darkrp_position
		NATURAL JOIN darkrp_jobspawn
		WHERE map = ]] .. MySQLite.SQLStr(map) .. [[
		AND team = ]].. t ..[[;]], function(data)

		MySQLite.begin()
		for k,v in pairs(data or {}) do
			-- The trigger will make sure the values get deleted from the jobspawn as well
			MySQLite.query([[DELETE FROM darkrp_position WHERE id = ]]..v.id..[[;]])
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

function DarkRP.retrieveTeamSpawnPos(t)
	local isTeam = fn.Compose{fn.Curry(fn.Eq, 2)(t), tonumber, fn.Curry(fn.GetValue, 2)("team")}
	local getPos = function(tbl) return Vector(tonumber(tbl.x), tonumber(tbl.y), tonumber(tbl.z)) end

	return table.ClearKeys(fn.Map(getPos, fn.Filter(isTeam, teamSpawns)))
end
