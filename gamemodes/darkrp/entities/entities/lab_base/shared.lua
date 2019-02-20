ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Lab"
ENT.Author = "DarkRP Developers"
ENT.Spawnable = false
ENT.CanSetPrice = true

-- These are variables that should be set in entities that base from this
ENT.model = ""
ENT.initialPrice = 0
ENT.labPhrase = ""
ENT.itemPhrase = ""
ENT.noIncome = false
ENT.camMul = -30
ENT.blastRadius = 200
ENT.blastDamage = 200

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:initVars()
    -- Implement this to set the above variables
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "price")
    self:NetworkVar("Entity", 1, "owning_ent")
end
