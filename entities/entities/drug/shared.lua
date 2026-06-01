ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Drugs"
ENT.Author = "Rickster"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "price")
    self:NetworkVar("Entity", 1, "owning_ent")
end

hook.Add("Move", "DruggedPlayer", function(ply, mv)
    if not ply.isDrugged then return end

    mv:SetMaxSpeed(mv:GetMaxSpeed() * 2)
    mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 2)

    if ply:IsOnGround() and mv:KeyPressed(IN_JUMP) then
        local vec = mv:GetVelocity()
        vec.z = 100 -- Adds on to the jump power
        mv:SetVelocity(vec)
    end
end)
