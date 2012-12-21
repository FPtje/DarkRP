local ChatCommands = {}

function AddChatCommand(cmd, callback, prefixconst)
	for k,v in pairs(ChatCommands) do
		if cmd == v.cmd then return end
	end
	ChatCommands[string.lower(cmd)] = {
		cmd = cmd,
		callback = callback,
		prefixconst = prefixconst,
	}
end

local function RP_PlayerChat(ply, text)
	DB.Log(ply:SteamName().." ("..ply:SteamID().."): "..text )
	local callback = ""
	local DoSayFunc
	local tblCmd = ChatCommands[string.lower( string.Explode(" ", text )[1] )];
	if tblCmd then
		callback, DoSayFunc = tblCmd.callback( ply, string.sub( text, string.len( tblCmd.cmd ) + 2, string.len( text ) ) );
		if( callback == "") then
			return "", "", DoSayFunc;
		end
		text = string.sub(text, string.len(tblCmd.cmd) + 2, string.len(text))
	end
	if( callback != "") then
		callback = ( callback || "").." "
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
			GAMEMODE:TalkToPerson(v, col, callback..ply:Name(), col2, text, ply)
		end
	else
		GAMEMODE:TalkToRange(ply, callback..ply:Name(), text, 250)
	end
	return ""
end

local otherhooks = {}
function GM:PlayerSay(ply, text, teamonly, dead) -- We will make the old hooks run AFTER DarkRP's playersay has been run.
	local text2 = (not teamonly and "" or "/g ") .. text
	local callback

	for k,v in SortedPairs(otherhooks, false) do
		if type(v) == "function" then
			text2 = v(ply, text, teamonly, dead) or text2
		end
	end

	text2, callback, DoSayFunc = RP_PlayerChat(ply, text2)
	if tostring(text2) == " " then text2, callback = callback, text2 end

	if game.IsDedicated() then
		ServerLog("\""..ply:Nick().."<"..ply:UserID()..">" .."<"..ply:SteamID()..">".."<"..team.GetName( ply:Team() )..">\" say \""..text.. "\"\n" .. "\n")
	end

	if DoSayFunc then DoSayFunc(text2) return "" end
	RP_ActualDoSay(ply, text2, callback)

	hook.Call("PostPlayerSay", nil, ply, text2, teamonly, dead)
	return ""
end

function GM:ReplaceChatHooks()
	if not hook.GetTable().PlayerSay then return end
	for k,v in pairs(hook.GetTable().PlayerSay) do -- Remove all PlayerSay hooks, they all interfere with DarkRP's PlayerSay
		otherhooks[k] = v
		hook.Remove("PlayerSay", k)
	end
	for a,b in pairs(otherhooks) do
		if type(b) ~= "function" then
			otherhooks[a] = nil
		end
	end
end
