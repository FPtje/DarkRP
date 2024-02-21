--[[---------------------------------------------------------------------------
Functions and variables
---------------------------------------------------------------------------]]
local setUpNonOwnableDoors,
    setUpTeamOwnableDoors,
    setUpGroupDoors,
    migrateDB

--[[---------------------------------------------------------
 Database initialize
 ---------------------------------------------------------]]
function DarkRP.initDatabase()
    MySQLite.begin()
        -- Gotta love the difference between SQLite and MySQL
        local is_mysql = MySQLite.isMySQL()
        local AUTOINCREMENT = is_mysql and "AUTO_INCREMENT" or "AUTOINCREMENT"
        -- in MySQL, the engine is set to InnoDB. InnoDB has been the default
        -- for a while, but people might be running old versions of MySQL.
        -- SQLite has no database engine, so it is not explicitly set.
        local ENGINE_INNODB = is_mysql and "ENGINE=InnoDB" or ""

        -- Table that holds all position data (jail, spawns etc.)
        -- Queue these queries because other queries depend on the existence of the darkrp_position table
        -- Race conditions could occur if the queries are executed simultaneously
        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS darkrp_position(
                id INTEGER NOT NULL PRIMARY KEY ]] .. AUTOINCREMENT .. [[,
                map VARCHAR(45) NOT NULL,
                type CHAR(1) NOT NULL,
                x INTEGER NOT NULL,
                y INTEGER NOT NULL,
                z INTEGER NOT NULL
            ) ]] .. ENGINE_INNODB .. [[;
        ]])

        -- team spawns require extra data
        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS darkrp_jobspawn(
                id INTEGER NOT NULL PRIMARY KEY REFERENCES darkrp_position(id)
                    ON UPDATE CASCADE
                    ON DELETE CASCADE,

                teamcmd VARCHAR(255) NOT NULL
            ) ]] .. ENGINE_INNODB .. [[;
        ]])

        -- This table is kept for compatibility with older addons and websites
        -- See https://github.com/FPtje/DarkRP/issues/819
        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS playerinformation(
                uid BIGINT NOT NULL,
                steamID VARCHAR(50) NOT NULL PRIMARY KEY
            ) ]] .. ENGINE_INNODB .. [[
        ]])

        -- Player information
        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS darkrp_player(
                uid BIGINT NOT NULL PRIMARY KEY,
                rpname VARCHAR(45),
                salary INTEGER NOT NULL DEFAULT 45,
                wallet BIGINT NOT NULL
            ) ]] .. ENGINE_INNODB .. [[;
        ]])

        -- Door data
        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS darkrp_door(
                idx INTEGER NOT NULL,
                map VARCHAR(45) NOT NULL,
                title VARCHAR(25),
                isLocked BOOLEAN,
                isDisabled BOOLEAN NOT NULL DEFAULT FALSE,
                PRIMARY KEY(idx, map)
            ) ]] .. ENGINE_INNODB .. [[;
        ]])

        -- Some doors are owned by certain teams
        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS darkrp_doorjobs(
                idx INTEGER NOT NULL,
                map VARCHAR(45) NOT NULL,
                job VARCHAR(255) NOT NULL,

                PRIMARY KEY(idx, map, job)
            ) ]] .. ENGINE_INNODB .. [[;
        ]])

        -- Door groups
        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS darkrp_doorgroups(
                idx INTEGER NOT NULL,
                map VARCHAR(45) NOT NULL,
                doorgroup VARCHAR(100) NOT NULL,

                PRIMARY KEY(idx, map)
            ) ]] .. ENGINE_INNODB .. [[
        ]])

        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS darkrp_dbversion(version INTEGER NOT NULL PRIMARY KEY) ]] .. ENGINE_INNODB .. [[
        ]])

        -- Load the last DBVersion into DarkRP.DBVersion, to allow checks to see whether migration is needed.
        MySQLite.queueQuery([[
            SELECT MAX(version) AS version FROM darkrp_dbversion
        ]], function(data)
            -- The database is created with the schema of the latest version. On
            -- initialization the version is not set yet. Set it to the latest
            -- version.
            if not data or not data[1] or not tonumber(data[1].version) then
                DarkRP.DBVersion = 20211228
                MySQLite.query([[
                    REPLACE INTO darkrp_dbversion VALUES(20211228)
                ]])
            else
                DarkRP.DBVersion = tonumber(data[1].version)
            end
        end)

    MySQLite.commit(fp{migrateDB, -- Migrate the database
        function() -- Initialize the data after all the tables have been created
            setUpNonOwnableDoors()
            setUpTeamOwnableDoors()
            setUpGroupDoors()

            if MySQLite.isMySQL() then -- In a listen server, the connection with the external database is often made AFTER the listen server host has joined,
                                        --so he walks around with the settings from the SQLite database
                for _, v in ipairs(player.GetAll()) do
                    DarkRP.offlinePlayerData(v:SteamID(), function(data)
                        local Data = data and data[1]
                        if not IsValid(v) or not Data then return end

                        v:setDarkRPVar("rpname", Data.rpname)
                        v:setSelfDarkRPVar("salary", Data.salary)
                        v:setDarkRPVar("money", Data.wallet)
                    end)
                end
            end

            hook.Call("DarkRPDBInitialized")
        end})
end

--[[---------------------------------------------------------------------------
Database migration
backwards compatibility with older versions of DarkRP
---------------------------------------------------------------------------]]
function migrateDB(callback)
    -- Simple function that checks the database version, migrates if
    -- necessary, and recurses to perform the next migration, until the last
    -- migration has been performed.
    -- Calls callback when the migration is finished or not necessary.
    local function migrate(version)
        if version < 20160610 then
            MySQLite.begin()
                if MySQLite.isMySQL() then
                    -- if only SQLite were this easy
                    MySQLite.queueQuery([[DROP INDEX rpname ON darkrp_player]])
                else
                    -- darkrp_player used to have a UNIQUE rpname field.
                    -- This sucks, get rid of it
                    MySQLite.queueQuery([[PRAGMA foreign_keys=OFF]])

                    MySQLite.queueQuery([[
                        CREATE TABLE IF NOT EXISTS new_darkrp_player(
                            uid BIGINT NOT NULL PRIMARY KEY,
                            rpname VARCHAR(45),
                            salary INTEGER NOT NULL DEFAULT 45,
                            wallet INTEGER NOT NULL
                        );
                    ]])

                    MySQLite.queueQuery([[INSERT INTO new_darkrp_player SELECT * FROM darkrp_player]])

                    MySQLite.queueQuery([[DROP TABLE darkrp_player]])

                    MySQLite.queueQuery([[ALTER TABLE new_darkrp_player RENAME TO darkrp_player]])

                    MySQLite.queueQuery([[PRAGMA foreign_keys=ON]])
                end
                MySQLite.queueQuery([[REPLACE INTO darkrp_dbversion VALUES(20160610)]])
            MySQLite.commit(fp{migrate, 20160610})
            return
        end

        if version < 20181013 then
            -- migrate from darkrp_jobown to darkrp_doorjobs
            MySQLite.tableExists("darkrp_jobown", function(exists)
                if not exists then migrate(20181013) return end

                MySQLite.begin()
                    -- Create a temporary table that links job IDs to job commands
                    MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS TempJobCommands(id INT NOT NULL PRIMARY KEY, cmd VARCHAR(255) NOT NULL);")
                    if MySQLite.isMySQL() then
                        local jobCommands = {}
                        for k, v in pairs(RPExtraTeams) do
                            table.insert(jobCommands, "(" .. k .. "," .. MySQLite.SQLStr(v.command) .. ")")
                        end

                        -- This WOULD work with SQLite if the implementation in GMod wasn't out of date.
                        MySQLite.queueQuery("INSERT IGNORE INTO TempJobCommands VALUES " .. table.concat(jobCommands, ",") .. ";")
                    else
                        for k, v in pairs(RPExtraTeams) do
                            MySQLite.queueQuery("INSERT INTO TempJobCommands VALUES(" .. k .. ", " .. MySQLite.SQLStr(v.command) .. ");")
                        end
                    end

                    MySQLite.queueQuery("REPLACE INTO darkrp_doorjobs SELECT darkrp_jobown.idx AS idx, darkrp_jobown.map AS map, TempJobCommands.cmd AS job FROM darkrp_jobown JOIN TempJobCommands ON darkrp_jobown.job = TempJobCommands.id;")

                    -- Clean up the transition table and the old table
                    MySQLite.queueQuery("DROP TABLE TempJobCommands;")
                    MySQLite.queueQuery("DROP TABLE darkrp_jobown;")
                    MySQLite.queueQuery([[REPLACE INTO darkrp_dbversion VALUES(20181013)]])
                MySQLite.commit(fp{migrate, 20181013})
            end)
            return
        end

        if version < 20181014 then
            MySQLite.query([[SELECT * FROM darkrp_jobspawn]], function(oldData)
                oldData = oldData or {}
                MySQLite.begin()

                MySQLite.queueQuery([[DROP TABLE darkrp_jobspawn]])

                MySQLite.queueQuery([[
                    CREATE TABLE darkrp_jobspawn(
                        id INTEGER NOT NULL PRIMARY KEY REFERENCES darkrp_position(id)
                            ON UPDATE CASCADE
                            ON DELETE CASCADE,

                        teamcmd VARCHAR(255) NOT NULL
                    );
                ]])

                for i, row in pairs(oldData) do
                    local teamcmd = (RPExtraTeams[tonumber(row.team)] or {}).command
                    if not teamcmd then continue end

                    MySQLite.queueQuery(string.format([[INSERT INTO darkrp_jobspawn(id, teamcmd) VALUES(%s, %s)]], row.id, MySQLite.SQLStr(teamcmd)))
                end

                MySQLite.queueQuery([[REPLACE INTO darkrp_dbversion VALUES(20181014)]])

                MySQLite.commit(fp{migrate, 20181014})
            end)
            return
        end

        if version < 20190914 then
            MySQLite.begin()
                -- Migration not necessary for SQLite, since BIGINT and
                -- INTEGER are considered the same in SQLite
                -- https://www.sqlite.org/datatype3.html
                if MySQLite.isMySQL() then
                    MySQLite.queueQuery([[DROP TRIGGER IF EXISTS JobPositionFKDelete]])
                    MySQLite.queueQuery([[ALTER TABLE darkrp_player MODIFY wallet BIGINT;]])
                end
                MySQLite.queueQuery([[REPLACE INTO darkrp_dbversion VALUES(20190914)]])
            MySQLite.commit(fp{migrate, 20190914})

            return
        end

        if version < 20211228 then
            MySQLite.begin()
                -- Migrate all tables to InnoDB if they weren't already.
                -- See https://github.com/FPtje/DarkRP/issues/3157
                if MySQLite.isMySQL() then
                    MySQLite.queueQuery([[ALTER TABLE darkrp_dbversion ENGINE = InnoDB;]])
                    MySQLite.queueQuery([[ALTER TABLE darkrp_door ENGINE = InnoDB;]])
                    MySQLite.queueQuery([[ALTER TABLE darkrp_doorgroups ENGINE = InnoDB;]])
                    MySQLite.queueQuery([[ALTER TABLE darkrp_doorjobs ENGINE = InnoDB;]])
                    MySQLite.queueQuery([[ALTER TABLE darkrp_jobspawn ENGINE = InnoDB;]])
                    MySQLite.queueQuery([[ALTER TABLE darkrp_player ENGINE = InnoDB;]])
                    MySQLite.queueQuery([[ALTER TABLE darkrp_position ENGINE = InnoDB;]])
                    MySQLite.queueQuery([[ALTER TABLE playerinformation ENGINE = InnoDB;]])
                end

                MySQLite.queueQuery([[REPLACE INTO darkrp_dbversion VALUES(20211228)]])
            MySQLite.commit(fp{migrate, 20211228})

            return
        end

        -- All migrations finished
        callback()
    end
    migrate(DarkRP.DBVersion)
end

--[[---------------------------------------------------------
Players
 ---------------------------------------------------------]]
function DarkRP.storeRPName(ply, name)
    if not name or string.len(name) < 2 then return end
    hook.Call("onPlayerChangedName", nil, ply, ply:getDarkRPVar("rpname"), name)
    ply:setDarkRPVar("rpname", name)

    MySQLite.query([[UPDATE darkrp_player SET rpname = ]] .. MySQLite.SQLStr(name) .. [[ WHERE UID = ]] .. ply:SteamID64() .. ";")
    MySQLite.query([[UPDATE darkrp_player SET rpname = ]] .. MySQLite.SQLStr(name) .. [[ WHERE UID = ]] .. ply:UniqueID() .. ";")
end

function DarkRP.retrieveRPNames(name, callback)
    MySQLite.query("SELECT COUNT(*) AS count FROM darkrp_player WHERE rpname = " .. MySQLite.SQLStr(name) .. ";", function(r)
        callback(tonumber(r[1].count) > 0)
    end)
end

function DarkRP.offlinePlayerData(steamid, callback, failed)
    local sid64 = util.SteamIDTo64(steamid)
    local uniqueid = util.CRC("gm_" .. string.upper(steamid) .. "_gm")

    MySQLite.query(string.format([[REPLACE INTO playerinformation VALUES(%s, %s);]], MySQLite.SQLStr(sid64), MySQLite.SQLStr(steamid)), nil, failed)

    local query = [[
    SELECT rpname, wallet, salary, "SID64" AS kind
    FROM darkrp_player
    where uid = %s

    UNION

    SELECT rpname, wallet, salary, "UniqueID" AS kind
    FROM darkrp_player
    where uid = %s
    ;
    ]]

    MySQLite.query(
        query:format(sid64, uniqueid),
        function(data, ...)
            -- The database has no record of the player data in SteamID64 form
            -- Otherwise the first row would have kind SID64
            if data and data[1] and data[1].kind == "UniqueID" then
                -- The rpname must be unique
                -- adding a new row with uid = SteamID64, but the same rpname will remove the uid=UniqueID row

                local replquery = [[
                REPLACE INTO darkrp_player(uid, rpname, wallet, salary)
                VALUES (%s, %s, %s, %s)
                ]]

                MySQLite.begin()
                MySQLite.queueQuery(
                    replquery:format(
                        sid64,
                        data[1].rpname == "NULL" and "NULL" or MySQLite.SQLStr(data[1].rpname),
                        data[1].wallet,
                        data[1].salary
                        ),
                    nil,
                    failed
                    )
                MySQLite.commit()
            end

            return callback and callback(data, ...)
        end
        , failed
        )
end

function DarkRP.retrievePlayerData(ply, callback, failed, attempts, err)
    attempts = attempts or 0

    if attempts > 3 then return failed(err) end

    DarkRP.offlinePlayerData(ply:SteamID(), callback, function(sqlErr)
        if not IsValid(ply) then return end

        DarkRP.retrievePlayerData(ply, callback, failed, attempts + 1, sqlErr)
    end)
end

function DarkRP.createPlayerData(ply, name, wallet, salary)
    MySQLite.query([[REPLACE INTO darkrp_player VALUES(]] ..
            ply:SteamID64() .. [[, ]] ..
            MySQLite.SQLStr(name)  .. [[, ]] ..
            salary  .. [[, ]] ..
            wallet .. ");")

    -- Backwards compatibility
    MySQLite.query([[REPLACE INTO darkrp_player VALUES(]] ..
            ply:UniqueID() .. [[, ]] ..
            MySQLite.SQLStr(name)  .. [[, ]] ..
            salary  .. [[, ]] ..
            wallet .. ");")
end

function DarkRP.storeMoney(ply, amount)
    if not isnumber(amount) or amount < 0 or amount >= 1 / 0 then
        DarkRP.errorNoHalt("Some addon attempted to store a invalid money amount " .. tostring(amount) .. " for Player " .. ply:Nick() .. " (" .. ply:SteamID() .. ")", 1, {
            "This money amount will not be stored in the database, but it may be set in the game.",
            "The database simply stores the last valid, non-negative amount of money.",
            "Please try to find the very first time this error happened for this player. Then look at the files mentioned in this error.",
            "That will tell you which addon is causing this.",
            "IMPORTANT: This is NOT a DarkRP bug!",
            "Note: The player can simply rejoin to fix their negative money, until whatever causes this happens again."
        })
        return
    end

    -- Also keep deprecated UniqueID data at least somewhat up to date
    MySQLite.query([[UPDATE darkrp_player SET wallet = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID() .. [[ OR uid = ]] .. ply:SteamID64())
end

function DarkRP.storeOfflineMoney(sid64, amount)
    if isnumber(sid64) or isstring(sid64) and string.len(sid64) < 17 then -- smaller than 76561197960265728 is not a SteamID64
        DarkRP.errorNoHalt([[Some addon is giving DarkRP.storeOfflineMoney a UniqueID as its first argument, but this function now expects a SteamID64]], 1, {
            "The function used to take UniqueIDs, but it does not anymore.",
            "If you are a server owner, please look closely to the files mentioned in this error",
            "After all, these files will tell you WHICH addon is doing it",
            "This is NOT a DarkRP bug!",
            "Your server will continue working normally",
            "But whichever addon just tried to store an offline player's money",
            "Will NOT take effect!"
        })
    end

    if not isnumber(amount) or amount < 0 or amount >= 1 / 0 then
        DarkRP.errorNoHalt("Some addon attempted to store a invalid money amount " .. tostring(amount) .. " for an offline player with steamID64 " .. sid64, 1, {
            "This money amount will not be stored in the database.",
            "Please try to find the very first time this error happened for this player. Then look at the files mentioned in this error.",
            "That will tell you which addon is causing this.",
            "IMPORTANT: This is NOT a DarkRP bug!"
        })
        return
    end

    -- Also store on deprecated UniqueID
    local uniqueid = util.CRC("gm_" .. string.upper(util.SteamIDFrom64(sid64)) .. "_gm")
    MySQLite.query([[UPDATE darkrp_player SET wallet = ]] .. amount .. [[ WHERE uid = ]] .. uniqueid .. [[ OR uid = ]] .. sid64)
end

local function resetAllMoney(ply, cmd, args)
    if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then return end
    MySQLite.query("UPDATE darkrp_player SET wallet = " .. GAMEMODE.Config.startingmoney .. " ;")
    for _, v in ipairs(player.GetAll()) do
        v:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
    end
    if ply:IsPlayer() then
        DarkRP.notifyAll(0, 4, DarkRP.getPhrase("reset_money", ply:Nick()))
    else
        DarkRP.notifyAll(0, 4, DarkRP.getPhrase("reset_money", "Console"))
    end
end
concommand.Add("rp_resetallmoney", resetAllMoney)

function DarkRP.storeSalary(ply, amount)
    ply:setSelfDarkRPVar("salary", math.floor(amount))

    return amount
end

function DarkRP.retrieveSalary(ply, callback)
    local val =
        ply:getJobTable() and ply:getJobTable().salary or
        RPExtraTeams[GAMEMODE.DefaultTeam].salary or
        (GM or GAMEMODE).Config.normalsalary

    if callback then callback(val) end

    return val
end

--[[---------------------------------------------------------------------------
Players
---------------------------------------------------------------------------]]
local meta = FindMetaTable("Player")
function meta:restorePlayerData()
    self.DarkRPUnInitialized = true

    DarkRP.retrievePlayerData(self, function(data)
        if not IsValid(self) then return end

        self.DarkRPUnInitialized = nil

        local info = data and data[1] or {}
        if not info.rpname or info.rpname == "NULL" then info.rpname = string.gsub(self:SteamName(), "\\\"", "\"") end

        info.wallet = info.wallet or GAMEMODE.Config.startingmoney
        info.salary = DarkRP.retrieveSalary(self)

        self:setDarkRPVar("money", tonumber(info.wallet))
        self:setSelfDarkRPVar("salary", tonumber(info.salary))

        self:setDarkRPVar("rpname", info.rpname)

        if not data then
            info = hook.Call("onPlayerFirstJoined", nil, self, info) or info
            DarkRP.createPlayerData(self, info.rpname, info.wallet, info.salary)
        end
    end, function(err) -- Retrieving data failed, go on without it
        if not IsValid(self) then return end
        self.DarkRPUnInitialized = true -- no information should be saved from here, or the playerdata might be reset

        self:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
        self:setSelfDarkRPVar("salary", DarkRP.retrieveSalary(self))
        local name = string.gsub(self:SteamName(), "\\\"", "\"")
        self:setDarkRPVar("rpname", name)

        self.DarkRPDataRetrievalFailed = true -- marker on the player that says shit is fucked
        DarkRP.error("Failed to retrieve player information from the database. ", nil, {"This means your database or the connection to your database is fucked.", "This is the error given by the database:\n\t\t" .. tostring(err)})
    end)
end

--[[---------------------------------------------------------
 Doors
 ---------------------------------------------------------]]
function DarkRP.storeDoorData(ent)
    if not ent:CreatedByMap() then return end
    local map = string.lower(game.GetMap())
    local nonOwnable = ent:getKeysNonOwnable()
    local title = ent:getKeysTitle()

    MySQLite.query([[REPLACE INTO darkrp_door VALUES(]] .. ent:doorIndex() .. [[, ]] .. MySQLite.SQLStr(map) .. [[, ]] .. (title and MySQLite.SQLStr(title) or "NULL") .. [[, ]] .. "NULL" .. [[, ]] .. (nonOwnable and 1 or 0) .. [[);]])
end

function setUpNonOwnableDoors()
    MySQLite.query("SELECT idx, title, isLocked, isDisabled FROM darkrp_door WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
        if not r then return end

        for _, row in pairs(r) do
            local e = DarkRP.doorIndexToEnt(tonumber(row.idx))

            if not IsValid(e) then continue end
            if e:isKeysOwnable() then
                if tobool(row.isDisabled) then
                    e:setKeysNonOwnable(tobool(row.isDisabled))
                end
                if row.isLocked and row.isLocked ~= "NULL" then
                    e:Fire((tobool(row.isLocked) and "" or "un") .. "lock", "", 0)
                end
                e:setKeysTitle(row.title ~= "NULL" and row.title or nil)
            end
        end
    end)
end

local keyValueActions = {
    ["DarkRPNonOwnable"] = function(ent, val) ent:setKeysNonOwnable(tobool(val)) end,
    ["DarkRPTitle"]      = function(ent, val) ent:setKeysTitle(val) end,
    ["DarkRPDoorGroup"]  = function(ent, val) if RPExtraTeamDoors[val] then ent:setDoorGroup(val) end end,
    ["DarkRPCanLockpick"] = function(ent, val) ent.DarkRPCanLockpick = tobool(val) end
}

local function onKeyValue(ent, key, value)
    if not ent:isDoor() then return end

    if keyValueActions[key] then
        keyValueActions[key](ent, value)
    end
end
hook.Add("EntityKeyValue", "darkrp_doors", onKeyValue)

function DarkRP.storeTeamDoorOwnability(ent)
    if not ent:CreatedByMap() then return end
    local map = string.lower(game.GetMap())

    MySQLite.query("DELETE FROM darkrp_doorjobs WHERE idx = " .. ent:doorIndex() .. " AND map = " .. MySQLite.SQLStr(map) .. ";")
    for k in pairs(ent:getKeysDoorTeams() or {}) do
        MySQLite.query("INSERT INTO darkrp_doorjobs VALUES(" .. ent:doorIndex() .. ", " .. MySQLite.SQLStr(map) .. ", " .. MySQLite.SQLStr(RPExtraTeams[k].command) .. ");")
    end
end

function setUpTeamOwnableDoors()
    MySQLite.query("SELECT idx, job FROM darkrp_doorjobs WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";", function(r)
        if not r then return end
        local map = string.lower(game.GetMap())

        for _, row in pairs(r) do
            row.idx = tonumber(row.idx)

            local e = DarkRP.doorIndexToEnt(row.idx)
            if not IsValid(e) then continue end

            local _, job = DarkRP.getJobByCommand(row.job)

            if job then
                e:addKeysDoorTeam(job)
            else
                print(("can't find job %s for door %d, removing from database"):format(row.job, row.idx))
                MySQLite.query(("DELETE FROM darkrp_doorjobs WHERE idx = %d AND map = %s AND job = %s;"):format(row.idx, MySQLite.SQLStr(map), MySQLite.SQLStr(row.job)))
            end
        end
    end)
end

function DarkRP.storeDoorGroup(ent, group)
    if not ent:CreatedByMap() then return end
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
            local ent = DarkRP.doorIndexToEnt(tonumber(row.idx))

            if not IsValid(ent) or not ent:isKeysOwnable() then
                continue
            end

            if not RPExtraTeamDoorIDs[row.doorgroup] then continue end
            ent:setDoorGroup(row.doorgroup)
        end
    end)
end

hook.Add("PostCleanupMap", "DarkRP.hooks", function()
    setUpNonOwnableDoors()
    setUpTeamOwnableDoors()
    setUpGroupDoors()
end)
