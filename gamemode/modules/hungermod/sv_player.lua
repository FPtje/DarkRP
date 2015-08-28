local meta = FindMetaTable("Player")

function meta:newHungerData()
	if not IsValid(self) then return end
	self:setSelfDarkRPVar("Energy", GAMEMODE.Config.maxhunger)
	self.LastHungerUpdate = CurTime()
end

function meta:hungerUpdate()
	if not IsValid(self) then return end
	if not GAMEMODE.Config.hungerspeed then return end

	local energy = self:getDarkRPVar("Energy")
	self:setSelfDarkRPVar("Energy", energy and math.Clamp(energy - GAMEMODE.Config.hungerspeed, 0, GAMEMODE.Config.maxhunger) or GAMEMODE.Config.maxhunger)
	self.LastHungerUpdate = CurTime()

	if self:getDarkRPVar("Energy") == 0 then
		self:SetHealth(self:Health() - GAMEMODE.Config.starverate)
		if self:Health() <= 0 and self:Alive() then
			self.Slayed = true
			self:Kill()
		end
	end
end
