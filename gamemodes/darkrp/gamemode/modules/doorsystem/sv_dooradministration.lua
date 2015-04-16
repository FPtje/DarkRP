local function ccDoorOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_own"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:keysUnOwn()
	trace.Entity:keysOwn(ply)
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-owned a door with rp_own", Color(30, 30, 30))
end
concommand.Add("rp_own", ccDoorOwn)

local function ccDoorUnOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_unown"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:keysUnOwn()
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-unowned a door with rp_unown", Color(30, 30, 30))
end
concommand.Add("rp_unown", ccDoorUnOwn)

local function unownAll(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_unown"))
		return
	end

	if not args or not args[1] then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if not IsValid(target) then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("could_not_find", tostring(args[1])))
		return
	end
	target:keysUnOwnAll()

	if ply:EntIndex() == 0 then
		DarkRP.log("Console force-unowned all doors owned by " .. target:Nick(), Color(30, 30, 30))
	else
		DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-unowned all doors owned by " .. target:Nick(), Color(30, 30, 30))
	end
end
concommand.Add("rp_unownall", unownAll)

local function ccAddOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_addowner"))
		return
	end

	if not args or not args[1] then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if target then
		if trace.Entity:isKeysOwned() then
			if not trace.Entity:isKeysOwnedBy(target) and not trace.Entity:isKeysAllowedToOwn(target) then
				trace.Entity:addKeysAllowedToOwn(target)
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("rp_addowner_already_owns_door", target))
			end
		else
			trace.Entity:keysOwn(target)
		end
		DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-added a door owner with rp_addowner", Color(30, 30, 30))
	else
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("could_not_find", tostring(args[1])))
	end
end
concommand.Add("rp_addowner", ccAddOwner)

local function ccRemoveOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_removeowner"))
		return
	end

	if not args or not args[1] then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if target then
		if trace.Entity:isKeysAllowedToOwn(target) then
			trace.Entity:removeKeysAllowedToOwn(target)
		end

		if trace.Entity:isKeysOwnedBy(target) then
			trace.Entity:removeKeysDoorOwner(target)
		end
		DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-removed a door owner with rp_removeowner", Color(30, 30, 30))
	else
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("could_not_find", tostring(args[1])))
	end
end
concommand.Add("rp_removeowner", ccRemoveOwner)

local function ccLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_lock"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("locked"))

	trace.Entity:keysLock()

	if not trace.Entity:CreatedByMap() then return end
	MySQLite.query("REPLACE INTO darkrp_door VALUES("..MySQLite.SQLStr(trace.Entity:doorIndex())..", "..MySQLite.SQLStr(string.lower(game.GetMap()))..", "..MySQLite.SQLStr(trace.Entity:getKeysTitle() or "")..", 1, "..(trace.Entity:getKeysNonOwnable() and 1 or 0)..");")
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-locked a door with rp_lock (locked door is saved)", Color(30, 30, 30))
end
concommand.Add("rp_lock", ccLock)

local function ccUnLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print(DarkRP.getPhrase("cmd_cant_be_run_server_console"))
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_unlock"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:isKeysOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("must_be_looking_at", DarkRP.getPhrase("door_or_vehicle")))
		return
	end

	ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("unlocked"))
	trace.Entity:keysUnLock()

	if not trace.Entity:CreatedByMap() then return end
	MySQLite.query("REPLACE INTO darkrp_door VALUES("..MySQLite.SQLStr(trace.Entity:doorIndex())..", "..MySQLite.SQLStr(string.lower(game.GetMap()))..", "..MySQLite.SQLStr(trace.Entity:getKeysTitle() or "")..", 0, "..(trace.Entity:getKeysNonOwnable() and 1 or 0)..");")
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-unlocked a door with rp_unlock (unlocked door is saved)", Color(30, 30, 30))
end
concommand.Add("rp_unlock", ccUnLock)
