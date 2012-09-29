TOOL.AddToMenu = false


if CLIENT then
    language.Add("Tool_checkpoint_setter_name", "Checkpoint setter")
    language.Add("Tool_checkpoint_setter_desc", "Set checkpoints for the race")
    language.Add("Tool_checkpoint_setter_0", "Left mouse to add a start/checkpoint, Right mouse to set the finish" )
end

function TOOL:LeftClick(trace)
	if not IsValid(self:GetSWEP():GetNWEntity("Game")) or CLIENT then return end

    local pos, ang = self:CalcPosAng(self:GetOwner())

	if not self:GetWeapon():GetNWBool("RadiusMode") and pos then
		local checkpoint = self:GetSWEP():GetNWEntity("Game"):addCheckpoint(pos, ang)

		if IsValid(checkpoint) and checkpoint:GetClass() == "ent_checkpoint" then
			self:GetWeapon():SetNWBool("Radiusmode", true)
            self:GetOwner():ChatPrint("Now left click to select the radius!")
			self.Checkpoint = checkpoint
            return
		end
        self:GetOwner():ChatPrint("Now left click to create a checkpoint! Right click to make the finish!")
	elseif self:GetWeapon():GetNWBool("RadiusMode") then -- Select radius
		self.Checkpoint.dt.radius = trace.HitPos:Distance(self.Checkpoint:GetPos())
		self:GetWeapon():SetNWBool("Radiusmode", false)
	end
end

function TOOL:RightClick(trace)
    local pos, ang = self:CalcPosAng(self:GetOwner())
	if not IsValid(self:GetSWEP():GetNWEntity("Game")) or CLIENT or not pos then return end
	self:GetSWEP():GetNWEntity("Game"):createFinish(self:CalcPosAng(self:GetOwner()))
end

function TOOL:UpdateGhostCheckpoint(ent, ply)
	if not IsValid(ent) then return end

	local model = self:GetSWEP():GetNWString("nextEntity") == "start" and "models/props_c17/truss02a.mdl" or "models/XQM/Rails/gumball_1.mdl"
	ent:SetModel(model)

    ent:SetNoDraw(false)

    local pos, ang = self:CalcPosAng(self:GetOwner())
    if not pos then ent:SetNoDraw(true) return end

    if self:GetSWEP():GetNWString("nextEntity") == "checkpoint" and CLIENT then
        ent:SetMaterial("models/debug/debugwhite")
        ent:SetColor(255,255,0,80)
        ent:SetModelScale(Vector(10,10,10))
    else
        pos = pos + Vector(0,0,68)
        ent:SetColor(255,255,255,255)
    end

    ent:SetPos(pos)
    ent:SetAngles(ang)
end

function TOOL:CalcPosAng(ply)
	local tr = utilx.GetPlayerTrace(ply, ply:GetCursorAimVector())
    local trace = util.TraceLine(tr)
    if not trace.Hit then return end

    if trace.HitNormal ~= Vector(0,0,1) or self:GetWeapon():GetNWBool("RadiusMode") then
    	return false
    end

    local Ang = trace.HitNormal:Angle()
    Ang.pitch = Ang.pitch + 90
    Ang.yaw = self:GetOwner():EyeAngles().yaw

    local min = IsValid(ent) and ent:OBBMins() or Vector(0,0,-128)
    local pos = trace.HitPos - trace.HitNormal * min.z * 0.5
    if self:GetSWEP():GetNWString("nextEntity") == "start" then
        pos = pos - Vector(0,0,67)
    end

    return pos, Ang
end

function TOOL:Think()
	--if SERVER and not IsValid(self:GetSWEP():GetNWEntity("Game")) then return end
    if not self.GhostEntity or not self.GhostEntity:IsValid() then
    	local model = self:GetSWEP():GetNWString("nextEntity") == "start" and "models/props_c17/truss02a.mdl" or "models/XQM/Rails/gumball_1.mdl"
        self:MakeGhostEntity(model, Vector(0,0,0), Angle(0,0,0) )
    end

    self:UpdateGhostCheckpoint(self.GhostEntity, self:GetOwner())

    if SERVER and self:GetWeapon():GetNWBool("RadiusMode") then
    	self.Checkpoint.dt.radius = self:GetOwner():GetEyeTrace().HitPos:Distance(self.Checkpoint:GetPos())
	end
end