local function JailPos(ply)
	-- Admin or Chief can set the Jail Position
	if (RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].chief and GAMEMODE.Config.chiefjailpos) or ply:hasfprpPrivilege("rp_commands") then
		fprp.storeJailPos(ply);
	else
		local str = fprp.getPhrase("admin_only");
		if GAMEMODE.Config.chiefjailpos then
			str = fprp.getPhrase("chief_or") .. str
		end

		fprp.notify(ply, 1, 4, str);
	end
	return ""
end
fprp.defineChatCommand("jailpos", JailPos);

local function AddJailPos(ply)
	-- Admin or Chief can add Jail Positions
	if (RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].chief and GAMEMODE.Config.chiefjailpos) or ply:hasfprpPrivilege("rp_commands") then
		fprp.storeJailPos(ply, true);
	else
		local str = fprp.getPhrase("admin_only");
		if GAMEMODE.Config.chiefjailpos then
			str = fprp.getPhrase("chief_or") .. str
		end

		fprp.notify(ply, 1, 4, str);
	end
	return ""
end
fprp.defineChatCommand("addjailpos", AddJailPos);
