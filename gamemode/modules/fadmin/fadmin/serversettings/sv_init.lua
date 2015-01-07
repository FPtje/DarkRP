local Whitelist = {"sv_password"} -- Make sure people don't use FAdmin serversetting as easy RCON, only the SBOX commands are allowed
table.insert(Whitelist, "sbox_.*")
table.insert(Whitelist, "_FAdmin_.*")

function FAdmin.SaveSetting(var, value)
	MySQLite.query("REPLACE INTO FAdmin_ServerSettings VALUES("..MySQLite.SQLStr(var:lower())..", "..MySQLite.SQLStr(value)..");")
end

hook.Add("DatabaseInitialized", "FAdmin_Settings", function()
	MySQLite.query("SELECT * FROM FAdmin_ServerSettings;", function(data)
		if not data then return end
		
		for k,v in pairs(data) do
			RunConsoleCommand(v.setting, v.value)
		end
	end) 
	
	if sql.TableExists("FAdmin_ServerSettings") and MySQLite.isMySQL() then -- Read Settings out of the local DB and add them to MySQL one
		local settings = sql.Query("SELECT * FROM FAdmin_ServerSettings;") or {}
		for k,v in pairs(Settings) do
			FAdmin.SaveSetting(v.setting, v.value)
			RunConsoleCommand(v.setting, v.value)
		end
		sql.Query("DROP TABLE FAdmin_ServerSettings;") -- Drop the old table so we only load it once.
	end
end) 

local function ServerSetting(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "ServerSetting") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[2] then FAdmin.Messages.SendMessage(ply, 5, "Incorrect argument") return end

	local found = false
	for k,v in pairs(Whitelist) do
		if string.match(args[1], v) then
			found = true
			break
		end
	end
	if not found then return end

	local CommandArgs = table.Copy(args)
	CommandArgs[1] = nil
	CommandArgs = table.ClearKeys(CommandArgs)
	RunConsoleCommand(args[1], unpack(CommandArgs))
	FAdmin.SaveSetting(args[1], CommandArgs[1])
	FAdmin.Messages.ActionMessage(ply, player.GetAll(), "You have set ".. args[1].. " to ".. unpack(CommandArgs),
	args[1].. " was set to " .. unpack(CommandArgs), "Set ".. args[1].. " to ".. unpack(CommandArgs))
end

FAdmin.StartHooks["ServerSettings"] = function()
	FAdmin.Commands.AddCommand("ServerSetting", ServerSetting)

	FAdmin.Access.AddPrivilege("ServerSetting", 2)
end