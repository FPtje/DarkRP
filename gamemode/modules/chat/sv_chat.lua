function DarkRP.defineChatCommand(cmd, callback)
	cmd = string.lower(cmd)
	local detour = function(ply, arg, ...)
		if ply.DarkRPUnInitialized then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("data_not_loaded_one"))
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("data_not_loaded_two"))
			return ""
		end
		return callback(ply, arg, ...)
	end

	local chatcommands = DarkRP.getChatCommands()

	chatcommands[cmd] = chatcommands[cmd] or {}
	chatcommands[cmd].callback = detour
	chatcommands[cmd].command = chatcommands[cmd].command or cmd
end


local function RP_PlayerChat(ply, text)
	DarkRP.log(ply:Nick().." ("..ply:SteamID().."): "..text )
	local chatcommands = DarkRP.getChatCommands()
	local callback = ""
	local DoSayFunc
	local tblCmd = fn.Compose{ -- Extract the chat command
		DarkRP.getChatCommand,
		string.lower,
		fn.Curry(fn.Flip(string.sub), 2)(2), -- extract prefix
		fn.Curry(fn.GetValue, 2)(1), -- Get the first word
		fn.Curry(string.Explode, 2)(' ') -- split by spaces
	}(text)

	if string.sub(text, 1, 1) == GAMEMODE.Config.chatCommandPrefix and tblCmd then
		local arg = string.sub(text, string.len(tblCmd.command) + 3)
		if string.sub(arg, 1, 1) == "#" then return "", "", fn.Id end -- Exploit workaround

		callback, DoSayFunc = tblCmd.callback(ply, arg)
		if callback == "" then
			return "", "", DoSayFunc;
		end

		text = arg
	end

	if callback ~= "" then
		callback = callback or "" .. " "
	end

	return text, callback, DoSayFunc;
end

local function RP_ActualDoSay(ply, text, callback)
	callback = callback or ""
	if text == "" then return "" end
	local col = team.GetColor(ply:Team())
	local col2 = Color(255,255,255,255)
	if not ply:Alive() then
		col2 = Color(255,200,200,255)
		col = col2
	end

	if GAMEMODE.Config.alltalk then
		for k,v in pairs(player.GetAll()) do
			DarkRP.talkToPerson(v, col, callback..ply:Name(), col2, text, ply)
		end
	else
		DarkRP.talkToRange(ply, callback..ply:Name(), text, 250)
	end
	return ""
end

GM.OldChatHooks = GM.OldChatHooks or {}
function GM:PlayerSay(ply, text, teamonly, dead) -- We will make the old hooks run AFTER DarkRP's playersay has been run.
	local text2 = (not teamonly and "" or "/g ") .. text
	local callback

	for k,v in pairs(self.OldChatHooks) do
		if type(v) ~= "function" then continue end

		if type(k) == "Entity" or type(k) == "Player" then
			text2 = v(k, ply, text, teamonly, dead) or text2
		else
			text2 = v(ply, text, teamonly, dead) or text2
		end
	end

	text2, callback, DoSayFunc = RP_PlayerChat(ply, text2)
	if tostring(text2) == " " then text2, callback = callback, text2 end

	if game.IsDedicated() then
		ServerLog("\""..ply:Nick().."<"..ply:UserID()..">" .."<"..ply:SteamID()..">".."<"..team.GetName(ply:Team())..">\" say \""..text.. "\"\n" .. "\n")
	end

	if DoSayFunc then DoSayFunc(text2) return "" end
	RP_ActualDoSay(ply, text2, callback)

	hook.Call("PostPlayerSay", nil, ply, text2, teamonly, dead)
	return ""
end

local function ReplaceChatHooks()
	if not hook.GetTable().PlayerSay then return end
	for k,v in pairs(hook.GetTable().PlayerSay) do -- Remove all PlayerSay hooks, they all interfere with DarkRP's PlayerSay
		GAMEMODE.OldChatHooks[k] = v
		hook.Remove("PlayerSay", k)
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
	end)

	-- give warnings for undeclared chat commands
	local warning = fn.Compose{ErrorNoHalt, fn.Curry(string.format, 2)("Chat command \"%s\" is defined but not declared!\n")}
	fn.ForEach(warning, DarkRP.getIncompleteChatCommands())
end
hook.Add("InitPostEntity", "RemoveChatHooks", ReplaceChatHooks)

local function ConCommand(ply, _, args)
	if not args[1] then return end

	local cmd = string.lower(args[1])
	local arg = table.concat(args, ' ', 2)
	local tbl = DarkRP.getChatCommand(cmd)
	local time = CurTime()

	if not tbl then return end

	ply.DrpCommandDelays = ply.DrpCommandDelays or {}

	if tbl.delay and ply.DrpCommandDelays[cmd] and ply.DrpCommandDelays[cmd] > time - tbl.delay then
		return
	end

	for i = 2, #args do
		if string.sub(args[i], 1, 1) == "#" then return end -- Exploit workaround
	end

	ply.DrpCommandDelays[cmd] = time

	tbl.callback(ply, arg)
end
concommand.Add("darkrp", ConCommand)
