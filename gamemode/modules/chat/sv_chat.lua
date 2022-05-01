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

GM.OldChatHooks = GM.OldChatHooks or {}

local function callHooks(hooks, canReturn, ...)
    local text

    for id, f in pairs(hooks) do
        local isString

        -- ULib hook tables are {fn = func, isstring = istring(id)}
        if istable(f) then
            isString = f.isstring
            f = f.fn
        else
            isString = isstring(id)
        end

        if not isfunction(f) then continue end

        if not isString then
            -- Non valid hooks are removed, as entities don't become valid after being non-valid
            if IsValid(id) then
                text = f(id, ...)
            else
                hooks[id] = nil
            end
        else
            text = f(...)
        end

        if text ~= nil and canReturn then return text end
    end
end

local function callPlayerSayHooks(ply, text, teamonly, dead)
    if ULib then
        -- Run through priorities in order
        for priority = -2, 2 do
            local hooks = GAMEMODE.OldChatHooks[priority]
            -- Monitor hooks cannot return

            if hooks then
                local out = callHooks(hooks, priority > -2 and priority < 2, ply, text, teamonly, dead)
                if out ~= nil then return out end
            end
        end
    else
        local out = callHooks(GAMEMODE.OldChatHooks, true, ply, text, teamonly, dead)
        if out ~= nil then return out end
    end
end

local function applyHookTable(tab, priority)
    -- Set the metatable of the PlayerSay hook table
    -- This will monitor any hooks that get added or removed
    -- This is more efficient than overriding hook.Add and hook.Remove because it only adds logic to the PlayerSay hooks.
    -- If a previous metatable exists, then add this one to the "chain"
    local mt
    local oldMetatable = getmetatable(tab)
    if istable(oldMetatable) then
        local oldNI = oldMetatable.__newindex or function() end

        mt = oldMetatable
        if priority then
            mt.__newindex = function(t, k, v)
                GAMEMODE.OldChatHooks[priority][k] = v
                oldNI(t, k, v)
            end
        else
            mt.__newindex = function(t, k, v)
                GAMEMODE.OldChatHooks[k] = v
                oldNI(t, k, v)
            end
        end
    else
        if priority then
            mt = {
                __newindex = function(_, k, v)
                    GAMEMODE.OldChatHooks[priority][k] = v
                end
            }
        else
            mt = {
                __newindex = function(_, k, v)
                    GAMEMODE.OldChatHooks[k] = v
                end
            }
        end
    end

    if priority then
        mt.__index = function(tbl, k)
            return GAMEMODE.OldChatHooks[priority][k]
        end
    else
        mt.__index = function(tbl, k)
            return GAMEMODE.OldChatHooks[k]
        end
    end

    -- Someone preventing metatable changes
    -- My metatable swap should be compatible.
    -- This is a public table. Play nice, you cunt.
    if oldMetatable ~= nil then
        DarkRP.errorNoHalt("Some addon is fucking up DarkRP's chat hook reorganising mechanism. Start getting rid of scripts and addons until you don't see this error on startup anymore.")
        return
    end

    setmetatable(tab, mt)
end

function GM:PlayerSay(ply, text, teamonly) -- We will make the old hooks run AFTER DarkRP's playersay has been run.
    local dead = not ply:Alive()

    local text2 = text
    local callback
    local DoSayFunc

    text2 = callPlayerSayHooks(ply, text, teamonly, dead) or text2

    text2, callback, DoSayFunc = RP_PlayerChat(ply, text2, teamonly)
    if tostring(text2) == " " then text2, callback = callback, text2 end
    if not self.Config.deadtalk and dead then return "" end

    if game.IsDedicated() then
        ServerLog("\"" .. ply:Nick() .. "<" .. ply:UserID() .. ">" .. "<" .. ply:SteamID() .. ">" .. "<" .. team.GetName(ply:Team()) .. ">\" say \"" .. text .. "\"\n" .. "\n")
    end

    if DoSayFunc then DoSayFunc(text2) return "" end
    RP_ActualDoSay(ply, text2, callback)

    hook.Call("PostPlayerSay", nil, ply, text2, teamonly, dead)
    return ""
end

-- DarkRP has local chat and all sorts of who-sees-what chat modifiers
-- In order for chat hooks to abide by those rules, we have to make sure that
-- the DarkRP chat hook (which is the gamemode function) runs first and last
-- All other chat hooks must be run within DarkRP's function for it to play
-- nicely with its chat rules.
local function ReplaceChatHooks()
    local hookTbl = hook.GetTable()

    -- give warnings for undeclared chat commands
    local warning = fn.Compose{ErrorNoHalt, fn.Curry(string.format, 2)("Chat command \"%s\" is defined but not declared!\n")}
    fn.ForEach(warning, DarkRP.getIncompleteChatCommands())

    if ULib then
        local ulibTbl = hook.GetULibTable()
        -- Make sure the PlayerSay hook table exists
        hookTbl.PlayerSay = hookTbl.PlayerSay or {}
        ulibTbl.PlayerSay = ulibTbl.PlayerSay or {[-2] = {}, [-1] = {}, [0] = {}, [1] = {}, [2] = {}}

        for priority, hooks in pairs(ulibTbl.PlayerSay) do
            GAMEMODE.OldChatHooks[priority] = GAMEMODE.OldChatHooks[priority] or {}

            for hookName, v in pairs(hooks) do
                hooks[hookName] = nil
                GAMEMODE.OldChatHooks[priority][hookName] = v
            end

            applyHookTable(hooks, priority)
        end

    else
        -- Make sure the PlayerSay hook table exists
        hookTbl.PlayerSay = hookTbl.PlayerSay or {}

        for k, v in pairs(hookTbl.PlayerSay) do
            GAMEMODE.OldChatHooks[k] = v
            hook.Remove("PlayerSay", k)
        end

        applyHookTable(hookTbl.PlayerSay)
    end
end
hook.Add("InitPostEntity", "RemoveChatHooks", ReplaceChatHooks)

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
