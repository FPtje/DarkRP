FAdmin.Messages = {}

FAdmin.Messages.MsgTypes = {
    ERROR = {TEXTURE = "icon16/exclamation.png", COLOR = Color(255,180,0,80)},
    NOTIFY = {TEXTURE = "vgui/notices/error", COLOR = Color(255,255,0,80)},
    QUESTION = {TEXTURE = "vgui/notices/hint", COLOR = Color(0,0,255,80)},
    GOOD = {TEXTURE = "icon16/tick.png", COLOR = Color(0,255,0,80)},
    BAD = {TEXTURE = "icon16/cross.png", COLOR = Color(255,0,0,80)}
}
FAdmin.Messages.MsgTypesByName = {
    ERROR = 1,
    NOTIFY = 2,
    QUESTION = 3,
    GOOD = 4,
    BAD = 5,
}

function FAdmin.PlayerName(ply)
    if CLIENT and ply == LocalPlayer() then return "you" end

    if isstring(ply) then return ply end

    return isentity(ply) and (ply:EntIndex() == 0 and "Console" or ply:Nick()) or "unknown"
end

function FAdmin.TargetsToString(targets)
    if not istable(targets) then
        return FAdmin.PlayerName(targets)
    end

    local targetCount = #targets
    if targetCount == 0 then
        return "no one"
    end

    if targetCount == player.GetCount() and targetCount ~= 1 then
        return "everyone"
    end

    targets = table.Copy(targets)
    local names = fn.Map(FAdmin.PlayerName, targets)

    if #names == 1 then
        return names[1]
    end

    return table.concat(names, ", ", 1, #names - 1) .. " and " .. names[#names]
end

FAdmin.Notifications = {}

local validNotification = tc.checkTable{
    -- A name to identify the notification by
    name =
        tc.addHint(
            isstring,
            "The name must be a string!"
        ),

    -- Whether the notification applies to some kind of target
    hasTarget =
        tc.addHint(
            tc.optional(isbool),
            "hasTarget must either be true, false or nil!"
        ),

    -- Who receives the notification. Can be either one of the list or a function that returns a table of players
    receivers =
        tc.addHint(
            fn.FOr{tc.client, isfunction, tc.oneOf{"everyone", "admins", "superadmins", "self", "targets", "involved", "involved+admins", "involved+superadmins"}},
            "receivers must either be a function returning a table of players or one of 'admins', 'superadmins', 'everyone', 'self', 'targets', 'involved', 'involved+admins', 'involved+superadmins'"
        ),

    -- A table containing the message in parts. There are special strings
    message =
        tc.addHint(
            tc.tableOf(isstring),
            "The message field must be a table of strings! with special strings 'targets', 'you', 'instigator', 'extraInfo.#', with # a number."
        ),

    -- The message type when chat notifications are disabled. NOTIFY by default
    msgType =
        tc.default(
            "NOTIFY",
            tc.addHint(
                tc.oneOf{"ERROR", "NOTIFY", "QUESTION", "GOOD", "BAD"}, "msgType must be one of 'ERROR', 'NOTIFY', 'QUESTION', 'GOOD', 'BAD'"
            )
        ),

    -- A function that writes extra data in the net message
    writeExtraInfo =
        tc.addHint(
            tc.optional(isfunction),
            "writeExtraInfo must be a function"
        ),

    -- A function that reads the written data, formats it and puts it in a table
    readExtraInfo =
        tc.addHint(
            tc.optional(isfunction),
            "writeExtraInfo must be a function"
        ),

    -- When using extra information, this table contains the colours of the extraInfo messages
    extraInfoColors =
        tc.addHint(
            tc.optional(tc.tableOf(tc.iscolor)),
            "extraInfoColors must be a table of colours!"
        ),

    -- Whether the notification is to be logged to console
    logging =
        tc.default(true,
            tc.addHint(
                isbool,
                "logging must be a boolean!"
            )
        ),
}


FAdmin.NotificationNames = {}

function FAdmin.Messages.RegisterNotification(tbl)
    local correct, err = validNotification(tbl)

    if not correct then
        error(string.format("Incorrect notification format for notification '%s'!\n\n%s", istable(tbl) and tbl.name or "unknown", err), 2)
    end

    local key = table.insert(FAdmin.Notifications, tbl)
    FAdmin.NotificationNames[tbl.name] = key

    return key
end
