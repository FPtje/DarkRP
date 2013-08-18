include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
end

function ENT:Use(activator, caller)
	print("Called")
	activator:GiveAmmo(self.amountGiven, self.ammoType)
	self:Remove()
end
