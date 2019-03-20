--[[---------------------------------------------------------------------------
Messages
---------------------------------------------------------------------------]]
util.AddNetworkString("AdminTell")
local function ccTell(ply, args)
    local target = DarkRP.findPlayer(args[1])

    if target then
        local msg = ""

        for n = 2, #args do
            msg = msg .. args[n] .. " "
        end

        net.Start("AdminTell")
            net.WriteString(msg)
        net.Send(target)

        if ply:EntIndex() == 0 then
            DarkRP.log("Console did admintell \"" .. msg .. "\" on " .. target:SteamName(), Color(30, 30, 30))
        else
            DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") did admintell \"" .. msg .. "\" on " .. target:SteamName(), Color(30, 30, 30))
        end
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args[1])))
    end
end
DarkRP.definePrivilegedChatCommand("admintell", "DarkRP_AdminCommands", ccTell)

local function ccTellAll(ply, args)
    net.Start("AdminTell")
        net.WriteString(args)
    net.Broadcast()

    if ply:EntIndex() == 0 then
        DarkRP.log("Console did admintellall \"" .. args .. "\"", Color(30, 30, 30))
    else
        DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") did admintellall \"" .. args .. "\"", Color(30, 30, 30))
    end

end
DarkRP.definePrivilegedChatCommand("admintellall", "DarkRP_AdminCommands", ccTellAll)
