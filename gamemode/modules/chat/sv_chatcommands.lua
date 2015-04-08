/*---------------------------------------------------------
Talking
 ---------------------------------------------------------*/
local function PM(ply, args)
	local namepos = string.find(args, " ");
	if not namepos then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end

	local name = string.sub(args, 1, namepos - 1);
	local msg = string.sub(args, namepos + 1);

	if msg == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end

	local target = fprp.findPlayer(name);

	if target then
		local col = team.GetColor(ply:Team());
		fprp.talkToPerson(target, col, "(PM) "..ply:Nick(), Color(255,255,255,255), msg, ply);
		fprp.talkToPerson(ply, col, "(PM) "..ply:Nick(), Color(255,255,255,255), msg, ply);
	else
		fprp.notify(ply, 1, 4, fprp.getPhrase("could_not_find", tostring(name)));
	end

	return ""
end
fprp.defineChatCommand("pm", PM, 1.5);

local function Whisper(ply, args)
	local DoSay = function(text)
		if text == "" then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
			return ""
		end
		fprp.talkToRange(ply, "(".. fprp.getPhrase("whisper") .. ") " .. ply:Nick(), text, 90);
	end
	return args, DoSay
end
fprp.defineChatCommand("w", Whisper, 1.5);

local function Yell(ply, args)
	local DoSay = function(text)
		if text == "" then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
			return ""
		end
		fprp.talkToRange(ply, "(".. fprp.getPhrase("yell") .. ") " .. ply:Nick(), text, 550);
	end
	return args, DoSay
end
fprp.defineChatCommand("y", Yell, 1.5);

local function Me(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
			return ""
		end
		if GAMEMODE.Config.alltalk then
			for _, target in pairs(player.GetAll()) do
				fprp.talkToPerson(target, team.GetColor(ply:Team()), ply:Nick() .. " " .. text);
			end
		else
			fprp.talkToRange(ply, ply:Nick() .. " " .. text, "", 250);
		end
	end
	return args, DoSay
end
fprp.defineChatCommand("me", Me, 1.5);

local function OOC(ply, args)
	if not GAMEMODE.Config.ooc then
		fprp.notify(ply, 1, 4, fprp.getPhrase("disabled", fprp.getPhrase("ooc"), ""));
		return ""
	end

	local DoSay = function(text)
		if text == "" then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
			return ""
		end
		local col = team.GetColor(ply:Team());
		local col2 = Color(255,255,255,255);
		if not ply:Alive() then
			col2 = Color(255,200,200,255);
			col = col2
		end
		for k,v in pairs(player.GetAll()) do
			fprp.talkToPerson(v, col, "("..fprp.getPhrase("ooc")..") "..ply:Name(), col2, text, ply);
		end
	end
	return args, DoSay
end
fprp.defineChatCommand("/", OOC, true, 1.5);
fprp.defineChatCommand("a", OOC, true, 1.5);
fprp.defineChatCommand("ooc", OOC, true, 1.5);

local function PlayerAdvertise(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end
	local DoSay = function(text)
		if text == "" then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
			return
		end
		for k,v in pairs(player.GetAll()) do
			local col = team.GetColor(ply:Team());
			fprp.talkToPerson(v, col, fprp.getPhrase("advert") .." "..ply:Nick(), Color(255,255,0,255), text, ply);
		end
	end
	return args, DoSay
end
fprp.defineChatCommand("advert", PlayerAdvertise, 1.5);

local function MayorBroadcast(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then fprp.notify(ply, 1, 4, "You have to be mayor") return "" end
	local DoSay = function(text)
		if text == "" then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
			return
		end
		for k,v in pairs(player.GetAll()) do
			local col = team.GetColor(ply:Team());
			fprp.talkToPerson(v, col, fprp.getPhrase("broadcast") .. " " ..ply:Nick(), Color(170, 0, 0,255), text, ply);
		end
	end
	return args, DoSay
end
fprp.defineChatCommand("broadcast", MayorBroadcast, 1.5);

local function SetRadioChannel(ply,args)
	if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 100 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", "0<channel<100"));
		return ""
	end
	fprp.notify(ply, 2, 4, fprp.getPhrase("channel_set_to_x", args));
	ply.RadioChannel = tonumber(args);
	return ""
end
fprp.defineChatCommand("channel", SetRadioChannel);

local function SayThroughRadio(ply,args)
	if not ply.RadioChannel then ply.RadioChannel = 1 end
	if not args or args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end
	local DoSay = function(text)
		if text == "" then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
			return
		end
		for k,v in pairs(player.GetAll()) do
			if v.RadioChannel == ply.RadioChannel then
				fprp.talkToPerson(v, Color(180,180,180,255), fprp.getPhrase("radio_x", ply.RadioChannel), Color(180,180,180,255), text, ply);
			end
		end
	end
	return args, DoSay
end
fprp.defineChatCommand("radio", SayThroughRadio, 1.5);

local function GroupMsg(ply, args)
	local DoSay = function(text)
		local plyMeta = FindMetaTable("Player");
		if text == "" then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
			return
		end

		local t = ply:Team();
		local col = team.GetColor(ply:Team());

		local groupChat
		local hasReceived = {}
		for _, func in pairs(GAMEMODE.fprpGroupChats) do
			-- not the group of the player
			if not func(ply) then continue end
			groupChat = func
			break
		end

		groupChat = groupChat or fc{fp{fn.Eq, ply:Team()}, plyMeta.Team} -- Either in group chat or in the same team

		for _, target in pairs(player.GetAll()) do
			if groupChat(target) then
				fprp.talkToPerson(target, col, fprp.getPhrase("group") .. " " .. ply:Nick(), Color(255,255,255,255), text, ply);
			end
		end
	end
	return args, DoSay
end
fprp.defineChatCommand("g", GroupMsg, 0);

-- here's the new easter egg. Easier to find, more subtle, doesn't only credit FPtje and unib5
-- WARNING: DO NOT EDIT THIS
-- You can edit fprp but you HAVE to credit the original authors!
-- You even have to credit all the previous authors when you rename the gamemode.

-- you're not my mom fuck you

util.AddNetworkString('fprp_credits')

local function GetfprpAuthors(ply, args)
	net.Start('fprp_credits')
	net.Send(ply)
	return ""
end
fprp.defineChatCommand("credits", GetfprpAuthors, 50);

