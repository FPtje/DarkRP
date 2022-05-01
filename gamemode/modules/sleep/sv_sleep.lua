-- very old sleep module
local KnockoutTime = 5

local function ResetKnockouts(player)
    player.SleepRagdoll = nil
    player.KnockoutTimer = 0
end
hook.Add("PlayerSpawn", "Knockout", ResetKnockouts)

local function stopSleep(ply)
    if ply.Sleeping then
        DarkRP.toggleSleep(ply, "force")
    end
end

local function onRagdollArrested(arrestee, _, arrester)
    DarkRP.toggleSleep(arrestee, "force")

    -- onArrestStickUsed
    local canArrest, message = hook.Call("canArrest", DarkRP.hooks, arrester, arrestee)
    if not canArrest then
        if message then DarkRP.notify(arrester, 1, 5, message) end
        return
    end

    arrestee:arrest(nil, arrester)

    DarkRP.notify(arrestee, 0, 20, DarkRP.getPhrase("youre_arrested_by", arrester:Nick()))

    if arrester.SteamName then
        DarkRP.log(arrester:Nick() .. " (" .. arrester:SteamID() .. ") arrested " .. arrestee:Nick(), Color(0, 255, 255))
    end
end

local hookCanSleep = {canSleep = function(_, ply, force)
    if not ply:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", "/sleep") end
    if (not ply.KnockoutTimer or ply.KnockoutTimer + KnockoutTime >= CurTime()) and not force then return false, DarkRP.getPhrase("have_to_wait", math.ceil((ply.KnockoutTimer + KnockoutTime) - CurTime()), "/sleep") end
    if ply:IsFrozen() then return false, DarkRP.getPhrase("unable", "/sleep", DarkRP.getPhrase("frozen")) end

    return true
end}

function DarkRP.toggleSleep(player, command)
    if player:InVehicle() then return end

    local canSleep, message = hook.Call("canSleep", hookCanSleep, player, command == "force")

    if not canSleep then
        DarkRP.notify(player, 1, 4, message ~= nil and message or DarkRP.getPhrase("unable", GAMEMODE.Config.chatCommandPrefix .. "sleep", ""))
        return ""
    end

    if not player.SleepSound then
        player.SleepSound = CreateSound(player, "npc/ichthyosaur/water_breath.wav")
    end
    local timerName = player:EntIndex() .. "SleepExploit"


    if player.Sleeping and IsValid(player.SleepRagdoll) then
        player:SetParent()
        local frozen = player:IsFrozen()
        player.OldHunger = player:getDarkRPVar("Energy")
        player.SleepSound:Stop()
        local ragdoll = player.SleepRagdoll
        local health = player:Health()
        local armor = player:Armor()
        player:Spawn()
        player:SetHealth(health)
        player:SetArmor(armor)
        player:SetPos(ragdoll:GetPos())
        local model = ragdoll:GetModel()
        -- TEMPORARY WORKAROUND
        if string.lower(model) == "models/humans/corpse1.mdl" then
            model = "models/player/corpse1.mdl"
        end
        player:SetModel(model)
        player:SetAngles(Angle(0, ragdoll:GetPhysicsObjectNum(10) and ragdoll:GetPhysicsObjectNum(10):GetAngles().Yaw or 0, 0))
        player:UnSpectate()
        player:StripWeapons()
        ragdoll:Remove()
        ragdoll.OwnerINT = 0
        if player.WeaponsForSleep and player:GetTable().BeforeSleepTeam == player:Team() then
            player:RemoveAllAmmo()
            for _, v in pairs(player.WeaponsForSleep) do
                local wep = player:Give(v[1])
                if not IsValid(wep) then continue end

                player:GiveAmmo(v[2], v[3], true)
                player:GiveAmmo(v[4], v[5], true)

                wep:SetClip1(v[6])
                wep:SetClip2(v[7])

            end
            local cl_defaultweapon = player:GetInfo("cl_defaultweapon")
            if player:HasWeapon(cl_defaultweapon) then
                player:SelectWeapon(cl_defaultweapon)
            end
            player:GetTable().BeforeSleepTeam = nil
            player.WeaponsForSleep = nil
        else
            gamemode.Call("PlayerLoadout", player)
        end

        if frozen then
            player:UnLock()
            player:Lock()
        end

        if player.blackScreen then
            player.blackScreen = false
            SendUserMessage("blackScreen", player, false)
        end

        if command == true then
            player:arrest()
        end
        player.Sleeping = false
        if player:getDarkRPVar("Energy") then
            player:setSelfDarkRPVar("Energy", player.OldHunger)
            player.OldHunger = nil
        end

        if player:isArrested() then
            GAMEMODE:SetPlayerSpeed(player, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed)
        end
        timer.Remove(timerName)
    else
        if IsValid(player:GetObserverTarget()) then return "" end
        for _, v in ipairs(ents.FindInSphere(player:GetPos(), 30)) do
            if v:GetClass() == "func_door" then
                DarkRP.notify(player, 1, 4, DarkRP.getPhrase("unable", "/sleep", "func_door exploit"))
                return ""
            end
        end

        if not player:isArrested() then
            player.WeaponsForSleep = {}
            for k, v in ipairs(player:GetWeapons()) do
                player.WeaponsForSleep[k] = {v:GetClass(), player:GetAmmoCount(v:GetPrimaryAmmoType()),
                v:GetPrimaryAmmoType(), player:GetAmmoCount(v:GetSecondaryAmmoType()), v:GetSecondaryAmmoType(),
                v:Clip1(), v:Clip2()}
                --[[{class, ammocount primary, type primary, ammo count secondary, type secondary, clip primary, clip secondary]]
            end
        end
        local ragdoll = ents.Create("prop_ragdoll")
        ragdoll:SetPos(player:GetPos())
        ragdoll:SetAngles(Angle(0,player:GetAngles().Yaw,0))
        local model = player:GetModel()
        -- TEMPORARY WORKAROUND
        if string.lower(model) == "models/player/corpse1.mdl" then
            model = "models/Humans/corpse1.mdl"
        end
        ragdoll:SetModel(model)
        ragdoll:Spawn()
        ragdoll:Activate()
        ragdoll:SetVelocity(player:GetVelocity())
        ragdoll.OwnerINT = player:EntIndex()
        ragdoll.PhysgunPickup = false
        ragdoll.CanTool = false
        ragdoll.onArrestStickUsed = fp{onRagdollArrested, player}
        player:StripWeapons()
        player:Spectate(OBS_MODE_CHASE)
        player:SpectateEntity(ragdoll)
        player.IsSleeping = true
        player.SleepRagdoll = ragdoll
        player.KnockoutTimer = CurTime()
        player:GetTable().BeforeSleepTeam = player:Team()
        player:SetMoveType(MOVETYPE_NONE) -- Required for parenting to work properly
        player:SetParent(ragdoll)
        --Make sure noone can pick it up:
        ragdoll:CPPISetOwner(player)

        if not player.blackScreen then
            player.blackScreen = true
            SendUserMessage("blackScreen", player, true)
        end

        player.SleepSound = CreateSound(ragdoll, "npc/ichthyosaur/water_breath.wav")
        player.SleepSound:PlayEx(0.10, 100)
        player.Sleeping = true

        timer.Create(timerName, 0.3, 0, function()
            if not IsValid(player) then timer.Remove(timerName) return end

            if player:GetObserverTarget() ~= ragdoll then
                if IsValid(ragdoll) then
                    ragdoll:Remove()
                end
                stopSleep(player)
                player.SleepSound:Stop()
            end
        end)
    end

    return ""
end
DarkRP.defineChatCommand("sleep", DarkRP.toggleSleep)
DarkRP.defineChatCommand("wake", DarkRP.toggleSleep)
DarkRP.defineChatCommand("wakeup", DarkRP.toggleSleep)

hook.Add("OnPlayerChangedTeam", "SleepMod", stopSleep)


local function DamageSleepers(ent, dmginfo)
    local attacker = dmginfo:GetAttacker()
    local amount = dmginfo:GetDamage()

    local ownerint = ent.OwnerINT
    if not ownerint or ownerint == 0 then return end

    for _, v in ipairs(player.GetAll()) do
        if v:EntIndex() ~= ownerint then continue end

        if attacker == game.GetWorld() then
            amount = 10
            dmginfo:ScaleDamage(0.1)
        end

        v:SetHealth(v:Health() - amount)

        if v:Health() <= 0 and v:Alive() then
            DarkRP.toggleSleep(v, "force")
            -- reapply damage to properly kill the player
            v:StripWeapons()
            v:TakeDamageInfo(dmginfo)
        end
    end
end
hook.Add("EntityTakeDamage", "Sleepdamage", DamageSleepers)
