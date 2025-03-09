--[[
    MySQLite - Abstraction mechanism for SQLite and MySQL

    Why use this?
        - Easy to use interface for MySQL
        - No need to modify code when switching between SQLite and MySQL
        - Queued queries: execute a bunch of queries in order an run the callback when all queries are done

    License: LGPL V2.1 (read here: https://www.gnu.org/licenses/lgpl-2.1.html)

    Supported MySQL modules:
    - MySQLOO
    - tmysql4

    Note: When both MySQLOO and tmysql4 modules are installed, MySQLOO is used by default.

    /*---------------------------------------------------------------------------
    Documentation
    ---------------------------------------------------------------------------*/

    MySQLite.initialize([config :: table]) :: No value
        Initialize MySQLite. Loads the config from either the config parameter OR the MySQLite_config global.
        This loads the module (if necessary) and connects to the MySQL database (if set up).
        The config must have this layout:
            {
                EnableMySQL      :: Bool   - set to true to use MySQL, false for SQLite
                Host             :: String - database hostname
                Username         :: String - database username
                Password         :: String - database password (keep away from clients!)
                Database_name    :: String - name of the database
                Database_port    :: Number - connection port (3306 by default)
                Preferred_module :: String - Preferred module, case sensitive, must be either "mysqloo" or "tmysql4"
                MultiStatements  :: Bool   - Only available in tmysql4: allow multiple SQL statements per query
            }

    ----------------------------- Utility functions -----------------------------
    MySQLite.isMySQL() :: Bool
        Returns whether MySQLite is set up to use MySQL. True for MySQL, false for SQLite.
        Use this when the query syntax between SQLite and MySQL differs (example: AUTOINCREMENT vs AUTO_INCREMENT)

    MySQLite.SQLStr(str :: String) :: String
        Escapes the string and puts it in quotes.
        It uses the escaping method of the module that is currently being used.

    MySQLite.tableExists(tbl :: String, callback :: function, errorCallback :: function)
        Checks whether table tbl exists.

        callback format: function(res :: Bool)
            res is a boolean indicating whether the table exists.

        The errorCallback format is the same as in MySQLite.query.

    ----------------------------- Running queries -----------------------------
    MySQLite.query(sqlText :: String, callback :: function, errorCallback :: function) :: No value
        Runs a query. Calls the callback parameter when finished, calls errorCallback when an error occurs.

        callback format:
            function(result :: table, lastInsert :: number)
            Result is the table with results (nil when there are no results or when the result list is empty)
            lastInsert is the row number of the last inserted value (use with AUTOINCREMENT)

            Note: lastInsert is NOT supported when using SQLite.

        errorCallback format:
            function(error :: String, query :: String) :: Bool
            error is the error given by the database module.
            query is the query that triggered the error.

            Return true to suppress the error!

    MySQLite.queryValue(sqlText :: String, callback :: function, errorCallback :: function) :: No value
        Runs a query and returns the first value it comes across.

        callback format:
            function(result :: any)
                where the result is either a string or a number, depending on the requested database field.

        The errorCallback format is the same as in MySQLite.query.

    MySQLite.prepare(sqlText :: String, sqlParams :: Table, callback :: function, errorCallback :: function)
        Calls a prepared statement, faster for queries that are ran multiple times. Params do not need to be escaped.
        This does not work with SQLite, and will instead call a regular query

        callback format:
            function(result :: table, lastInsert :: number, rowsChanged :: number)
            Result is the table with results (nil when there are no results or when the result list is empty)
            lastInsert is the row number of the last inserted value (use with AUTOINCREMENT)
            rowsChanged is the amount of rows that were changed with the query

            Note: lastInsert is NOT supported when using SQLite.

        The errorCallback format is the same as in MySQLite.query.

        Example:
            MySQLite.prepare("UPDATE `darkrp_player` SET `rpname` = ? WHERE  `rpname` = ?", { "players_old_name", "players_new_name"}, success_callback, error_callback)

    ----------------------------- Transactions -----------------------------
    MySQLite.begin() :: No value
        Starts a transaction. Use in combination with MySQLite.queueQuery and MySQLite.commit.

    MySQLite.queueQuery(sqlText :: String, callback :: function, errorCallback :: function) :: No value
        Queues a query in the transaction. Note: a transaction must be started with MySQLite.begin() for this to work.
        The callback will be called when this specific query has been executed successfully.
        The errorCallback function will be called when an error occurs in this specific query.

        See MySQLite.query for the callback and errorCallback format.

    MySQLite.commit(onFinished)
        Commits a transaction and calls onFinished when EVERY queued query has finished.
        onFinished is NOT called when an error occurs in one of the queued queries.

        onFinished is called without arguments.

    ----------------------------- Hooks -----------------------------
    DatabaseInitialized
        Called when a successful connection to the database has been made.
]]

local debug = debug
local error = error
local ErrorNoHalt = ErrorNoHalt
local hook = hook
local pairs = pairs
local require = require
local sql = sql
local string = string
local table = table
local timer = timer
local tostring = tostring
local mysqlOO
local TMySQL
local _G = _G
local ipairs = ipairs
local type = type
local unpack = unpack

local multistatements

local MySQLite_config = MySQLite_config or RP_MySQLConfig or FPP_MySQLConfig
local moduleLoaded

local function loadMySQLModule()
    if moduleLoaded or not MySQLite_config or not MySQLite_config.EnableMySQL then return end

    local moo, tmsql = util.IsBinaryModuleInstalled("mysqloo"), util.IsBinaryModuleInstalled("tmysql4")

    if not moo and not tmsql then
        error("Could not find a suitable MySQL module. Please either:\n  - Install tmysql. It can be obtained from https://github.com/SuperiorServers/gm_tmysql4\n  - Install MySQLOO. It can be obtained from https://github.com/FredyH/MySQLOO\nDue to this error, MySQL is disabled. This means that SQLite is used instead to store data.")
    end
    moduleLoaded = true

    require(
        moo and tmsql and MySQLite_config.Preferred_module or
        moo and "mysqloo" or
        tmsql and "tmysql4"
    )

    multistatements = CLIENT_MULTI_STATEMENTS

    mysqlOO = mysqloo
    TMySQL = tmysql

    if MySQLite_config.Preferred_module == "tmysql4" then
        if not tmsql then
            ErrorNoHalt("The preferred module for MySQL is selected to be tmysql4. However, tmysql4 does not appear to be installed. Please either:\n  - Install tmysql. It can be obtained from https://github.com/SuperiorServers/gm_tmysql4\n  - Select MySQLOO as the preferred module for MySQL. MySQLOO appears to be installed.")
            return
        end

        if not tmysql.Version or tmysql.Version < 4.1 then
            MsgC(Color(255, 0, 0), "Using older tmysql version, please consider updating!\n")
            MsgC(Color(255, 0, 0), "Newer Version: https://github.com/SuperiorServers/gm_tmysql4\n")
        end

        -- Turns tmysql.Connect into tmysql.Initialize if they're using an older version.
        TMySQL.Connect = tmysql.Version and tmysql.Version >= 4.1 and TMySQL.Connect or TMySQL.initialize
        TMySQL.SetOption = tmysql.Version and tmysql.Version >= 4.1 and TMySQL.SetOption or TMySQL.Option
    else
        if not moo then
            ErrorNoHalt("The preferred module for MySQL is selected to be MySQLOO. However, MySQLOO does not appear to be installed. Please either:\n  - Install MySQLOO. It can be obtained from https://github.com/FredyH/MySQLOO\n  - Select tmysql4 as the preferred module for MySQL. tmysql4 appears to be installed.")
        end
    end
end
loadMySQLModule()

module("MySQLite")

-- Helper function to return the first value found when iterating over a table.
-- Replaces the now deprecated table.GetFirstValue
local function arbitraryTableValue(tbl)
    for _, v in pairs(tbl) do return v end
end

function initialize(config)
    MySQLite_config = config or MySQLite_config

    if not MySQLite_config then
        ErrorNoHalt("Warning: No MySQL config!")
    end

    loadMySQLModule()

    if MySQLite_config.EnableMySQL then
        connectToMySQL(MySQLite_config.Host, MySQLite_config.Username, MySQLite_config.Password, MySQLite_config.Database_name, MySQLite_config.Database_port)
    else
        timer.Simple(0, function()
            _G.GAMEMODE.DatabaseInitialized = _G.GAMEMODE.DatabaseInitialized or function() end
            hook.Call("DatabaseInitialized", _G.GAMEMODE)
        end)
    end
end

local CONNECTED_TO_MYSQL = false
local msOOConnect
databaseObject = nil

local queuedQueries
local cachedQueries

function isMySQL()
    return CONNECTED_TO_MYSQL
end

function begin()
    if not CONNECTED_TO_MYSQL then
        sql.Begin()
    else
        if queuedQueries then
            debug.Trace()
            error("Transaction ongoing!")
        end
        queuedQueries = {}
    end
end

function commit(onFinished)
    if not CONNECTED_TO_MYSQL then
        sql.Commit()
        if onFinished then onFinished() end
        return
    end

    if not queuedQueries then
        error("No queued queries! Call begin() first!")
    end

    if #queuedQueries == 0 then
        queuedQueries = nil
        if onFinished then onFinished() end
        return
    end

    -- Copy the table so other scripts can create their own queue
    local queue = table.Copy(queuedQueries)
    queuedQueries = nil

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
        query(nextQuery.query, call, nextQuery.onError)
    end

    query(queue[1].query, call, queue[1].onError)
end

function queueQuery(sqlText, callback, errorCallback)
    if CONNECTED_TO_MYSQL then
        table.insert(queuedQueries, {query = sqlText, callback = callback, onError = errorCallback})
        return
    end
    -- SQLite is instantaneous, simply running the query is equal to queueing it
    query(sqlText, callback, errorCallback)
end

local function msOOQuery(sqlText, callback, errorCallback, queryValue)
    local queryObject = databaseObject:query(sqlText)
    local data
    queryObject.onData = function(Q, D)
        data = data or {}
        data[#data + 1] = D
    end

    queryObject.onError = function(Q, E)
        if databaseObject:status() == mysqlOO.DATABASE_NOT_CONNECTED then
            table.insert(cachedQueries, {sqlText, callback, queryValue})

            -- Immediately try reconnecting
            msOOConnect(MySQLite_config.Host, MySQLite_config.Username, MySQLite_config.Password, MySQLite_config.Database_name, MySQLite_config.Database_port)
            return
        end

        local supp = errorCallback and errorCallback(E, sqlText)
        if not supp then error(E .. " (" .. sqlText .. ")") end
    end

    queryObject.onSuccess = function()
        local res = queryValue and data and data[1] and arbitraryTableValue(data[1]) or not queryValue and data or nil
        if callback then callback(res, queryObject:lastInsert()) end
    end
    queryObject:start()
end

local preparedStatements = {}
local paramTypes = {}
paramTypes["number"] = function(queryObj, paramIndex, paramValue) return queryObj:setNumber(paramIndex, paramValue) end
paramTypes["string"] = function(queryObj, paramIndex, paramValue) return queryObj:setString(paramIndex, paramValue) end
paramTypes["boolean"] = function(queryObj, paramIndex, paramValue) return queryObj:setBoolean(paramIndex, paramValue) end

local function msOOPrepare(sqlText, sqlParams, callback, errorCallback)
    local queryObject

    if preparedStatements[sqlText] then
        queryObject = preparedStatements[sqlText]
    else
        queryObject = databaseObject:prepare(sqlText)
        preparedStatements[sqlText] = queryObject
    end

    for i, param in ipairs(sqlParams) do
        local paramType = type(param)

        if paramTypes[paramType] then
            paramTypes[paramType](queryObject, i, param)
        else
            queryObject:setString(i, param)
        end
    end

    queryObject.onError = function(_, E)
        local supp = errorCallback and errorCallback(E, sqlText)
        if not supp then error(E .. " (" .. sqlText .. ")") end
    end

    queryObject.onSuccess = function(_, data)
        if callback then callback(data, queryObject:lastInsert(), queryObject:affectedRows()) end
    end

    queryObject:start()
end

local function tmsqlPrepare(sqlText, sqlParams, callback, errorCallback)
    local queryObject

    if preparedStatements[sqlText] then
        queryObject = preparedStatements[sqlText]
    else
        queryObject = databaseObject:Prepare(sqlText)
        preparedStatements[sqlText] = queryObject
    end

    for i, param in ipairs(sqlParams) do
        param = SQLStr(param, true)
    end

    local varcount = queryObject:GetArgCount()

    sqlParams[varcount + 1] = function(results)
        if results[1].error ~= nil then
            local supp = errorCallback and errorCallback(E, results[1].error)
            if not supp then error(E .. " (" .. results[1].error .. ")") end
        end

        if callback then callback(data, results[1].lastid, results[1].affected) end
    end

    queryObject:Run(unpack(sqlParams, 1, varcount + 2))
end

local function tmsqlQuery(sqlText, callback, errorCallback, queryValue)
    local call = function(res)
        res = res[1] -- For now only support one result set
        if not res.status then
            local supp = errorCallback and errorCallback(res.error, sqlText)
            if not supp then error(res.error .. " (" .. sqlText .. ")") end
            return
        end

        if not res.data or #res.data == 0 then res.data = nil end -- compatibility with other backends
        if queryValue and callback then return callback(res.data and res.data[1] and arbitraryTableValue(res.data[1]) or nil) end
        if callback then callback(res.data, res.lastid) end
    end

    databaseObject:Query(sqlText, call)
end

local function SQLiteQuery(sqlText, callback, errorCallback, queryValue)
    sql.m_strError = "" -- reset last error

    local lastError = sql.LastError()
    local Result = queryValue and sql.QueryValue(sqlText) or sql.Query(sqlText)

    if sql.LastError() and sql.LastError() ~= lastError then
        local err = sql.LastError()
        local supp = errorCallback and errorCallback(err, sqlText)
        if supp == false then error(err .. " (" .. sqlText .. ")", 2) end
        return
    end

    if callback then callback(Result) end
    return Result
end

-- SQLite doesn't support preparedStatements, so convert it to a regular query.
local function SQLitePrepare(sqlText, sqlParams, callback, errorCallback)
    for _, param in ipairs(sqlParams) do
        sqlText = sqlText:gsub("%?", sql.SQLStr(param), 1)
    end

    return SQLiteQuery(sqlText, callback, errorCallback, false)
end

function query(sqlText, callback, errorCallback)
    local qFunc = (CONNECTED_TO_MYSQL and ((mysqlOO and msOOQuery) or (TMySQL and tmsqlQuery))) or SQLiteQuery
    return qFunc(sqlText, callback, errorCallback, false)
end

function queryValue(sqlText, callback, errorCallback)
    local qFunc = (CONNECTED_TO_MYSQL and ((mysqlOO and msOOQuery) or (TMySQL and tmsqlQuery))) or SQLiteQuery
    return qFunc(sqlText, callback, errorCallback, true)
end

function prepare(sqlText, sqlParams, callback, errorCallback)
    local qFunc = (CONNECTED_TO_MYSQL and ((mysqlOO and msOOPrepare) or (TMySQL and tmsqlPrepare))) or SQLitePrepare
    return qFunc(sqlText, sqlParams, callback, errorCallback, false)
end

local function onConnected()
    CONNECTED_TO_MYSQL = true

    -- Run the queries that were called before the connection was made
    for k, v in pairs(cachedQueries or {}) do
        cachedQueries[k] = nil
        if v[3] then
            queryValue(v[1], v[2])
        else
            query(v[1], v[2])
        end
    end
    cachedQueries = {}
    local GM = _G.GAMEMODE or _G.GM

    hook.Call("DatabaseInitialized", GM.DatabaseInitialized and GM or nil)

end

msOOConnect = function(host, username, password, database_name, database_port)
    databaseObject = mysqlOO.connect(host, username, password, database_name, database_port)

    if timer.Exists("darkrp_check_mysql_status") then timer.Remove("darkrp_check_mysql_status") end

    databaseObject.onConnectionFailed = function(_, msg)
        timer.Simple(5, function()
            msOOConnect(MySQLite_config.Host, MySQLite_config.Username, MySQLite_config.Password, MySQLite_config.Database_name, MySQLite_config.Database_port)
        end)
        error("Connection failed! " .. tostring(msg) ..  "\nTrying again in 5 seconds.")
    end

    databaseObject.onConnected = onConnected

    databaseObject:connect()
end

local function tmsqlConnect(host, username, password, database_name, database_port)
    local db, err = TMySQL.Connect(host, username, password, database_name, database_port, nil, MySQLite_config.MultiStatements and multistatements or nil)
    if err then error("Connection failed! " .. err ..  "\n") end

    databaseObject = db
    onConnected()

    if (TMySQL.Version and TMySQL.Version >= 4.1) then
        hook.Add("Think", "MySQLite:tmysqlPoll", function()
            db:Poll()
        end)
    end
end

function connectToMySQL(host, username, password, database_name, database_port)
    database_port = database_port or 3306
    local func = mysqlOO and msOOConnect or TMySQL and tmsqlConnect or function() end
    func(host, username, password, database_name, database_port)
end

function SQLStr(sqlStr)
    local escape =
        not CONNECTED_TO_MYSQL and sql.SQLStr or
        mysqlOO                and function(str) return "\"" .. databaseObject:escape(tostring(str)) .. "\"" end or
        TMySQL                 and function(str) return "\"" .. databaseObject:Escape(tostring(str)) .. "\"" end

    return escape(sqlStr)
end

function tableExists(tbl, callback, errorCallback)
    if not CONNECTED_TO_MYSQL then
        local exists = sql.TableExists(tbl)
        callback(exists)

        return exists
    end

    queryValue(string.format("SHOW TABLES LIKE %s", SQLStr(tbl)), function(v)
        callback(v ~= nil)
    end, errorCallback)
end
