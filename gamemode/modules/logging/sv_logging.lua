util.AddNetworkString('DRPLogMsg')
local function AdminLog(message, colour, allowedPlys)
    local RF = RecipientFilter()
    for _, v in pairs(allowedPlys) do
        local canHear = hook.Call("canSeeLogMessage", GAMEMODE, v, message, colour)

        if canHear then
            RF:AddPlayer(v)
        end
    end

    net.Start('DRPLogMsg')
        net.WriteInt(colour.r,16)
        net.WriteInt(colour.g,16)
        net.WriteInt(colour.b,16)
        net.WriteString(message)
    net.Send(RF)
end

local DarkRPFile
function DarkRP.log(text, colour, noFileSave)
    if colour then
        CAMI.GetPlayersWithAccess("DarkRP_SeeEvents", fp{AdminLog, text, colour})
    end

    if not GAMEMODE.Config.logging or noFileSave then return end

    if not DarkRPFile then -- The log file of this session, if it's not there then make it!
        if not file.IsDir("darkrp_logs", "DATA") then
            file.CreateDir("darkrp_logs")
        end

        DarkRPFile = "darkrp_logs/" .. os.date("%m_%d_%Y %I_%M %p") .. ".txt"
        file.Write(DarkRPFile, os.date() .. "\t" .. text)
        return
    end
    file.Append(DarkRPFile, "\n" .. os.date() .. "\t" .. (text or ""))
end
