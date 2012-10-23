include("_MySQL.lua")
DB = {}

if file.Exists("lua/includes/modules/gmsv_mysqloo.dll", "GAME") or file.Exists("lua/includes/modules/gmsv_mysqloo_i486.dll", "GAME") then
	require("mysqloo")
end

local CONNECTED_TO_MYSQL = false
DB.MySQLDB = nil

function DB.Begin()
	if not CONNECTED_TO_MYSQL then sql.Begin() end
end

function DB.Commit()
	if not CONNECTED_TO_MYSQL then sql.Commit() end
end

function DB.Query(query, callback)
	if CONNECTED_TO_MYSQL then
		if DB.MySQLDB and DB.MySQLDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
			DB.ConnectToMySQL(FPP_MySQLConfig.Host, FPP_MySQLConfig.Username, FPP_MySQLConfig.Password, FPP_MySQLConfig.Database_name, FPP_MySQLConfig.Database_port)
		end

		local query = DB.MySQLDB:query(query)
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
			DB.Log("MySQL Error: ".. E)
		end

		query.onSuccess = function()
			if callback then callback(data) end
		end
		query:start()
		return
	end
	sql.Begin()
	local Result = sql.Query(query)

	sql.Commit() -- Otherwise it won't save, don't ask me why
	if callback then callback(Result) end
	return Result
end

function DB.QueryValue(query, callback)
	if CONNECTED_TO_MYSQL then
		if DB.MySQLDB and DB.MySQLDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
			DB.ConnectToMySQL(FPP_MySQLConfig.Host, FPP_MySQLConfig.Username, FPP_MySQLConfig.Password, FPP_MySQLConfig.Database_name, FPP_MySQLConfig.Database_port)
		end

		local query = DB.MySQLDB:query(query)
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
		query.onError = function(Q, E) callback() DB.Log("MySQL Error: ".. E) ErrorNoHalt(E) end
		query:start()
		return
	end
	local val = sql.QueryValue(query)

	if callback then callback(val) end
	return val
end

function DB.ConnectToMySQL(host, username, password, database_name, database_port)
	if not mysqloo then Error("MySQL modules aren't installed properly!") DB.Log("MySQL Error: MySQL modules aren't installed properly!") end
	local databaseObject = mysqloo.connect(host, username, password, database_name, database_port)

	databaseObject.onConnectionFailed = function(msg)
		Error("Connection failed! " ..tostring(msg))
		DB.Log("MySQL Error: Connection failed! "..tostring(msg))
	end

	databaseObject.onConnected = function()
		DB.Log("MySQL: Connection to external database "..host.." succeeded!")
		CONNECTED_TO_MYSQL = true

		DB.Init() -- Initialize database
	end
	databaseObject:connect()
	DB.MySQLDB = databaseObject
end

if FPP_MySQLConfig and FPP_MySQLConfig.EnableMySQL then
	DB.ConnectToMySQL(FPP_MySQLConfig.Host, FPP_MySQLConfig.Username, FPP_MySQLConfig.Password, FPP_MySQLConfig.Database_name, FPP_MySQLConfig.Database_port)
end

function DB.Log(text)
	if not DB.File then -- The log file of this session, if it's not there then make it!
		if not file.IsDir("FPP_logs", "DATA") then
			file.CreateDir("FPP_logs")
		end
		DB.File = "FPP_logs/"..os.date("%m_%d_%Y %I_%M %p")..".txt"
		file.Write(DB.File, os.date().. "\t".. text)
		return
	end
	file.Append(DB.File, "\n"..os.date().. "\t"..(text or ""))
end