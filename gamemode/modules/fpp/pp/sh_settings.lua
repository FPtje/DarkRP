-- These are the default settings. Don't mind changing these.
FPP = FPP or {}

-- Don't reset the settings when they're already there
if FPP.Settings then
    return
end

FPP.Settings = {}
FPP.Settings.FPP_PHYSGUN1 = {
    toggle = 1,
    adminall = 1,
    worldprops = 0,
    adminworldprops = 1,
    canblocked = 0,
    admincanblocked = 0,
    shownocross = 1,
    checkconstrained = 1,
    reloadprotection = 1,
    iswhitelist = 0}
FPP.Settings.FPP_GRAVGUN1 = {
    toggle = 1,
    adminall = 1,
    worldprops = 1,
    adminworldprops = 1,
    canblocked = 0,
    admincanblocked = 0,
    shownocross = 1,
    checkconstrained = 1,
    noshooting = 1,
    iswhitelist = 0}
FPP.Settings.FPP_TOOLGUN1 = {
    toggle = 1,
    adminall = 1,
    worldprops = 0,
    adminworldprops = 0,
    canblocked = 0,
    admincanblocked = 0,
    shownocross = 1,
    checkconstrained = 1,
    iswhitelist = 0,

    duplicatorprotect = 1,
    duplicatenoweapons = 1,
    spawniswhitelist = 0,
    spawnadmincanweapon = 0,
    spawnadmincanblocked = 0}
FPP.Settings.FPP_PLAYERUSE1 = {
    toggle = 0,
    adminall = 1,
    worldprops = 1,
    adminworldprops = 1,
    canblocked = 0,
    admincanblocked = 1,
    shownocross = 1,
    checkconstrained = 0,
    iswhitelist = 0}
FPP.Settings.FPP_ENTITYDAMAGE1 = {
    toggle = 1,
    protectpropdamage = 1,
    adminall = 1,
    worldprops = 1,
    adminworldprops = 1,
    canblocked = 0,
    admincanblocked = 0,
    shownocross = 1,
    checkconstrained = 0,
    iswhitelist = 0}
FPP.Settings.FPP_GLOBALSETTINGS1 = {
    freezedisconnected = 0,
    cleanupdisconnected = 1,
    cleanupdisconnectedtime = 120,
    cleanupadmin = 1,
    antie2minge = 1}
FPP.Settings.FPP_ANTISPAM1 = {
    toggle = 1,
    antispawninprop = 0,
    bigpropantispam = 1,
    bigpropsize = 5.85,
    bigpropwait = 1.5,
    smallpropdowngradecount = 3,
    smallpropghostlimit = 2,
    smallpropdenylimit = 6,
    duplicatorlimit = 3
}
FPP.Settings.FPP_BLOCKMODELSETTINGS1 = {
    toggle = 1,
    propsonly = 0,
    iswhitelist = 0
}

FPP.InitialSettings = table.Copy(FPP.Settings)

function FPP.ForAllSettings(fn)
    -- Loop in sorted pairs for deterministic order
    for kind, sets in SortedPairs(FPP.Settings) do
        for setting, val in SortedPairs(sets) do
            if fn(kind, setting, val) then break end
        end
    end
end

--[[-------------------------------------------------------------------------
CAMI
Register the CAMI privilege
---------------------------------------------------------------------------]]
CAMI.RegisterPrivilege{
    Name = "FPP_Settings",
    MinAccess = "superadmin" -- By default only superadmins can change settings
}

CAMI.RegisterPrivilege{
    Name = "FPP_Cleanup",
    MinAccess = "admin"
}

CAMI.RegisterPrivilege{
    Name = "FPP_TouchOtherPlayersProps",
    MinAccess = "admin"
}

function FPP.calculatePlayerPrivilege(priv, callback)
    local plys = player.GetAll()
    local count = #plys

    for _, ply in ipairs(plys) do
        local function onRes(b)
            count = count - 1
            ply.FPP_Privileges = ply.FPPPrivileges or {}
            ply.FPP_Privileges[priv] = b

            if count == 0 then callback() end
        end
        CAMI.PlayerHasAccess(ply, priv, onRes)
    end
end
