FPP = FPP or {}
FPP.AntiSpam = {}

function FPP.AntiSpam.GhostFreeze(ent, phys)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:DrawShadow(false)
	ent.OldColor = ent.OldColor or ent:GetColor()
	ent.StartPos = ent:GetPos()
	ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a - 155))

	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent.CollisionGroup = COLLISION_GROUP_WORLD

	ent.FPPAntiSpamMotionEnabled = phys:IsMoveable()
	phys:EnableMotion(false)

	ent.FPPAntiSpamIsGhosted = true
end

function FPP.UnGhost(ply, ent)
	if ent.FPPAntiSpamIsGhosted then
		ent.FPPAntiSpamIsGhosted = nil
		ent:DrawShadow(true)
		if ent.OldCollisionGroup then ent:SetCollisionGroup(ent.OldCollisionGroup) ent.OldCollisionGroup = nil end

		if ent.OldColor then
			ent:SetColor(Color(ent.OldColor.r, ent.OldColor.g, ent.OldColor.b, ent.OldColor.a))
		end
		ent.OldColor = nil


		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
		ent.CollisionGroup = COLLISION_GROUP_NONE

		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(ent.FPPAntiSpamMotionEnabled)
		end
	end
end

function FPP.AntiSpam.CreateEntity(ply, ent, IsDuplicate)
	if not tobool(FPP.Settings.FPP_ANTISPAM1.toggle) then return end
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return end

	local class = ent:GetClass()
	-- I power by ten because the volume of a prop can vary between 65 and like a few billion
	if phys:GetVolume() and phys:GetVolume() > math.pow(10, FPP.Settings.FPP_ANTISPAM1.bigpropsize) and not string.find(class, "constraint") and not string.find(class, "hinge")
	and not string.find(class, "magnet") and not string.find(class, "collision") then
		if not IsDuplicate then
			ply.FPPAntispamBigProp = (ply.FPPAntispamBigProp or 0) + 1
			timer.Simple(10*FPP.Settings.FPP_ANTISPAM1.bigpropwait, function()
				if not ply:IsValid() then return end
				ply.FPPAntispamBigProp = ply.FPPAntispamBigProp or 0
				ply.FPPAntispamBigProp = math.Max(ply.FPPAntispamBigProp - 1, 0)
			end)
		end

		if ply.FPPAntiSpamLastBigProp and ply.FPPAntiSpamLastBigProp > (CurTime() - (FPP.Settings.FPP_ANTISPAM1.bigpropwait * ply.FPPAntispamBigProp)) then
			FPP.Notify(ply, "Please wait " .. FPP.Settings.FPP_ANTISPAM1.bigpropwait * ply.FPPAntispamBigProp .. " Seconds before spawning a big prop again", false)
			ply.FPPAntiSpamLastBigProp = CurTime()
			ent:Remove()
			return
		end

		if not IsDuplicate then
			ply.FPPAntiSpamLastBigProp = CurTime()
		end
		FPP.AntiSpam.GhostFreeze(ent, phys)
		FPP.Notify(ply, "Your prop is ghosted because it is too big. Interract with it to unghost it.", true)
		return
	end

	if not IsDuplicate then
		ply.FPPAntiSpamCount = (ply.FPPAntiSpamCount or 0) + 1
		timer.Simple(ply.FPPAntiSpamCount / FPP.Settings.FPP_ANTISPAM1.smallpropdowngradecount, function() if IsValid(ply) then ply.FPPAntiSpamCount = ply.FPPAntiSpamCount - 1 end end)
		if ply.FPPAntiSpamCount >= FPP.Settings.FPP_ANTISPAM1.smallpropghostlimit and ply.FPPAntiSpamCount <= FPP.Settings.FPP_ANTISPAM1.smallpropdenylimit
			and not ent:IsVehicle()--[[Vehicles don't like being ghosted, they tend to crash the server]] then
			FPP.AntiSpam.GhostFreeze(ent, phys)
			FPP.Notify(ply, "Your prop is ghosted for antispam, interract with it to unghost it.", true)
			return
		elseif ply.FPPAntiSpamCount > FPP.Settings.FPP_ANTISPAM1.smallpropdenylimit then
			ent:Remove()
			FPP.Notify(ply, "Prop removed due to spam", false)
			return
		end
	end
end

function FPP.AntiSpam.DuplicatorSpam(ply)
	if not tobool(FPP.Settings.FPP_ANTISPAM1.toggle) then return true end
	ply.FPPAntiSpamLastDuplicate = ply.FPPAntiSpamLastDuplicate or 0
	ply.FPPAntiSpamLastDuplicate = ply.FPPAntiSpamLastDuplicate + 1

	timer.Simple(ply.FPPAntiSpamLastDuplicate / FPP.Settings.FPP_ANTISPAM1.duplicatorlimit, function() if IsValid(ply) then ply.FPPAntiSpamLastDuplicate = ply.FPPAntiSpamLastDuplicate - 1 end end)

	if ply.FPPAntiSpamLastDuplicate >= FPP.Settings.FPP_ANTISPAM1.duplicatorlimit then
		FPP.Notify(ply, "Can't duplicate due to spam", false)
		return false
	end
	return true
end


local function IsEmpty(ent)
	local mins, maxs = ent:LocalToWorld(ent:OBBMins( )), ent:LocalToWorld(ent:OBBMaxs( ))
	local tr = {}
	tr.start = mins
	tr.endpos = maxs
	local ignore = player.GetAll()
	table.insert(ignore, ent)
	tr.filter = ignore
	local trace = util.TraceLine(tr)
	return trace.Entity
end

hook.Add("InitPostEntity", "FPP.InitializePreventSpawnInProp", function()
	local backupPropSpawn = DoPlayerEntitySpawn
	function DoPlayerEntitySpawn(ply, ...)
		local ent = backupPropSpawn(ply, ...)
		if not tobool(FPP.Settings.FPP_ANTISPAM1.antispawninprop) then return ent end

		local PropInProp = IsEmpty(ent)
		if not PropInProp:IsValid() then return ent end
		local pos = PropInProp:NearestPoint(ply:EyePos()) + ply:GetAimVector() * -1 * ent:BoundingRadius()
		ent:SetPos(pos)
		return ent
	end
end)

--More crash preventing:
local function antiragdollcrash(ply)
	local pos = ply:GetEyeTraceNoCursor().HitPos
	for k,v in pairs(ents.FindInSphere(pos, 30)) do
		if v:GetClass() == "func_door" then
			FPP.Notify(ply, "Can't spawn a ragdoll near doors", false)
			return false
		end
	end
end
hook.Add("PlayerSpawnRagdoll", "FPP.AntiSpam.AntiCrash", antiragdollcrash)