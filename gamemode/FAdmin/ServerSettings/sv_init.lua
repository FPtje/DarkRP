local Whitelist = {"sv_password"} -- Make sure people don't use FAdmin serversetting as easy RCON, only the SBOX commands are allowed
table.insert(Whitelist, "sbox_.*")
table.insert(Whitelist, "_FAdmin_.*")

sql.Query([[CREATE TABLE IF NOT EXISTS FAdmin_ServerSettings(setting STRING NOT NULL PRIMARY KEY, value STRING NOT NULL);]])
function FAdmin.SaveSetting(var, value)
	sql.Query([[REPLACE INTO FAdmin_ServerSettings VALUES(]]..sql.SQLStr(var:lower())..[[, ]]..sql.SQLStr(value)..");")
end

hook.Add("InitPostEntity", "FAdmin_Settings", function()
	local Settings = sql.Query("SELECT * FROM FAdmin_ServerSettings;") or {}
	for k,v in pairs(Settings) do
		RunConsoleCommand(v.setting, v.value)
	end
end)

local function ServerSetting(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "ServerSetting") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[2] then FAdmin.Messages.SendMessage(ply, 5, "Incorrect argument") return end

	found = false
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