local meta = FindMetaTable("Player")

function meta:NewHungerData()
	if not IsValid(self) then return end
	self:SetSelfDarkRPVar("Energy", 100)
	self:GetTable().LastHungerUpdate = 0
end

function meta:HungerUpdate()
	if not IsValid(self) then return end
	if not GAMEMODE.Config.hungerspeed then return end
	self:SetSelfDarkRPVar("Energy", math.Clamp(self.DarkRPVars.Energy - GAMEMODE.Config.hungerspeed / 10, 0, 100))
	self:GetTable().LastHungerUpdate = CurTime()

	if self.DarkRPVars.Energy == 0 then
		self:SetHealth(self:Health() - GAMEMODE.Config.starverate)
		if self:Health() <= 0 then
			self:GetTable().Slayed = true
			self:Kill()
		end
	end
end
