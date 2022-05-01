local function Slay(ply, cmd, args)
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end
    local SlayType = string.lower(FAdmin.PlayerActions.SlayTypes[tonumber(args[2])] or args[2] or "Normal")

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Slay", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if IsValid(target) then
            if SlayType == "normal" then
                target:Kill()
            elseif SlayType == "silent" then
                target:KillSilent()
            elseif SlayType == "explode" then
                local effectdata = EffectData()
                effectdata:SetStart(target:GetPos())
                effectdata:SetOrigin(target:GetPos())
                effectdata:SetScale(3)
                util.Effect("HelicopterMegaBomb", effectdata)
                target:EmitSound("ambient/explosions/explode_1.wav", 100, 100)
                target:SetVelocity(Vector(math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(200, 700)))
                target:Kill()
            elseif SlayType == "rocket" then
                target:SetVelocity(Vector(0,0,1000))
                timer.Simple(1, function()
                    local effectdata = EffectData()
                    effectdata:SetStart(target:GetPos())
                    effectdata:SetOrigin(target:GetPos())
                    effectdata:SetScale(3)
                    util.Effect("HelicopterMegaBomb", effectdata)
                    target:EmitSound("ambient/explosions/explode_1.wav", 100, 100)
                    target:SetVelocity(Vector(math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(200, 700)))
                    target:Kill()
                end)
            end
        end
    end

    FAdmin.Messages.FireNotification("slay", ply, targets)

    return true, targets, SlayType
end

FAdmin.StartHooks["Slay"] = function()
    FAdmin.Commands.AddCommand("Slay", Slay)

    FAdmin.Access.AddPrivilege("Slay", 2)
end
