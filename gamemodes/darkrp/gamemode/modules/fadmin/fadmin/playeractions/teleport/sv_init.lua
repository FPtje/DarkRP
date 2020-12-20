local function zapEffect(target)
    local effectdata = EffectData()
    effectdata:SetStart(target:GetShootPos())
    effectdata:SetOrigin(target:GetShootPos())
    effectdata:SetScale(1)
    effectdata:SetMagnitude(1)
    effectdata:SetScale(3)
    effectdata:SetRadius(1)
    effectdata:SetEntity(target)
    for i = 1, 100, 1 do
        timer.Simple(1 / i, function()
            util.Effect("TeslaHitBoxes", effectdata, true, true)
        end)
    end
    local Zap = math.random(1,9)
    if Zap == 4 then Zap = 3 end
    target:EmitSound("ambient/energy/zap" .. Zap .. ".wav")
end

local function TPToPos(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "Teleport") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local x, y, z = string.match(args[1] or "", "([-0-9\\.]+),%s?([-0-9\\.]+),%s?([-0-9\\.]+)")
    local vx, vy, vz = string.match(args[2] or "", "([-0-9\\.]+),%s?([-0-9\\.]+),%s?([-0-9\\.]+)")
    local pos = Vector(tonumber(x), tonumber(y), tonumber(z))
    local vel = Vector(tonumber(vx), tonumber(vy), tonumber(vz))

    if not args[1] or not x or not y or not z then return false end

    ply:SetPos(pos)
    if vx and vy and vz then ply:SetVelocity(vel) end
    zapEffect(ply)

    return true, pos, vel
end

local function Teleport(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "Teleport") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        targets = {ply}
    end

    for _, target in pairs(targets) do
        if IsValid(target) and target:Alive() then
            target:ExitVehicle()

            local tracedata = {}
            tracedata.start = ply:GetShootPos()
            tracedata.endpos = tracedata.start + ply:GetAimVector() * 10000
            tracedata.filter = ply

            local trace = util.TraceLine(tracedata)
            local offset = Vector(0, 0, 1)
            if trace.HitNormal ~= Vector(0, 0, 1) then
                offset = trace.HitNormal * 16
            end

            local _, hull = ply:GetHull()

            local InitialPosition = DarkRP.findEmptyPos(trace.HitPos + offset, {ply}, 600, 20, hull)
            target:SetPos(InitialPosition)

            zapEffect(target)
            FAdmin.Log(string.format("FAdmin: %s (%s) teleported %s", ply:Nick(), ply:SteamID(), target:Nick()))
        end
    end

    return true, targets, ply:GetEyeTrace().HitPos
end

local function Bring(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "Teleport") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    local BringTo = FAdmin.FindPlayer(args[2])

    BringTo = (BringTo and BringTo[1]) or ply
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    for _, target in pairs(targets) do
        if not IsValid(target) or target == ply then continue end

        target:ExitVehicle()
        if not target:Alive() then target:Spawn() end
        local PHYSGUN = false
        if IsValid(target:GetActiveWeapon()) and target:GetActiveWeapon():GetClass() == "weapon_physgun" and target:KeyDown(IN_ATTACK) then
            target:ConCommand("-attack") --release the stuff he's holding :)
            target:GetActiveWeapon():Remove()
            PHYSGUN = true
        end
        timer.Simple(0, function()
            if not IsValid(target) then return end
            local tracedata = {}
            tracedata.start = BringTo:GetShootPos()
            tracedata.endpos = tracedata.start + BringTo:GetAimVector() * 50
            tracedata.filter = BringTo

            local trace = util.TraceLine(tracedata)
            if trace.HitPos:DistToSqr(BringTo:GetShootPos()) < 2025 then
                tracedata.endpos = tracedata.start - BringTo:GetAimVector() * 50
                trace = util.TraceLine(tracedata)
            end

            local _, hull = target:GetHull()

            target:SetPos(DarkRP.findEmptyPos(BringTo:GetPos(), {target}, 600, 30, hull))

            zapEffect(target)

            if PHYSGUN then timer.Simple(0.5, function() target:Give("weapon_physgun") target:SelectWeapon("weapon_physgun") end) end
        end)
    end

    FAdmin.Messages.FireNotification("bring", ply, targets)

    return true, targets, BringTo
end

local function Goto(ply, cmd, args)
    if not FAdmin.Access.PlayerHasPrivilege(ply, "Teleport") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    if not args[1] then return false end

    local target = FAdmin.FindPlayer(args[1])
    target = target and target[1]
    if not IsValid(target) then return false end

    ply:ExitVehicle()
    if not ply:Alive() then ply:Spawn() end

    local _, hull = ply:GetHull()

    ply:SetPos(DarkRP.findEmptyPos(target:GetPos(), {ply}, 600, 30, hull))

    zapEffect(ply)

    FAdmin.Messages.FireNotification("goto", ply, target)

    return true, target
end

FAdmin.StartHooks["zz_Teleport"] = function()
    FAdmin.Access.AddPrivilege("Teleport", 2)

    FAdmin.Messages.RegisterNotification{
        name = "goto",
        hasTarget = true,
        receivers = "admins",
        message = {"instigator", " teleported to ", "targets"},
    }

    FAdmin.Messages.RegisterNotification{
        name = "bring",
        hasTarget = true,
        receivers = "admins",
        message = {"instigator", " brought ", "targets", " to them"},
    }

    FAdmin.Commands.AddCommand("Teleport", Teleport)
    FAdmin.Commands.AddCommand("TP", Teleport)
    FAdmin.Commands.AddCommand("Bring", Bring)
    FAdmin.Commands.AddCommand("Goto", Goto)
    FAdmin.Commands.AddCommand("TPToPos", TPToPos)
end
