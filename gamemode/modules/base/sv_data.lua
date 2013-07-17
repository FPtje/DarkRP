/*---------------------------------------------------------------------------
Functions and variables
---------------------------------------------------------------------------*/
local teamSpawns = {}
local jailPos = {}
local setUpNonOwnableDoors,
	setUpTeamOwnableDoors,
	setUpGroupDoors

/*---------------------------------------------------------
 Database initialize
 ---------------------------------------------------------*/
function DarkRP.initDatabase()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	MySQLite.begin()
		-- Gotta love the difference between SQLite and MySQL
		local AUTOINCREMENT = MySQLite.CONNECTED_TO_MYSQL and "AUTO_INCREMENT" or "AUTOINCREMENT"

		-- Table that holds all position data (jail, zombie spawns etc.)
		-- Queue these queries because other queries depend on the existence of the darkrp_position table
		-- Race conditions could occur if the queries are executed simultaneously
		MySQLite.queueQuery([[
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
		MySQLite.queueQuery([[
			CREATE TABLE IF NOT EXISTS darkrp_jobspawn(
				id INTEGER NOT NULL PRIMARY KEY,
				team INTEGER NOT NULL
			);
		]])

		if MySQLite.CONNECTED_TO_MYSQL then
			MySQLite.queueQuery([[
				ALTER TABLE darkrp_jobspawn ADD FOREIGN KEY(id) REFERENCES darkrp_position(id)
					ON UPDATE CASCADE
					ON DELETE CASCADE;
			]])
		end

		-- Player information
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS darkrp_player(
				uid BIGINT NOT NULL PRIMARY KEY,
				rpname VARCHAR(45),
				salary INTEGER NOT NULL DEFAULT 45,
				wallet INTEGER NOT NULL,
				UNIQUE(rpname)
			);
		]])

		-- Door data
		MySQLite.query([[
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
		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS darkrp_jobown(
				idx INTEGER NOT NULL,
				map VARCHAR(45) NOT NULL,
				job INTEGER NOT NULL,

				PRIMARY KEY(idx, map, job)
			);
		]])

		-- Door groups
		MySQLite.query([[
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
		if MySQLite.CONNECTED_TO_MYSQL then
			MySQLite.query("show triggers", function(data)
				-- Check if the trigger exists first
				if data then
					for k,v in pairs(data) do
						if v.Trigger == "JobPositionFKDelete" then
							return
						end
					end
				end

				MySQLite.query("SHOW PRIVILEGES", function(data)
					if not data then return end

					local found;
					for k,v in pairs(data) do
						if v.Privilege == "Trigger" then
							found = true
							break;
						end
					end

					if not found then return end
					MySQLite.query([[
						CREATE TRIGGER JobPositionFKDelete
							AFTER DELETE ON darkrp_position
							FOR EACH ROW
								IF OLD.type = "T" THEN
									DELETE FROM darkrp_jobspawn WHERE darkrp_jobspawn.id = OLD.id;
								END IF
						;
					]])
				end)
			end)
		else -- SQLite triggers, quite a different syntax
			MySQLite.query([[
				CREATE TRIGGER IF NOT EXISTS JobPositionFKDelete
					AFTER DELETE ON darkrp_position
					FOR EACH ROW
					WHEN OLD.type = "T"
					BEGIN
						DELETE FROM darkrp_jobspawn WHERE darkrp_jobspawn.id = OLD.id;
					END;
			]])
		end
	MySQLite.commit(function() -- Initialize the data after all the tables have been created

		setUpNonOwnableDoors()
		setUpTeamOwnableDoors()
		setUpGroupDoors()

		jailPos = jailPos or {}
		MySQLite.query([[SELECT * FROM darkrp_position WHERE type = 'J' AND map = ]] .. map .. [[;]], function(data)
			for k,v in pairs(data or {}) do
				table.insert(jailPos, v)
			end
		end)

		MySQLite.query("SELECT * FROM darkrp_position NATURAL JOIN darkrp_jobspawn WHERE map = "..map..";", function(data)
			teamSpawns = data or {}
		end)

		if MySQLite.CONNECTED_TO_MYSQL then -- In a listen server, the connection with the external database is often made AFTER the listen server host has joined,
									--so he walks around with the settings from the SQLite database
			for k,v in pairs(player.GetAll()) do
				local UniqueID = MySQLite.SQLStr(v:UniqueID())
				MySQLite.query([[SELECT * FROM darkrp_player WHERE uid = ]].. UniqueID ..[[;]], function(data)
					if not data or not data[1] then return end

					local Data = data[1]
					v:setDarkRPVar("rpname", Data.rpname)
					v:setSelfDarkRPVar("salary", Data.salary)
					v:setDarkRPVar("money", Data.wallet)
				end)
			end
		end

		hook.Call("DarkRPDBInitialized")
	end)
end

/*---------------------------------------------------------
 positions
 ---------------------------------------------------------*/
local JailIndex = 1 -- Used to circulate through the jailpos table
function DB.StoreJailPos(ply, addingPos)
	local map = string.lower(game.GetMap())
	local pos = string.Explode(" ", tostring(ply:GetPos()))
	MySQLite.queryValue("SELECT COUNT(*) FROM darkrp_position WHERE type = 'J' AND map = " .. MySQLite.SQLStr(map) .. ";", function(already)
		if not already or already == 0 then
			MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")
			GAMEMODE:Notify(ply, 0, 4,  DarkRP.getPhrase("created_first_jailpos"))

			return
		end

		if addingPos then
			MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")

			table.insert(jailPos, {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"})
			GAMEMODE:Notify(ply, 0, 4,  DarkRP.getPhrase("added_jailpos"))
		else
			MySQLite.query("DELETE FROM darkrp_position WHERE type = 'J' AND map = " .. MySQLite.SQLStr(map) .. ";", function()
				MySQLite.query("INSERT INTO darkrp_position VALUES(NULL, " .. MySQLite.SQLStr(map) .. ", 'J', " .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ");")


				jailPos = {[1] = {map = map, x = pos[1], y = pos[2], z = pos[3], type = "J"}}
				GAMEMODE:Notify(ply, 0, 5,  DarkRP.getPhrase("reset_add_jailpos"))
			end)
		end
	end)

	JailIndex = 1
end

function DB.RetrieveJailPos()
	local map = string.lower(game.GetMap())
	if not jailPos then return Vector(0,0,0) end

	-- Retrieve the least recently used jail position
	local oldestPos = jailPos[JailIndex]
	JailIndex = JailIndex % #jailPos + 1

	return oldestPos and Vector(oldestPos.x, oldestPos.y, oldestPos.z)
end

function DB.CountJailPos()
	return table.Count(jailPos or {})
end

function DB.StoreTeamSpawnPos(t, pos)
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

function DB.AddTeamSpawnPos(t, pos)
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

function DB.RemoveTeamSpawnPos(t, callback)
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

function DB.RetrieveTeamSpawnPos(ply)
	local map = string.lower(game.GetMap())
	local t = ply:Team()

	local returnal = {}

	if teamSpawns then
		for k,v in pairs(teamSpawns) do
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

	MySQLite.query([[UPDATE darkrp_player SET rpname = ]] .. MySQLite.SQLStr(name) .. [[ WHERE UID = ]] .. ply:UniqueID() .. ";")
end

function DB.RetrieveRPNames(ply, name, callback)
	MySQLite.query("SELECT COUNT(*) AS count FROM darkrp_player WHERE rpname = "..MySQLite.SQLStr(name)..";", function(r)
		callback(tonumber(r[1].count) > 0)
	end)
end

function DB.RetrievePlayerData(ply, callback, failed, attempts)
	attempts = attempts or 0

	if attempts > 3 then return failed() end

	MySQLite.query("SELECT rpname, wallet, salary FROM darkrp_player WHERE uid = " .. ply:UniqueID() .. ";", callback, function()
		DB.RetrievePlayerData(ply, callback, failed, attempts + 1)
	end)
end

function DB.CreatePlayerData(ply, name, wallet, salary)
	MySQLite.query([[REPLACE INTO darkrp_player VALUES(]] ..
			ply:UniqueID() .. [[, ]] ..
			MySQLite.SQLStr(name)  .. [[, ]] ..
			salary  .. [[, ]] ..
			wallet .. ");")
end

function DB.StoreMoney(ply, amount)
	if not IsValid(ply) then return end
	if amount < 0  then return end

	MySQLite.query([[UPDATE darkrp_player SET wallet = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID())
end

function DB.ResetAllMoney(ply,cmd,args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then return end
	MySQLite.query("UPDATE darkrp_player SET wallet = "..GAMEMODE.Config.startingmoney.." ;")
	for k,v in pairs(player.GetAll()) do
		v:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
	end
	if ply:IsPlayer() then
		GAMEMODE:NotifyAll(0,4, DarkRP.getPhrase("reset_money", ply:Nick()))
	else
		GAMEMODE:NotifyAll(0,4, DarkRP.getPhrase("reset_money", "Console"))
	end
end
concommand.Add("rp_resetallmoney", DB.ResetAllMoney)

function DB.StoreSalary(ply, amount)
	ply:setSelfDarkRPVar("salary", math.floor(amount))

	MySQLite.query([[UPDATE darkrp_player SET salary = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID())

	return amount
end

function DB.RetrieveSalary(ply, callback)
	if not IsValid(ply) then return 0 end

	if ply:getDarkRPVar("salary") then return callback and callback(ply:getDarkRPVar("salary")) end -- First check the cache.

	MySQLite.queryValue("SELECT salary FROM darkrp_player WHERE uid = " .. ply:UniqueID() .. ";", function(r)
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

	MySQLite.query([[REPLACE INTO darkrp_door VALUES(]]..
		ent:DoorIndex() ..[[, ]] ..
		MySQLite.SQLStr(map) .. [[, ]] ..
		(ent.DoorData.title and MySQLite.SQLStr(ent.DoorData.title) or "NULL") .. [[, ]] ..
		"NULL" .. [[, ]] ..
		(ent.DoorData.NonOwnable and 1 or 0) .. [[);]])
end

function DB.StoreDoorTitle(ent, text)
	ent.DoorData = ent.DoorData or {}
	ent.DoorData.title = text
	MySQLite.query("UPDATE darkrp_door SET title = " .. MySQLite.SQLStr(text) .. " WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. " AND idx = " .. ent:DoorIndex() .. ";")
end

function setUpNonOwnableDoors()
	MySQLite.query("SELECT idx, title, isLocked, isDisabled FROM darkrp_door WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
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

	MySQLite.query("DELETE FROM darkrp_jobown WHERE idx = " .. ent:DoorIndex() .. " AND map = " .. MySQLite.SQLStr(map) .. ";")
	for k,v in pairs(string.Explode("\n", ent.DoorData.TeamOwn or "")) do
		if v == "" then continue end

		MySQLite.query("INSERT INTO darkrp_jobown VALUES("..ent:DoorIndex() .. ", "..MySQLite.SQLStr(map) .. ", " .. v .. ");")
	end
end

function setUpTeamOwnableDoors()
	MySQLite.query("SELECT idx, job FROM darkrp_jobown WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
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
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	local index = ent:DoorIndex()

	if group == "" then
		MySQLite.query("DELETE FROM darkrp_doorgroups WHERE map = " .. map .. " AND idx = " .. index .. ";")
		return
	end

	MySQLite.query("REPLACE INTO darkrp_doorgroups VALUES(" .. index .. ", " .. map .. ", " .. MySQLite.SQLStr(group) .. ");");
end

function setUpGroupDoors()
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	MySQLite.query("SELECT idx, doorgroup FROM darkrp_doorgroups WHERE map = " .. map, function(data)
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
