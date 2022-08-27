--[[---------------------------------------------------------------------------
This module finds out for you who can see you talk or speak through the microphone
---------------------------------------------------------------------------]]

--[[---------------------------------------------------------------------------
Variables
---------------------------------------------------------------------------]]
local receivers
local currentChatText = {}
local receiverConfigs = {}
local currentConfig = {text = "", hearFunc = fn.Id} -- Default config is not loaded yet

--[[---------------------------------------------------------------------------
addChatReceiver
Add a chat command with specific receivers

prefix: the chat command itself ("/pm", "/ooc", "/me" are some examples)
text: the text that shows up when it says "Some people can hear you X"
hearFunc: a function(ply, splitText) that decides whether this player can or cannot hear you.
    return true if the player can hear you
           false if the player cannot
           nil if you want to prevent the text from showing up temporarily
---------------------------------------------------------------------------]]
function DarkRP.addChatReceiver(prefix, text, hearFunc)
    receiverConfigs[prefix] = {
        text = text,
        hearFunc = hearFunc
    }
end

--[[---------------------------------------------------------------------------
removeChatReceiver
Remove a chat command.

prefix: the command, like in addChatReceiver
---------------------------------------------------------------------------]]
function DarkRP.removeChatReceiver(prefix)
    receiverConfigs[prefix] = nil
end

--[[---------------------------------------------------------------------------
Draw the results to the screen
---------------------------------------------------------------------------]]
local function drawChatReceivers()
    if not receivers then return end

    local fontHeight = draw.GetFontHeight("DarkRPHUD1")
    local x, y = chat.GetChatBoxPos()
    y = y - fontHeight - 4

    local receiversCount = #receivers
    -- No one hears you
    if receiversCount == 0 then
        draw.WordBox(2, x, y, DarkRP.getPhrase("hear_noone", currentConfig.text), "DarkRPHUD1", Color(0,0,0,160), Color(255,0,0,255))
        return
    -- Everyone hears you
    elseif receiversCount == player.GetCount() - 1 then
        draw.WordBox(2, x, y, DarkRP.getPhrase("hear_everyone"), "DarkRPHUD1", Color(0,0,0,160), Color(0,255,0,255))
        return
    end

    draw.WordBox(2, x, y - (receiversCount * (fontHeight + 4)), DarkRP.getPhrase("hear_certain_persons", currentConfig.text), "DarkRPHUD1", Color(0,0,0,160), Color(0,255,0,255))
    for i = 1, receiversCount, 1 do
        if not IsValid(receivers[i]) then
            receivers[i] = receivers[#receivers]
            receivers[#receivers] = nil
            continue
        end

        draw.WordBox(2, x, y - (i - 1) * (fontHeight + 4), receivers[i]:Nick(), "DarkRPHUD1", Color(0, 0, 0, 160), color_white)
    end
end

--[[---------------------------------------------------------------------------
Find out who could hear the player if they were to speak now
---------------------------------------------------------------------------]]
local function chatGetRecipients()
    if not currentConfig then return end

    receivers = {}
    for _, ply in ipairs(player.GetAll()) do
        local hidePly = hook.Run("chatHideRecipient", ply)
        if not IsValid(ply) or ply == LocalPlayer() or ply:GetNoDraw() or hidePly then continue end

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

--[[---------------------------------------------------------------------------
Called when the player starts typing
---------------------------------------------------------------------------]]
local function startFind()
    local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_ChatReceivers")
    if shouldDraw == false then return end

    currentConfig = receiverConfigs[""]
    hook.Add("Think", "DarkRP_chatRecipients", chatGetRecipients)
    hook.Add("HUDPaint", "DarkRP_DrawChatReceivers", drawChatReceivers)
end
hook.Add("StartChat", "DarkRP_StartFindChatReceivers", startFind)

--[[---------------------------------------------------------------------------
Called when the player stops typing
---------------------------------------------------------------------------]]
local function stopFind()
    hook.Remove("Think", "DarkRP_chatRecipients")
    hook.Remove("HUDPaint", "DarkRP_DrawChatReceivers")
end
hook.Add("FinishChat", "DarkRP_StopFindChatReceivers", stopFind)

--[[---------------------------------------------------------------------------
Find out which chat command the user is typing
---------------------------------------------------------------------------]]
local function findConfig(text)
    local split = string.Explode(' ', text)
    local prefix = string.lower(split[1])

    currentChatText = split

    currentConfig = receiverConfigs[prefix] or receiverConfigs[""]
end
hook.Add("ChatTextChanged", "DarkRP_FindChatRecipients", findConfig)


--[[---------------------------------------------------------------------------
Default chat receievers. If you want to add your own ones, don't add them to this file. Add them to a clientside module file instead.
---------------------------------------------------------------------------]]
-- Load after the custom languages have been loaded
local function loadChatReceivers()
    -- Default talk chat receiver has no prefix
    DarkRP.addChatReceiver("", DarkRP.getPhrase("talk"), function(ply)
        if GAMEMODE.Config.alltalk then return nil end

        return LocalPlayer():GetPos():DistToSqr(ply:GetPos()) <
            GAMEMODE.Config.talkDistance * GAMEMODE.Config.talkDistance
    end)

    DarkRP.addChatReceiver("/ooc", DarkRP.getPhrase("speak_in_ooc"), function(ply) return true end)
    DarkRP.addChatReceiver("//", DarkRP.getPhrase("speak_in_ooc"), function(ply) return true end)
    DarkRP.addChatReceiver("/a", DarkRP.getPhrase("speak_in_ooc"), function(ply) return true end)
    DarkRP.addChatReceiver("/w", DarkRP.getPhrase("whisper"), function(ply) return LocalPlayer():GetPos():DistToSqr(ply:GetPos()) < GAMEMODE.Config.whisperDistance * GAMEMODE.Config.whisperDistance end)
    DarkRP.addChatReceiver("/y", DarkRP.getPhrase("yell"), function(ply) return LocalPlayer():GetPos():DistToSqr(ply:GetPos()) < GAMEMODE.Config.yellDistance * GAMEMODE.Config.yellDistance end)
    DarkRP.addChatReceiver("/me", DarkRP.getPhrase("perform_your_action"), function(ply) return LocalPlayer():GetPos():DistToSqr(ply:GetPos()) < GAMEMODE.Config.meDistance * GAMEMODE.Config.meDistance end)
    DarkRP.addChatReceiver("/g", DarkRP.getPhrase("talk_to_your_group"), function(ply)
        for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
            if func(LocalPlayer()) and func(ply) then
                return true
            end
        end
        return false
    end)


    DarkRP.addChatReceiver("/pm", "PM", function(ply, text)
        if not isstring(text[2]) then return false end
        text[2] = string.lower(tostring(text[2]))

        return string.find(string.lower(ply:Nick()), text[2], 1, true) ~= nil or
            string.find(string.lower(ply:SteamName()), text[2], 1, true) ~= nil or
            string.lower(ply:SteamID()) == text[2]
    end)

    --[[---------------------------------------------------------------------------
        Voice chat receivers
        ---------------------------------------------------------------------------]]
    local voiceDistance = GM.Config.voiceDistance * GM.Config.voiceDistance
    DarkRP.addChatReceiver("speak", DarkRP.getPhrase("speak"), function(ply)
        if not LocalPlayer().DRPIsTalking then return nil end
        if LocalPlayer():GetPos():DistToSqr(ply:GetPos()) > voiceDistance then return false end

        return not GAMEMODE.Config.dynamicvoice or ply:isInRoom()
    end)
end
hook.Add("loadCustomDarkRPItems", "loadChatListeners", loadChatReceivers)

--[[---------------------------------------------------------------------------
Called when the player starts using their voice
---------------------------------------------------------------------------]]
local function startFindVoice(ply)
    if ply ~= LocalPlayer() then return end

    local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_ChatReceivers")
    if shouldDraw == false then return end

    currentConfig = receiverConfigs["speak"]
    hook.Add("Think", "DarkRP_chatRecipients", chatGetRecipients)
    hook.Add("HUDPaint", "DarkRP_DrawChatReceivers", drawChatReceivers)
end
hook.Add("PlayerStartVoice", "DarkRP_VoiceChatReceiverFinder", startFindVoice)

--[[---------------------------------------------------------------------------
Called when the player stops using their voice
---------------------------------------------------------------------------]]
local function stopFindVoice(ply)
    if ply ~= LocalPlayer() then return end

    stopFind()
end
hook.Add("PlayerEndVoice", "DarkRP_VoiceChatReceiverFinder", stopFindVoice)
