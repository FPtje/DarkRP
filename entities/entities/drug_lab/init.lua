AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");

ENT.SeizeReward = 350

function ENT:Initialize()
	self:SetModel("models/props_lab/crematorcase.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	local phys = self:GetPhysicsObject();
	phys:Wake();
	self.sparking = false
	self.damage = 100
	local ply = self:Getowning_ent();
	self.SID = ply.SID
	self:Setprice(math.Clamp((GAMEMODE.Config.pricemin ~= 0 and GAMEMODE.Config.pricemin) or 100, (GAMEMODE.Config.pricecap ~= 0 and GAMEMODE.Config.pricecap) or 100));
	self.CanUse = true
	self.ShareGravgun = true
end

function ENT:OnTakeDamage(dmg)
	self.damage = self.damage - dmg:GetDamage();
	if (self.damage <= 0) then
		self:Remove();
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos();
	local effectdata = EffectData();
	effectdata:SetStart(vPoint);
	effectdata:SetOrigin(vPoint);
	effectdata:SetScale(1);
	util.Effect("Explosion", effectdata);
end

function ENT:Use(activator,caller)
	if not self.CanUse then return false end
	self.CanUse = false
	self.drug_user = activator
	if activator.maxDrugs and activator.maxDrugs >= GAMEMODE.Config.maxdrugs then
		fprp.notify(activator, 1, 3, fprp.getPhrase("limit", string.lower(fprp.getPhrase("drugs"))));
		timer.Simple(0.5, function() self.CanUse = true end)
	else
		local productioncost = math.random(math.Round(self:Getprice() / 8), math.Round(self:Getprice() / 4));
		if not activator:canAfford(productioncost) then
			fprp.notify(activator, 1, 4, fprp.getPhrase("cant_afford", string.lower(fprp.getPhrase("drugs"))));
			timer.Simple(0.5, function() self.CanUse = true end)
			return false
		end
		activator:addshekel(-productioncost);
		fprp.notify(activator, 0, 4, fprp.getPhrase("you_bought", string.lower(fprp.getPhrase("drugs")), fprp.formatshekel(productioncost), ""));
		self.sparking = true
		timer.Create(self:EntIndex() .. "drug", 1, 1, function() self:createDrug() end)
	end
end

function ENT:createDrug()
	self.CanUse = true
	local userb = self.drug_user
	local drugPos = self:GetPos();
	local drug = ents.Create("drug");
	drug:SetPos(Vector(drugPos.x,drugPos.y,drugPos.z + 35));
	drug:Setowning_ent(userb);
	drug.SID = userb.SID
	drug.ShareGravgun = true
	drug.nodupe = true
	drug:Setprice(self:Getprice() or 100);
	drug:Spawn();
	if not userb.maxDrugs then
		userb.maxDrugs = 0
	end
	userb.maxDrugs = userb.maxDrugs + 1
	self.sparking = false
end

function ENT:Think()
	if not self.SID then
		self.SID = self:Getprice();
	end
	if self.sparking then
		local effectdata = EffectData();
		effectdata:SetOrigin(self:GetPos());
		effectdata:SetMagnitude(1);
		effectdata:SetScale(1);
		effectdata:SetRadius(2);
		util.Effect("Sparks", effectdata);
	end
end

function ENT:OnRemove()
	if not IsValid(self) then return end
	timer.Destroy(self:EntIndex() .. "drug");
	self:Destruct();
end
