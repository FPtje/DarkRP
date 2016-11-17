ENT.Base = "lab_base"
ENT.PrintName = "Gun Lab"

function ENT:initVars()
    self.model = "models/props_c17/TrapPropeller_Engine.mdl"
    self.initialPrice = 200
    self.labPhrase = DarkRP.getPhrase("gun_lab")
    self.itemPhrase = DarkRP.getPhrase("gun")
end
