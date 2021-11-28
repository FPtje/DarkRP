local function ExecuteSlap(target, Amount, ply)
    if not IsValid(target) or not IsValid(ply) then return end

    local Force = Vector(math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(-100, 700))

    local DmgInfo = DamageInfo()
    DmgInfo:SetDamage(Amount)
    DmgInfo:SetDamageType(DMG_DROWN)
    DmgInfo:SetAttacker(ply)
    DmgInfo:SetDamageForce(Force)

    target:TakeDamageInfo(DmgInfo)
    target:SetVelocity(Force)
end

local function Slap(ply, cmd, args)
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end
    local Amount = DarkRP.toInt(args[2]) or 10
    local Repetitions = DarkRP.toInt(args[3])

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Slap", target) then
            FAdmin.Messages.SendMessage(ply, 5, "No access!")

            return false
        end

        if IsValid(target) then
            if not Repetitions or Repetitions == 1 then
                ExecuteSlap(target, Amount, ply)
            else
                for i = 1, Repetitions, 1 do
                    timer.Simple(i * 0.7, function()
                        ExecuteSlap(target, Amount, ply)
                    end)
                end
            end
        end
    end

    FAdmin.Messages.FireNotification("slap", ply, targets)

    return true, targets, Amount, Repetitions
end

FAdmin.StartHooks["Slap"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "slap",
        hasTarget = true,
        receivers = "involved+admins",
        message = {"instigator", " slapped ", "targets"},
    }

    FAdmin.Commands.AddCommand("Slap", Slap)

    FAdmin.Access.AddPrivilege("Slap", 2)
end
