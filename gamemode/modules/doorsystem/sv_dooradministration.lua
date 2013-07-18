local function ccDoorOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_own"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	trace.Entity:Own(ply)
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-owned a door with rp_own", Color(30, 30, 30))
end
concommand.Add("rp_own", ccDoorOwn)

local function ccDoorUnOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_unown"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-unowned a door with rp_unown", Color(30, 30, 30))
end
concommand.Add("rp_unown", ccDoorUnOwn)

local function unownAll(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_unown"))
		return
	end

	target = GAMEMODE:FindPlayer(args[1])

	if not IsValid(target) then
		ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args)))
		return
	end
	target:unownAll()
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-unowned all doors owned by " .. target:Nick(), Color(30, 30, 30))
end
concommand.Add("rp_unownall", unownAll)

local function ccAddOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_addowner"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = DarkRP.findPlayer(args[1])

	if target then
		if trace.Entity:IsOwned() then
			if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
				trace.Entity:AddAllowed(target)
			else
				ply:PrintMessage(2, DarkRP.getPhrase("rp_addowner_already_owns_door", target))
			end
		else
			trace.Entity:Own(target)
		end
	else
		ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args)))
	end
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-added a door owner with rp_addowner", Color(30, 30, 30))
end
concommand.Add("rp_addowner", ccAddOwner)

local function ccRemoveOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(2,  DarkRP.getPhrase("need_admin", "rp_removeowner"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = DarkRP.findPlayer(args[1])

	if target then
		if trace.Entity:AllowedToOwn(target) then
			trace.Entity:RemoveAllowed(target)
		end

		if trace.Entity:OwnedBy(target) then
			trace.Entity:removeDoorOwner(target)
		end
	else
		ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args)))
	end
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-removed a door owner with rp_removeowner", Color(30, 30, 30))
end
concommand.Add("rp_removeowner", ccRemoveOwner)

local function ccLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(2,  DarkRP.getPhrase("need_admin", "rp_lock"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, DarkRP.getPhrase("locked"))

	trace.Entity:KeysLock()
	MySQLite.query("REPLACE INTO darkrp_door VALUES("..MySQLite.SQLStr(trace.Entity:EntIndex())..", "..MySQLite.SQLStr(string.lower(game.GetMap()))..", "..MySQLite.SQLStr(trace.Entity.DoorData.title or "")..", 1, "..(trace.Entity.DoorData.NonOwnable and 1 or 0)..");")
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-locked a door with rp_lock (locked door is saved)", Color(30, 30, 30))
end
concommand.Add("rp_lock", ccLock)

local function ccUnLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(2,  DarkRP.getPhrase("need_admin", "rp_unlock"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, DarkRP.getPhrase("unlocked"))
	trace.Entity:KeysUnLock()
	MySQLite.query("REPLACE INTO darkrp_door VALUES("..MySQLite.SQLStr(trace.Entity:EntIndex())..", "..MySQLite.SQLStr(string.lower(game.GetMap()))..", "..MySQLite.SQLStr(trace.Entity.DoorData.title or "")..", 0, "..(trace.Entity.DoorData.NonOwnable and 1 or 0)..");")
	DarkRP.log(ply:Nick().." ("..ply:SteamID()..") force-unlocked a door with rp_unlock (ulocked door is saved)", Color(30, 30, 30))
end
concommand.Add("rp_unlock", ccUnLock)
