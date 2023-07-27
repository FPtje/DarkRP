-- lua_Run A = Player(5):GetEyeTrace().Entity
-- lua_run for i = 1, A:GetPhysicsObjectCount() do B = A:WorldToLocal(A:GetPhysicsObjectNum(i):GetPos()) print("Vector("..B.x..", "..B.y..", "..B.z.."),") end
-- lua_run for i = 1, A:GetPhysicsObjectCount() do B = A:GetPhysicsObjectNum(i):GetAngle() print("Angle("..B.p..", "..B.y..", "..B.r.."),") end

FAdmin.PlayerActions.RagdollTypes = {
    [1] = "Normal",
    [2] = "Kick them in the nuts",
    [3] = "Hang",
    [4] = "Unragdoll"
}

FAdmin.StartHooks["Ragdolling"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "ragdoll",
        hasTarget = true,
        message = {"instigator", " ragdolled ", "targets", " ", "extraInfo.1"},
        receivers = "involved+admins",
        writeExtraInfo = function(info) net.WriteUInt(info[1], 16) end,
        readExtraInfo = function()
            local time = net.ReadUInt(16)
            return {time == 0 and FAdmin.PlayerActions.commonTimes[time] or string.format("for %s", FAdmin.PlayerActions.commonTimes[time] or (time .. " seconds"))}
        end
    }

    FAdmin.Messages.RegisterNotification{
        name = "unragdoll",
        hasTarget = true,
        message = {"instigator", " unragdolled ", "targets"},
        receivers = "involved+admins",
    }
end
