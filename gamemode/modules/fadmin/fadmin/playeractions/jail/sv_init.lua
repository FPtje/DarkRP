local function Jail(ply, cmd, args)
    if not args[1] then return false end

    local targets = FAdmin.FindPlayer(args[1])
    if not targets or #targets == 1 and not IsValid(targets[1]) then
        FAdmin.Messages.SendMessage(ply, 1, "Player not found")
        return false
    end

    local JailType = FAdmin.PlayerActions.JailTypes[tonumber(args[2])] or args[2] or FAdmin.PlayerActions.JailTypes[2]
    JailType = string.lower(JailType)
    local JailTime = tonumber(args[3]) or 0
    local time = ""

    for _, target in pairs(targets) do
        if not FAdmin.Access.PlayerHasPrivilege(ply, "Jail", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
        if not IsValid(target) then continue end
        local jailDistance = 50

        ply:ExitVehicle()

        local JailProps = {}
        if JailType == "unjail" or string.lower(cmd) == "unjail" then
            if target.FAdminJailProps then
                for k,v in pairs(target.FAdminJailProps) do
                    if not IsValid(k) then continue end
                    k:SetCanRemove(true)
                    k:Remove()
                end
            end

            target.FAdminJailProps = nil
            timer.Remove("FAdmin_jail" .. target:UserID())
            timer.Remove("FAdmin_jail_watch" .. target:UserID())
            target:FAdmin_SetGlobal("fadmin_jailed", false)

        elseif JailType == "small" then
            table.insert(JailProps, {pos = Vector(0,0,58), ang = Angle(0,0,0), model = "models/props_wasteland/laundry_dryer001.mdl"})
        elseif JailType == "normal" then
            jailDistance = 70
            table.insert(JailProps, {pos = Vector(0,0,-5), ang = Angle(90,0,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
            table.insert(JailProps, {pos = Vector(0,0,97), ang = Angle(90,0,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})

            table.insert(JailProps, {pos = Vector(21,31,46), ang = Angle(0,90,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
            table.insert(JailProps, {pos = Vector(21,-31,46), ang = Angle(0,90,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
            table.insert(JailProps, {pos = Vector(-21,31,46), ang = Angle(0,90,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
            table.insert(JailProps, {pos = Vector(-21,-31,46), ang = Angle(0,90,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})

            table.insert(JailProps, {pos = Vector(-52,0,46), ang = Angle(0,0,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
            table.insert(JailProps, {pos = Vector(52,0,46), ang = Angle(0,0,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})

        elseif JailType == "big" then -- Requires CSS but it's really funny
            jailDistance = 80
            table.insert(JailProps, {pos = Vector(0,0,-5), ang = Angle(0,0,0), model = "models/props/cs_havana/gazebo.mdl"})
            table.insert(JailProps, {pos = Vector(70,0,50), ang = Angle(0,0,0), model = "models/props_borealis/borealis_door001a.mdl"})

            table.insert(JailProps, {pos = Vector(-70,0,100), ang = Angle(0,0,90), model = "models/props_lab/lockerdoorleft.mdl"})
            table.insert(JailProps, {pos = Vector(-35,-55,100), ang = Angle(0,60,90), model = "models/props_lab/lockerdoorleft.mdl"})
            table.insert(JailProps, {pos = Vector(-35,55,100), ang = Angle(0,300,90), model = "models/props_lab/lockerdoorleft.mdl"})

            table.insert(JailProps, {pos = Vector(35,-55,100), ang = Angle(0,300,90), model = "models/props_lab/lockerdoorleft.mdl"})
            table.insert(JailProps, {pos = Vector(35,55,100), ang = Angle(0,240,90), model = "models/props_lab/lockerdoorleft.mdl"})
        end
        if not target:FAdmin_GetGlobal("fadmin_jailed") and JailType ~= "unjail" and string.lower(cmd) ~= "unjail"  then
            target:SetMoveType(MOVETYPE_WALK)

            target:FAdmin_SetGlobal("fadmin_jailed", true)
            target.FAdminJailPos = target:GetPos()
            target.FAdminJailProps = {}

            for k,v in pairs(JailProps) do
                local JailProp = ents.Create("fadmin_jail")
                JailProp:SetPos(target.FAdminJailPos + v.pos)
                JailProp:SetAngles(v.ang)
                JailProp:SetModel(v.model)
                JailProp:Spawn()
                JailProp:Activate()

                JailProp.target = target
                JailProp.targetPos = target.FAdminJailPos
                target.FAdminJailProps[JailProp] = true
            end

            if JailTime ~= 0 then
                timer.Create("FAdmin_jail" .. target:UserID(), JailTime, 1, function()
                    if not IsValid(target) then return end
                    if not target:FAdmin_GetGlobal("fadmin_jailed") then return end
                    timer.Remove("FAdmin_jail_watch" .. target:UserID())
                    target:FAdmin_SetGlobal("fadmin_jailed", false)

                    for k, v in pairs(target.FAdminJailProps) do
                        if not IsValid(k) then continue end
                        k:SetCanRemove(true)
                        k:Remove()
                    end

                    target.FAdminJailProps = nil
                end)
            end

            jailDistance = jailDistance * jailDistance
            local userid = target:UserID()
            timer.Create("FAdmin_jail_watch" .. target:UserID(), 1, 0, function()
                if not IsValid(target) then
                    timer.Remove("FAdmin_jail_watch" .. userid)

                    return
                end

                if target:GetPos():DistToSqr(target.FAdminJailPos) > jailDistance then
                    target:SetPos(target.FAdminJailPos)
                end
            end)

            time = "for " .. JailTime .. " seconds"
            if JailTime == 0 then time = "indefinitely" end
        end
    end
    if JailType == "unjail" or string.lower(cmd) == "unjail" then
        FAdmin.Messages.ActionMessage(ply, targets, "Unjailed %s", "You were unjailed by %s", "Unjailed %s")
    else
        FAdmin.Messages.ActionMessage(ply, targets, "Jailed %s in a " .. JailType .. " jail " .. time, "You were jailed " .. time .. " by %s", "Jailed %s for " .. time)
    end

    return true, targets, JailType, time
end

FAdmin.StartHooks["Jail"] = function()
    FAdmin.Commands.AddCommand("Jail", Jail)
    FAdmin.Commands.AddCommand("UnJail", Jail)

    FAdmin.Access.AddPrivilege("Jail", 2)
end

hook.Add("PlayerSpawn", "FAdmin_jail", function(ply)
    if ply:FAdmin_GetGlobal("fadmin_jailed") then
        timer.Simple(0.1, function() if IsValid(ply) then ply:SetPos(ply.FAdminJailPos) end end)
    end
end)

hook.Add("PlayerNoClip", "FAdmin_jail", function(ply)
    if ply:FAdmin_GetGlobal("fadmin_jailed") then
        return false
    end
end)

hook.Add("PlayerSpawnObject", "FAdmin_jailed", function(ply)
    if ply:FAdmin_GetGlobal("fadmin_jailed") then
        return false
    end
end)

hook.Add("CanPlayerEnterVehicle", "FAdmin_jailed", function(ply)
    if ply:FAdmin_GetGlobal("fadmin_jailed") then
        return false
    end
end)

--Kill stupid addons that does not call CanPlayerEnterVehicle (like Sit Anywhere script)
hook.Add("PlayerEnteredVehicle", "FAdmin_jailed", function(ply) 
    if ply:FAdmin_GetGlobal("fadmin_jailed") then
        ply:ExitVehicle()
    end
end)
