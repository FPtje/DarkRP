local plyMeta = FindMetaTable("Player")
local finishWarrantRequest
local arrestedPlayers = {}

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function plyMeta:warrant(warranter, reason)
    if self.warranted then return end
    local suppressMsg = hook.Call("playerWarranted", GAMEMODE, self, warranter, reason)

    self.warranted = true
    timer.Simple(GAMEMODE.Config.searchtime, function()
        if not IsValid(self) then return end
        self:unWarrant(warranter)
    end)

    if suppressMsg then return end

    local warranterNick = IsValid(warranter) and warranter:Nick() or DarkRP.getPhrase("disconnected_player")
    local centerMessage = DarkRP.getPhrase("warrant_approved", self:Nick(), reason, warranterNick)
    local printMessage = DarkRP.getPhrase("warrant_ordered", warranterNick, self:Nick(), reason)

    for a, b in pairs(player.GetAll()) do
        b:PrintMessage(HUD_PRINTCENTER, centerMessage)
        b:PrintMessage(HUD_PRINTCONSOLE, printMessage)
    end

    DarkRP.notify(warranter, 0, 4, DarkRP.getPhrase("warrant_approved2"))
end

function plyMeta:unWarrant(unwarranter)
    if not self.warranted then return end

    local suppressMsg = hook.Call("playerUnWarranted", GAMEMODE, self, unwarranter)

    self.warranted = false

    if suppressMsg then return end

    DarkRP.notify(unwarranter, 2, 4, DarkRP.getPhrase("warrant_expired", self:Nick()))
end

function plyMeta:requestWarrant(suspect, actor, reason)
    local question = DarkRP.getPhrase("warrant_request", actor:Nick(), suspect:Nick(), reason)
    DarkRP.createQuestion(question, suspect:EntIndex() .. "warrant", self, 40, finishWarrantRequest, actor, suspect, reason)
end

function plyMeta:wanted(actor, reason, time)
    local suppressMsg = hook.Call("playerWanted", DarkRP.hooks, self, actor, reason)

    self:setDarkRPVar("wanted", true)
    self:setDarkRPVar("wantedReason", reason)

    timer.Create(self:UniqueID() .. " wantedtimer", time or GAMEMODE.Config.wantedtime, 1, function()
        if not IsValid(self) then return end
        self:unWanted()
    end)

    if suppressMsg then return end

    local actorNick = IsValid(actor) and actor:Nick() or DarkRP.getPhrase("disconnected_player")
    local centerMessage = DarkRP.getPhrase("wanted_by_police", self:Nick(), reason, actorNick)
    local printMessage = DarkRP.getPhrase("wanted_by_police_print", actorNick, self:Nick(), reason)

    for _, ply in pairs(player.GetAll()) do
        ply:PrintMessage(HUD_PRINTCENTER, centerMessage)
        ply:PrintMessage(HUD_PRINTCONSOLE, printMessage)
    end

    DarkRP.log(string.Replace(printMessage, "\n", " "), Color(0, 150, 255))
end

function plyMeta:unWanted(actor)
    local suppressMsg = hook.Call("playerUnWanted", GAMEMODE, self, actor)
    self:setDarkRPVar("wanted", nil)
    self:setDarkRPVar("wantedReason", nil)

    timer.Remove(self:UniqueID() .. " wantedtimer")

    if suppressMsg then return end

    local expiredMessage = IsValid(actor) and DarkRP.getPhrase("wanted_revoked", self:Nick(), actor:Nick() or "") or
        DarkRP.getPhrase("wanted_expired", self:Nick())

    DarkRP.log(string.Replace(expiredMessage, "\n", " "), Color(0, 150, 255))

    for _, ply in pairs(player.GetAll()) do
        ply:PrintMessage(HUD_PRINTCENTER, expiredMessage)
        ply:PrintMessage(HUD_PRINTCONSOLE, expiredMessage)
    end
end

function plyMeta:arrest(time, arrester)
    time = time or GAMEMODE.Config.jailtimer or 120

    hook.Call("playerArrested", DarkRP.hooks, self, time, arrester)
    if self:InVehicle() then self:ExitVehicle() end
    self:setDarkRPVar("Arrested", true)
    arrestedPlayers[self:SteamID()] = true

    -- Always get sent to jail when Arrest() is called, even when already under arrest
    if GAMEMODE.Config.teletojail and DarkRP.jailPosCount() ~= 0 then
        self:Spawn()
    end
end

function plyMeta:unArrest(unarrester)
    if not self:isArrested() then return end

    self:setDarkRPVar("Arrested", nil)
    arrestedPlayers[self:SteamID()] = nil
    hook.Call("playerUnArrested", DarkRP.hooks, self, unarrester)
end

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
local function CombineRequest(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end

    local DoSay = function(text)
        if text == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
            return
        end
        for k, v in pairs(player.GetAll()) do
            if v:isCP() or v == ply then
                DarkRP.talkToPerson(v, team.GetColor(ply:Team()), DarkRP.getPhrase("request") .. ply:Nick(), Color(255, 0, 0, 255), text, ply)
            end
        end
    end
    return args, DoSay
end
DarkRP.defineChatCommand("cr", CombineRequest, 1.5)

local function warrantCommand(ply, args)
    local target = DarkRP.findPlayer(args[1])
    local reason = table.concat(args, " ", 2)

    local canRequest, message = hook.Call("canRequestWarrant", DarkRP.hooks, target, ply, reason)
    if not canRequest then
        DarkRP.notify(ply, 1, 4, message)
        return ""
    end

    if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then -- No need to search through all the teams if the player is a mayor
        local mayors = {}

        for k,v in pairs(RPExtraTeams) do
            if v.mayor then
                table.Add(mayors, team.GetPlayers(k))
            end
        end

        if #mayors > 0 then -- Request a warrant if there's a mayor
            local mayor = table.Random(mayors)
            mayor:requestWarrant(target, ply, reason)
            DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("warrant_request2", mayor:Nick()))
            return ""
        end
    end

    target:warrant(ply, reason)

    return ""
end
DarkRP.defineChatCommand("warrant", warrantCommand)

local function wantedCommand(ply, args)
    local target = DarkRP.findPlayer(args[1])
    local reason = table.concat(args, " ", 2)

    local canWanted, message = hook.Call("canWanted", DarkRP.hooks, target, ply, reason)
    if not canWanted then
        DarkRP.notify(ply, 1, 4, message)
        return ""
    end

    target:wanted(ply, reason)

    return ""
end
DarkRP.defineChatCommand("wanted", wantedCommand)

local function unwantedCommand(ply, args)
    local target = DarkRP.findPlayer(args)

    local canUnwant, message = hook.Call("canUnwant", DarkRP.hooks, target, ply)
    if not canUnwant then
        DarkRP.notify(ply, 1, 4, message)
        return ""
    end

    target:unWanted(ply)

    return ""
end
DarkRP.defineChatCommand("unwanted", unwantedCommand)

/*---------------------------------------------------------------------------
Admin commands
---------------------------------------------------------------------------*/
local function ccArrest(ply, args)
    if DarkRP.jailPosCount() == 0 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("no_jail_pos"))
        return
    end

    local targets = DarkRP.findPlayers(args[1])

    if not targets then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args[1]))
        return
    end

    for k, target in pairs(targets) do
        local length = tonumber(args[2])
        if length then
            target:arrest(length, ply)
        else
            target:arrest(nil, ply)
        end

        if ply:EntIndex() == 0 then
            DarkRP.log("Console force-arrested " .. target:SteamName(), Color(0, 255, 255))
        else
            DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") force-arrested " .. target:SteamName(), Color(0, 255, 255))
        end
    end
end
DarkRP.definePrivilegedChatCommand("arrest", "DarkRP_AdminCommands", ccArrest)

local function ccUnarrest(ply, args)
    local targets = DarkRP.findPlayers(args[1])

    if not targets then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args[1]))
        return
    end

    for _, target in pairs(targets) do
        target:unArrest(ply)
        if not target:Alive() then target:Spawn() end

        if ply:EntIndex() == 0 then
            DarkRP.log("Console force-unarrested " .. target:SteamName(), Color(0, 255, 255))
        else
            DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") force-unarrested " .. target:SteamName(), Color(0, 255, 255))
        end
    end
end
DarkRP.definePrivilegedChatCommand("unarrest", "DarkRP_AdminCommands", ccUnarrest)

/*---------------------------------------------------------------------------
Callback functions
---------------------------------------------------------------------------*/
function finishWarrantRequest(choice, mayor, initiator, suspect, reason)
    if not tobool(choice) then
        DarkRP.notify(initiator, 1, 4, DarkRP.getPhrase("warrant_denied", mayor:Nick()))
        return
    end
    if IsValid(suspect) then
        suspect:warrant(initiator, reason)
    end
end

/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/
function DarkRP.hooks:playerArrested(ply, time, arrester)
    if ply:isWanted() then ply:unWanted(arrester) end
    ply:setDarkRPVar("HasGunlicense", nil)

    ply:StripWeapons()

    if ply:isArrested() then return end -- hasn't been arrested before

    ply:PrintMessage(HUD_PRINTCENTER, DarkRP.getPhrase("youre_arrested", time))
    for k, v in pairs(player.GetAll()) do
        if v == ply then continue end
        v:PrintMessage(HUD_PRINTCENTER, DarkRP.getPhrase("hes_arrested", ply:Name(), time))
    end

    local steamID = ply:SteamID()
    timer.Create(ply:UniqueID() .. "jailtimer", time, 1, function()
        if IsValid(ply) then ply:unArrest() end
        arrestedPlayers[steamID] = nil
    end)
    umsg.Start("GotArrested", ply)
        umsg.Float(time)
    umsg.End()
end

function DarkRP.hooks:playerUnArrested(ply, actor)
    if ply.Sleeping and GAMEMODE.KnockoutToggle then
        DarkRP.toggleSleep(ply, "force")
    end

    gamemode.Call("PlayerLoadout", ply)
    if GAMEMODE.Config.telefromjail then
        local ent, pos = GAMEMODE:PlayerSelectSpawn(ply)
        timer.Simple(0, function() if IsValid(ply) then ply:SetPos(pos or ent:GetPos()) end end) -- workaround for SetPos in weapon event bug
    end

    timer.Remove(ply:UniqueID() .. "jailtimer")
    DarkRP.notifyAll(0, 4, DarkRP.getPhrase("hes_unarrested", ply:Name()))
end

hook.Add("PlayerInitialSpawn", "Arrested", function(ply)
    if not arrestedPlayers[ply:SteamID()] then return end
    local time = GAMEMODE.Config.jailtimer
    -- Delay the actual arrest by a single frame to allow
    -- the player to initialise
    timer.Simple(0, fp{ply.arrest, ply, time})
    DarkRP.notify(ply, 0, 5, DarkRP.getPhrase("jail_punishment", time))
end)
