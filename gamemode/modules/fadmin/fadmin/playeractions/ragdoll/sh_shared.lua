-- lua_Run A = Player(5):GetEyeTrace().Entity
-- lua_run for i = 1, A:GetPhysicsObjectCount() do B = A:WorldToLocal(A:GetPhysicsObjectNum(i):GetPos()) print("Vector("..B.x..", "..B.y..", "..B.z.."),") end
-- lua_run for i = 1, A:GetPhysicsObjectCount() do B = A:GetPhysicsObjectNum(i):GetAngle() print("Angle("..B.p..", "..B.y..", "..B.r.."),") end

FAdmin.PlayerActions.RagdollTypes = {
    [1] = "Normal",
    [2] = "Kick him in the nuts",
    [3] = "Hang",
    [4] = "Unragdoll"
}
