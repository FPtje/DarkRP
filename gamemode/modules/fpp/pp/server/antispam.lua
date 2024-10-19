FPP = FPP or {}
FPP.AntiSpam = FPP.AntiSpam or {}

function FPP.AntiSpam.GhostFreeze(ent, phys)
    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
    ent:DrawShadow(false)
    ent.FPPOldColor = ent.FPPOldColor or ent:GetColor()
    ent.StartPos = ent:GetPos()
    ent:SetColor(Color(ent.FPPOldColor.r, ent.FPPOldColor.g, ent.FPPOldColor.b, ent.FPPOldColor.a - 155))

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

        if ent.FPPOldColor then
            ent:SetColor(Color(ent.FPPOldColor.r, ent.FPPOldColor.g, ent.FPPOldColor.b, ent.FPPOldColor.a))
        end
        ent.FPPOldColor = nil


        ent:SetCollisionGroup(COLLISION_GROUP_NONE)
        ent.CollisionGroup = COLLISION_GROUP_NONE

        local phys = ent:GetPhysicsObject()
        if phys:IsValid() then
            phys:EnableMotion(ent.FPPAntiSpamMotionEnabled)
        end
    end
end

local blacklist = {
    ["gmod_wire_indicator"] = true,
    ["phys_constraint"] = true
}
function FPP.AntiSpam.CreateEntity(ply, ent, IsDuplicate)
    if not tobool(FPP.Settings.FPP_ANTISPAM1.toggle) then return end
    local phys = ent:GetPhysicsObject()
    if not phys:IsValid() then return end
    local entTable = ent:GetTable()
    -- Some spawn methods trigger different paths to this function, causing an
    -- entity to be counted multiple times for antispam.
    if entTable.FPPCountedForAntispam then return end
    entTable.FPPCountedForAntispam = true

    local shouldRegister = hook.Call("FPP_ShouldRegisterAntiSpam", nil, ply, ent, IsDuplicate)
    if shouldRegister == false then return end

    local class = ent:GetClass()
    -- I power by ten because the volume of a prop can vary between 65 and like a few billion
    if tobool(FPP.Settings.FPP_ANTISPAM1.bigpropantispam) and phys:GetVolume() and phys:GetVolume() > math.pow(10, FPP.Settings.FPP_ANTISPAM1.bigpropsize) and not string.find(class, "constraint") and not string.find(class, "hinge")
    and not string.find(class, "magnet") and not string.find(class, "collision") and not blacklist[class] then
        ply.FPPAntispamBigProp = ply.FPPAntispamBigProp or 0
        ply.FPPAntiSpamLastBigProp = ply.FPPAntiSpamLastBigProp or 0
        if not IsDuplicate then
            ply.FPPAntispamBigProp = ply.FPPAntispamBigProp + 1
        end

        local curTime = CurTime()
        local spawningBlockedUntil =
            ply.FPPAntiSpamLastBigProp + ply.FPPAntispamBigProp * FPP.Settings.FPP_ANTISPAM1.bigpropwait

        if curTime < spawningBlockedUntil then
            -- The current attempt would have been blocked until
            -- spawningBlockedUntil. The next attempt will add up to that time.
            -- The wait time is thus the time the user should wait before the
            -- next attempt.
            local waitTime = spawningBlockedUntil + FPP.Settings.FPP_ANTISPAM1.bigpropwait - curTime
            FPP.Notify(
                ply,
                "Please wait " .. math.Round(waitTime, 2) .. " Seconds before spawning a big prop again",
                false,
                waitTime
            )
            ent:Remove()
            return
        end

        if not IsDuplicate then
            ply.FPPAntiSpamLastBigProp = curTime
            -- Spawning succeeded, reset big prop count to 0
            ply.FPPAntispamBigProp = 0
        end
        local waitTime = FPP.Settings.FPP_ANTISPAM1.bigpropwait
        FPP.AntiSpam.GhostFreeze(ent, phys)
        FPP.Notify(
            ply,
            "Your prop is ghosted because it is too big. Interract with it to unghost it.",
            true,
            waitTime
        )
        return
    end

    if not IsDuplicate and not blacklist[class] then
        ply.FPPAntiSpamCount = (ply.FPPAntiSpamCount or 0) + 1
        local time = math.Max(1, FPP.Settings.FPP_ANTISPAM1.smallpropdowngradecount)
        timer.Simple(ply.FPPAntiSpamCount / time, function()
            if IsValid(ply) then
                ply.FPPAntiSpamCount = ply.FPPAntiSpamCount - 1
            end
        end)

        if ply.FPPAntiSpamCount >= FPP.Settings.FPP_ANTISPAM1.smallpropghostlimit and ply.FPPAntiSpamCount <= FPP.Settings.FPP_ANTISPAM1.smallpropdenylimit
            and not ent:IsVehicle() --[[Vehicles don't like being ghosted, they tend to crash the server]] then
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
    if FPP.Settings.FPP_ANTISPAM1.duplicatorlimit == 0 then return true end

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

local function e2AntiMinge()
    if not wire_expression2_funcs then return end
    local e2func = wire_expression2_funcs["applyForce(e:v)"]
    if not e2func or not e2func[3] then return end

    local applyForce = e2func[3]
    e2func[3] = function(self, args, ...)
        if not tobool(FPP.Settings.FPP_GLOBALSETTINGS1.antie2minge) then return applyForce(self, args, ...) end

        local arg_2_1 = args[2][1]
        local ent
        -- In some earlier versions of wiremod, args[2][1] is a function, which
        -- can be called to get the target entity.
        if isfunction(arg_2_1) then
            ent = args[2][1](self, args[2])
        else
            -- In later versions, the first argument is the entity
            ent = args[1]
        end
        if not IsValid(ent) or ent:CPPIGetOwner() ~= self.player then return end

        -- No check for whether the entity has already been no collided with players
        -- because while it would help performance,
        -- it would make it possible to get around this with constrained ents
        local ConstrainedEnts = constraint.GetAllConstrainedEntities(ent)
        if ConstrainedEnts then -- Includes original entity
            for _, v in pairs(ConstrainedEnts) do
                if IsValid(v) then
                    v:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                end
            end
        end

        return applyForce(self, args, ...)
    end
end

hook.Add("InitPostEntity", "FPP.InitializeAntiMinge", function()
    local backupPropSpawn = DoPlayerEntitySpawn
    function DoPlayerEntitySpawn(ply, ...)
        local ent = backupPropSpawn(ply, ...)
        if not tobool(FPP.Settings.FPP_ANTISPAM1.antispawninprop) then return ent end

        local PropInProp = IsEmpty(ent)
        if not IsValid(PropInProp) then return ent end
        local pos = PropInProp:NearestPoint(ply:EyePos()) + ply:GetAimVector() * -1 * ent:BoundingRadius()
        ent:SetPos(pos)
        return ent
    end

    e2AntiMinge()
end)
e2AntiMinge()

--More crash preventing:
local function antiragdollcrash(ply)
    local pos = ply:GetEyeTraceNoCursor().HitPos
    for _, v in ipairs(ents.FindInSphere(pos, 30)) do
        if v:GetClass() == "func_door" then
            FPP.Notify(ply, "Can't spawn a ragdoll near doors", false)
            return false
        end
    end
end
hook.Add("PlayerSpawnRagdoll", "FPP.AntiSpam.AntiCrash", antiragdollcrash)
