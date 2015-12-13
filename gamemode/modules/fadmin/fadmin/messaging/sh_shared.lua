FAdmin.Messages = {}

FAdmin.Messages.MsgTypes = {
    ERROR = {COLOR = Color(255,180,0,80)},
    NOTIFY = {COLOR = Color(255,255,0,80)},
    QUESTION = {COLOR = Color(0,0,255,80)},
    GOOD = {COLOR = Color(0,255,0,80)},
    BAD = {COLOR = Color(255,0,0,80)}
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
    name = tc.assert(isstring, "The name must be a string!"),
    hasTarget = tc.assert(tc.optional(isbool), "hasTarget must either be true, false or nil!"),

    -- Receivers - optional on the client
    receivers = tc.assert(fn.FOr{tc.client, isfunction, tc.oneOf{"everyone", "admins", "superadmins", "self", "targets", "involved", "involved+admins", "involved+superadmins"}}, "receivers must either be a function returning a list of players or one of 'admins', 'superadmins', 'everyone', 'self', 'targets', 'involved', 'involved+admins', 'involved+superadmins'"),
    message = tc.assert(fn.FOr{tc.server, tc.tableOf(isstring)}, "The message field must be a table of strings! with special strings 'targets', 'you', 'instigator', 'extraInfo.#', with # a number."),

    -- The message type when chat notifications are disabled. NOTIFY by default
    msgType = tc.default("NOTIFY", tc.assert(tc.oneOf{"ERROR", "NOTIFY", "QUESTION", "GOOD", "BAD"}, "msgType must be one of 'ERROR', 'NOTIFY', 'QUESTION', 'GOOD', 'BAD'")),

    writeExtraInfo = tc.assert(tc.optional(isfunction), "writeExtraInfo must be a function"),
    readExtraInfo = tc.assert(tc.optional(isfunction), "writeExtraInfo must be a function"),

    extraInfoColors = tc.assert(tc.optional(tc.tableOf(tc.assertTable{r,g,b})), "extraInfoColors must be a table of colours!")
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
