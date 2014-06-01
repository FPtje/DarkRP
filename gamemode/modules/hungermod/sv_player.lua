local meta = FindMetaTable("Player")

function meta:newHungerData()
	if not IsValid(self) then return end
	self:setSelfDarkRPVar("Energy", 100)
	self:GetTable().LastHungerUpdate = 0
end

function meta:hungerUpdate()
	if not IsValid(self) then return end
	if not GAMEMODE.Config.hungerspeed then return end
	self:setSelfDarkRPVar("Energy", math.Clamp(self:getDarkRPVar("Energy") - GAMEMODE.Config.hungerspeed, 0, 100))
	self:GetTable().LastHungerUpdate = CurTime()

	if self:getDarkRPVar("Energy") == 0 then
		self:SetHealth(self:Health() - GAMEMODE.Config.starverate)
		if self:Health() <= 0 then
			self:GetTable().Slayed = true
			self:Kill()
		end
	end
end
