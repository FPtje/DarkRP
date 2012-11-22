/*---------------------------------------------------------------------------
Doors
---------------------------------------------------------------------------*/
local function ccDoorOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_own"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	trace.Entity:Own(ply)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-owned a door with rp_own", nil, Color(30, 30, 30))
end
concommand.Add("rp_own", ccDoorOwn)

local function ccDoorUnOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_unown"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-unowned a door with rp_unown", nil, Color(30, 30, 30))
end
concommand.Add("rp_unown", ccDoorUnOwn)

local function ccAddOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_addowner"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = GAMEMODE:FindPlayer(args[1])

	if target then
		if trace.Entity:IsOwned() then
			if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
				trace.Entity:AddAllowed(target)
			else
				ply:PrintMessage(2, string.format(LANGUAGE.rp_addowner_already_owns_door))
			end
		else
			trace.Entity:Own(target)
		end
	else
		ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
	end
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-added a door owner with rp_addowner", nil, Color(30, 30, 30))
end
concommand.Add("rp_addowner", ccAddOwner)

local function ccRemoveOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_removeowner"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = GAMEMODE:FindPlayer(args[1])

	if target then
		if trace.Entity:AllowedToOwn(target) then
			trace.Entity:RemoveAllowed(target)
		end

		if trace.Entity:OwnedBy(target) then
			trace.Entity:RemoveOwner(target)
		end
	else
		ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
	end
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed a door owner with rp_removeowner", nil, Color(30, 30, 30))
end
concommand.Add("rp_removeowner", ccRemoveOwner)

local function ccLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_lock"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, "Locked.")

	trace.Entity:KeysLock()
	DB.Query("REPLACE INTO darkrp_door VALUES("..sql.SQLStr(trace.Entity:EntIndex())..", "..sql.SQLStr(string.lower(game.GetMap()))..", "..sql.SQLStr(trace.Entity.DoorData.title or "")..", 1, "..(trace.Entity.DoorData.NonOwnable and 1 or 0)..");")
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-locked a door with rp_lock (locked door is saved)", nil, Color(30, 30, 30))
end
concommand.Add("rp_lock", ccLock)

local function ccUnLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_unlock"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, "Unlocked.")
	trace.Entity:KeysUnLock()
	DB.Query("REPLACE INTO darkrp_door VALUES("..sql.SQLStr(trace.Entity:EntIndex())..", "..sql.SQLStr(string.lower(game.GetMap()))..", "..sql.SQLStr(trace.Entity.DoorData.title or "")..", 0, "..(trace.Entity.DoorData.NonOwnable and 1 or 0)..");")
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-unlocked a door with rp_unlock (ulocked door is saved)", nil, Color(30, 30, 30))
end
concommand.Add("rp_unlock", ccUnLock)

/*---------------------------------------------------------------------------
Messages
---------------------------------------------------------------------------*/
local function ccTell(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_tell"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local msg = ""

		for n = 2, #args do
			msg = msg .. args[n] .. " "
		end

		umsg.Start("AdminTell", target)
			umsg.String(msg)
		umsg.End()

		if ply:EntIndex() == 0 then
			DB.Log("Console did rp_tell \""..msg .. "\" on "..target:SteamName(), nil, Color(30, 30, 30))
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") did rp_tell \""..msg .. "\" on "..target:SteamName(), nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
	end
end
concommand.Add("rp_tell", ccTell)

local function ccTellAll(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_tellall"))
		return
	end


	local msg = ""

	for n = 1, #args do
		msg = msg .. args[n] .. " "
	end

	umsg.Start("AdminTell")
		umsg.String(msg)
	umsg.End()

	if ply:EntIndex() == 0 then
		DB.Log("Console did rp_tellall \""..msg .. "\"", nil, Color(30, 30, 30))
	else
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") did rp_tellall \""..msg .. "\"", nil, Color(30, 30, 30))
	end

end
concommand.Add("rp_tellall", ccTellAll)

/*---------------------------------------------------------------------------
Misc
---------------------------------------------------------------------------*/
local function ccRemoveLetters(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands")then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_removeletters"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		for k, v in pairs(ents.FindByClass("letter")) do
			if v.SID == target.SID then v:Remove() end
		end
	else
		-- Remove ALL letters
		for k, v in pairs(ents.FindByClass("letter")) do
			v:Remove()
		end
	end

	if ply:EntIndex() == 0 then
		DB.Log("Console force-removed all letters", nil, Color(30, 30, 30))
	else
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed all letters", nil, Color(30, 30, 30))
	end
end
concommand.Add("rp_removeletters", ccRemoveLetters)

local function ccArrest(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_arrest"))
		return
	end

	if DB.CountJailPos() == 0 then
		if ply:EntIndex() == 0 then
			print(LANGUAGE.no_jail_pos)
		else
			ply:PrintMessage(2, LANGUAGE.no_jail_pos)
		end
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])
	if target then
		local length = tonumber(args[2])
		if length then
			target:Arrest(length)
		else
			target:Arrest()
		end

		if ply:EntIndex() == 0 then
			DB.Log("Console force-arrested "..target:SteamName(), nil, Color(0, 255, 255))
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-arrested "..target:SteamName(), nil, Color(0, 255, 255))
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
	end

end
concommand.Add("rp_arrest", ccArrest)

local function ccUnarrest(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_unarrest"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		target:Unarrest()
		if not target:Alive() then target:Spawn() end

		if ply:EntIndex() == 0 then
			DB.Log("Console force-unarrested "..target:SteamName(), nil, Color(0, 255, 255))
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-unarrested "..target:SteamName(), nil, Color(0, 255, 255))
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end

end
concommand.Add("rp_unarrest", ccUnarrest)

local function ccSetMoney(ply, cmd, args)
	if not tonumber(args[2]) then ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguments") return end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_setmoney"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local nick = ""
		DB.StoreMoney(target, amount)

		if ply:EntIndex() == 0 then
			print("Set " .. target:Nick() .. "'s money to: " .. CUR .. amount)
			nick = "Console"
		else
			ply:PrintMessage(2, "Set " .. target:Nick() .. "'s money to: " .. CUR .. amount)
			nick = ply:Nick()
		end
		target:PrintMessage(2, nick .. " set your money to: " .. CUR .. amount)
		if ply:EntIndex() == 0 then
			DB.Log("Console set "..target:SteamName().."'s money to "..CUR..amount, nil, Color(30, 30, 30))
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") set "..target:SteamName().."'s money to "..CUR..amount, nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_setmoney", ccSetMoney)

local function ccSetSalary(ply, cmd, args)
	if not tonumber(args[2]) then ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguments") return end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_setsalary"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if amount < 0 then
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.invalid_x, "argument", args[2]))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", args[2]))
		end
		return
	end

	if amount > 150 then
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.invalid_x, "argument", args[2].." (<150)"))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", args[2].." (<150)"))
		end
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local nick = ""
		DB.StoreSalary(target, amount)
		target:SetSelfDarkRPVar("salary", amount)
		if ply:EntIndex() == 0 then
			print("Set " .. target:Nick() .. "'s Salary to: " .. CUR .. amount)
			nick = "Console"
		else
			ply:PrintMessage(2, "Set " .. target:Nick() .. "'s Salary to: " .. CUR .. amount)
			nick = ply:Nick()
		end
		target:PrintMessage(2, nick .. " set your Salary to: " .. CUR .. amount)
		if ply:EntIndex() == 0 then
			DB.Log("Console set "..target:SteamName().."'s salary to "..CUR..amount, nil, Color(30, 30, 30))
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") set "..target:SteamName().."'s salary to "..CUR..amount, nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_setsalary", ccSetSalary)

local function ccSENTSPawn(ply, cmd, args)
	if GAMEMODE.Config.adminsents then
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			GAMEMODE:Notify(ply, 1, 2, string.format(LANGUAGE.need_admin, "gm_spawnsent"))
			return
		end
	end
	Spawn_SENT(ply, args[1])
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned SENT "..args[1], nil, Color(255, 255, 0))
end
concommand.Add("gm_spawnsent", ccSENTSPawn)

local function ccVehicleSpawn(ply, cmd, args)
	if GAMEMODE.Config.adminvehicles then
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			GAMEMODE:Notify(ply, 1, 2, string.format(LANGUAGE.need_admin, "gm_spawnvehicle"))
			return
		end
	end
	Spawn_Vehicle(ply, args[1])
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned Vehicle "..args[1], nil, Color(255, 255, 0))
end
concommand.Add("gm_spawnvehicle", ccVehicleSpawn)

local function ccNPCSpawn(ply, cmd, args)
	if GAMEMODE.Config.adminnpcs then
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			GAMEMODE:Notify(ply, 1, 2, string.format(LANGUAGE.need_admin, "gm_spawnnpc"))
			return
		end
	end
	Spawn_NPC(ply, args[1])
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") spawned NPC "..args[1], nil, Color(255, 255, 0))
end
concommand.Add("gm_spawnnpc", ccNPCSpawn)

local function ccSetRPName(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_setname"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if not args[2] or string.len(args[2]) < 2 or string.len(args[2]) > 30 then
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.invalid_x, "argument", args[2]))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", args[2]))
		end
	end

	if target then
		local oldname = target:Nick()
		local nick = ""
		DB.StoreRPName(target, args[2])
		target:SetDarkRPVar("rpname", args[2])
		if ply:EntIndex() == 0 then
			print("Set " .. oldname .. "'s name to: " .. args[2])
			nick = "Console"
		else
			ply:PrintMessage(2, "Set " .. oldname .. "'s name to: " .. args[2])
			nick = ply:Nick()
		end
		target:PrintMessage(2, nick .. " set your name to: " .. args[2])
		if ply:EntIndex() == 0 then
			DB.Log("Console set "..target:SteamName().."'s name to " .. args[2], nil, Color(30, 30, 30))
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") set "..target:SteamName().."'s name to " .. args[2], nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
	end
end
concommand.Add("rp_setname", ccSetRPName)

local function ccCancelVote(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_cancelvote"))
		return
	end

	GAMEMODE.vote.DestroyLast()
	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end

	GAMEMODE:NotifyAll(0, 4, nick .. " canceled the last vote")
end
concommand.Add("rp_cancelvote", ccCancelVote)