include("_MySQL.lua")
FPPDB = FPPDB or {}

if FPP_MySQLConfig.EnableMySQL then
	require("mysqloo")
end

local CONNECTED_TO_MYSQL = false
FPPDB.MySQLDB = nil
local QueuedQueries
function FPPDB.Begin()
	if not CONNECTED_TO_MYSQL then
		sql.Begin()
	else
		if QueuedQueries then
			debug.Trace()
			error("Transaction ongoing!")
		end
		QueuedQueries = {}
	end
end

function FPPDB.Commit(onFinished)
	if not CONNECTED_TO_MYSQL then
		sql.Commit()
		if onFinished then onFinished() end
	else
		if not QueuedQueries then
			error("No queued queries! Call FPPDB.Begin() first!")
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

			-- Reqursion
			local nextQuery = queue[queuePos + 1]
			FPPDB.Query(nextQuery.query, call, nextQuery.onError)
		end

		FPPDB.Query(queue[1].query, call, queue[1].onError)
	end
end

function FPPDB.QueueQuery(sqlText, callback, errorCallback)
	if CONNECTED_TO_MYSQL then
		table.insert(QueuedQueries, {query = sqlText, callback = callback, onError = errorCallback})
	end
	-- SQLite is instantaneous, simply running the query is equal to queueing it
	FPPDB.Query(sqlText, callback, errorCallback)
end

function FPPDB.Query(query, callback)
	if CONNECTED_TO_MYSQL then
		if FPPDB.MySQLDB and FPPDB.MySQLDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
			FPPDB.ConnectToMySQL(FPP_MySQLConfig.Host, FPP_MySQLConfig.Username, FPP_MySQLConfig.Password, FPP_MySQLConfig.Database_name, FPP_MySQLConfig.Database_port)
		end

		local query = FPPDB.MySQLDB:query(query)
		local data
		query.onData = function(Q, D)
			data = data or {}
			data[#data + 1] = D
		end

		query.onError = function(Q, E)
			ErrorNoHalt(E)
			if callback then
				callback()
			end
			FPPDB.Log("MySQL Error: ".. E)
		end

		query.onSuccess = function()
			if callback then callback(data) end
		end
		query:start()
		return
	end

	local Result = sql.Query(query)

	if callback then callback(Result) end
	return Result
end

function FPPDB.QueryValue(query, callback)
	if CONNECTED_TO_MYSQL then
		if FPPDB.MySQLDB and FPPDB.MySQLDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
			FPPDB.ConnectToMySQL(FPP_MySQLConfig.Host, FPP_MySQLConfig.Username, FPP_MySQLConfig.Password, FPP_MySQLConfig.Database_name, FPP_MySQLConfig.Database_port)
		end

		local query = FPPDB.MySQLDB:query(query)
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
		query.onError = function(Q, E) callback() FPPDB.Log("MySQL Error: ".. E) ErrorNoHalt(E) end
		query:start()
		return
	end

	local val = sql.QueryValue(query)

	if callback then callback(val) end
	return val
end

function FPPDB.ConnectToMySQL(host, username, password, database_name, database_port)
	if not mysqloo then Error("MySQL modules aren't installed properly!") FPPDB.Log("MySQL Error: MySQL modules aren't installed properly!") end
	local databaseObject = mysqloo.connect(host, username, password, database_name, database_port)

	databaseObject.onConnectionFailed = function(_, msg)
		Error("Connection failed! " ..tostring(msg))
		FPPDB.Log("MySQL Error: Connection failed! "..tostring(msg))
	end

	databaseObject.onConnected = function()
		FPPDB.Log("MySQL: Connection to external database "..host.." succeeded!")
		CONNECTED_TO_MYSQL = true

		FPP.Init() -- Initialize database
	end
	databaseObject:connect()
	FPPDB.MySQLDB = databaseObject
end

function FPPDB.Log(text)
	if not FPPDB.File then -- The log file of this session, if it's not there then make it!
		if not file.IsDir("FPP_logs", "DATA") then
			file.CreateDir("FPP_logs")
		end
		FPPDB.File = "FPP_logs/"..os.date("%m_%d_%Y %I_%M %p")..".txt"
		file.Write(FPPDB.File, os.date().. "\t".. text)
		return
	end
	file.Append(FPPDB.File, "\n"..os.date().. "\t"..(text or ""))
end