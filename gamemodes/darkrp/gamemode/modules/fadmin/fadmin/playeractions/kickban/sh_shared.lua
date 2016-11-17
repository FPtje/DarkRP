function FAdmin.PlayerActions.ConvertBanTime(time)
    local Add = ""
    time = math.Round(time)

    if time <= 0 then
        return "permanent"
    elseif time < 60 then
        -- minutes
        return math.ceil(time) .. " minute(s)"
    elseif time >= 60 and time < 1440 then
        -- hours
        if math.floor((time / 60 - math.floor(time / 60)) * 60) > 0 then
            Add = ", " .. FAdmin.PlayerActions.ConvertBanTime((time / 60 - math.floor(time / 60)) * 60)
        end

        return math.floor(time / 60) .. " hour(s)" .. Add
    elseif time >= 1440 and time < 10080 then
        -- days
        if math.floor((time / 1440 - math.floor(time / 1440)) * 1440) > 0 then
            Add = ", " .. FAdmin.PlayerActions.ConvertBanTime((time / 1440 - math.floor(time / 1440)) * 1440)
        end

        return math.floor(time / 1440) .. " day(s)" .. Add
    elseif time >= 10080 and time < 525948 then
        -- weeks
        if math.floor((time / 10080 - math.floor(time / 10080)) * 10080) > 0 then
            Add = ", " .. FAdmin.PlayerActions.ConvertBanTime((time / 10080 - math.floor(time / 10080)) * 10080)
        end

        return math.floor(time / 10080) .. " week(s)" .. Add
    elseif time >= 525948 then
        -- years
        if math.floor((time / 525948 - math.floor(time / 525948)) * 525948) > 0 then
            Add = ", " .. FAdmin.PlayerActions.ConvertBanTime((time / 525948 - math.floor(time / 525948)) * 525948)
        end

        return math.floor(time / 525948) .. " year(s)" .. Add
    end

    return time
end

FAdmin.StartHooks["kickbanning"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "kick",
        hasTarget = false,
        message = {"instigator", " kicked ", "extraInfo.1", " (", "extraInfo.2", ")"},
        receivers = "everyone",
        writeExtraInfo = function(info)
            net.WriteUInt(#info[1], 8)
            -- Manually send targets, because they might be gone from the client when kicked
            for _, target in pairs(info[1]) do
                if not IsValid(target) then
                    net.WriteString("Unknown")
                    continue
                end

                net.WriteString(target:Nick())
            end

            net.WriteString(info[2])
        end,

        readExtraInfo = function()
            local count = net.ReadUInt(8)
            local targets = {}

            for i = 1, count do
                table.insert(targets, net.ReadString())
            end

            return {table.concat(targets, ", "), net.ReadString()}
        end,
        extraInfoColors = {Color(102, 0, 255), Color(255, 102, 0)}
    }

    FAdmin.Messages.RegisterNotification{
        name = "ban",
        hasTarget = false,
        message = {"instigator", " banned ", "extraInfo.1", " for ", "extraInfo.2", " (", "extraInfo.3", ")"},
        receivers = "everyone",
        writeExtraInfo = function(info)
            net.WriteUInt(#info[1], 8)
            -- Manually send targets, because they might be gone from the client when kicked
            for _, target in pairs(info[1]) do
                if isstring(target) then
                    net.WriteString("Unknown (" .. target .. ")")
                    continue
                end

                if not IsValid(target) then
                    net.WriteString("Unknown")
                    continue
                end

                net.WriteString(target:Nick())
            end

            net.WriteUInt(info[2], 32)

            net.WriteString(info[3])
        end,

        readExtraInfo = function()
            local count = net.ReadUInt(8)
            local targets = {}

            for i = 1, count do
                table.insert(targets, net.ReadString())
            end

            return {table.concat(targets, ", "), FAdmin.PlayerActions.ConvertBanTime(net.ReadUInt(32)), net.ReadString()}
        end,

        extraInfoColors = {Color(102, 0, 255), Color(255, 102, 0), Color(255, 102, 0)}
    }

    FAdmin.Messages.RegisterNotification{
        name = "unban",
        hasTarget = false,
        message = {"instigator", " unbanned ", "extraInfo.1", " (", "extraInfo.2", ")"},
        receivers = "everyone",
        writeExtraInfo = function(info)
            net.WriteString(info[1])
            net.WriteString(info[2])
        end,

        readExtraInfo = function()
            return {net.ReadString(), net.ReadString()}
        end,

        extraInfoColors = {Color(102, 0, 255), Color(255, 102, 0)}
    }
end
