local meta = FindMetaTable("Player");

function meta:newHungerData()
	if not IsValid(self) then return end
	self:setSelffprpVar("Energy", 100);
	self:GetTable().LastHungerUpdate = 0
end

function meta:hungerUpdate()
	if not IsValid(self) then return end
	if not GAMEMODE.Config.hungerspeed then return end

	local energy = self:getfprpVar("Energy");
	self:setSelffprpVar("Energy", energy and math.Clamp(energy - GAMEMODE.Config.hungerspeed, 0, 100) or 100);
	self:GetTable().LastHungerUpdate = CurTime();

	if self:getfprpVar("Energy") == 0 then
		self:SetHealth(self:Health() - GAMEMODE.Config.starverate);
		if self:Health() <= 0 then
			self:GetTable().Slayed = true
			self:Kill();
		end
	end
end
