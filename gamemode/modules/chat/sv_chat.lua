local function registerCommandDefinition(cmd, callback)
    local chatcommands = DarkRP.getChatCommands()

    chatcommands[cmd] = chatcommands[cmd] or {}
    chatcommands[cmd].callback = callback
    chatcommands[cmd].command = chatcommands[cmd].command or cmd
end

function DarkRP.defineChatCommand(cmd, callback)
    cmd = string.lower(cmd)
    local detour = function(ply, arg, ...)
        local canChatCommand = gamemode.Call("canChatCommand", ply, cmd, arg, ...)
        if not canChatCommand then
            return ""
        end

        local ret = {callback(ply, arg, ...)}
        local overrideTxt, overrideDoSayFunc = hook.Run("onChatCommand", ply, cmd, arg, ret, ...)

        if overrideTxt then return overrideTxt, overrideDoSayFunc end
        return unpack(ret)
    end

    registerCommandDefinition(cmd, detour)
end

function DarkRP.definePrivilegedChatCommand(cmd, priv, callback, extraInfoTbl)
    cmd = string.lower(cmd)

    local function onCAMIResult(ply, arg, hasAccess, reason)
        if hasAccess then return callback(ply, arg) end

        local notify = ply:EntIndex() == 0 and print or fp{DarkRP.notify, ply, 1, 4}
        notify(DarkRP.getPhrase("no_privilege"))
    end

    local function callbackdetour(ply, arg, ...)
        local canChatCommand = gamemode.Call("canChatCommand", ply, cmd, arg)
        if not canChatCommand then
            return ""
        end

        CAMI.PlayerHasAccess(ply, priv, fp{onCAMIResult, ply, arg}, nil, extraInfoTbl)

        local overrideTxt, overrideDoSayFunc = hook.Run("onChatCommand", ply, cmd, arg, {""})

        if overrideTxt then return overrideTxt, overrideDoSayFunc end
        return ""
    end

    registerCommandDefinition(cmd, callbackdetour)
end

local function RP_PlayerChat(ply, text, teamonly)
    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. "): " .. text)
    local callback = ""
    local DoSayFunc
    local groupSay = DarkRP.getChatCommand("g")

    -- Extract the chat command
    local tblCmd = fn.Compose{
        DarkRP.getChatCommand,
        string.lower,
        fn.Curry(fn.Flip(string.sub), 2)(2), -- extract prefix
        fn.Curry(fn.GetValue, 2)(1), -- Get the first word
        fn.Curry(string.Explode, 2)(' ') -- split by spaces
    }(text)

    if string.sub(text, 1, 1) == GAMEMODE.Config.chatCommandPrefix and tblCmd then
        local args = string.sub(text, string.len(tblCmd.command) + 3, string.len(text))
        args = tblCmd.tableArgs and DarkRP.explodeArg(args) or args

        ply.DrpCommandDelays = ply.DrpCommandDelays or {}
        if tblCmd.delay and ply.DrpCommandDelays[tblCmd.command] and ply.DrpCommandDelays[tblCmd.command] > CurTime() - tblCmd.delay then
            return ""
        end

        ply.DrpCommandDelays[tblCmd.command] = CurTime()

        callback, DoSayFunc = tblCmd.callback(ply, args)
        if callback == "" then
            return "", "", DoSayFunc
        end
        text = string.sub(text, string.len(tblCmd.command) + 3, string.len(text))
    elseif teamonly and groupSay then
        callback, DoSayFunc = groupSay.callback(ply, text)
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
    local col = team.GetColor(ply:Team())
    local col2 = color_white
    if not ply:Alive() then
        col2 = Color(255, 200, 200, 255)
        col = col2
    end

    if GAMEMODE.Config.alltalk then
        local name = ply:Nick()
        for _, v in ipairs(player.GetAll()) do
            DarkRP.talkToPerson(v, col, callback .. name, col2, text, ply)
        end
    else
        DarkRP.talkToRange(ply, callback .. ply:Nick(), text, GAMEMODE.Config.talkDistance)
    end
    return ""
end

function GM:canChatCommand(ply, cmd, ...)
    if not ply.DarkRPUnInitialized then return true end

    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("data_not_loaded_one"))
    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("data_not_loaded_two"))

    return false
end

g_DarkRPOldHookCall = g_DarkRPOldHookCall or hook.Call

local GM = GM
function hook.Call(name, gm, ply, text, teamonly, ...)
    if name == "PlayerSay" then
        local dead = not ply:Alive()

        local text2 = text
        local callback
        local DoSayFunc

        text2 = g_DarkRPOldHookCall(name, gm, ply, text, teamonly, dead) or text2

        text2, callback, DoSayFunc = RP_PlayerChat(ply, text2, teamonly)
        if tostring(text2) == " " then text2, callback = callback, text2 end
        if not GM.Config.deadtalk and dead then return "" end

        if game.IsDedicated() then
            ServerLog("\"" .. ply:Nick() .. "<" .. ply:UserID() .. ">" .. "<" .. ply:SteamID() .. ">" .. "<" .. team.GetName(ply:Team()) .. ">\" say \"" .. text .. "\"\n" .. "\n")
        end

        if DoSayFunc then DoSayFunc(text2) return "" end
        RP_ActualDoSay(ply, text2, callback)

        hook.Call("PostPlayerSay", nil, ply, text2, teamonly, dead)
        return ""
    end

    return g_DarkRPOldHookCall(name, gm, ply, text, teamonly, ...)
end

local function ConCommand(ply, _, args)
    if not args[1] then return end
    local cmd = string.lower(args[1])
    local tbl = DarkRP.getChatCommand(cmd)

    if not tbl then return end

    table.remove(args, 1) -- Remove subcommand
    local arg = tbl.tableArgs and args or table.concat(args, ' ')
    local time = CurTime()

    if not tbl then return end

    ply.DrpCommandDelays = ply.DrpCommandDelays or {}

    if IsValid(ply) then -- Server console isn't valid
        if tbl.delay and ply.DrpCommandDelays[cmd] and ply.DrpCommandDelays[cmd] > time - tbl.delay then
            return
        end

        ply.DrpCommandDelays[cmd] = time
    end

    tbl.callback(ply, arg)
end
concommand.Add("darkrp", ConCommand)
