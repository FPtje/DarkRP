TOOL.Category           = "Falco Prop Protection"
TOOL.Name               = "Share props"
TOOL.Command            = nil
TOOL.ConfigName         = ""

if SERVER then
    util.AddNetworkString('FPP_ShareSettings')
end

function TOOL:RightClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or CLIENT then return true end

    ent.SharePhysgun1 = nil
    ent.ShareGravgun1 = nil
    ent.SharePlayerUse1 = nil
    ent.ShareEntityDamage1 = nil
    ent.ShareToolgun1 = nil

    ent.AllowedPlayers = nil
    return true
end

function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or CLIENT then return true end

    local ply = self:GetOwner()

    local Physgun = ent.SharePhysgun1 or false
    local GravGun = ent.ShareGravgun1 or false
    local PlayerUse = ent.SharePlayerUse1 or false
    local Damage = ent.ShareEntityDamage1 or false
    local Toolgun = ent.ShareToolgun1 or false

    -- This big usermessage will be too big if you select 63 players, since that will not happen I can't be arsed to solve it
    net.Start('FPP_ShareSettings')
        net.WriteEntity(ent)
        net.WriteBool(Physgun)
        net.WriteBool(GravGun)
        net.WriteBool(PlayerUse)
        net.WriteBool(Damage)
        net.WriteBool(Toolgun)
        if ent.AllowedPlayers then
            net.WriteInt(#ent.AllowedPlayers, 32)
            for k,v in pairs(ent.AllowedPlayers) do
                net.WriteEntity(v)
            end
        end
    net.Send(ply)
    return true
end

if CLIENT then
    language.Add( "Tool.shareprops.name", "Share tool" )
    language.Add( "Tool.shareprops.desc", "Change sharing settings per prop" )
    language.Add( "Tool.shareprops.0", "Left click: shares a prop. Right click unshares a prop")
end
