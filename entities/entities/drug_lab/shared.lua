ENT.Base = "lab_base"
ENT.PrintName = "Drug Lab"

function ENT:initVars()
    self.model = "models/props_lab/crematorcase.mdl"
    self.initialPrice = 100
    self.labPhrase = DarkRP.getPhrase("drug_lab")
    self.itemPhrase = string.lower(DarkRP.getPhrase("drugs"))
    self.noIncome = true
    self.camMul = -39
end
