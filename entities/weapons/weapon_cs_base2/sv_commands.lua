local meta = FindMetaTable("Player")
function meta:dropDRPWeapon(weapon)
    if GAMEMODE.Config.restrictdrop then
        local found = false
        for k,v in pairs(CustomShipments) do
            if v.entity == weapon:GetClass() then
                found = true
                break
            end
        end

        if not found then return end
    end

    local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())
    self:DropWeapon(weapon) -- Drop it so the model isn't the viewmodel

    local ent = ents.Create("spawned_weapon")
    local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()
    model = util.IsValidModel(model) and model or "models/weapons/w_rif_ak47.mdl"

    ent:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
    ent:SetModel(model)
    ent:SetSkin(weapon:GetSkin() or 0)
    ent:SetWeaponClass(weapon:GetClass())
    ent.nodupe = true
    ent.clip1 = weapon:Clip1()
    ent.clip2 = weapon:Clip2()
    ent.ammoadd = ammo

    hook.Call("onDarkRPWeaponDropped", nil, self, ent, weapon)

    self:RemoveAmmo(ammo, weapon:GetPrimaryAmmoType())

    ent:Spawn()

    weapon:Remove()
end

local function DropWeapon(ply)
    local ent = ply:GetActiveWeapon()
    if not IsValid(ent) or not ent:GetModel() or ent:GetModel() == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
        return ""
    end

    local canDrop = hook.Call("canDropWeapon", GAMEMODE, ply, ent)
    if not canDrop then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
        return ""
    end

    local RP = RecipientFilter()
    RP:AddAllPlayers()

    umsg.Start("anim_dropitem", RP)
        umsg.Entity(ply)
    umsg.End()
    ply.anim_DroppingItem = true

    timer.Simple(1, function()
        if IsValid(ply) and IsValid(ent) and ent:GetModel() and ent:GetModel() ~= "" then
            ply:dropDRPWeapon(ent)
        end
    end)
    return ""
end
DarkRP.defineChatCommand("drop", DropWeapon)
DarkRP.defineChatCommand("dropweapon", DropWeapon)
DarkRP.defineChatCommand("weapondrop", DropWeapon)

DarkRP.stub{
    name = "dropDRPWeapon",
    description = "Drop the weapon with animations.",
    parameters = {
        {
            name = "weapon",
            description = "The weapon to drop",
            type = "Entity",
            optional = false
        }
    },
    returns = {
    },
    metatable = meta
}

DarkRP.hookStub{
    name = "onDarkRPWeaponDropped",
    description = "When a player drops a weapon. Use this hook (in combination with PlayerPickupDarkRPWeapon) to store extra information about a weapon. This hook cannot prevent weapon dropping. If you want to prevent weapon dropping, use canDropWeapon instead.",
    parameters = {
        {
            name = "ply",
            description = "The player who dropped the weapon.",
            type = "Player"
        },
        {
            name = "spawned_weapon",
            description = "The spawned_weapon created from the weapon that is dropped.",
            type = "Entity"
        },
        {
            name = "original_weapon",
            description = "The original weapon from which the spawned_weapon is made.",
            type = "Weapon"
        }
    },
    returns = {

    }
}

DarkRP.hookStub{
    name = "PlayerPickupDarkRPWeapon",
    description = "When a player picks up a spawned_weapon.",
    parameters = {
        {
            name = "ply",
            description = "The player who dropped the weapon.",
            type = "Player"
        },
        {
            name = "spawned_weapon",
            description = "The spawned_weapon created from the weapon that is dropped.",
            type = "Entity"
        },
        {
            name = "real_weapon",
            description = "The actual weapon that will be used by the player.",
            type = "Weapon"
        }
    },
    returns = {
        {
            name = "ShouldntContinue",
            description = "Whether weapon should be picked up or not.",
            type = "boolean"
        }
    }
}
