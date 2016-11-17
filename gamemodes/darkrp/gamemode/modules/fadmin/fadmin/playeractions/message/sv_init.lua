local function DoMessage(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "Message") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    if not args[2] then return false end

    ply.FAdmin_LastMessageTime = ply.FAdmin_LastMessageTime or CurTime() - 2
    if ply.FAdmin_LastMessageTime > (CurTime() - 2) then
        FAdmin.Messages.SendMessage(ply, 5, "Wait before sending a new message")
        return false
    end

    ply.FAdmin_LastMessageTime = CurTime()

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) or not args[3] then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end
    local MsgType = tonumber(args[2]) or 2
    for _, target in pairs(targets) do
        if IsValid(target) then
            FAdmin.Messages.SendMessage(target, MsgType, ply:Nick() .. ": " .. args[3])
        end
    end

    if ply ~= targets[1] then
        FAdmin.Messages.SendMessage(ply, MsgType, ply:Nick() .. ": " .. args[3])
    end

    return true, targets, MsgType, args[3]
end


FAdmin.StartHooks["DoMessage"] = function()
    FAdmin.Commands.AddCommand("Message", DoMessage)

    FAdmin.Access.AddPrivilege("Message", 1) -- Anyone can send messages. Why not?
end
