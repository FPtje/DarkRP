FPP = FPP or {}
FPP.DisconnectedPlayers = FPP.DisconnectedPlayers or {}

local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

--[[-------------------------------------------------------------------------
Checks if a model is blocked
---------------------------------------------------------------------------]]
function FPP.IsBlockedModel(model)
    if model == "" or not FPP.Settings or not FPP.Settings.FPP_BLOCKMODELSETTINGS1 or
        not tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.toggle)
        or not FPP.BlockedModels or not model then return end

    model = string.lower(model or "")
    model = string.Replace(model, "\\", "/")
    model = string.gsub(model, "[\\/]+", "/")

    if string.find(model, "../", 1, true) then
        return true, "The model path goes up in the folder tree."
    end

    local found = FPP.BlockedModels[model]
    if tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.iswhitelist) and not found then
        -- Prop is not in the white list
        return true, "The model of this entity is not in the white list!"
    elseif not tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.iswhitelist) and found then
        -- prop is in the black list
        return true, "The model of this entity is in the black list!"
    end
    return false
end

--[[-------------------------------------------------------------------------
Prevents spawning a prop or effect when its model is blocked
---------------------------------------------------------------------------]]
local function propSpawn(ply, model)
    local blocked, msg = FPP.IsBlockedModel(model)
    if blocked then
        FPP.Notify(ply, msg, false)
        return false
    end
end
hook.Add("PlayerSpawnObject", "FPP_SpawnEffect", propSpawn) -- prevents precaching
hook.Add("PlayerSpawnProp", "FPP_SpawnProp", propSpawn) -- PlayerSpawnObject isn't always called
hook.Add("PlayerSpawnEffect", "FPP_SpawnEffect", propSpawn)
hook.Add("PlayerSpawnRagdoll", "FPP_SpawnEffect", propSpawn)

--[[-------------------------------------------------------------------------
Setting owner when someone spawns something
---------------------------------------------------------------------------]]
if cleanup then
    FPP.oldcleanup = FPP.oldcleanup or cleanup.Add
    function cleanup.Add(ply, Type, ent)
        if not IsValid(ply) or not IsValid(ent) then return FPP.oldcleanup(ply, Type, ent) end

        --Set the owner of the entity
        ent:CPPISetOwner(ply)

        if not tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.propsonly) then
            local model = ent.GetModel and ent:GetModel()
            local blocked, msg = FPP.IsBlockedModel(model)

            if blocked then
                FPP.Notify(ply, msg, false)
                ent:Remove()

                return
            end
        end

        if FPP.AntiSpam and Type ~= "constraints" and Type ~= "stacks" and Type ~= "AdvDupe2" and (not AdvDupe2 or not AdvDupe2.SpawningEntity) and (not ent.IsVehicle or not ent:IsVehicle()) then
            FPP.AntiSpam.CreateEntity(ply, ent, Type == "duplicates")
        end

        if ent:GetClass() == "gmod_wire_expression2" then
            ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        end

        return FPP.oldcleanup(ply, Type, ent)
    end
end

if PLAYER.AddCount then
    FPP.oldcount = FPP.oldcount or PLAYER.AddCount
    function PLAYER:AddCount(Type, ent)
        if not IsValid(self) or not IsValid(ent) then return FPP.oldcount(self, Type, ent) end
        --Set the owner of the entity
        ent:CPPISetOwner(self)
        return FPP.oldcount(self, Type, ent)
    end
end

local entSetCreator = ENTITY.SetCreator
if entSetCreator then
    function ENTITY:SetCreator(ply)
        self:CPPISetOwner(ply)
        entSetCreator(self, ply)
    end
end

if undo then
    local AddEntity, SetPlayer, Finish =  undo.AddEntity, undo.SetPlayer, undo.Finish
    local Undo = {}
    local UndoPlayer
    function undo.AddEntity(ent, ...)
        if not isbool(ent) and IsValid(ent) then table.insert(Undo, ent) end
        AddEntity(ent, ...)
    end

    function undo.SetPlayer(ply, ...)
        UndoPlayer = ply
        SetPlayer(ply, ...)
    end

    function undo.Finish(...)
        if IsValid(UndoPlayer) then
            for _, v in pairs(Undo) do
                v:CPPISetOwner(UndoPlayer)
            end
        end
        Undo = {}
        UndoPlayer = nil

        Finish(...)
    end
end

hook.Add("PlayerSpawnedSWEP", "FPP.Spawn.SWEP", function(ply, ent)
    ent:CPPISetOwner(ply)
end)

hook.Add("PlayerSpawnedSENT", "FPP.Spawn.SENT", function(ply, ent)
    ent:CPPISetOwner(ply)
end)

--------------------------------------------------------------------------------------
--The protecting itself
--------------------------------------------------------------------------------------

FPP.Protect = {}

--Physgun Pickup
function FPP.Protect.PhysgunPickup(ply, ent)
    if not tobool(FPP.Settings.FPP_PHYSGUN1.toggle) then if FPP.UnGhost then FPP.UnGhost(ply, ent) end return end
    if not ent:IsValid() then return end
    local cantouch
    local skipReturn = false

    if isfunction(ent.PhysgunPickup) then
        cantouch = ent:PhysgunPickup(ply, ent)
        -- Do not return the value, the gamemode will do this
        -- Allows other hooks to run
        skipReturn = true
    elseif ent.PhysgunPickup ~= nil then
        cantouch = ent.PhysgunPickup
    else
        cantouch = not ent:IsPlayer() and FPP.plyCanTouchEnt(ply, ent, "Physgun")
        skipReturn = ent:IsPlayer()
    end

    if cantouch and FPP.UnGhost then FPP.UnGhost(ply, ent) end
    if not cantouch and not skipReturn then return false end
end
hook.Add("PhysgunPickup", "FPP.Protect.PhysgunPickup", FPP.Protect.PhysgunPickup)

--Physgun reload
function FPP.Protect.PhysgunReload(weapon, ply)
    if not tobool(FPP.Settings.FPP_PHYSGUN1.reloadprotection) then return end

    local ent = ply:GetEyeTrace().Entity

    if not IsValid(ent) then return end

    local cantouch
    local skipReturn = false

    if isfunction(ent.OnPhysgunReload) then
        cantouch = ent:OnPhysgunReload(ply, ent)
        -- Do not return the value, the gamemode will do this
        -- Allows other hooks to run
        skipReturn = true
    elseif ent.OnPhysgunReload ~= nil then
        cantouch = ent.OnPhysgunReload
    else
        cantouch = not ent:IsPlayer() and FPP.plyCanTouchEnt(ply, ent, "Physgun")
    end

    if cantouch and FPP.UnGhost then FPP.UnGhost(ply, ent) end
    if not cantouch and not skipReturn then return false end

    -- Double reload breaks when returning true here
end
hook.Add("OnPhysgunReload", "FPP.Protect.PhysgunReload", FPP.Protect.PhysgunReload)

function FPP.PhysgunFreeze(weapon, phys, ent, ply)
    if isfunction(ent.OnPhysgunFreeze) then
        local val = ent:OnPhysgunFreeze(weapon, phys, ent, ply)
        -- Do not return the value, the gamemode will do this
        if val ~= nil then return end
    elseif ent.OnPhysgunFreeze ~= nil then
        return ent.OnPhysgunFreeze
    end
end
hook.Add("OnPhysgunFreeze", "FPP.Protect.PhysgunFreeze", FPP.PhysgunFreeze)

--Gravgun pickup
function FPP.Protect.GravGunPickup(ply, ent)
    if not tobool(FPP.Settings.FPP_GRAVGUN1.toggle) then return end

    if not IsValid(ent) then return end -- You don't want a cross when looking at the floor while holding right mouse

    if ent:IsPlayer() then return end

    local cantouch

    if isfunction(ent.GravGunPickup) then
        cantouch = ent:GravGunPickup(ply, ent)
    elseif ent.GravGunPickup ~= nil then
        cantouch = ent.GravGunPickup
    else
        cantouch = not ent:IsPlayer() and FPP.plyCanTouchEnt(ply, ent, "Gravgun")
    end

    if cantouch and FPP.UnGhost then FPP.UnGhost(ply, ent) end
    if cantouch == false then DropEntityIfHeld(ent) end
end
hook.Add("GravGunOnPickedUp", "FPP.Protect.GravGunPickup", FPP.Protect.GravGunPickup)

function FPP.Protect.CanGravGunPickup(ply, ent)
    if not tobool(FPP.Settings.FPP_GRAVGUN1.toggle) or not IsValid(ent) then return end

    if isfunction(ent.GravGunPickup) then
        -- Function name different than gamemode's (GravGunPickup vs GravGunPickupAllowed)
        -- Override FPP's behavior when implemented
        local val = ent:GravGunPickup(ply, ent)
        if val ~= nil then
            if val == false then return false end
            return
        end
    elseif ent.GravGunPickup ~= nil then
        if ent.GravGunPickup == false then return false end
        return
    end

    local cantouch = FPP.plyCanTouchEnt(ply, ent, "Gravgun")

    if cantouch == false then return false end
end
hook.Add("GravGunPickupAllowed", "FPP.Protect.CanGravGunPickup", FPP.Protect.CanGravGunPickup)

--Gravgun punting
function FPP.Protect.GravGunPunt(ply, ent)
    if tobool(FPP.Settings.FPP_GRAVGUN1.noshooting) then DropEntityIfHeld(ent) return false end
    -- Do not reason further if gravgun protection is disabled.
    if not tobool(FPP.Settings.FPP_GRAVGUN1.toggle) then return end

    if not IsValid(ent) then DropEntityIfHeld(ent) return end

    local cantouch
    local skipReturn = false

    if isfunction(ent.GravGunPunt) then
        cantouch = ent:GravGunPunt(ply, ent)
        -- Do not return the value, the gamemode will do this
        -- Allows other hooks to run
        skipReturn = true
    elseif ent.GravGunPunt ~= nil then
        cantouch = ent.GravGunPunt
    else
        cantouch = not ent:IsPlayer() and FPP.plyCanTouchEnt(ply, ent, "Gravgun")
    end

    if cantouch and FPP.UnGhost then FPP.UnGhost(ply, ent) end
    if not cantouch then DropEntityIfHeld(ent) end
    if not cantouch and not skipReturn then return false end
end
hook.Add("GravGunPunt", "FPP.Protect.GravGunPunt", FPP.Protect.GravGunPunt)

--PlayerUse
function FPP.Protect.PlayerUse(ply, ent)
    if not tobool(FPP.Settings.FPP_PLAYERUSE1.toggle) then return end

    if not IsValid(ent) then return end

    local cantouch
    local skipReturn = false

    if isfunction(ent.PlayerUse) then
        cantouch = ent:PlayerUse(ply, ent)
        -- Do not return the value, the gamemode will do this
        -- Allows other hooks to run
        skipReturn = true
    elseif ent.PlayerUse ~= nil then
        cantouch = ent.PlayerUse
    else
        cantouch = not ent:IsPlayer() and FPP.plyCanTouchEnt(ply, ent, "PlayerUse")
    end

    if cantouch and FPP.UnGhost then FPP.UnGhost(ply, ent) end
    if not cantouch and not skipReturn then return false end
end
hook.Add("PlayerUse", "FPP.Protect.PlayerUse", FPP.Protect.PlayerUse)

--EntityDamage
function FPP.Protect.EntityDamage(ent, dmginfo)
    if not IsValid(ent) then return end

    local inflictor = dmginfo:GetInflictor()
    local attacker = dmginfo:GetAttacker()
    local amount = dmginfo:GetDamage()

    if isfunction(ent.EntityDamage) then
        local val = ent:EntityDamage(ent, inflictor, attacker, amount, dmginfo)
        -- Do not return the value, the gamemode will do this
        if val ~= nil then return end
    elseif ent.EntityDamage ~= nil then
        return ent.EntityDamage
    end

    if not tobool(FPP.Settings.FPP_ENTITYDAMAGE1.toggle) then return end

    -- Don't do anything about players
    if ent:IsPlayer() then return end

    if not attacker:IsPlayer() then
        if not tobool(FPP.Settings.FPP_ENTITYDAMAGE1.protectpropdamage) then return end
        local attackerOwner = attacker:CPPIGetOwner()
        local entOwner = ent:CPPIGetOwner()
        if IsValid(attackerOwner) and IsValid(entOwner) then
            local cantouch = FPP.plyCanTouchEnt(attackerOwner, ent, "EntityDamage")

            if not cantouch then
                dmginfo:SetDamage(0)
                ent.FPPAntiDamageWorld = ent.FPPAntiDamageWorld or 0
                ent.FPPAntiDamageWorld = ent.FPPAntiDamageWorld + 1
                timer.Simple(1, function()
                    if not ent.FPPAntiDamageWorld then return end
                    ent.FPPAntiDamageWorld = ent.FPPAntiDamageWorld - 1
                    if ent.FPPAntiDamageWorld == 0 then
                        ent.FPPAntiDamageWorld = nil
                    end
                end)
            end
            return
        end

        if attacker == game.GetWorld() and ent.FPPAntiDamageWorld then
            dmginfo:SetDamage(0)
        end
        return
    end

    local cantouch = FPP.plyCanTouchEnt(attacker, ent, "EntityDamage")

    if not cantouch then dmginfo:SetDamage(0) end
end
hook.Add("EntityTakeDamage", "FPP.Protect.EntityTakeDamage", FPP.Protect.EntityDamage)

--Toolgun
--for advanced duplicator, you can't use the IsWeapon function
local allweapons = {
["weapon_crowbar"] = true,
["weapon_physgun"] = true,
["weapon_physcannon"] = true,
["weapon_pistol"] = true,
["weapon_stunstick"] = true,
["weapon_357"] = true,
["weapon_smg1"] = true,
["weapon_ar2"] = true,
["weapon_shotgun"] = true,
["weapon_crossbow"] = true,
["weapon_frag"] = true,
["weapon_rpg"] = true,
["gmod_camera"] = true,
["gmod_tool"] = true,
["weapon_bugbait"] = true}

timer.Simple(5, function()
    for _, v in ipairs(weapons.GetList()) do
        if v.ClassName then allweapons[string.lower(v.ClassName or "")] = true end
    end
end)

local invalidToolData = {
    ["model"] = {
        "*",
        "\\"
    },
    ["material"] = {
        "*",
        "\\",
        " ",
        "effects/highfive_red",
        "pp/copy",
        ".v",
        "skybox/"
    },
    ["sound"] = {
        "?",
        " "
    },
    ["soundname"] = {
        " ",
        "?"
    },
    ["tracer"] = {
        "dof_node"
    },
    ["door_class"] = {
        "env_laser"
    },
    -- Limit wheel torque
    ["rx"] = 360,
    ["ry"] = 360,
    ["rz"] = 360
}
invalidToolData.override = invalidToolData.material
invalidToolData.rope_material = invalidToolData.material

function FPP.Protect.CanTool(ply, trace, tool, ENT)
    local ignoreGeneralRestrictTool = false
    local SteamID = ply:SteamID()

    FPP.RestrictedToolsPlayers = FPP.RestrictedToolsPlayers or {}
    if FPP.RestrictedToolsPlayers[tool] and FPP.RestrictedToolsPlayers[tool][SteamID] ~= nil then--Player specific
        if FPP.RestrictedToolsPlayers[tool][SteamID] == false then
            FPP.Notify(ply, "Toolgun restricted for you!", false)
            return false
        elseif FPP.RestrictedToolsPlayers[tool][SteamID] == true then
            ignoreGeneralRestrictTool = true --If someone is allowed, then he's allowed even though he's not admin, so don't check for further restrictions
        end
    end


    if not ignoreGeneralRestrictTool then
        local Group = FPP.Groups[FPP.GroupMembers[SteamID]] or FPP.Groups[ply:GetUserGroup()] or FPP.Groups.default  -- What group is the player in. If not in a special group, then he's in default group

        local CanGroup = true
        if Group and ((Group.allowdefault and table.HasValue(Group.tools, tool)) or -- If the tool is on the BLACKLIST or
            (not Group.allowdefault and not table.HasValue(Group.tools, tool))) then -- If the tool is NOT on the WHITELIST
            CanGroup = false
        end

        if FPP.RestrictedTools[tool] then
            if tonumber(FPP.RestrictedTools[tool].admin) == 1 and not ply:IsAdmin() then
                FPP.Notify(ply, "Toolgun restricted! Admin only!", false)
                return false
            elseif tonumber(FPP.RestrictedTools[tool].admin) == 2 and not ply:IsSuperAdmin() then
                FPP.Notify(ply, "Toolgun restricted! Superadmin only!", false)
                return false
            elseif (tonumber(FPP.RestrictedTools[tool].admin) == 1 and ply:IsAdmin()) or (tonumber(FPP.RestrictedTools[tool].admin) == 2 and ply:IsSuperAdmin()) then
                CanGroup = true -- If the person is not in the BUT has admin access, he should be able to use the tool
            end

            if FPP.RestrictedTools[tool]["team"] and #FPP.RestrictedTools[tool]["team"] > 0 and not table.HasValue(FPP.RestrictedTools[tool]["team"], ply:Team()) then
                FPP.Notify(ply, "Toolgun restricted! incorrect team!", false)
                return false
            end
        end

        if not CanGroup then
            FPP.Notify(ply, "Toolgun restricted! incorrect group!", false)
            return false
        end
    end

    -- Anti server crash
    if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().GetToolObject and ply:GetActiveWeapon():GetToolObject() then
        local toolObj = ply:GetActiveWeapon():GetToolObject()
        for t, block in pairs(invalidToolData) do
            local clientInfo = string.lower(toolObj:GetClientInfo(t) or "")
            -- Check for number limits
            if isnumber(block) then
                local num = tonumber(clientInfo) or 0
                if num > block or num < -block then
                    FPP.Notify(ply, "The client settings of the tool are invalid!", false)
                    return false
                end
                continue
            end

            for _, item in pairs(block) do
                if string.find(clientInfo, item, 1, true) then
                    FPP.Notify(ply, "The client settings of the tool are invalid!", false)
                    return false
                end
            end
        end
    end

    local ent = IsEntity(ENT) and ENT or trace and trace.Entity

    if IsEntity(ent) and isfunction(ent.CanTool) and ent:GetClass() ~= "gmod_cameraprop" and ent:GetClass() ~= "gmod_rtcameraprop" then
        local val = ent:CanTool(ply, trace, tool, ENT)
        -- Do not return the value, the gamemode will do this
        if val ~= nil then return end
    elseif IsEntity(ent) and ent.CanTool ~= nil and ent:GetClass() ~= "gmod_cameraprop" and ent:GetClass() ~= "gmod_rtcameraprop" then
        return ent.CanTool
    end

    if tobool(FPP.Settings.FPP_TOOLGUN1.toggle) and IsValid(ent) then
        local cantouch = FPP.plyCanTouchEnt(ply, ent, "Toolgun")

        if not cantouch then return false end
    end

    if tool ~= "adv_duplicator" and tool ~= "duplicator" and tool ~= "advdupe2" then return end
    if not ENT and not FPP.AntiSpam.DuplicatorSpam(ply) then return false end

    local EntTable =
        (tool == "adv_duplicator" and ply:GetActiveWeapon():GetToolObject().Entities) or
        (tool == "advdupe2" and ply.AdvDupe2 and ply.AdvDupe2.Entities) or
        (tool == "duplicator" and ply.CurrentDupe and ply.CurrentDupe.Entities)

    if not EntTable then return end


    for k, v in pairs(EntTable) do
        local lowerClass = string.lower(v.Class)

        if tobool(FPP.Settings.FPP_TOOLGUN1.duplicatenoweapons) and
          (not ply:IsAdmin() or (ply:IsAdmin() and not tobool(FPP.Settings.FPP_TOOLGUN1.spawnadmincanweapon))) and
          (allweapons[lowerClass] or string.find(lowerClass, "ai_") == 1 or string.find(lowerClass, "item_ammo_") == 1) then
            FPP.Notify(ply, "Duplicating blocked entity " .. lowerClass, false)
            EntTable[k] = nil
        end
        if tobool(FPP.Settings.FPP_TOOLGUN1.duplicatorprotect) and (not ply:IsAdmin() or (ply:IsAdmin() and not tobool(FPP.Settings.FPP_TOOLGUN1.spawnadmincanblocked))) then
            local setspawning = tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist)

            if not tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist) and FPP.Blocked.Spawning1[lowerClass] then
                FPP.Notify(ply, "Duplicating blocked entity " .. lowerClass, false)
                EntTable[k] = nil
            end

            -- if the whitelist is on you can't spawn it unless it's found
            if tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist) and FPP.Blocked.Spawning1[lowerClass] then
                setspawning = false
            end

            if setspawning then
                FPP.Notify(ply, "Duplicating blocked entity " .. lowerClass, false)
                EntTable[k] = nil
            end
        end
    end
    return
end
hook.Add("CanTool", "FPP.Protect.CanTool", FPP.Protect.CanTool)

function FPP.Protect.CanEditVariable(ent, ply, key, varVal, editTbl)
    if not tobool(FPP.Settings.FPP_TOOLGUN1.toggle) then return true end
    local val = FPP.Protect.CanProperty(ply, "editentity", ent)
    if val ~= nil then return val end
end
hook.Add("CanEditVariable", "FPP.Protect.CanEditVariable", FPP.Protect.CanEditVariable)

function FPP.Protect.CanProperty(ply, property, ent)
    -- Use Toolgun because I'm way too lazy to make a new type
    if not tobool(FPP.Settings.FPP_TOOLGUN1.toggle) then return true end
    local cantouch = FPP.plyCanTouchEnt(ply, ent, "Toolgun")

    if not cantouch then return false end
end
hook.Add("CanProperty", "FPP.Protect.CanProperty", FPP.Protect.CanProperty)

function FPP.Protect.CanDrive(ply, ent)
    -- Use Toolgun because I'm way too lazy to make a new type
    if not tobool(FPP.Settings.FPP_TOOLGUN1.toggle) then return true end
    local cantouch = FPP.plyCanTouchEnt(ply, ent, "Toolgun")

    if not cantouch then return false end
end
hook.Add("CanDrive", "FPP.Protect.CanDrive", FPP.Protect.CanDrive)

local function freezeDisconnected(ply)
    local SteamID = ply:SteamID()

    for _, ent in ipairs(ents.GetAll()) do
        local physObj = ent:GetPhysicsObject()
        if ent.FPPOwnerID ~= SteamID or ent:GetPersistent() or not physObj:IsValid() then continue end

        physObj:EnableMotion(false)
    end
end

--Player disconnect, not part of the Protect table.
function FPP.PlayerDisconnect(ply)
    if not IsValid(ply) then return end

    local SteamID = ply:SteamID()
    FPP.DisconnectedPlayers[SteamID] = true

    if tobool(FPP.Settings.FPP_GLOBALSETTINGS1.freezedisconnected) then
        freezeDisconnected(ply)
    end

    if ply.FPPFallbackOwner then
        -- FPP.DisconnectedOriginalOwners = FPP.DisconnectedOriginalOwners or {}
        -- FPP.DisconnectedOriginalOwners[SteamID] = {props = {}}


        local fallback = player.GetBySteamID(ply.FPPFallbackOwner)
        for _, v in ipairs(ents.GetAll()) do
            if v.FPPOwnerID ~= SteamID or v:GetPersistent() then continue end

            v.FPPFallbackOwner = ply.FPPFallbackOwner

            if IsValid(fallback) then
                v:CPPISetOwner(fallback)
            end

            -- table.insert(FPP.DisconnectedOriginalOwners[SteamID].props, v)

            -- Only set when not set already
            -- this prevents the original owner being set again
            -- when the fallback hands their props over to a second
            -- (or third, or nth) fallback
            if v:GetNW2String("FPP_OriginalOwner", "") == "" then
                v:SetNW2String("FPP_OriginalOwner", SteamID)
            end
        end

        -- Create disconnect timer if fallback is not in server
        -- ownership is transferred immediately when fallback is in server
        if IsValid(fallback) then
            return
        end
    end

    if not tobool(FPP.Settings.FPP_GLOBALSETTINGS1.cleanupdisconnected) or
    not FPP.Settings.FPP_GLOBALSETTINGS1.cleanupdisconnectedtime then
        return
    end

    if ply:IsAdmin() and not tobool(FPP.Settings.FPP_GLOBALSETTINGS1.cleanupadmin) then return end

    timer.Simple(FPP.Settings.FPP_GLOBALSETTINGS1.cleanupdisconnectedtime, function()
        if not tobool(FPP.Settings.FPP_GLOBALSETTINGS1.cleanupdisconnected) then return end -- Settings can change in time.

        for _, v in ipairs(player.GetAll()) do
            if v:SteamID() == SteamID then
                return
            end
        end
        for _, v in ipairs(ents.GetAll()) do
            if v.FPPOwnerID ~= SteamID or v:GetPersistent() then continue end
            v:Remove()
        end
        FPP.DisconnectedPlayers[SteamID] = nil -- Player out of the Disconnect table
    end)
end
hook.Add("PlayerDisconnected", "FPP.PlayerDisconnect", FPP.PlayerDisconnect)

-- PlayerInitialspawn, the props he had left before will now be theirs again
function FPP.PlayerInitialSpawn(ply)
    local RP = RecipientFilter()
    local SteamID = ply:SteamID()

    timer.Simple(5, function()
        if not IsValid(ply) then return end
        RP:AddAllPlayers()
        RP:RemovePlayer(ply)
        umsg.Start("FPP_CheckBuddy", RP) --Message everyone that a new player has joined
            umsg.Entity(ply)
        umsg.End()
    end)

    local entities = {}
    if FPP.DisconnectedPlayers[SteamID] then -- Check if the player has rejoined within the auto remove time
        for _, v in ipairs(ents.GetAll()) do
            if (v.FPPOwnerID == SteamID or v.FPPFallbackOwner == SteamID or v:GetNW2String("FPP_OriginalOwner") == SteamID) then
                v.FPPFallbackOwner = nil
                v:CPPISetOwner(ply)
                table.insert(entities, v)

                if v:GetNW2String("FPP_OriginalOwner") == SteamID then
                    v:SetNW2String("FPP_OriginalOwner", "")
                end
            end
        end
    end

    local plys = {}
    for _, v in ipairs(player.GetAll()) do if v ~= ply then table.insert(plys, v) end end

    timer.Create("FPP_recalculate_cantouch_" .. ply:UserID(), 0, 1, function()
        FPP.recalculateCanTouch({ply}, ents.GetAll())
    end)
end
hook.Add("PlayerInitialSpawn", "FPP.PlayerInitialSpawn", FPP.PlayerInitialSpawn)

local backup = ENTITY.FireBullets
local blockedEffects = {
    ["particleeffect"] = true,
    ["smoke"] = true,
    ["vortdispel"] = true,
    ["helicoptermegabomb"] = true,
}

function ENTITY:FireBullets(bullet, ...)
    if not bullet.TracerName then return backup(self, bullet, ...) end
    if blockedEffects[string.lower(bullet.TracerName)] then
        bullet.TracerName = ""
    end
    return backup(self, bullet, ...)
end

-- Hydraulic exploit workaround
-- One should not be able to constrain doors to anything
local canConstrain = constraint.CanConstrain
local disallowedConstraints = {
    ["prop_door_rotating"] = true,
    ["func_door"] = true,
    ["func_breakable_surf"] = true
}
function constraint.CanConstrain(ent, bone)
    if IsValid(ent) and disallowedConstraints[string.lower(ent:GetClass())] then return false end

    return canConstrain(ent, bone)
end
