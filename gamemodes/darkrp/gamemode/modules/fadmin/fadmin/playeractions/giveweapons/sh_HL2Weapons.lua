FAdmin.HL2Guns = {
    Crowbar = "weapon_crowbar",
    Gravgun = "weapon_gravgun",
    Physgun = "weapon_physgun",
    Stunstick = "weapon_stunstick",
    Pistol = "weapon_pistol",
    ["357"] = "weapon_357",
    Smg1 = "weapon_smg1",
    Ar2 = "weapon_ar2",
    Shotgun = "weapon_shotgun",
    Crossbow = "weapon_crossbow",
    Grenade = "weapon_frag",
    RPG = "weapon_rpg",
    ["S.L.A.M."] = "weapon_SLAM",
    Camera = "gmod_camera",
    Toolgun = "gmod_tool"
}

FAdmin.AmmoTypes = {
    AR2 = 30,
    AR2AltFire = 3,
    pistol = 180,
    smg1 = 45,
    ["357"] = 6,
    XBowBolt = 3,
    Buckshot = 6,
    RPG_Round = 3,
    SMG1_Grenade = 1,
    Grenade = 3,
    slam = 1
}

FAdmin.StartHooks["GivingWeapons"] = function()
    FAdmin.Messages.RegisterNotification{
        name = "giveweapon",
        hasTarget = true,
        message = {"instigator", " gave ", "extraInfo.1", " to ", "targets"},
        receivers = "everyone",
        writeExtraInfo = function(i) net.WriteString(i[1]) end,
        readExtraInfo = function()
            return {net.ReadString()}
        end,
        extraInfoColors = {Color(255, 102, 0)}
    }

    FAdmin.Messages.RegisterNotification{
        name = "giveammo",
        hasTarget = true,
        message = {"instigator", " gave ", "extraInfo.1", " ", "extraInfo.2", " ammo to ", "targets"},
        receivers = "everyone",
        writeExtraInfo = function(info) net.WriteUInt(info[1], 32) net.WriteString(info[2]) end,
        readExtraInfo = function()
            return {tostring(net.ReadUInt(32)), net.ReadString()}
        end,
        extraInfoColors = {Color(255, 102, 0), Color(255, 102, 153)}
    }
end
