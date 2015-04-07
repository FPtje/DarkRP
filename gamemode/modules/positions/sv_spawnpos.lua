local function SetSpawnPos(ply, args)
	if not ply:hasfprpPrivilege("rp_commands") then
		fprp.notify(ply, 1, 2, fprp.getPhrase("need_admin", "setspawn"));
		return ""
	end

	local pos = string.Explode(" ", tostring(ply:GetPos()));
	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			fprp.notify(ply, 0, 4, fprp.getPhrase("created_spawnpos", v.name));
		end
	end

	if t then
		fprp.storeTeamSpawnPos(t, pos);
	else
		fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", tostring(args)));
	end

	return ""
end
fprp.defineChatCommand("setspawn", SetSpawnPos);

local function AddSpawnPos(ply, args)
	if not ply:hasfprpPrivilege("rp_commands") then
		fprp.notify(ply, 1, 2, fprp.getPhrase("need_admin", "addspawn"));
		return ""
	end

	local pos = string.Explode(" ", tostring(ply:GetPos()));
	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			fprp.notify(ply, 0, 4, fprp.getPhrase("updated_spawnpos", v.name));
		end
	end

	if t then
		fprp.addTeamSpawnPos(t, pos);
	else
		fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", tostring(args)));
	end

	return ""
end
fprp.defineChatCommand("addspawn", AddSpawnPos);

local function RemoveSpawnPos(ply, args)
	if not ply:hasfprpPrivilege("rp_commands") then
		fprp.notify(ply, 1, 2, fprp.getPhrase("need_admin", "remove spawn"));
		return ""
	end

	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			fprp.notify(ply, 0, 4, fprp.getPhrase("updated_spawnpos", v.name));
			break
		end
	end

	if t then
		fprp.removeTeamSpawnPos(t);
	else
		fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", tostring(args)));
	end

	return ""
end
fprp.defineChatCommand("removespawn", RemoveSpawnPos);
