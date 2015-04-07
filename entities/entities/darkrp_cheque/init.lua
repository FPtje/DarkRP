AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");

function ENT:Initialize()
	self:SetModel("models/props_lab/clipboard.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);

	local phys = self:GetPhysicsObject();
	self.nodupe = true
	self.ShareGravgun = true

	phys:Wake();

	hook.Add("PlayerDisconnected", self, self.onPlayerDisconnected);
end


function ENT:Use(activator, caller)
	local owner = self:Getowning_ent();
	local recipient = self:Getrecipient();
	local amount = self:Getamount() or 0

	if (IsValid(activator) and IsValid(recipient)) and activator == recipient then
		owner = (IsValid(owner) and owner:Nick()) or fprp.getPhrase("disconnected_player");
		fprp.notify(activator, 0, 4, fprp.getPhrase("found_cheque", fprp.formatshekel(amount), "", owner));
		activator:addshekel(amount);
		self:Remove();
	elseif (IsValid(owner) and IsValid(recipient)) and owner ~= activator then
		fprp.notify(activator, 0, 4, fprp.getPhrase("cheque_details", recipient:Name()));
	elseif IsValid(owner) and owner == activator then
		fprp.notify(activator, 0, 4, fprp.getPhrase("cheque_torn"));
		owner:addshekel(self:Getamount()) -- return the shekel on the cheque to the owner.
		self:Remove();
	elseif not IsValid(recipient) then self:Remove();
	end
end

function ENT:Touch(ent)
	-- the .USED var is also used in other mods for the same purpose
	if ent:GetClass() ~= "fprp_cheque" or self.USED or ent.USED or self.hasMerged or ent.hasMerged then return end
	if ent.dt.owning_ent ~= self.dt.owning_ent then return end
	if ent.dt.recipient ~= self.dt.recipient then return end

	-- Both hasMerged and USED are used by third party mods. Keep both in.
	ent.USED = true
	ent.hasMerged = true

	ent:Remove();
	self:Setamount(self:Getamount() + ent:Getamount());
end

function ENT:onPlayerDisconnected(ply)
	if self.dt.owning_ent == ply or self.dt.recipient == ply then
		self:Remove();
	end
end
