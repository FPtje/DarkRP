--[[---------------------------------------------------------
Talking
 ---------------------------------------------------------]]
local function PM(ply, args)
    local namepos = string.find(args, " ")
    if not namepos then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end

    local name = string.sub(args, 1, namepos - 1)
    local msg = string.sub(args, namepos + 1)

    if msg == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end

    local target = DarkRP.findPlayer(name)

    if target then
        local col = team.GetColor(ply:Team())
        DarkRP.talkToPerson(target, col, "(PM) " .. ply:Nick(), Color(255, 255, 255, 255), msg, ply)
        DarkRP.talkToPerson(ply, col, "(PM) " .. ply:Nick(), Color(255, 255, 255, 255), msg, ply)
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(name)))
    end

    return ""
end
DarkRP.defineChatCommand("pm", PM, 1.5)

local function Whisper(ply, args)
    local DoSay = function(text)
        if text == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return ""
        end
        DarkRP.talkToRange(ply, "(" .. DarkRP.getPhrase("whisper") .. ") " .. ply:Nick(), text, 90)
    end
    return args, DoSay
end
DarkRP.defineChatCommand("w", Whisper, 1.5)

local function Yell(ply, args)
    local DoSay = function(text)
        if text == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return ""
        end
        DarkRP.talkToRange(ply, "(" .. DarkRP.getPhrase("yell") .. ") " .. ply:Nick(), text, 550)
    end
    return args, DoSay
end
DarkRP.defineChatCommand("y", Yell, 1.5)

local function Me(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end

    local DoSay = function(text)
        if text == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return ""
        end
        if GAMEMODE.Config.alltalk then
            for _, target in pairs(player.GetAll()) do
                DarkRP.talkToPerson(target, team.GetColor(ply:Team()), ply:Nick() .. " " .. text)
            end
        else
            DarkRP.talkToRange(ply, ply:Nick() .. " " .. text, "", 250)
        end
    end
    return args, DoSay
end
DarkRP.defineChatCommand("me", Me, 1.5)

local function OOC(ply, args)
    if not GAMEMODE.Config.ooc then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("disabled", DarkRP.getPhrase("ooc"), ""))
        return ""
    end

    local DoSay = function(text)
        if text == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return ""
        end
        local col = team.GetColor(ply:Team())
        local col2 = Color(255,255,255,255)
        if not ply:Alive() then
            col2 = Color(255,200,200,255)
            col = col2
        end
        for k,v in pairs(player.GetAll()) do
            DarkRP.talkToPerson(v, col, "(" .. DarkRP.getPhrase("ooc") .. ") " .. ply:Name(), col2, text, ply)
        end
    end
    return args, DoSay
end
DarkRP.defineChatCommand("/", OOC, true, 1.5)
DarkRP.defineChatCommand("a", OOC, true, 1.5)
DarkRP.defineChatCommand("ooc", OOC, true, 1.5)

local function MayorBroadcast(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end
    if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then DarkRP.notify(ply, 1, 4, "You have to be mayor") return "" end
    local DoSay = function(text)
        if text == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return
        end
        for k,v in pairs(player.GetAll()) do
            local col = team.GetColor(ply:Team())
            DarkRP.talkToPerson(v, col, DarkRP.getPhrase("broadcast") .. " " .. ply:Nick(), Color(170, 0, 0, 255), text, ply)
        end
    end
    return args, DoSay
end
DarkRP.defineChatCommand("broadcast", MayorBroadcast, 1.5)

local function SetRadioChannel(ply,args)
    if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 100 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "0<channel<100"))
        return ""
    end
    DarkRP.notify(ply, 2, 4, DarkRP.getPhrase("channel_set_to_x", args))
    ply.RadioChannel = tonumber(args)
    return ""
end
DarkRP.defineChatCommand("channel", SetRadioChannel)

local function SayThroughRadio(ply,args)
    if not ply.RadioChannel then ply.RadioChannel = 1 end
    if not args or args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end
    local DoSay = function(text)
        if text == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return
        end
        for k,v in pairs(player.GetAll()) do
            if v.RadioChannel == ply.RadioChannel then
                DarkRP.talkToPerson(v, Color(180,180,180,255), DarkRP.getPhrase("radio_x", ply.RadioChannel), Color(180,180,180,255), text, ply)
            end
        end
    end
    return args, DoSay
end
DarkRP.defineChatCommand("radio", SayThroughRadio, 1.5)

local function GroupMsg(ply, args)
    local DoSay = function(text)
        if text == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return
        end

        local col = team.GetColor(ply:Team())

        local groupChats = {}
        for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
            -- not the group of the player
            if not func(ply) then continue end

            table.insert(groupChats, func)
        end

        if #groupChats == 0 then return "" end

        for _, target in pairs(player.GetAll()) do
            -- The target is in any of the group chats
            for k, func in pairs(groupChats) do
                if not func(target, ply) then continue end

                DarkRP.talkToPerson(target, col, DarkRP.getPhrase("group") .. " " .. ply:Nick(), Color(255,255,255,255), text, ply)
                break
            end
        end
    end
    return args, DoSay
end
DarkRP.defineChatCommand("g", GroupMsg, 0)

-- here's the new easter egg. Easier to find, more subtle, doesn't only credit FPtje and unib5
-- WARNING: DO NOT EDIT THIS
-- You can edit DarkRP but you HAVE to credit the original authors!
-- You even have to credit all the previous authors when you rename the gamemode.
-- local CreditsWait = true
local function GetDarkRPAuthors(ply, args)
    local target = DarkRP.findPlayer(args) -- Only send to one player. Prevents spamming
    target = IsValid(target) and target or ply

    if target ~= ply then
        if ply.CreditsWait then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("wait_with_that")) return "" end
        ply.CreditsWait = true
        timer.Simple(60, function() if IsValid(ply) then ply.CreditsWait = nil end end) -- so people don't spam it
    end

    local rf = RecipientFilter()
    rf:AddPlayer(target)
    if ply ~= target then
        rf:AddPlayer(ply)
    end

    umsg.Start("DarkRP_Credits", rf)
    umsg.End()

    return ""
end
DarkRP.defineChatCommand("credits", GetDarkRPAuthors, 50)
