local debug = debug
local error = error
local Error = Error
local ErrorNoHalt = ErrorNoHalt
local hook = hook
local include = include
local pairs = pairs
local require = require
local sql = sql
local table = table
local timer = timer
local tostring = tostring
local print = print
local GAMEMODE = GM
local mysqlOO

local RP_MySQLConfig = RP_MySQLConfig
if RP_MySQLConfig.EnableMySQL then
	require("mysqloo")
	mysqlOO = mysqloo
end

module("MySQLite")

function initialize()
	if RP_MySQLConfig.EnableMySQL then
		timer.Simple(1, function()
			connectToMySQL(RP_MySQLConfig.Host, RP_MySQLConfig.Username, RP_MySQLConfig.Password, RP_MySQLConfig.Database_name, RP_MySQLConfig.Database_port)
		end)
	else
		timer.Simple(0, function()
			GAMEMODE.DatabaseInitialized = GAMEMODE.DatabaseInitialized or function() end
			hook.Call("DatabaseInitialized", GAMEMODE)
		end)
	end
end

CONNECTED_TO_MYSQL = false
databaseObject = nil


local queuedQueries

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
	end
	-- SQLite is instantaneous, simply running the query is equal to queueing it
	query(sqlText, callback, errorCallback)
end

function query(sqlText, callback, errorCallback)
	if CONNECTED_TO_MYSQL then
		local query = databaseObject:query(sqlText)
		local data
		query.onData = function(Q, D)
			data = data or {}
			data[#data + 1] = D
		end

		query.onError = function(Q, E)
			if (databaseObject:status() == mysqlOO.DATABASE_NOT_CONNECTED) then
				table.insert(cachedQueries, {sqlText, callback, false})
				return
			end

			if errorCallback then
				errorCallback()
			end

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

function queryValue(sqlText, callback, errorCallback)
	if CONNECTED_TO_MYSQL then
		local query = databaseObject:query(sqlText)
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
			if (databaseObject:status() == mysqlOO.DATABASE_NOT_CONNECTED) then
				table.insert(cachedQueries, {sqlText, callback, true})
				return
			end

			if errorCallback then
				errorCallback()
			end

			ErrorNoHalt(E .. " (" .. sqlText .. ")\n")
		end

		query:start()
		return
	end

	local lastError = sql.LastError()
	local val = sql.QueryValue(sqlText)
	if sql.LastError() and sql.LastError() ~= lastError then
		error("SQLite error: " .. sql.LastError())
	end

	if callback then callback(val) end
	return val
end

function connectToMySQL(host, username, password, database_name, database_port)
	if not mysqlOO then Error("MySQL modules aren't installed properly!") end
	databaseObject = mysqlOO.connect(host, username, password, database_name, database_port)

	if timer.Exists("darkrp_check_mysql_status") then timer.Destroy("darkrp_check_mysql_status") end

	databaseObject.onConnectionFailed = function(_, msg)
		Error("Connection failed! " ..tostring(msg))
	end

	databaseObject.onConnected = function()
		CONNECTED_TO_MYSQL = true
		if cachedQueries then
			for _, v in pairs(cachedQueries) do
				if v[3] then
					queryValue(v[1], v[2])
				else
					query(v[1], v[2])
				end
			end
		end
		cachedQueries = {}

		timer.Create("darkrp_check_mysql_status", 60, 0, function()
			if (databaseObject and databaseObject:status() == mysqlOO.DATABASE_NOT_CONNECTED) then
				connectToMySQL(RP_MySQLConfig.Host, RP_MySQLConfig.Username, RP_MySQLConfig.Password, RP_MySQLConfig.Database_name, RP_MySQLConfig.Database_port)
			end
		end)

		hook.Call("DatabaseInitialized")
	end
	databaseObject:connect()
end

function SQLStr(str)
	if not CONNECTED_TO_MYSQL then
		return sql.SQLStr(str)
	end

	return "\"" .. databaseObject:escape(tostring(str)) .. "\""
end
