AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");

function ENT:Initialize()
	self:SetModel(GAMEMODE.Config.shekelModel or "models/props/cs_assault/money.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);

	local phys = self:GetPhysicsObject();
	self.nodupe = true
	self.ShareGravgun = true

	phys:Wake();
end

function ENT:Use(activator,caller)
	if self.USED or self.hasMerged then return end
	local amount = self:Getamount();

	activator:addshekel(amount or 0);
	fprp.notify(activator, 0, 4, fprp.getPhrase("found_shekel", fprp.formatshekel(self:Getamount())));
	self:Remove();
end

function ENT:Touch(ent)
	-- the .USED var is also used in other mods for the same purpose
	if ent:GetClass() ~= "spawned_money" or self.USED or ent.USED or self.hasMerged or ent.hasMerged then return end

	-- Both hasMerged and USED are used by third party mods. Keep both in.
	ent.USED = true
	ent.hasMerged = true

	ent:Remove();
	self:Setamount(self:Getamount() + ent:Getamount());
	if GAMEMODE.Config.shekelRemoveTime and  GAMEMODE.Config.shekelRemoveTime ~= 0 then
		timer.Adjust("RemoveEnt"..self:EntIndex(), GAMEMODE.Config.shekelRemoveTime, 1, fn.Partial(SafeRemoveEntity, self));
	end
end
