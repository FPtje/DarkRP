ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spawned Food"
ENT.Author = "Rickster"
ENT.Spawnable = false
ENT.IsSpawnedFood = true
ENT.EatSound = "vo/sandwicheat09.mp3" -- Requires Team Fortress 2

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 1, "owning_ent")
end
