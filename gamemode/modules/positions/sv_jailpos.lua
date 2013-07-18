local function JailPos(ply)
	-- Admin or Chief can set the Jail Position
	if (RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].chief and GAMEMODE.Config.chiefjailpos) or ply:hasDarkRPPrivilege("rp_commands") then
		DarkRP.storeJailPos(ply)
	else
		local str = DarkRP.getPhrase("admin_only")
		if GAMEMODE.Config.chiefjailpos then
			str = DarkRP.getPhrase("chief_or") .. str
		end

		DarkRP.notify(ply, 1, 4, str)
	end
	return ""
end
DarkRP.defineChatCommand("jailpos", JailPos)

local function AddJailPos(ply)
	-- Admin or Chief can add Jail Positions
	if (RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].chief and GAMEMODE.Config.chiefjailpos) or ply:hasDarkRPPrivilege("rp_commands") then
		DarkRP.storeJailPos(ply, true)
	else
		local str = DarkRP.getPhrase("admin_only")
		if GAMEMODE.Config.chiefjailpos then
			str = DarkRP.getPhrase("chief_or") .. str
		end

		DarkRP.notify(ply, 1, 4, str)
	end
	return ""
end
DarkRP.defineChatCommand("addjailpos", AddJailPos)
