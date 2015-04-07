/*---------------------------------------------------------------------------
Messages
---------------------------------------------------------------------------*/
local function ccTell(ply, cmd, args)
	if not args or not args[1] then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		end
		return
	end

	if ply:EntIndex() ~= 0 and not ply:hasfprpPrivilege("rp_commands") then
		ply:PrintMessage(2, fprp.getPhrase("need_admin", "rp_tell"));
		return
	end

	local target = fprp.findPlayer(args[1]);

	if target then
		local msg = ""

		for n = 2, #args do
			msg = msg .. args[n] .. " "
		end

		umsg.Start("AdminTell", target);
			umsg.String(msg);
		umsg.End();

		if ply:EntIndex() == 0 then
			fprp.log("Console did rp_tell \""..msg .. "\" on "..target:SteamName(), Color(30, 30, 30));
		else
			fprp.log(ply:Nick().." ("..ply:SteamID()..") did rp_tell \""..msg .. "\" on "..target:SteamName(), Color(30, 30, 30));
		end
	else
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", tostring(args[1])));
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])));
		end
	end
end
concommand.Add("rp_tell", ccTell);

local function ccTellAll(ply, cmd, args)
	if not args or not args[1] then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		end
		return
	end

	if ply:EntIndex() ~= 0 and not ply:hasfprpPrivilege("rp_commands") then
		ply:PrintMessage(2, fprp.getPhrase("need_admin", "rp_tellall"));
		return
	end

	local msg = ""

	for n = 1, #args do
		msg = msg .. args[n] .. " "
	end

	umsg.Start("AdminTell");
		umsg.String(msg);
	umsg.End();

	if ply:EntIndex() == 0 then
		fprp.log("Console did rp_tellall \""..msg .. "\"", Color(30, 30, 30));
	else
		fprp.log(ply:Nick().." ("..ply:SteamID()..") did rp_tellall \""..msg .. "\"", Color(30, 30, 30));
	end

end
concommand.Add("rp_tellall", ccTellAll);
