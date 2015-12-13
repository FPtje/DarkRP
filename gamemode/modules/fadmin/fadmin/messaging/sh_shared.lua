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

FAdmin.Notifications = {}

local validNotification = tc.assertTable{
    -- A name to identify the notification by
    name =
        tc.assert(
            isstring,
            "The name must be a string!"
        ),

    -- Whether the notification applies to some kind of target
    hasTarget =
        tc.assert(
            tc.optional(isbool),
            "hasTarget must either be true, false or nil!"
        ),

    -- Who receives the notification. Can be either one of the list or a function that returns a table of players
    receivers =
        tc.assert(
            fn.FOr{tc.client, isfunction, tc.oneOf{"everyone", "admins", "superadmins", "self", "targets", "involved", "involved+admins", "involved+superadmins"}},
            "receivers must either be a function returning a table of players or one of 'admins', 'superadmins', 'everyone', 'self', 'targets', 'involved', 'involved+admins', 'involved+superadmins'"
        ),

    -- A table containing the message in parts. There are special strings
    message =
        tc.assert(
            fn.FOr{tc.server, tc.tableOf(isstring)},
            "The message field must be a table of strings! with special strings 'targets', 'you', 'instigator', 'extraInfo.#', with # a number."
        ),

    -- The message type when chat notifications are disabled. NOTIFY by default
    msgType =
        tc.default(
            "NOTIFY",
            tc.assert(
                tc.oneOf{"ERROR", "NOTIFY", "QUESTION", "GOOD", "BAD"}, "msgType must be one of 'ERROR', 'NOTIFY', 'QUESTION', 'GOOD', 'BAD'"
            )
        ),

    -- A function that writes extra data in the net message
    writeExtraInfo =
        tc.assert(
            tc.optional(isfunction),
            "writeExtraInfo must be a function"
        ),

    -- A function that reads the written data, formats it and puts it in a table
    readExtraInfo =
        tc.assert(
            tc.optional(isfunction),
            "writeExtraInfo must be a function"
        ),

    -- When using extra information, this table contains the colours of the extraInfo messages
    extraInfoColors =
        tc.assert(
            tc.optional(tc.tableOf(tc.iscolor)),
            "extraInfoColors must be a table of colours!"
        )
}


FAdmin.NotificationNames = {}

function FAdmin.Messages.RegisterNotification(tbl)
    local correct, err = validNotification(tbl)

    if not correct then
        error(string.format("Incorrect notification format!\n\n%s", err), 2)
    end

    local key = table.insert(FAdmin.Notifications, tbl)
    FAdmin.NotificationNames[tbl.name] = key

    return key
end
