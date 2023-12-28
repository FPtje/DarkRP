-- Shared part

function DarkRP.getAvailableVehicles()
    local vehicles = list.Get("Vehicles")
    for _, v in pairs(list.Get("SCarsList")) do
        vehicles[v.PrintName] = {
            Name = v.PrintName,
            Class = v.ClassName,
            Model = v.CarModel
        }
    end

    return vehicles
end

local function argError(Val, iArg, sType)
    error(string.format("bad argument #%u to '%s' (%s expected, got %s)", iArg, debug.getinfo(2, "n").name, sType, type(Val)), 3)
end

if not DarkRP.disabledDefaults["workarounds"]["os.date() Windows crash"] and system.IsWindows() then
    local osdate = os.date
    local replace = function(txt)
        if txt == "%%" then return txt end -- Edge case, %% is allowed
        return ""
    end

    function os.date(format, time, ...)
        if (isstring(format) or isnumber(format)) then
            format = string.gsub(format, "%%[^aAbBcdHIjmMpSUwWxXyYz]", replace)
        elseif (format ~= nil) then
            argError(Val, 1, "string")
        end

        if (not (time == nil or isnumber(time)) and (not isstring(time) or tonumber(time) == nil)) then
            argError(Val, 2, "number")
        end

        return osdate(format, time, ...)
    end
end

timer.Simple(3, function()
    if DarkRP.disabledDefaults["workarounds"]["SkidCheck"] then return end

    -- Malicious addons that kicks players this one person doesn't like.
    if not istable(Skid) then return end
    Skid.Check = fn.Id
    hook.Remove("CheckPassword", "Skid.CheckPassword")

    MsgC(Color(0, 255, 0), "SkidCheck", color_white, " has been ", Color(255, 0, 0), "DISABLED\n", color_white, [[
    SkidCheck was detected on this server and has been disabled.

    SkidCheck is a ban list addon made by HeX as an attempt to get the people he doesn't like
    banned from as many servers as possible.

    You have probably installed this addon thinking that it would get rid of cheaters, and sure,
    it might get rid of some, but that's only to make you want to download this.

    SkidCheck would ban me (FPtje, developer of DarkRP) from your server because I have a
    workshop addon that he doesn't like and because I know how to throw a prop around
        (type /credits yourname in chat for the full story on that)
    It doesn't just ban /me/ for that, it bans EVERYONE who is subscribed to the addon.

    Can you imagine trying an addon out and getting on this list /just/ because you have
    it installed? That's SkidCheck for you.

    It also bans people who have a VAC ban (even if gotten from another game), people from
    arbitrary groups, /friends/ of people he doesn't like and many, many more.

    I'm not pulling this out of my ass either, you can check everything here:
    https://forum.facepunch.com//f/gmoddev/nujl/PSA-Hex-SkidCheck-global-banlist-is-a-thing-and-people-actually-use-it/1/

    On a somewhat unrelated note, HeX has been known to be malicious for quite some time:
    He used to have an anticheat (called HAC) on his server, which not only misfired from
    time to time, but actively used exploits to fuck "cheaters" up as much as possible,
    doing malicious shit ranging from unbinding keys to removing every friend they had in
    their friends list.

    That too can be fact checked right here:
    https://forum.facepunch.com//f/gmoddev/lrbf/So-hac-got-released/1/

    DO NOT trust this guy to decide who gets banned from your server. In fact,
    DO NOT EVER TRUST ANYONE with that power. No one ever should have the power
    to decide who gets banned and who doesn't over the servers that decide to install
    their addon.
]])
end)

if SERVER and not DarkRP.disabledDefaults["workarounds"]["Error on edict limit"] then
    -- https://github.com/FPtje/DarkRP/issues/2640
    local entsCreate = ents.Create
    local entsCreateError = [[
    Unable to create entity.

    The server has come to a point where it has become impossible to create new
    entities. The entity limit has been hit. Try cleaning up the server or
    changing level. In the meantime, expect lots of errors coming from a lot of
    addons.

    If you do decide to send a bug report to ANY addon, please include this
    message.]]

    local function varArgsLen(...)
        return {...}, select("#", ...)
    end

    function ents.Create(name, ...)
        local res, len = varArgsLen(entsCreate(name, ...))

        if res[1] == NULL and ents.GetEdictCount() >= 8176 then
            DarkRP.error(entsCreateError, 2, {string.format("Affected entity: '%s'", name)})
        end

        return unpack(res, 1, len)
    end
end

--[[---------------------------------------------------------------------------
Generic InitPostEntity workarounds
---------------------------------------------------------------------------]]
hook.Add("InitPostEntity", "DarkRP_Workarounds", function()
    if CLIENT then
        if not DarkRP.disabledDefaults["workarounds"]["White flashbang flashes"] then
            -- Removes the white flashes when the server lags and the server has flashbang. Workaround because it's been there for fucking years
            hook.Remove("HUDPaint","drawHudVital")
        end

        -- Fuck up APAnti
        if not DarkRP.disabledDefaults["workarounds"]["APAnti"] then
            net.Receivers.sblockgmspawn = nil
            hook.Remove("PlayerBindPress", "_sBlockGMSpawn")
        end
        return
    end
    local commands = concommand.GetTable()
    if not DarkRP.disabledDefaults["workarounds"]["Durgz witty sayings"] and commands["durgz_witty_sayings"] then
        game.ConsoleCommand("durgz_witty_sayings 0\n") -- Deals with the cigarettes exploit. I'm fucking tired of them. I hate having to fix other people's mods, but this mod maker is retarded and refuses to update his mod.
    end

    -- Remove ULX /me command. (the /me command is the only thing this hook does)
    if not DarkRP.disabledDefaults["workarounds"]["ULX /me command"] then
        hook.Remove("PlayerSay", "ULXMeCheck")
    end

    -- why can people even save multiplayer games?
    -- Lag exploit
    if not DarkRP.disabledDefaults["workarounds"]["gm_save"] then
        concommand.Remove("gm_save")
    end

    -- Remove that weird rooftop spawn in rp_downtown_v4c_v2
    if not DarkRP.disabledDefaults["workarounds"]["rp_downtown_v4c_v2 rooftop spawn"] and
    game.GetMap() == "rp_downtown_v4c_v2" then
        for _, v in ipairs(ents.FindByClass("info_player_terrorist")) do
            v:Remove()
        end
    end
end)

--[[---------------------------------------------------------------------------
Fuck up APAnti. These hooks send unnecessary net messages.
---------------------------------------------------------------------------]]
if not DarkRP.disabledDefaults["workarounds"]["APAnti"] then
    timer.Simple(3, function()
        hook.Remove("Move", "_APA.Settings.AllowGMSpawn")
        hook.Remove("PlayerSpawnObject", "_APA.Settings.AllowGMSpawn")
    end)
end

--[[---------------------------------------------------------------------------
Wire field generator exploit
---------------------------------------------------------------------------]]
if SERVER and not DarkRP.disabledDefaults["workarounds"]["Wire field generator exploit fix"] then
    hook.Add("OnEntityCreated", "DRP_WireFieldGenerator", function(ent)
        timer.Simple(0, function()
            if IsValid(ent) and ent:GetClass() == "gmod_wire_field_device" then
                local TriggerInput = ent.TriggerInput
                function ent:TriggerInput(iname, value)
                    if iname == "Distance" and isnumber(value) then
                        value = math.min(value, 400)
                    end
                    TriggerInput(self, iname, value)
                end
            end
        end)
    end)
end

--[[---------------------------------------------------------------------------
Door tool is shitty
Let's fix that huge class exploit
---------------------------------------------------------------------------]]
if not DarkRP.disabledDefaults["workarounds"]["Door tool class fix"] then
    hook.Add("InitPostEntity", "FixDoorTool", function()
        local oldFunc = makedoor
        if isfunction(oldFunc) then
            function makedoor(ply, trace, ang, model, open, close, autoclose, closetime, class, hardware, ...)
                if class ~= "prop_dynamic" and class ~= "prop_door_rotating" then return end

                oldFunc(ply, trace, ang, model, open, close, autoclose, closetime, class, hardware, ...)
            end
        end
    end)

    local allowedDoors = {
        ["prop_dynamic"] = true,
        ["prop_door_rotating"] = true,
        [""] = true
    }

    hook.Add("CanTool", "DoorExploit", function(ply, trace, tool)
        if not IsValid(ply) or not ply:IsPlayer() or not IsValid(ply:GetActiveWeapon()) or not ply:GetActiveWeapon().GetToolObject or not ply:GetActiveWeapon():GetToolObject() then return end

        tool = ply:GetActiveWeapon():GetToolObject()
        if not allowedDoors[string.lower(tool:GetClientInfo("door_class") or "")] then
            return false
        end
    end)
end
--[[---------------------------------------------------------------------------
Anti crash exploit
---------------------------------------------------------------------------]]
if SERVER and not DarkRP.disabledDefaults["workarounds"]["Constraint crash exploit fix"] then
    hook.Add("PropBreak", "drp_AntiExploit", function(attacker, ent)
        if IsValid(ent) and ent:GetPhysicsObject():IsValid() then
            constraint.RemoveAll(ent)
        end
    end)
end

--[[---------------------------------------------------------------------------
Actively deprecate commands
---------------------------------------------------------------------------]]
if SERVER and not DarkRP.disabledDefaults["workarounds"]["Deprecated console commands"] then
    local deprecated = {
        {command = "rp_removeletters",      alternative = "removeletters"},
        {command = "rp_setname",            alternative = "forcerpname"},
        {command = "rp_unlock",             alternative = "forceunlock"},
        {command = "rp_lock",               alternative = "forcelock"},
        {command = "rp_removeowner",        alternative = "forceremoveowner"},
        {command = "rp_addowner",           alternative = "forceown"},
        {command = "rp_unownall",           alternative = "forceunownall"},
        {command = "rp_unown",              alternative = "forceunown"},
        {command = "rp_own",                alternative = "forceown"},
        {command = "rp_tellall",            alternative = "admintellall"},
        {command = "rp_tell",               alternative = "admintell"},
        {command = "rp_teamunban",          alternative = "teamunban"},
        {command = "rp_teamban",            alternative = "teamban"},
        {command = "rp_setsalary",          alternative = "setmoney"},
        {command = "rp_setmoney",           alternative = "setmoney"},
        {command = "rp_revokelicense",      alternative = "unsetlicense"},
        {command = "rp_givelicense",        alternative = "setlicense"},
        {command = "rp_unlockdown",         alternative = "unlockdown"},
        {command = "rp_lockdown",           alternative = "lockdown"},
        {command = "rp_unarrest",           alternative = "unarrest"},
        {command = "rp_arrest",             alternative = "arrest"},
        {command = "rp_cancelvote",         alternative = "forcecancelvote"},
    }

    local lastDeprecated = 0
    local function msgDeprecated(cmd, ply)
        if CurTime() - lastDeprecated < 0.5 then return end
        lastDeprecated = CurTime()

        DarkRP.notify(ply, 1, 4, ("This command has been deprecated. Please use 'DarkRP %s' or '/%s' instead."):format(cmd.alternative, cmd.alternative))
    end

    for _, cmd in pairs(deprecated) do
        concommand.Add(cmd.command, fp{msgDeprecated, cmd})
    end
end


--[[-------------------------------------------------------------------------
CAC tends to kick innocent people when they use the x86_64 branch. Since the
author is unable to maintain it, it is better to disable the addon altogether.
---------------------------------------------------------------------------]]
local disableCacMsg = [[CAC was detected on this server and has been disabled.
It turns out there is a trivial and very well known way for cheats to bypass
CAC. Worse yet, CAC tends to kick innocent players who are using the 64 bits
branch of GMod.

The author of the addon does not maintain CAC anymore, so this is to prevent
further damage and to warn you of this situation.

If you wish to leave CAC enabled, please open

addons\darkrpmodification\lua\darkrp_config\disabled_defaults.lua

Head to the section about disabled workarounds and make sure the following line is there:
["disable CAC"]                                  = true,
]]
if SERVER and not DarkRP.disabledDefaults["workarounds"]["disable CAC"] then
    timer.Create("disable CAC", 2, 1, function()
        if not CAC then return end

        --remove CAC's hooks
        hook.Remove("CheckPassword"      , "CAC.CheckPassword")
        hook.Remove("Initialize"         , "CAC.LuaWhitelistController.261b4998")
        hook.Remove("OnNPCKilled"        , "CAC.Aimbotdetector")
        hook.Remove("PlayerDeath"        , "CAC.AimbotDetector")
        hook.Remove("PlayerInitialSpawn" , "CAC.PlayerMonitor.PlayerConnected")
        hook.Remove("PlayerSay"          , "CAC.ChatCommands")
        hook.Remove("SetupMove"          , "CAC.MoveHandler")
        hook.Remove("ShutDown"           , "CAC")
        hook.Remove("Think"              , "CAC.DelayedCalls")
        hook.Remove("Tick"               , "CAC.PlayerMonitor.ProcessQueue")
        hook.Remove("player_disconnect"  , "CAC.PlayerMonitor.PlayerDisconnected")

        --remove CAC's timers
        timer.Remove("CAC.AdminUIBootstrapper")
        timer.Remove("CAC.DataUpdater")
        timer.Remove("CAC.IncidentController")
        timer.Remove("CAC.LivePlayerSessionController")
        timer.Remove("CAC.SettingsSaver")

        --remove CAC's net receivers
        net.Receivers[CAC.Identifiers.MultiplexedDataChannelName] = nil
        net.Receivers[CAC.Identifiers.AdminChannelName] = nil

        for k,v in pairs(CAC) do
            if istable(CAC[k]) and CAC[k].dtor then CAC[k]:dtor() end
        end

        CAC = nil

        MsgC(Color(0, 255, 0), "Cake Anticheat (CAC)", color_white, " has been ", Color(255, 0, 0), "DISABLED\n", Color(253, 151, 31), disableCacMsg)
    end)
end
