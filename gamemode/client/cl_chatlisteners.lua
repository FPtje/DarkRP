-----------------------------------------------------------------------------[[
/*---------------------------------------------------------------------------
This module finds out for you who can see you talk or speak through the microphone
---------------------------------------------------------------------------*/
-----------------------------------------------------------------------------]]

/*---------------------------------------------------------------------------
Variables
---------------------------------------------------------------------------*/
local receivers
local currentChatText = {}
local receiverConfigs = {
	[""] = { -- The default config decides who can hear you when you speak normally
		text = "talk",
		hearFunc = function(ply)
			if GAMEMODE.Config.alltalk then return nil end

			return LocalPlayer():GetPos():Distance(ply:GetPos()) < 250
		end
	}
}

local currentConfig = receiverConfigs[""] -- Default config is normal talk

/*---------------------------------------------------------------------------
AddChatReceiver
Add a chat command with specific receivers

prefix: the chat command itself ("/pm", "/ooc", "/me" are some examples)
text: the text that shows up when it says "Some people can hear you X"
hearFunc: a function(ply, splitText) that decides whether this player can or cannot hear you.
	return true if the player can hear you
		   false if the player cannot
		   nil if you want to prevent the text from showing up temporarily
---------------------------------------------------------------------------*/
function GM:AddChatReceiver(prefix, text, hearFunc)
	receiverConfigs[prefix] = {
		text = text,
		hearFunc = hearFunc
	}
end

/*---------------------------------------------------------------------------
removeChatReceiver
Remove a chat command.

prefix: the command, like in addChatReceiver
---------------------------------------------------------------------------*/
function GM:removeChatReceiver(prefix)
	receiverConfigs[prefix] = nil
end

/*---------------------------------------------------------------------------
Draw the results to the screen
---------------------------------------------------------------------------*/
local function drawChatReceivers()
	if not receivers then return end

	local x, y = chat.GetChatBoxPos()
	y = y - 21

	-- No one hears you
	if #receivers == 0 then
		draw.WordBox(2, x, y, DarkRP.getPhrase("hear_noone", currentConfig.text), "DarkRPHUD1", Color(0,0,0,160), Color(255,0,0,255))
		return
	-- Everyone hears you
	elseif #receivers == #player.GetAll() - 1 then
		draw.WordBox(2, x, y, DarkRP.getPhrase("hear_everyone"), "DarkRPHUD1", Color(0,0,0,160), Color(0,255,0,255))
		return
	end

	draw.WordBox(2, x, y - (#receivers * 21), DarkRP.getPhrase("hear_certain_persons", currentConfig.text), "DarkRPHUD1", Color(0,0,0,160), Color(0,255,0,255))
	for i = 1, #receivers, 1 do
		if not IsValid(receivers[i]) then
			receivers[i] = receivers[#receivers]
			receivers[#receivers] = nil
			continue
		end

		draw.WordBox(2, x, y - (i - 1)*21, receivers[i]:Nick(), "DarkRPHUD1", Color(0,0,0,160), Color(255,255,255,255))
	end
end

/*---------------------------------------------------------------------------
Find out who could hear the player if they were to speak now
---------------------------------------------------------------------------*/
local function chatGetRecipients()
	if not currentConfig then return end

	receivers = {}
	for _, ply in pairs(player.GetAll()) do
		if not IsValid(ply) or ply == LocalPlayer() then continue end

		local val = currentConfig.hearFunc(ply, currentChatText)

		-- Return nil to disable the chat recipients temporarily.
		if val == nil then
			receivers = nil
			return
		elseif val == true then
			table.insert(receivers, ply)
		end
	end
end

/*---------------------------------------------------------------------------
Called when the player starts typing
---------------------------------------------------------------------------*/
local function startFind()
	currentConfig = receiverConfigs[""]
	hook.Add("Think", "DarkRP_chatRecipients", chatGetRecipients)
	hook.Add("HUDPaint", "DarkRP_DrawChatReceivers", drawChatReceivers)
end
hook.Add("StartChat", "DarkRP_StartFindChatReceivers", startFind)

/*---------------------------------------------------------------------------
Called when the player stops typing
---------------------------------------------------------------------------*/
local function stopFind()
	hook.Remove("Think", "DarkRP_chatRecipients")
	hook.Remove("HUDPaint", "DarkRP_DrawChatReceivers")
end
hook.Add("FinishChat", "DarkRP_StopFindChatReceivers", stopFind)

/*---------------------------------------------------------------------------
Find out which chat command the user is typing
---------------------------------------------------------------------------*/
local function findConfig(text)
	local split = string.Explode(' ', text)
	local prefix = string.lower(split[1])

	currentChatText = split

	currentConfig = receiverConfigs[prefix] or receiverConfigs[""]
end
hook.Add("ChatTextChanged", "DarkRP_FindChatRecipients", findConfig)


/*---------------------------------------------------------------------------
Default chat receievers. If you want to add your own ones, don't add them to this file. Add them to a clientside module file instead.
---------------------------------------------------------------------------*/
GM:AddChatReceiver("/ooc", "speak in OOC", function(ply) return true end)
GM:AddChatReceiver("//", "speak in OOC", function(ply) return true end)
GM:AddChatReceiver("/a", "speak in OOC", function(ply) return true end)
GM:AddChatReceiver("/w", "whisper", function(ply) return LocalPlayer():GetPos():Distance(ply:GetPos()) < 90 end)
GM:AddChatReceiver("/y", "yell", function(ply) return LocalPlayer():GetPos():Distance(ply:GetPos()) < 550 end)
GM:AddChatReceiver("/me", "perform your action", function(ply) return LocalPlayer():GetPos():Distance(ply:GetPos()) < 250 end)
GM:AddChatReceiver("/g", "talk to your group", function(ply)
	for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
		if func(LocalPlayer()) and func(ply) then
			return true
		end
	end
	return false
end)

GM:AddChatReceiver("/pm", "PM", function(ply, text)
	if not isstring(text[2]) then return false end
	text[2] = string.lower(tostring(text[2]))

	return string.find(string.lower(ply:Nick()), text[2], 1, true) ~= nil or
		string.find(string.lower(ply:SteamName()), text[2], 1, true) ~= nil or
		string.lower(ply:SteamID()) == text[2]
end)

/*---------------------------------------------------------------------------
Voice chat receivers
---------------------------------------------------------------------------*/
GM:AddChatReceiver("speak", "speak", function(ply)
	if not LocalPlayer().DRPIsTalking then return nil end
	if LocalPlayer():GetPos():Distance(ply:GetPos()) > 550 then return false end

	return not GAMEMODE.Config.dynamicvoice or ply:IsInRoom()
end)

/*---------------------------------------------------------------------------
Called when the player starts using their voice
---------------------------------------------------------------------------*/
local function startFindVoice(ply)
	if ply ~= LocalPlayer() then return end

	currentConfig = receiverConfigs["speak"]
	hook.Add("Think", "DarkRP_chatRecipients", chatGetRecipients)
	hook.Add("HUDPaint", "DarkRP_DrawChatReceivers", drawChatReceivers)
end
hook.Add("PlayerStartVoice", "DarkRP_VoiceChatReceiverFinder", startFindVoice)

/*---------------------------------------------------------------------------
Called when the player stops using their voice
---------------------------------------------------------------------------*/
local function stopFindVoice(ply)
	if ply ~= LocalPlayer() then return end

	stopFind()
end
hook.Add("PlayerEndVoice", "DarkRP_VoiceChatReceiverFinder", stopFindVoice)

-- THE FOLLOWING FUNCTION IS REMOVED IN REFACTOR BRANCH
local meta = FindMetaTable("Player")
function meta:IsInRoom()
	local tracedata = {}
	tracedata.start = LocalPlayer():GetShootPos()
	tracedata.endpos = self:GetShootPos()
	local trace = util.TraceLine(tracedata)

	return not trace.HitWorld
end
