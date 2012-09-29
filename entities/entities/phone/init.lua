
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/weapons/w_camphone.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end

	if self.dt.IsBeingHeld then return end--Don't make noise when already picked up

	self.sound = CreateSound(self, "ambient/alarms/city_firebell_loop1.wav")
	self.sound:PlayEx(0.6, 60)
	timer.Simple(2, function(ent) if ent and ent.sound then ent.sound:Stop() end end, self)
	local S = self.sound
	timer.Create("PhoneRinging"..tostring(self:EntIndex()), 3.5, 0, function(sound)
		sound:PlayEx(0.6, 60)
		timer.Simple(2, function(s) s:Stop() end, sound)
	end, S)
end


function ENT:Use( activator, caller )

	if ( !activator:IsPlayer() ) then return end

	-- Someone is already using the phone
	if ( self.LastUser && self.LastUser:IsValid() ) then return end

	if ValidEntity(self.Caller) and activator == self.Caller then return end

	if self.sound then
		self.sound:Stop()
	end

	timer.Remove("PhoneRinging"..tostring(self:EntIndex()))

	local head = activator:LookupBone("ValveBiped.Bip01_Head1")
	local headPos, headAng = activator:GetBonePosition(head)
	self:SetSolid(SOLID_NONE)
	self:SetPos(headPos)

	headAng:RotateAroundAxis(headAng:Right(), 270)
	headAng:RotateAroundAxis(headAng:Up(), 180)
	self:SetAngles(headAng)
	self:SetParent(activator)

	self.dt.IsBeingHeld = true

	if ValidEntity(self.Caller) then -- if you're BEING called and pick up the phone...
		local ply = self.Caller -- the one who called you
		ply.DarkRPVars.phone.Caller = activator -- Make sure he knows YOU picked up the phone
		ply.DarkRPVars.phone.HePickedUp = true

		activator:SetDarkRPVar("phone", self) -- This object is the phone you're holding

		activator:SendLua([[RunConsoleCommand("+voicerecord")]])
		ply:SendLua([[RunConsoleCommand("+voicerecord")]])
		timer.Create("PhoneCallCosts"..ply:EntIndex(), 20, 0, function(ply, ent) -- Make the caller pay!
			if ValidEntity(ply) and ply:CanAfford(1) then
				ply:AddMoney(-1)
			else
				ent:HangUp()
			end
		end, ply, self)
	end

	self.LastUser = activator
end

function ENT:Think()
	if not self.dt.owning_ent:Alive() then
		self:HangUp()
	end
	if self.HePickedUp and not ValidEntity(self.Caller) then
		self:HangUp(true)
	end

	if ValidEntity(self.LastUser) then
		self:SetParent()
		local head = self.LastUser:LookupBone("ValveBiped.Bip01_Head1")
		local headPos, headAng = self.LastUser:GetBonePosition(head)
		self:SetSolid(SOLID_NONE)
		self:SetPos(headPos)

		headAng:RotateAroundAxis(headAng:Right(), 270)
		headAng:RotateAroundAxis(headAng:Up(), 180)
		self:SetAngles(headAng)
		//self:GetPhysicsObject():EnableMotion(false)
		self:SetParent(self.LastUser)
	end
end

function ENT:HangUp(force)
	local ply = self.dt.owning_ent
	local him = self.Caller
	local HisPhone

	timer.Remove("PhoneCallCosts"..ply:EntIndex())

	if ValidEntity(him) then
		HisPhone = him.DarkRPVars.phone
		timer.Remove("PhoneCallCosts"..him:EntIndex())
		him:SendLua([[RunConsoleCommand("-voicerecord")]])
	end

	if ValidEntity(ply) and ply:IsPlayer() then
		ply:SendLua([[RunConsoleCommand("-voicerecord")]])
	end

	if ValidEntity(HisPhone) then
		self:EmitSound("buttons/combine_button2.wav", 50, 100)
		self:Remove()
		HisPhone:Remove()
	end

	if force then
		self:EmitSound("buttons/combine_button2.wav", 50, 100)
		self:Remove()
	end
end

function ENT:OnRemove()
	if self.sound then
		self.sound:Stop()
	end
	timer.Destroy("PhoneRinging"..tostring(self:EntIndex()))
	self:HangUp()
end
