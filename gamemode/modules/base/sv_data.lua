/*---------------------------------------------------------------------------
Functions and variables
---------------------------------------------------------------------------*/
local setUpNonOwnableDoors,
    setUpTeamOwnableDoors,
    setUpGroupDoors,
    migrateDB

/*---------------------------------------------------------
 Database initialize
 ---------------------------------------------------------*/
function DarkRP.initDatabase()
    local map = MySQLite.SQLStr(string.lower(game.GetMap()))
    MySQLite.begin()
        -- Gotta love the difference between SQLite and MySQL
        local AUTOINCREMENT = MySQLite.isMySQL() and "AUTO_INCREMENT" or "AUTOINCREMENT"

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
            );
        ]])

        -- team spawns require extra data
        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS darkrp_jobspawn(
                id INTEGER NOT NULL PRIMARY KEY,
                team INTEGER NOT NULL
            );
        ]])

        if MySQLite.isMySQL() then
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
            CREATE TABLE IF NOT EXISTS darkrp_doorjobs(
                idx INTEGER NOT NULL,
                map VARCHAR(45) NOT NULL,
                job VARCHAR(255) NOT NULL,

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

        MySQLite.queueQuery([[
            CREATE TABLE IF NOT EXISTS darkrp_dbversion(version INTEGER NOT NULL PRIMARY KEY)
        ]])

        -- Load the last DBVersion into DarkRP.DBVersion, to allow checks to see whether migration is needed.
        MySQLite.queueQuery([[
            SELECT MAX(version) AS version FROM darkrp_dbversion
        ]], function(data) DarkRP.DBVersion = data and data[1] and tonumber(data[1].version) or 0 end)

        MySQLite.queueQuery([[
            REPLACE INTO darkrp_dbversion VALUES(20150725)
        ]])

        -- SQlite doesn't really handle foreign keys strictly, neither does MySQL by default
        -- So to keep the DB clean, here's a manual partial foreign key enforcement
        -- For now it's deletion only, since updating of the common attribute doesn't happen.

        -- MySQL trigger
        if MySQLite.isMySQL() then
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
    MySQLite.commit(fp{migrateDB, -- Migrate the database
        function() -- Initialize the data after all the tables have been created
            setUpNonOwnableDoors()
            setUpTeamOwnableDoors()
            setUpGroupDoors()

            if MySQLite.isMySQL() then -- In a listen server, the connection with the external database is often made AFTER the listen server host has joined,
                                        --so he walks around with the settings from the SQLite database
                for k,v in pairs(player.GetAll()) do
                    local UniqueID = MySQLite.SQLStr(v:UniqueID())
                    MySQLite.query([[SELECT * FROM darkrp_player WHERE uid = ]] .. UniqueID .. [[;]], function(data)
                        if not data or not data[1] then return end

                        local Data = data[1]
                        v:setDarkRPVar("rpname", Data.rpname)
                        v:setSelfDarkRPVar("salary", Data.salary)
                        v:setDarkRPVar("money", Data.wallet)
                    end)
                end
            end

            hook.Call("DarkRPDBInitialized")
        end})
end

/*---------------------------------------------------------------------------
Database migration
backwards compatibility with older versions of DarkRP
---------------------------------------------------------------------------*/
function migrateDB(callback)
    -- migrte from darkrp_jobown to darkrp_doorjobs
    MySQLite.tableExists("darkrp_jobown", function(exists)
        if not exists then return callback() end

        MySQLite.begin()
            -- Create a temporary table that links job IDs to job commands
            MySQLite.queueQuery("CREATE TABLE IF NOT EXISTS TempJobCommands(id INT NOT NULL PRIMARY KEY, cmd VARCHAR(255) NOT NULL);")
            if MySQLite.isMySQL() then
                local jobCommands = {}
                for k,v in pairs(RPExtraTeams) do
                    table.insert(jobCommands, "(" .. k .. "," .. MySQLite.SQLStr(v.command) .. ")")
                end

                -- This WOULD work with SQLite if the implementation in GMod wasn't out of date.
                MySQLite.queueQuery("INSERT IGNORE INTO TempJobCommands VALUES " .. table.concat(jobCommands, ",") .. ";")
            else
                for k,v in pairs(RPExtraTeams) do
                    MySQLite.queueQuery("INSERT INTO TempJobCommands VALUES(" .. k .. ", " .. MySQLite.SQLStr(v.command) .. ");")
                end
            end

            MySQLite.queueQuery("REPLACE INTO darkrp_doorjobs SELECT darkrp_jobown.idx AS idx, darkrp_jobown.map AS map, TempJobCommands.cmd AS job FROM darkrp_jobown JOIN TempJobCommands ON darkrp_jobown.job = TempJobCommands.id;")

            -- Clean up the transition table and the old table
            MySQLite.queueQuery("DROP TABLE TempJobCommands;")
            MySQLite.queueQuery("DROP TABLE darkrp_jobown;")
        MySQLite.commit(callback) -- callback
    end)
end

/*---------------------------------------------------------
Players
 ---------------------------------------------------------*/
function DarkRP.storeRPName(ply, name)
    if not name or string.len(name) < 2 then return end
    hook.Call("onPlayerChangedName", nil, ply, ply:getDarkRPVar("rpname"), name)
    ply:setDarkRPVar("rpname", name)

    MySQLite.query([[UPDATE darkrp_player SET rpname = ]] .. MySQLite.SQLStr(name) .. [[ WHERE UID = ]] .. ply:UniqueID() .. ";")
end

function DarkRP.retrieveRPNames(name, callback)
    MySQLite.query("SELECT COUNT(*) AS count FROM darkrp_player WHERE rpname = " .. MySQLite.SQLStr(name) .. ";", function(r)
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
    if not isnumber(amount) or amount < 0 or amount >= 1 / 0 then return end

    MySQLite.query([[UPDATE darkrp_player SET wallet = ]] .. amount .. [[ WHERE uid = ]] .. ply:UniqueID())
end

local function resetAllMoney(ply,cmd,args)
    if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then return end
    MySQLite.query("UPDATE darkrp_player SET wallet = " .. GAMEMODE.Config.startingmoney .. " ;")
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
        self:setSelfDarkRPVar("salary", tonumber(info.salary))

        self:setDarkRPVar("rpname", info.rpname)

        if not data then
            DarkRP.createPlayerData(self, info.rpname, info.wallet, info.salary)
        end
    end, function() -- Retrieving data failed, go on without it
        self.DarkRPUnInitialized = true -- no information should be saved from here, or the playerdata might be reset

        self:setDarkRPVar("money", GAMEMODE.Config.startingmoney)
        self:setSelfDarkRPVar("salary", GAMEMODE.Config.normalsalary)
        self:setDarkRPVar("rpname", string.gsub(self:SteamName(), "\\\"", "\""))

        error("Failed to retrieve player information from MySQL server")
    end)
end

/*---------------------------------------------------------
 Doors
 ---------------------------------------------------------*/
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

            if IsValid(e) and e:isKeysOwnable() then
                e:setKeysNonOwnable(tobool(row.isDisabled))
                if row.isLocked ~= nil then
                    if row.isLocked ~= "NULL" then e:Fire((tobool(row.isLocked) and "" or "un") .. "lock", "", 0) end
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
    for k,v in pairs(ent:getKeysDoorTeams() or {}) do
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

            ent:setDoorGroup(row.doorgroup)
        end
    end)
end

hook.Add("PostCleanupMap", "DarkRP.hooks", function()
    timer.Simple(0.3, function() --Hahahhah, Gmod
        setUpNonOwnableDoors()
        setUpTeamOwnableDoors()
        setUpGroupDoors()
    end)
end)
