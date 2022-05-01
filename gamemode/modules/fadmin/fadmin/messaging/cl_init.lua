local showChat = CreateClientConVar("FAdmin_ShowChatNotifications", 1, true, false)

local HUDNote_c = 0
local HUDNote_i = 1
local HUDNotes = {}

--Notify ripped off the Sandbox notify, changed to my likings
function FAdmin.Messages.AddMessage(MsgType, Message)
    local tab = {}
    tab.text    = Message
    tab.recv    = SysTime()
    tab.velx    = 0
    tab.vely    = -5
    surface.SetFont("GModNotify")
    local w, _  = surface.GetTextSize(Message)
    tab.x       = ScrW() / 2 + w * 0.5 + (ScrW() / 20)
    tab.y       = ScrH()
    tab.a       = 255
    local MsgTypeNames = {"ERROR", "NOTIFY", "QUESTION", "GOOD", "BAD"}
    if not MsgTypeNames[MsgType] then return end
    tab.col = FAdmin.Messages.MsgTypes[MsgTypeNames[MsgType]].COLOR

    table.insert(HUDNotes, tab)

    HUDNote_c = HUDNote_c + 1
    HUDNote_i = HUDNote_i + 1

    LocalPlayer():EmitSound("npc/turret_floor/click1.wav", 30, 100)
end

usermessage.Hook("FAdmin_SendMessage", function(u) FAdmin.Messages.AddMessage(u:ReadShort(), u:ReadString()) end)


local function DrawNotice(k, v, i)
    local H = ScrH() / 1024
    local x = v.x - 75 * H
    local y = v.y - 27
    surface.SetFont("GModNotify")
    local w, h = surface.GetTextSize(v.text)
    h = h + 16
    local col = v.col

    draw.RoundedBox(4, x - w - h + 24, y - 8, w + h - 16, h, col)
    -- Draw Icon
    surface.SetDrawColor(255, 255, 255, v.a)

    draw.DrawNonParsedSimpleText(v.text, "GModNotify", x + 1, y + 1, Color(0, 0, 0, v.a * 0.8), TEXT_ALIGN_RIGHT)
    draw.DrawNonParsedSimpleText(v.text, "GModNotify", x - 1, y - 1, Color(0, 0, 0, v.a * 0.5), TEXT_ALIGN_RIGHT)
    draw.DrawNonParsedSimpleText(v.text, "GModNotify", x + 1, y - 1, Color(0, 0, 0, v.a * 0.6), TEXT_ALIGN_RIGHT)
    draw.DrawNonParsedSimpleText(v.text, "GModNotify", x - 1, y + 1, Color(0, 0, 0, v.a * 0.6), TEXT_ALIGN_RIGHT)
    draw.DrawNonParsedSimpleText(v.text, "GModNotify", x, y, Color(255, 255, 255, v.a), TEXT_ALIGN_RIGHT)
    local ideal_y = ScrH() - (HUDNote_c - i) * h
    local ideal_x = ScrW() / 2 + w * 0.5 + (ScrW() / 20)
    local timeleft = 6 - (SysTime() - v.recv)

    -- Cartoon style about to go thing
    if (timeleft < 0.8) then
        ideal_x = ScrW() / 2 + w * 0.5 + 200
    end

    -- Gone!
    if (timeleft < 0.5) then
        ideal_y = ScrH() + 50
    end

    local spd = RealFrameTime() * 15
    v.y = v.y + v.vely * spd
    v.x = v.x + v.velx * spd
    local dist = ideal_y - v.y
    v.vely = v.vely + dist * spd * 1

    if (math.abs(dist) < 2 and math.abs(v.vely) < 0.1) then
        v.vely = 0
    end

    dist = ideal_x - v.x
    v.velx = v.velx + dist * spd * 1

    if math.abs(dist) < 2 and math.abs(v.velx) < 0.1 then
        v.velx = 0
    end

    -- Friction.. kind of FPS independant.
    v.velx = v.velx * (0.95 - RealFrameTime() * 8)
    v.vely = v.vely * (0.95 - RealFrameTime() * 8)
end

local function HUDPaint()
    if not HUDNotes then return end
    local i = 0

    for k, v in pairs(HUDNotes) do
        if v ~= 0 then
            i = i + 1
            DrawNotice(k, v, i)
        end
    end

    for k, v in pairs(HUDNotes) do
        if v ~= 0 and v.recv + 6 < SysTime() then
            HUDNotes[k] = 0
            HUDNote_c = HUDNote_c - 1

            if HUDNote_c == 0 then
                HUDNotes = {}
            end
        end
    end
end
hook.Add("HUDPaint", "FAdmin_MessagePaint", HUDPaint)

local function ConsoleMessage(um)
    MsgC(Color(255, 0, 0, 255), "(FAdmin) ", Color(200, 0, 200, 255), um:ReadString() .. "\n")
end
usermessage.Hook("FAdmin_ConsoleMessage", ConsoleMessage)


local red = Color(255, 0, 0)
local white = Color(190, 190, 190)
local brown = Color(102, 51, 0)
local blue = Color(102, 0, 255)

-- Inserts the instigator into a notification message
local function insertInstigator(res, instigator, _)
    table.insert(res, brown)
    table.insert(res, FAdmin.PlayerName(instigator))
end

-- Inserts the targets into the notification message
local function insertTargets(res, _, targets)
    table.insert(res, blue)
    table.insert(res, FAdmin.TargetsToString(targets))
end

local modMessage = {
    instigator = insertInstigator,
    you = function(res) table.insert(res, brown) table.insert(res, "you") end,
    targets = insertTargets,
}
local function showNotification(notification, instigator, targets, extraInfo)
    local res = {red, "[", white, "FAdmin", red, "] "}

    for _, text in pairs(notification.message) do
        if modMessage[text] then modMessage[text](res, instigator, targets) continue end

        if string.sub(text, 1, 10) == "extraInfo." then
            local id = tonumber(string.sub(text, 11))

            table.insert(res, notification.extraInfoColors and notification.extraInfoColors[id] or white)
            table.insert(res, extraInfo[id])
            continue
        end

        table.insert(res, white)
        table.insert(res, text)
    end

    if showChat:GetBool() then
        chat.AddText(unpack(res))
    else
        local msgTbl = {}
        for i = 8, #res, 2 do table.insert(msgTbl, res[i]) end

        FAdmin.Messages.AddMessage(FAdmin.Messages.MsgTypesByName[notification.msgType], table.concat(msgTbl, ""))

        MsgC(unpack(res))
        Msg("\n")
    end
end

local function receiveNotification()
    local id = net.ReadUInt(16)
    local notification = FAdmin.Notifications[id]
    local instigator = net.ReadEntity()

    local targets = {}

    if notification.hasTarget then
        local targetCount = net.ReadUInt(8)
        for i = 1, targetCount do
            table.insert(targets, net.ReadEntity())
        end
    end

    local extraInfo = notification.readExtraInfo and notification.readExtraInfo()

    showNotification(notification, instigator, targets, extraInfo)
end
net.Receive("FAdmin_Notification", receiveNotification)
