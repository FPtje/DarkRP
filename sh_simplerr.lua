DarkRP.simplerrRun = fc{fn.Snd, simplerr.wrapError, simplerr.wrapHook, simplerr.wrapLog, simplerr.safeCall}
DarkRP.errorNoHalt = fc{simplerr.wrapHook, simplerr.wrapLog, simplerr.runError, function(msg, err, ...) return msg, err and err + 3 or 4, ... end}
DarkRP.error = fc{simplerr.wrapError, DarkRP.errorNoHalt}

if CLIENT then
    local function showError(count, errs)
        local one = count == 1
        chat.AddText(Color(255, 0, 0), string.format("There %s %i Lua problem%s!", one and "is" or "are", count, one and "" or 's'))
        chat.AddText(Color(255, 255, 255), "\tPlease check your console for more information!")

        for i = 1, count do
            MsgC(Color(137, 222, 255), errs[i] .. "\n")
        end
    end

    net.Receive("DarkRP_simplerrError", function()
        local count = net.ReadUInt(16)
        local errs = {}

        for i = 1, count do
            table.insert(errs, net.ReadString())
        end

        showError(count, errs)
    end)

    hook.Add("onSimplerrError", "DarkRP_Simplerr", function(err)
        showError(1, {err})
    end)

    return
end

local plyMeta = FindMetaTable("Player")
util.AddNetworkString("DarkRP_simplerrError")

local function sendErrors(plys, errs)
    local count = #errs
    local one = count == 1
    DarkRP.notify(plys, 1, 120, string.format("There %s %i Lua problem%s!\nPlease check your console for more information!", one and "is" or "are", count, one and "" or 's'))
    net.Start("DarkRP_simplerrError")
    net.WriteUInt(#errs, 16)
    fn.ForEach(fn.Flip(net.WriteString), errs)
    net.Send(plys)
end

local function annoyAdmins(err)
    local admins = fn.Filter(plyMeta.IsAdmin, player.GetAll())
    sendErrors(admins, {err})
end

hook.Add("onSimplerrError", "DarkRP_Simplerr", annoyAdmins)

local function annoyAdmin(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    local errs = table.Copy(simplerr.getLog())
    if #errs == 0 then return end
    fn.Map(fp{fn.GetValue, "err"}, errs)
    sendErrors(ply, errs)
end

hook.Add("PlayerInitialSpawn", "DarkRP_Simplerr", function(ply)
    timer.Simple(1, fp{annoyAdmin, ply})
end)