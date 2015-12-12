FAdmin.Messages = {}

FAdmin.Messages.MsgTypes = {
--[[ 1 --]] ERROR = {COLOR = Color(255,180,0,80)},
--[[ 2 --]] NOTIFY = {COLOR = Color(255,255,0,80)},
--[[ 3 --]] QUESTION = {COLOR = Color(0,0,255,80)},
--[[ 4 --]] GOOD = {COLOR = Color(0,255,0,80)},
--[[ 5 --]] BAD = {COLOR = Color(255,0,0,80)}
}

FAdmin.Notifications = {}

local validNotification = tc.assertTable{
    name = tc.assert(isstring, "The name must be a string!"),
    hasTarget = tc.assert(tc.optional(isbool), "hasTarget must either be true, false or nil!"),

    -- Receivers - optional on the client
    receivers = tc.assert(fn.FOr{tc.client, isfunction, tc.oneOf{"everyone", "admins", "superadmins", "self", "targets", "involved"}}, "receivers must either be a function returning a list of players or one of 'admins', 'superadmins', 'everyone', 'self', 'targets', 'involved'"),
    --msgType = tc.assert(tc.optional(tc.oneOf{"ERROR", "NOTIFY", "QUESTION", "GOOD", "BAD"}), "msgType must be one of 'ERROR', 'NOTIFY', 'QUESTION', 'GOOD', 'BAD'"),
    message = tc.assert(fn.FOr{tc.server, tc.tableOf(isstring)}, "The message field must be a table of strings! with special strings 'targets', 'you', 'instigator'")
}


FAdmin.NotificationNames = {}

function FAdmin.Messages.RegisterNotification(tbl)
    local correct, err = validNotification(tbl)

    if not correct then
        error(string.format("Incorrect notification format!\n\n%s", err), 2)
    end

    --tbl.msgType = tbl.msgType or "GOOD"

    local key = table.insert(FAdmin.Notifications, tbl)
    FAdmin.NotificationNames[tbl.name] = key

    return key
end
