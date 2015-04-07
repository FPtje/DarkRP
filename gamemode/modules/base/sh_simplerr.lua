-- simplerrRun: Run a function with the given parameters and send any runtime errors to admins
fprp.simplerrRun = fc{
    fn.Snd, -- On success ignore the first return value
    simplerr.wrapError,
    simplerr.wrapHook,
    simplerr.wrapLog,
    simplerr.safeCall
}

-- error: throw a runtime error without exiting the stack
-- parameters: msg, [stackNr], [hints], [path], [line]
fprp.errorNoHalt = fc{
    simplerr.wrapHook,
    simplerr.wrapLog,
    simplerr.runError,
    function(msg, err, ...) return msg, err and err + 1 or 2, ... end -- Raise error level one higher
}

-- error: throw a runtime error
-- parameters: msg, [stackNr], [hints], [path], [line]
fprp.error = fc{
    simplerr.wrapError,
    fprp.errorNoHalt
}

-- Print errors from the server in the console and show a message in chat
if CLIENT then
    net.Receive("fprp_simplerrError", function()
        local count = net.ReadUInt(16);

        local one = count == 1
        chat.AddText(Color(255, 0, 0), string.format("There %s %i Lua problem%s!", one and "is" or "are", count, one and '' or 's'));
        chat.AddText(Color(255, 255, 255), "\tPlease check your console for more information!");

        for i = 1, count do
            local err = net.ReadString();
            MsgC(Color(137, 222, 255), err .. "\n");
        end
    end);

    return
end

-- Serverside part
local plyMeta = FindMetaTable("Player");
util.AddNetworkString("fprp_simplerrError");

-- Send all errors to the client
local function sendErrors(plys, errs)
    local count = #errs
    local one = count == 1

    fprp.notify(plys, 1, 120, string.format("There %s %i Lua problem%s!\nPlease check your console for more information!", one and "is" or "are", count, one and '' or 's'));
    net.Start("fprp_simplerrError");
        net.WriteUInt(#errs, 16);
        fn.ForEach(fn.Flip(net.WriteString), errs);
    net.Send(plys);
end

-- Annoy all admins when an error occurs
local function annoyAdmins(err)
    local admins = fn.Filter(plyMeta.IsAdmin, player.GetAll());
    sendErrors(admins, {err});
end
hook.Add("onSimplerrError", "fprp_Simplerr", annoyAdmins);

-- Annoy joining admin with errors
local function annoyAdmin(ply)
    if not ply:IsAdmin() then return end
    local errs = table.Copy(simplerr.getLog());
    if #errs == 0 then return end

    fn.Map(fp{fn.GetValue, "err"}, errs);
    sendErrors(ply, errs);
end
hook.Add("PlayerInitialSpawn", "fprp_Simplerr", function(ply) timer.Simple(1, fp{annoyAdmin, ply}) end)
