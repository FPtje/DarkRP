local function SetSpawnPos(ply, args)
	if not ply:hasDarkRPPrivilege("rp_commands") then
		DarkRP.notify(ply, 1, 2, DarkRP.getPhrase("need_admin", "setspawn"))
		return ""
	end

	local pos = ply:GetPos()
	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("created_spawnpos", v.name))
		end
	end

	if t then
		DarkRP.storeTeamSpawnPos(t, {pos.x, pos.y, pos.z})
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
	end

	return ""
end
DarkRP.defineChatCommand("setspawn", SetSpawnPos)

local function AddSpawnPos(ply, args)
	if not ply:hasDarkRPPrivilege("rp_commands") then
		DarkRP.notify(ply, 1, 2, DarkRP.getPhrase("need_admin", "addspawn"))
		return ""
	end

	local pos = ply:GetPos()
	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("updated_spawnpos", v.name))
		end
	end

	if t then
		DarkRP.addTeamSpawnPos(t, {pos.x, pos.y, pos.z})
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
	end

	return ""
end
DarkRP.defineChatCommand("addspawn", AddSpawnPos)

local function RemoveSpawnPos(ply, args)
	if not ply:hasDarkRPPrivilege("rp_commands") then
		DarkRP.notify(ply, 1, 2, DarkRP.getPhrase("need_admin", "remove spawn"))
		return ""
	end

	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("updated_spawnpos", v.name))
			break
		end
	end

	if t then
		DarkRP.removeTeamSpawnPos(t)
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args)))
	end

	return ""
end
DarkRP.defineChatCommand("removespawn", RemoveSpawnPos)
