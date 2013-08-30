/*---------------------------------------------------------------------------
Functions and variables
---------------------------------------------------------------------------*/
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

		MySQLite.query([[
			CREATE TABLE IF NOT EXISTS playerinformation(
				uid BIGINT NOT NULL,
				steamID VARCHAR(50) NOT NULL PRIMARY KEY
			)
		]])

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
Players
 ---------------------------------------------------------*/
function DarkRP.storeRPName(ply, name)
	if not name or string.len(name) < 2 then return end
	ply:setDarkRPVar("rpname", name)

	MySQLite.query([[UPDATE darkrp_player SET rpname = ]] .. MySQLite.SQLStr(name) .. [[ WHERE UID = ]] .. ply:UniqueID() .. ";")
end

function DarkRP.retrieveRPNames(name, callback)
	MySQLite.query("SELECT COUNT(*) AS count FROM darkrp_player WHERE rpname = "..MySQLite.SQLStr(name)..";", function(r)
		callback(tonumber(r[1].count) > 0)
	end)
end

function DarkRP.retrievePlayerData(ply, callback, failed, attempts)
	attempts = attempts or 0

	if attempts > 3 then return failed() end
	MySQLite.query(string.format([[REPLACE INTO playerinformation VALUES(%s, %s);]], MySQLite.SQLStr(ply:UniqueID()), MySQLite.SQLStr(ply:SteamID())))

	MySQLite.query("SELECT rpname, wallet, salary FROM darkrp_player WHERE uid = " .. ply:UniqueID() .. ";", callback, function()
		DarkRP.retrievePlayerData(ply, callback, failed, attempts + 1)
	end)
end

function DarkRP.createPlayerData(ply, name, wallet, salary)
	MySQLite.query([[REPLACE INTO darkrp_player VALUES(]] ..
			ply:UniqueID() .. [[, ]] ..
			MySQLite.SQLStr(name)  .. [[, ]] ..
			salary  .. [[, ]] ..
			wallet .. ");")
end

function DarkRP.storeMoney(ply, amount)
	if not IsValid(ply) then return end
	if amount < 0  then return end

	MySQLite.query([[UPDATE darkrp_player SET wallet = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID())
end

local function resetAllMoney(ply,cmd,args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then return end
	MySQLite.query("UPDATE darkrp_player SET wallet = "..GAMEMODE.Config.startingmoney.." ;")
	for k,v in pairs(player.GetAll()) do
		v:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
	end
	if ply:IsPlayer() then
		DarkRP.notifyAll(0,4, DarkRP.getPhrase("reset_money", ply:Nick()))
	else
		DarkRP.notifyAll(0,4, DarkRP.getPhrase("reset_money", "Console"))
	end
end
concommand.Add("rp_resetallmoney", resetAllMoney)

function DarkRP.storeSalary(ply, amount)
	ply:setSelfDarkRPVar("salary", math.floor(amount))

	MySQLite.query([[UPDATE darkrp_player SET salary = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID())

	return amount
end

function DarkRP.retrieveSalary(ply, callback)
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

/*---------------------------------------------------------------------------
Players
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")
function meta:restorePlayerData()
	if not IsValid(self) then return end
	self.DarkRPUnInitialized = true

	DarkRP.retrievePlayerData(self, function(data)
		if not IsValid(self) then return end

		self.DarkRPUnInitialized = nil

		local info = data and data[1] or {}
		if not info.rpname or info.rpname == "NULL" then info.rpname = string.gsub(self:SteamName(), "\\\"", "\"") end

		info.wallet = info.wallet or GAMEMODE.Config.startingmoney
		info.salary = info.salary or GAMEMODE.Config.normalsalary

		self:setDarkRPVar("money", tonumber(info.wallet))
		self:setDarkRPVar("salary", tonumber(info.salary))

		self:setDarkRPVar("rpname", info.rpname)

		if not data then
			DarkRP.createPlayerData(self, info.rpname, info.wallet, info.salary)
		end
	end, function() -- Retrieving data failed, go on without it
		self.DarkRPUnInitialized = nil

		self:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
		self:setDarkRPVar("salary", GAMEMODE.Config.normalsalary)
		self:setDarkRPVar("name", string.gsub(self:SteamName(), "\\\"", "\""))

		error("Failed to retrieve player information from MySQL server")
	end)
end

/*---------------------------------------------------------
 Doors
 ---------------------------------------------------------*/
function DarkRP.storeDoorData(ent)
	local map = string.lower(game.GetMap())
	local nonOwnable = ent:getKeysNonOwnable()
	local title = ent:getKeysTitle()

	MySQLite.query([[REPLACE INTO darkrp_door VALUES(]]..
		ent:doorIndex() ..[[, ]] ..
		MySQLite.SQLStr(map) .. [[, ]] ..
		(title and MySQLite.SQLStr(title) or "NULL") .. [[, ]] ..
		"NULL" .. [[, ]] ..
		(nonOwnable and 1 or 0) .. [[);]])
end

function setUpNonOwnableDoors()
	MySQLite.query("SELECT idx, title, isLocked, isDisabled FROM darkrp_door WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(DarkRP.doorToEntIndex(tonumber(row.idx)))
			if IsValid(e) and e:isKeysOwnable() then
				e:setKeysNonOwnable(tobool(row.isDisabled))
				if r.isLocked ~= nil then
					e:Fire((tobool(row.locked) and "" or "un").."lock", "", 0)
				end
				e:setKeysTitle(row.title ~= "NULL" and row.title or nil)
			end
		end
	end)
end

function DarkRP.storeTeamDoorOwnability(ent)
	local map = string.lower(game.GetMap())

	MySQLite.query("DELETE FROM darkrp_jobown WHERE idx = " .. ent:doorIndex() .. " AND map = " .. MySQLite.SQLStr(map) .. ";")
	for k,v in pairs(ent:getKeysDoorTeams() or {}) do
		MySQLite.query("INSERT INTO darkrp_jobown VALUES(" .. ent:doorIndex() .. ", " .. MySQLite.SQLStr(map) .. ", " .. k .. ");")
	end
end

function setUpTeamOwnableDoors()
	MySQLite.query("SELECT idx, job FROM darkrp_jobown WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
		if not r then return end

		for _, row in pairs(r) do
			local e = ents.GetByIndex(DarkRP.doorToEntIndex(tonumber(row.idx)))
			if not IsValid(e) then continue end

			e:addKeysDoorTeam(tonumber(row.job))
		end
	end)
end

function DarkRP.storeDoorGroup(ent, group)
	local map = MySQLite.SQLStr(string.lower(game.GetMap()))
	local index = ent:doorIndex()

	if group == "" or not group then
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
			local ent = ents.GetByIndex(DarkRP.doorToEntIndex(tonumber(row.idx)))

			if not IsValid(ent) or not ent:isKeysOwnable() then
				continue
			end

			ent:setDoorGroup(row.doorgroup)
		end
	end)
end
