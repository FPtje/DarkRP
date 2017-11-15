local plyMeta = FindMetaTable("Player")
DarkRP.chatCommands = DarkRP.chatCommands or {}

local validChatCommand = {
    command = isstring,
    description = isstring,
    condition = fn.FOr{fn.Curry(fn.Eq, 2)(nil), isfunction},
    delay = isnumber,
    tableArgs = fn.FOr{fn.Curry(fn.Eq, 2)(nil), isbool},
}

local checkChatCommand = function(tbl)
    for k in pairs(validChatCommand) do
        if not validChatCommand[k](tbl[k]) then
            return false, k
        end
    end
    return true
end

function DarkRP.declareChatCommand(tbl)
    local valid, element = checkChatCommand(tbl)
    if not valid then
        DarkRP.error("Incorrect chat command! " .. element .. " is invalid!", 2)
    end

    tbl.command = string.lower(tbl.command)
    DarkRP.chatCommands[tbl.command] = DarkRP.chatCommands[tbl.command] or tbl
    for k, v in pairs(tbl) do
        DarkRP.chatCommands[tbl.command][k] = v
    end
end

function DarkRP.removeChatCommand(command)
    DarkRP.chatCommands[string.lower(command)] = nil
end

function DarkRP.chatCommandAlias(command, ...)
    local name
    for k, v in pairs{...} do
        name = string.lower(v)

        DarkRP.chatCommands[name] = {command = name}
        setmetatable(DarkRP.chatCommands[name], {
            __index = DarkRP.chatCommands[command]
        })
    end
end

function DarkRP.getChatCommand(command)
    return DarkRP.chatCommands[string.lower(command)]
end

function DarkRP.getChatCommands()
    return DarkRP.chatCommands
end

function DarkRP.getSortedChatCommands()
    local tbl = fn.Compose{table.ClearKeys, table.Copy, DarkRP.getChatCommands}()
    table.SortByMember(tbl, "command", true)

    return tbl
end

-- chat commands that have been defined, but not declared
DarkRP.getIncompleteChatCommands = fn.Curry(fn.Filter, 3)(fn.Compose{fn.Not, checkChatCommand})(DarkRP.chatCommands)

--[[---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------]]
DarkRP.declareChatCommand{
    command = "pm",
    description = "Send a private message to someone.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "w",
    description = "Say something in whisper voice.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "y",
    description = "Yell something out loud.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "me",
    description = "Chat roleplay to say you're doing things that you can't show otherwise.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "/",
    description = "Global server chat.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "a",
    description = "Global server chat.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "ooc",
    description = "Global server chat.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "broadcast",
    description = "Broadcast something as a mayor.",
    delay = 1.5,
    condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
    command = "channel",
    description = "Tune into a radio channel.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "radio",
    description = "Say something through the radio.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "g",
    description = "Group chat.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "credits",
    description = "Send the DarkRP credits to someone.",
    delay = 1.5
}
