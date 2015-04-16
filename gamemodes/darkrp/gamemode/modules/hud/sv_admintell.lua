/*---------------------------------------------------------------------------
Messages
---------------------------------------------------------------------------*/
local function ccTell(ply, cmd, args)
	if not args or not args[1] then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return
	end

	if ply:EntIndex() ~= 0 and not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_tell"))
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if target then
		local msg = ""

		for n = 2, #args do
			msg = msg .. args[n] .. " "
		end

		umsg.Start("AdminTell", target)
			umsg.String(msg)
		umsg.End()

		if ply:EntIndex() == 0 then
			DarkRP.log("Console did rp_tell \""..msg .. "\" on "..target:SteamName(), Color(30, 30, 30))
		else
			DarkRP.log(ply:Nick().." ("..ply:SteamID()..") did rp_tell \""..msg .. "\" on "..target:SteamName(), Color(30, 30, 30))
		end
	else
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("could_not_find", tostring(args[1])))
	end
end
concommand.Add("rp_tell", ccTell)

local function ccTellAll(ply, cmd, args)
	if not args or not args[1] then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return
	end

	if ply:EntIndex() ~= 0 and not ply:hasDarkRPPrivilege("rp_commands") then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", "rp_tellall"))
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
		DarkRP.log("Console did rp_tellall \""..msg .. "\"", Color(30, 30, 30))
	else
		DarkRP.log(ply:Nick().." ("..ply:SteamID()..") did rp_tellall \""..msg .. "\"", Color(30, 30, 30))
	end

end
concommand.Add("rp_tellall", ccTellAll)
