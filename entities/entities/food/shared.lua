ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Food"
ENT.Author = "Pcwizdan"
ENT.Spawnable = false
ENT.EatSound = "vo/sandwicheat09.mp3" -- Requires Team Fortress 2

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 1, "owning_ent")
end
