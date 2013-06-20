include("static_data.lua")

/*---------------------------------------------------------------------------
MySQL and SQLite connectivity
---------------------------------------------------------------------------*/
if RP_MySQLConfig.EnableMySQL then
	require("mysqloo")
end

DB.CONNECTED_TO_MYSQL = false
DB.MySQLDB = nil

local QueuedQueries
function DB.Begin()
	if not DB.CONNECTED_TO_MYSQL then
		sql.Begin()
	else
		if QueuedQueries then
			debug.Trace()
			error("Transaction ongoing!")
		end
		QueuedQueries = {}
	end
end

function DB.Commit(onFinished)
	if not DB.CONNECTED_TO_MYSQL then
		sql.Commit()
		if onFinished then onFinished() end
	else
		if not QueuedQueries then
			error("No queued queries! Call DB.Begin() first!")
		end

		if #QueuedQueries == 0 then
			QueuedQueries = nil
			return
		end

		-- Copy the table so other scripts can create their own queue
		local queue = table.Copy(QueuedQueries)
		QueuedQueries = nil

		-- Handle queued queries in order
		local queuePos = 0
		local call

		-- Recursion invariant: queuePos > 0 and queue[queuePos] <= #queue
		call = function(...)
			queuePos = queuePos + 1

			if queue[queuePos].callback then
				queue[queuePos].callback(...)
			end

			-- Base case, end of the queue
			if queuePos + 1 > #queue then
				if onFinished then onFinished() end -- All queries have finished
				return
			end

			-- Recursion
			local nextQuery = queue[queuePos + 1]
			DB.Query(nextQuery.query, call, nextQuery.onError)
		end

		DB.Query(queue[1].query, call, queue[1].onError)
	end
end

function DB.QueueQuery(sqlText, callback, errorCallback)
	if DB.CONNECTED_TO_MYSQL then
		table.insert(QueuedQueries, {query = sqlText, callback = callback, onError = errorCallback})
	end
	-- SQLite is instantaneous, simply running the query is equal to queueing it
	DB.Query(sqlText, callback, errorCallback)
end

function DB.Query(sqlText, callback, errorCallback)
	if DB.CONNECTED_TO_MYSQL then
		local query = DB.MySQLDB:query(sqlText)
		local data
		query.onData = function(Q, D)
			data = data or {}
			data[#data + 1] = D
		end

		query.onError = function(Q, E)
			if (DB.MySQLDB:status() == mysqloo.DATABASE_NOT_CONNECTED) then
				table.insert(DB.cachedQueries, {sqlText, callback, false})
				return
			end

			if errorCallback then
				errorCallback()
			end

			DB.Log("MySQL Error: ".. E)
			ErrorNoHalt(E .. " (" .. sqlText .. ")\n")
		end

		query.onSuccess = function()
			if callback then callback(data, query:lastInsert()) end
		end
		query:start()
		return
	end

	local lastError = sql.LastError()
	local Result = sql.Query(sqlText)
	if sql.LastError() and sql.LastError() ~= lastError then
		error("SQLite error: " .. sql.LastError())
	end

	if callback then callback(Result) end
	return Result
end

function DB.QueryValue(sqlText, callback, errorCallback)
	if DB.CONNECTED_TO_MYSQL then
		local query = DB.MySQLDB:query(sqlText)
		local data
		query.onData = function(Q, D)
			data = D
		end
		query.onSuccess = function()
			for k,v in pairs(data or {}) do
				callback(v)
				return
			end
			callback()
		end
		query.onError = function(Q, E)
			if (DB.MySQLDB:status() == mysqloo.DATABASE_NOT_CONNECTED) then
				table.insert(DB.cachedQueries, {sqlText, callback, true})
				return
			end

			if errorCallback then
				errorCallback()
			end

			DB.Log("MySQL Error: ".. E)
			ErrorNoHalt(E .. " (" .. sqlText .. ")\n")
		end

		query:start()
		return
	end

	local lastError = sql.LastError()
	local val = sql.QueryValue(sqlText)
	if sql.LastError() and sql.LastError() ~= lastError then
		error("SQLite error: " .. lastError)
	end

	if callback then callback(val) end
	return val
end

function DB.ConnectToMySQL(host, username, password, database_name, database_port)
	if not mysqloo then DB.Log("MySQL Error: MySQL modules aren't installed properly!") Error("MySQL modules aren't installed properly!") end
	local databaseObject = mysqloo.connect(host, username, password, database_name, database_port)

	if timer.Exists("darkrp_check_mysql_status") then timer.Destroy("darkrp_check_mysql_status") end

	databaseObject.onConnectionFailed = function(_, msg)
		DB.Log("MySQL Error: Connection failed! "..tostring(msg))
		Error("Connection failed! " ..tostring(msg))
	end

	databaseObject.onConnected = function()
		DB.Log("MySQL: Connection to external database "..host.." succeeded!")
		DB.CONNECTED_TO_MYSQL = true
		if DB.cachedQueries then
			for _, v in pairs(DB.cachedQueries) do
				if v[3] then
					DB.QueryValue(v[1], v[2])
				else
					DB.Query(v[1], v[2])
				end
			end
		end
		DB.cachedQueries = {}

		timer.Create("darkrp_check_mysql_status", 60, 0, function()
			if (DB.MySQLDB and DB.MySQLDB:status() == mysqloo.DATABASE_NOT_CONNECTED) then
				DB.ConnectToMySQL(RP_MySQLConfig.Host, RP_MySQLConfig.Username, RP_MySQLConfig.Password, RP_MySQLConfig.Database_name, RP_MySQLConfig.Database_port)
			end
		end)

		hook.Call("DatabaseInitialized")
	end
	databaseObject:connect()
	DB.MySQLDB = databaseObject
end

function DB.SQLStr(str)
	if not DB.CONNECTED_TO_MYSQL then
		return sql.SQLStr(str)
	end

	return "\"" .. DB.MySQLDB:escape(tostring(str)) .. "\""
end

/*---------------------------------------------------------
 Database initialize
 ---------------------------------------------------------*/
function DB.Init()
	local map = DB.SQLStr(string.lower(game.GetMap()))
	DB.Begin()
		-- Gotta love the difference between SQLite and MySQL
		local AUTOINCREMENT = DB.CONNECTED_TO_MYSQL and "AUTO_INCREMENT" or "AUTOINCREMENT"

		-- Create the table for the convars used in DarkRP
		DB.Query([[
			CREATE TABLE IF NOT EXISTS darkrp_cvar(
				var VARCHAR(25) NOT NULL PRIMARY KEY,
				value INTEGER NOT NULL
			);
		]])

		-- Table that holds all position data (jail, consoles, zombie spawns etc.)
		-- Queue these queries because other queries depend on the existence of the darkrp_position table
		-- Race conditions could occur if the queries are executed simultaneously
		DB.QueueQuery([[
			CREATE TABLE IF NOT EXISTS darkrp_position(
				id INTEGER NOT NULL PRIMARY KEY ]]..AUTOINCREMENT..[[,
				map VARCHAR(45) NOT NULL,
				type CHAR(1) NOT NULL,
				x INTEGER NOT NULL,
				y INTEGER NOT NULL,
				z INTEGER NOT NULL
			);
		]])

		-- team spawns require extra data
		DB.QueueQuery([[
			CREATE TABLE IF NOT EXISTS darkrp_jobspawn(
				id INTEGER NOT NULL PRIMARY KEY,
				team INTEGER NOT NULL
			);
		]])

		if DB.CONNECTED_TO_MYSQL then
			DB.QueueQuery([[
				ALTER TABLE darkrp_jobspawn ADD FOREIGN KEY(id) REFERENCES darkrp_position(id)
					ON UPDATE CASCADE
					ON DELETE CASCADE;
			]])
		end


		-- Consoles have to be spawned in an angle
		DB.QueueQuery([[
			CREATE TABLE IF NOT EXISTS darkrp_console(
				id INTEGER NOT NULL PRIMARY KEY,
				pitch INTEGER NOT NULL,
				yaw INTEGER NOT NULL,
				roll INTEGER NOT NULL,

				FOREIGN KEY(id) REFERENCES darkrp_position(id)
					ON UPDATE CASCADE
					ON DELETE CASCADE
			);
		]])

		-- Player information
		DB.Query([[
			CREATE TABLE IF NOT EXISTS darkrp_player(
				uid BIGINT NOT NULL PRIMARY KEY,
				rpname VARCHAR(45),
				salary INTEGER NOT NULL DEFAULT 45,
				wallet INTEGER NOT NULL,
				UNIQUE(rpname)
			);
		]])

		-- Door data
		DB.Query([[
			CREATE TABLE IF NOT EXISTS darkrp_door(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				title VARCHAR(25),
				isLocked BOOLEAN,
				isDisabled BOOLEAN NOT NULL DEFAULT FALSE,
				PRIMARY KEY(idx, map)
			);
		]])

		-- Some doors are owned by certain teams
		DB.Query([[
			CREATE TABLE IF NOT EXISTS darkrp_jobown(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				job INTEGER NOT NULL,

				PRIMARY KEY(idx, map, job)
			);
		]])

		-- Door groups
		DB.Query([[
			CREATE TABLE IF NOT EXISTS darkrp_doorgroups(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				doorgroup VARCHAR(100) NOT NULL,

				PRIMARY KEY(idx, map)
			)
		]])

		-- SQlite doesn't really handle foreign keys strictly, neither does MySQL by default
		-- So to keep the DB clean, here's a manual partial foreign key enforcement
		-- For now it's deletion only, since updating of the common attribute doesn't happen.

		-- MySQL trigger
		if DB.CONNECTED_TO_MYSQL then
			DB.Query("show triggers", function(data)
				-- Check if the trigger exists first
				if data then
					for k,v in pairs(data) do
						if v.Trigger == "JobPositionFKDelete" then
							return
						end
					end
				end

				DB.Query("SHOW PRIVILEGES", function(data)
					if not data then return end

					local found;
					for k,v in pairs(data) do
						if v.Privilege == "Trigger" then
							found = true
							break;
						end
					end

					if not found then return end
					DB.Query([[
						CREATE TRIGGER JobPositionFKDelete
							AFTER DELETE ON darkrp_position
							FOR EACH ROW
								IF OLD.type = "T" THEN
									DELETE FROM darkrp_jobspawn WHERE darkrp_jobspawn.id = OLD.id;
								ELSEIF OLD.type = "C" THEN
									DELETE FROM darkrp_console WHERE darkrp_console.id = OLD.id;
								END IF
						;
					]])
				end)
			end)
		else -- SQLite triggers, quite a different syntax
			DB.Query([[
				CREATE TRIGGER IF NOT EXISTS JobPositionFKDelete
					AFTER DELETE ON darkrp_position
					FOR EACH ROW
					WHEN OLD.type = "T"
					BEGIN
						DELETE FROM darkrp_jobspawn WHERE darkrp_jobspawn.id = OLD.id;
					END;
			]])

			DB.Query([[
				CREATE TRIGGER IF NOT EXISTS ConsolePosFKDelete
					AFTER DELETE ON darkrp_position
					FOR EACH ROW
					WHEN OLD.type = "C"
					BEGIN
						DELETE FROM darkrp_console WHERE darkrp_console.id = OLD.id;
					END;
			]])
		end
	DB.Commit(function() -- Initialize the data after all the tables have been created

		-- Update older version of database to the current database
		-- Only run when one of the older tables exist
		local updateQuery = [[SELECT name FROM sqlite_master WHERE type="table" AND name="darkrp_cvars";]]
		if DB.CONNECTED_TO_MYSQL then
			updateQuery = [[show tables like "darkrp_cvars";]]
		end

		DB.QueryValue(updateQuery, function(data)
			if data == "darkrp_cvars" then
				print("UPGRADING DATABASE!")
				DB.UpdateDatabase()
			end
		end)

		DB.SetUpNonOwnableDoors()
		DB.SetUpTeamOwnableDoors()
		DB.SetUpGroupDoors()
		DB.LoadConsoles()

		DB.Query("SELECT * FROM darkrp_cvar;", function(settings)
			for k,v in pairs(settings or {}) do
				RunConsoleCommand(v.var, v.value)
			end
		end)

		DB.JailPos = DB.JailPos or {}
		zombieSpawns = zombieSpawns or {}
		DB.Query([[SELECT * FROM darkrp_position WHERE type IN('J', 'Z') AND map = ]] .. map .. [[;]], function(data)
			for k,v in pairs(data or {}) do
				if v.type == "J" then
					table.insert(DB.JailPos, v)
				elseif v.type == "Z" then
					table.insert(zombieSpawns, v)
				end
			end

			if table.Count(DB.JailPos) == 0 then
				DB.CreateJailPos()
				return
			end
			if table.Count(zombieSpawns) == 0 then
				DB.CreateZombiePos()
				return
			end

			jail_positions = nil
		end)

		DB.TeamSpawns = {}
		DB.Query("SELECT * FROM darkrp_position NATURAL JOIN darkrp_jobspawn WHERE map = "..map..";", function(data)
			if not data or table.Count(data) == 0 then
				DB.CreateSpawnPos()
				return
			end

			team_spawn_positions = nil

			DB.TeamSpawns = data
		end)

		if DB.CONNECTED_TO_MYSQL then -- In a listen server, the connection with the external database is often made AFTER the listen server host has joined,
									--so he walks around with the settings from the SQLite database
			for k,v in pairs(player.GetAll()) do
				local UniqueID = sql.SQLStr(v:UniqueID())
				DB.Query([[SELECT * FROM darkrp_player WHERE uid = ]].. UniqueID ..[[;]], function(data)
					if not data or not data[1] then return end

					local Data = data[1]
					v:setDarkRPVar("rpname", Data.rpname)
					v:setSelfDarkRPVar("salary", Data.salary)
					v:setDarkRPVar("money", Data.wallet)
				end)
			end
		end
	end)
end

/*---------------------------------------------------------------------------
Updating the older database to work with the current version
(copy as much as possible over)
---------------------------------------------------------------------------*/
function DB.UpdateDatabase()
	print("CONVERTING DATABASE")
	-- Start transaction.
	DB.Begin()

	-- CVars
	DB.Query([[DELETE FROM darkrp_cvar;]])
	DB.Query([[INSERT INTO darkrp_cvar SELECT v.var, v.value FROM darkrp_cvars v;]])
	DB.Query([[DROP TABLE darkrp_cvars;]])

	-- Positions
	DB.Query([[DELETE FROM darkrp_position;]])

	-- Team spawns
	DB.Query([[INSERT INTO darkrp_position SELECT NULL, p.map, "T", p.x, p.y, p.z FROM darkrp_tspawns p;]])
	DB.Query([[
		INSERT INTO darkrp_jobspawn
			SELECT new.id, old.team FROM darkrp_position new JOIN darkrp_tspawns old ON
				new.map = old.map AND new.x = old.x AND new.y = old.y AND new.z = old.Z
			WHERE new.type = "T";
	]])
	DB.Query([[DROP TABLE darkrp_tspawns;]])

	-- Zombie spawns
	DB.Query([[INSERT INTO darkrp_position SELECT NULL, p.map, "Z", p.x, p.y, p.z FROM darkrp_zspawns p;]])
	DB.Query([[DROP TABLE darkrp_zspawns;]])


	-- Console spawns
	DB.Query([[INSERT INTO darkrp_position SELECT NULL, p.map, "C", p.x, p.y, p.z FROM darkrp_consolespawns p;]])
	DB.Query([[
		INSERT INTO darkrp_console
			SELECT new.id, old.pitch, old.yaw, old.roll FROM darkrp_position new JOIN darkrp_consolespawns old ON
				new.map = old.map AND new.x = old.x AND new.y = old.y AND new.z = old.z
			WHERE new.type = "C";
	]])
	DB.Query([[DROP TABLE darkrp_consolespawns;]])


	-- Jail positions
	DB.Query([[INSERT INTO darkrp_position SELECT NULL, p.map, "J", p.x, p.y, p.z FROM darkrp_jailpositions p;]])
	DB.Query([[DROP TABLE darkrp_jailpositions;]])

	-- Doors
	DB.Query([[DELETE FROM darkrp_door;]])
	DB.Query([[INSERT INTO darkrp_door SELECT old.idx - ]] .. game.MaxPlayers() .. [[, old.map, old.title, old.locked, old.disabled FROM darkrp_doors old;]])

	DB.Query([[DROP TABLE darkrp_doors;]])
	DB.Query([[DROP TABLE darkrp_teamdoors;]])
	DB.Query([[DROP TABLE darkrp_groupdoors;]])

	DB.Commit()


	local count = DB.QueryValue("SELECT COUNT(*) FROM darkrp_wallets;") or 0
	for i = 0, count, 1000 do -- SQLite selecting limit
		DB.Query([[SELECT darkrp_wallets.steam, amount, salary, name FROM darkrp_wallets
			LEFT OUTER JOIN darkrp_salaries ON darkrp_salaries.steam = darkrp_wallets.steam
			LEFT OUTER JOIN darkrp_rpnames ON darkrp_rpnames.steam = darkrp_wallets.steam LIMIT 1000 OFFSET ]]..i..[[;]], function(data)

			-- Separate transaction for the player data
			DB.Begin()

			for k,v in pairs(data or {}) do
				local uniqueID = util.CRC("gm_" .. v.steam .. "_gm")

				DB.Query([[INSERT INTO darkrp_player VALUES(]]
					..uniqueID..[[,]]
					..((v.name == "NULL" or not v.name) and "NULL" or DB.SQLStr(v.name))..[[,]]
					..((v.salary == "NULL" or not v.salary) and GAMEMODE.Config.normalsalary or v.salary)..[[,]]
					..v.amount..[[);]])
			end

			if count - i < 1000 then -- the last iteration
				DB.Query([[DROP TABLE darkrp_wallets;]])
				DB.Query([[DROP TABLE darkrp_salaries;]])
				DB.Query([[DROP TABLE darkrp_rpnames;]])
			end

			DB.Commit()
		end)
	end
end

/*---------------------------------------------------------
 positions
 ---------------------------------------------------------*/
function DB.CreateSpawnPos()
	local map = string.lower(game.GetMap())
	if not team_spawn_positions then return end

	for k, v in pairs(team_spawn_positions) do
		if v[1] == map then
			table.insert(DB.TeamSpawns, {id = k, map = v[1], x = v[3], y = v[4], z = v[5], team = v[2]})
		end
	end
	team_spawn_positions = nil -- We're done with this now.
end

function DB.CreateZombiePos()
	if not zombie_spawn_positions then return end
	local map = string.lower(game.GetMap())

	DB.Begin()
		for k, v in pairs(zombie_spawn_positions) do
			if map == string.lower(v[1]) then
				DB.Query("INSERT INTO darkrp_position VALUES(NULL, " .. DB.SQLStr(map) .. ", \"Z\", " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ");")
			end
		end
	DB.Commit()
end

function DB.StoreZombies()
	local map = string.lower(game.GetMap())
	DB.Begin()
	DB.Query([[DELETE FROM darkrp_position WHERE type = 'Z' AND map = ]] .. DB.SQLStr(map) .. ";", function()
		for k, v in pairs(zombieSpawns) do
			DB.Query("INSERT INTO darkrp_position VALUES(NULL, " .. DB.SQLStr(map) .. ", 'Z', " .. v.x .. ", " .. v.y .. ", " .. v.z .. ");")
		end
	end)
	DB.Commit()
end

local FirstZombieSpawn = true
function DB.RetrieveZombies(callback)
	if zombieSpawns and table.Count(zombieSpawns) > 0 and not FirstZombieSpawn then callback() return zombieSpawns end
	FirstZombieSpawn = false
	zombieSpawns = {}
	DB.Query([[SELECT * FROM darkrp_position WHERE type = 'Z' AND map = ]] .. DB.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then callback() return end
		for k,v in pairs(r) do
			zombieSpawns[k] = Vector(v.x, v.y, v.z)
		end
		callback()
	end)
end

function DB.RetrieveRandomZombieSpawnPos()
	if #zombieSpawns < 1 then return end
	local r = table.Random(zombieSpawns)

	local pos = GAMEMODE:FindEmptyPos(r, nil, 200, 10, Vector(2, 2, 2))

	return pos
end

function DB.CreateJailPos()
	if not jail_positions then return end
	local map = string.lower(game.GetMap())

	DB.Begin()
		DB.Query([[DELETE FROM darkrp_position WHERE type = "J" AND map = ]].. DB.SQLStr(map)..[[;]])
		for k, v in pairs(jail_positions) do
			if map == string.lower(v[1]) then
				DB.Query("INSERT INTO darkrp_position VALUES(NULL, " .. DB.SQLStr(map) .. ", 'J', " .. v[2] .. ", " .. v[3] .. ", " .. v[4] .. ");")
				table.insert(DB.JailPos, {map = map, x = v[2], y = v[3], z = v[4]})
			end
		end
	DB.Commit()
end

local JailIndex = 1 -- Used to circulate through the jailpos table
function DB.StoreJailPos(ply, addingPos)
	local map = string.lower(game.GetMap())
	local pos = string.Explode(" ", tostring(ply:GetPos()))
	DB.QueryValue("SELECT COUNT(*) FROM darkrp_position WHERE type = 'J' AND map = " .. DB.SQLStr(map) .. ";", function(already)
		if not already or already == 0 then
			DB.Query("INSERT INTO darkrp_position VALUES(NULL, " .. DB.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")
			GAMEMODE:Notify(ply, 0, 4,  LANGUAGE.created_first_jailpos)

			return
		end

		if addingPos then
			DB.Query("INSERT INTO darkrp_position VALUES(NULL, " .. DB.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")

			table.insert(DB.JailPos, {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"})
			GAMEMODE:Notify(ply, 0, 4,  LANGUAGE.added_jailpos)
		else
			DB.Query("DELETE FROM darkrp_position WHERE type = 'J' AND map = " .. DB.SQLStr(map) .. ";", function()
				DB.Query("INSERT INTO darkrp_position VALUES(NULL, " .. DB.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")


				DB.JailPos = {[1] = {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"}}
				GAMEMODE:Notify(ply, 0, 5,  LANGUAGE.reset_add_jailpos)
			end)
		end
	end)

	JailIndex = 1
end

function DB.RetrieveJailPos()
	local map = string.lower(game.GetMap())
	if not DB.JailPos then return Vector(0,0,0) end

	-- Retrieve the least recently used jail position
	local oldestPos = DB.JailPos[JailIndex]
	JailIndex = JailIndex % #DB.JailPos + 1

	return oldestPos and Vector(oldestPos.x, oldestPos.y, oldestPos.z)
end

function DB.SaveSetting(setting, value)
	DB.Query("REPLACE INTO darkrp_cvar VALUES("..DB.SQLStr(setting)..", "..DB.SQLStr(value)..");")
end

function DB.CountJailPos()
	return table.Count(DB.JailPos or {})
end

function DB.StoreTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	DB.Query([[DELETE FROM darkrp_position WHERE map = ]] .. DB.SQLStr(map) .. [[ AND id IN (SELECT id FROM darkrp_jobspawn WHERE team = ]] .. t .. [[)]])

	DB.Query([[INSERT INTO darkrp_position VALUES(NULL, ]] .. DB.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		DB.QueryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. DB.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if not id then return end
			DB.Query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(DB.TeamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)

	print(string.format(LANGUAGE.created_spawnpos, team.GetName(t)))
end

function DB.AddTeamSpawnPos(t, pos)
	local map = string.lower(game.GetMap())

	DB.Query([[INSERT INTO darkrp_position VALUES(NULL, ]] .. DB.SQLStr(map) .. [[, "T", ]] .. pos[1] .. [[, ]] .. pos[2] .. [[, ]] .. pos[3] .. [[);]]
		, function()
		DB.QueryValue([[SELECT MAX(id) FROM darkrp_position WHERE map = ]] .. DB.SQLStr(map) .. [[ AND type = "T";]], function(id)
			if type(id) == "boolean" then return end
			DB.Query([[INSERT INTO darkrp_jobspawn VALUES(]] .. id .. [[, ]] .. t .. [[);]])
			table.insert(DB.TeamSpawns, {id = id, map = map, x = pos[1], y = pos[2], z = pos[3], team = t})
		end)
	end)
end

function DB.RemoveTeamSpawnPos(t, callback)
	local map = string.lower(game.GetMap())
	DB.Query([[SELECT darkrp_position.id FROM darkrp_position
		NATURAL JOIN darkrp_jobspawn
		WHERE map = ]] .. DB.SQLStr(map) .. [[
		AND team = ]].. t ..[[;]], function(data)

		DB.Begin()
		for k,v in pairs(data or {}) do
			-- The trigger will make sure the values get deleted from the jobspawn as well
			DB.Query([[DELETE FROM darkrp_position WHERE id = ]]..v.id..[[;]])
		end
		DB.Commit()
	end)

	for k,v in pairs(DB.TeamSpawns) do
		if tonumber(v.team) == t then
			DB.TeamSpawns[k] = nil
		end
	end

	if callback then callback() end
end

function DB.RetrieveTeamSpawnPos(ply)
	local map = string.lower(game.GetMap())
	local t = ply:Team()

	local returnal = {}

	if DB.TeamSpawns then
		for k,v in pairs(DB.TeamSpawns) do
			if v.map == map and tonumber(v.team) == t then
				table.insert(returnal, Vector(v.x, v.y, v.z))
			end
		end
		return (table.Count(returnal) > 0 and returnal) or nil
	end
end

/*---------------------------------------------------------
Players
 ---------------------------------------------------------*/
function DB.StoreRPName(ply, name)
	if not name or string.len(name) < 2 then return end
	ply:setDarkRPVar("rpname", name)

	DB.Query([[UPDATE darkrp_player SET rpname = ]] .. DB.SQLStr(name) .. [[ WHERE UID = ]] .. ply:UniqueID() .. ";")
end

function DB.RetrieveRPNames(ply, name, callback)
	DB.Query("SELECT COUNT(*) AS count FROM darkrp_player WHERE rpname = "..DB.SQLStr(name)..";", function(r)
		callback(tonumber(r[1].count) > 0)
	end)
end

function DB.RetrievePlayerData(ply, callback, failed, attempts)
	attempts = attempts or 0

	if attempts > 3 then return failed() end

	DB.Query("SELECT rpname, wallet, salary FROM darkrp_player WHERE uid = " .. ply:UniqueID() .. ";", callback, function()
		DB.RetrievePlayerData(ply, callback, failed, attempts + 1)
	end)
end

function DB.CreatePlayerData(ply, name, wallet, salary)
	DB.Query([[REPLACE INTO darkrp_player VALUES(]] ..
			ply:UniqueID() .. [[, ]] ..
			DB.SQLStr(name)  .. [[, ]] ..
			salary  .. [[, ]] ..
			wallet .. ");")
end

function DB.StoreMoney(ply, amount)
	if not IsValid(ply) then return end
	if amount < 0  then return end

	DB.Query([[UPDATE darkrp_player SET wallet = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID())
end

function DB.ResetAllMoney(ply,cmd,args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then return end
	DB.Query("UPDATE darkrp_player SET wallet = "..GAMEMODE.Config.startingmoney.." ;")
	for k,v in pairs(player.GetAll()) do
		v:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
	end
	if ply:IsPlayer() then
		GAMEMODE:NotifyAll(0,4, string.format(LANGUAGE.reset_money, ply:Nick()))
	else
		GAMEMODE:NotifyAll(0,4, string.format(LANGUAGE.reset_money, "Console"))
	end
end
concommand.Add("rp_resetallmoney", DB.ResetAllMoney)

function DB.PayPlayer(ply1, ply2, amount)
	if not IsValid(ply1) or not IsValid(ply2) then return end
	ply1:AddMoney(-amount)
	ply2:AddMoney(amount)
end

function DB.StoreSalary(ply, amount)
	ply:setSelfDarkRPVar("salary", math.floor(amount))

	DB.Query([[UPDATE darkrp_player SET salary = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID())

	return amount
end

function DB.RetrieveSalary(ply, callback)
	if not IsValid(ply) then return 0 end

	if ply:getDarkRPVar("salary") then return callback and callback(ply:getDarkRPVar("salary")) end -- First check the cache.

	DB.QueryValue("SELECT salary FROM darkrp_player WHERE uid = " .. ply:UniqueID() .. ";", function(r)
		local normal = GAMEMODE.Config.normalsalary
		if not r then
			ply:setSelfDarkRPVar("salary", normal)
			callback(normal)
		else
			callback(r)
		end
	end)
end

/*---------------------------------------------------------
 Doors
 ---------------------------------------------------------*/
function DB.StoreDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	ent.DoorData = ent.DoorData or {}
	local nonOwnable = ent.DoorData.NonOwnable

	DB.Query([[REPLACE INTO darkrp_door VALUES(]]..
		ent:DoorIndex() ..[[, ]] ..
		DB.SQLStr(map) .. [[, ]] ..
		(ent.DoorData.title and DB.SQLStr(ent.DoorData.title) or "NULL") .. [[, ]] ..
		"NULL" .. [[, ]] ..
		(ent.DoorData.NonOwnable and 1 or 0) .. [[);]])
end

function DB.StoreDoorTitle(ent, text)
	ent.DoorData = ent.DoorData or {}
	ent.DoorData.title = text
	DB.Query("UPDATE darkrp_door SET title = " .. DB.SQLStr(text) .. " WHERE map = " .. DB.SQLStr(string.lower(game.GetMap())) .. " AND idx = " .. ent:DoorIndex() .. ";")
end

function DB.SetUpNonOwnableDoors()
	DB.Query("SELECT idx, title, isLocked, isDisabled FROM darkrp_door WHERE map = " .. DB.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(GAMEMODE:DoorToEntIndex(tonumber(row.idx)))
			if IsValid(e) then
				e.DoorData = e.DoorData or {}
				e.DoorData.NonOwnable = tobool(row.isDisabled)
				if r.isLocked ~= nil then
					e:Fire((tobool(row.locked) and "" or "un").."lock", "", 0)
				end
				e.DoorData.title = row.title ~= "NULL" and row.title or nil
			end
		end
	end)
end

function DB.StoreTeamDoorOwnability(ent)
	local map = string.lower(game.GetMap())
	ent.DoorData = ent.DoorData or {}

	DB.Query("DELETE FROM darkrp_jobown WHERE idx = " .. ent:DoorIndex() .. " AND map = " .. DB.SQLStr(map) .. ";")
	for k,v in pairs(string.Explode("\n", ent.DoorData.TeamOwn or "")) do
		if v == "" then continue end

		DB.Query("INSERT INTO darkrp_jobown VALUES("..ent:DoorIndex() .. ", "..DB.SQLStr(map) .. ", " .. v .. ");")
	end
end

function DB.SetUpTeamOwnableDoors()
	DB.Query("SELECT idx, job FROM darkrp_jobown WHERE map = " .. DB.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(GAMEMODE:DoorToEntIndex(tonumber(row.idx)))
			if IsValid(e) then
				e.DoorData = e.DoorData or {}
				e.DoorData.TeamOwn = e.DoorData.TeamOwn or ""
				e.DoorData.TeamOwn = (e.DoorData.TeamOwn == "" and row.job) or (e.DoorData.TeamOwn .. "\n" .. row.job)
			end
		end
	end)
end

function DB.SetDoorGroup(ent, group)
	local map = DB.SQLStr(string.lower(game.GetMap()))
	local index = ent:DoorIndex()

	if group == "" then
		DB.Query("DELETE FROM darkrp_doorgroups WHERE map = " .. map .. " AND idx = " .. index .. ";")
		return
	end

	DB.Query("REPLACE INTO darkrp_doorgroups VALUES(" .. index .. ", " .. map .. ", " .. DB.SQLStr(group) .. ");");
end

function DB.SetUpGroupDoors()
	local map = DB.SQLStr(string.lower(game.GetMap()))
	DB.Query("SELECT idx, doorgroup FROM darkrp_doorgroups WHERE map = " .. map, function(data)
		if not data then return end

		for _, row in pairs(data) do
			local ent = ents.GetByIndex(GAMEMODE:DoorToEntIndex(tonumber(row.idx)))

			if not IsValid(ent) then
				continue
			end

			ent.DoorData = ent.DoorData or {}
			ent.DoorData.GroupOwn = row.doorgroup
		end
	end)
end

/*---------------------------------------------------------------------------
Consoles
---------------------------------------------------------------------------*/

function DB.LoadConsoles()
	local map = string.lower(game.GetMap())
	DB.Query("SELECT * FROM darkrp_position NATURAL JOIN darkrp_console WHERE map = " .. DB.SQLStr(map) .. " AND type = 'C';", function(data)
		if data then
			for k, v in pairs(data) do
				local console = ents.Create("darkrp_console")
				console:SetPos(Vector(tonumber(v.x), tonumber(v.y), tonumber(v.z)))
				console:SetAngles(Angle(tonumber(v.pitch), tonumber(v.yaw), tonumber(v.roll)))
				console:Spawn()
				console.ID = v.id
			end
		else -- If there are no custom positions in the database, use the presets.
			for k,v in pairs(RP_ConsolePositions or {}) do
				if v[1] == map then
					local console = ents.Create("darkrp_console")
					console:SetPos(Vector(RP_ConsolePositions[k][2], RP_ConsolePositions[k][3], RP_ConsolePositions[k][4]))
					console:SetAngles(Angle(RP_ConsolePositions[k][5], RP_ConsolePositions[k][6], RP_ConsolePositions[k][7]))
					console:Spawn()
					console:Activate()

					console.ID = "0"
				end
			end
		end
		RP_ConsolePositions = nil
	end)
end

function DB.CreateConsole(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end

	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)

	local console = ents.Create("darkrp_console")
	console:SetPos(trace.HitPos)
	console:Spawn()
	console:Activate()

	DB.QueryValue("SELECT MAX(id) FROM darkrp_position;", function(Data)
		console.ID = (tonumber(Data) and tostring(tonumber(Data) + 1)) or "1"
	end)

	ply:ChatPrint("Console spawned, move and freeze it to save it!")
end
concommand.Add("rp_CreateConsole", DB.CreateConsole)

function DB.RemoveConsoles(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
	DB.Query("DELETE FROM darkrp_position WHERE map = " .. DB.SQLStr(string.lower(game.GetMap())) .. " AND type = 'C';")
	for k,v in pairs(ents.FindByClass("darkrp_console")) do
		v:Remove()
	end
	GAMEMODE:NotifyAll(0, 4, "All consoles have been removed")
end
concommand.Add("rp_removeallconsoles", DB.RemoveConsoles)

/*---------------------------------------------------------
 Logging
 ---------------------------------------------------------*/

local function AdminLog(message, colour)
	local RF = RecipientFilter()
	for k,v in pairs(player.GetAll()) do
		local canHear = hook.Call("CanSeeLogMessage", GAMEMODE, v, message, colour)

		if canHear then
			RF:AddPlayer(v)
		end
	end
	umsg.Start("DRPLogMsg", RF)
		umsg.Short(colour.r)
		umsg.Short(colour.g)
		umsg.Short(colour.b) -- Alpha is not needed
		umsg.String(message)
	umsg.End()
end

function DB.Log(text, force, colour)
	if colour then
		AdminLog(text, colour)
	end
	if (not GAMEMODE.Config.logging or not text) and not force then return end
	if not DB.File then -- The log file of this session, if it's not there then make it!
		if not file.IsDir("DarkRP_logs", "DATA") then
			file.CreateDir("DarkRP_logs")
		end
		DB.File = "DarkRP_logs/"..os.date("%m_%d_%Y %I_%M %p")..".txt"
		file.Write(DB.File, os.date().. "\t".. text)
		return
	end
	file.Append(DB.File, "\n"..os.date().. "\t"..(text or ""))
end
