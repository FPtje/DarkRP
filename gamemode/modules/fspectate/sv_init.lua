util.AddNetworkString("FSpectate")
util.AddNetworkString("FSpectateTarget")

local function findPlayer(info)
    if not info or info == "" then return nil end
    local pls = player.GetAll()

    for k = 1, #pls do
        local v = pls[k]
        if tonumber(info) == v:UserID() then
            return v
        end

        if info == v:SteamID() then
            return v
        end

        if string.find(string.lower(v:Name()), string.lower(tostring(info)), 1, true) ~= nil then
            return v
        end
    end

    return nil
end

local function startSpectating(ply, target)
    ply.FSpectatingEnt = target
    ply.FSpectating = true

    ply:ExitVehicle()

    net.Start("FSpectate")
        net.WriteBool(target == nil)
        if IsValid(ply.FSpectatingEnt) then
            net.WriteEntity(ply.FSpectatingEnt)
        end
    net.Send(ply)

    local targetText = IsValid(target) and target:IsPlayer() and (target:Nick() .. " (" .. target:SteamID() .. ")") or IsValid(target) and "an entity" or ""
    ply:ChatPrint("You are now spectating " .. targetText)
end

local function Spectate(ply, cmd, args)
    CAMI.PlayerHasAccess(ply, "FSpectate", function(b, _)
        if not b then ply:ChatPrint("No Access!") return end

        local target = findPlayer(args[1])
        if target == ply then ply:ChatPrint("Invalid target!") return end

        startSpectating(ply, target)
    end)
end
concommand.Add("FSpectate", Spectate)

net.Receive("FSpectateTarget", function(_, ply)
    CAMI.PlayerHasAccess(ply, "FSpectate", function(b, _)
        if not b then ply:ChatPrint("No Access!") return end

        startSpectating(ply, net.ReadEntity())
    end)
end)

local function TPToPos(ply, cmd, args)
    CAMI.PlayerHasAccess(ply, "FSpectateTeleport", function(b, _)
        if not b then ply:ChatPrint("No Access!") return end

        local x, y, z = string.match(args[1] or "", "([-0-9\\.]+),%s?([-0-9\\.]+),%s?([-0-9\\.]+)")
        local vx, vy, vz = string.match(args[2] or "", "([-0-9\\.]+),%s?([-0-9\\.]+),%s?([-0-9\\.]+)")
        local pos = Vector(tonumber(x), tonumber(y), tonumber(z))
        local vel = Vector(tonumber(vx or 0), tonumber(vy or 0), tonumber(vz or 0))

        if not args[1] or not x or not y or not z then return end

        ply:SetPos(pos)

        if vx and vy and vz then ply:SetVelocity(vel) end
    end)
end
concommand.Add("FTPToPos", TPToPos)

local function SpectateVisibility(ply, viewEnt)
    if not ply.FSpectating then return end

    if IsValid(ply.FSpectatingEnt) then
        AddOriginToPVS(ply.FSpectatingEnt:IsPlayer() and ply.FSpectatingEnt:GetShootPos() or ply.FSpectatingEnt:GetPos())
    end

    if ply.FSpectatePos then
        AddOriginToPVS(ply.FSpectatePos)
    end
end
hook.Add("SetupPlayerVisibility", "FSpectate", SpectateVisibility)

local function setSpectatePos(ply, cmd, args)
    CAMI.PlayerHasAccess(ply, "FSpectate", function(b, _)
        if not b then return end

        if not ply.FSpectating or not args[3] then return end
        local x, y, z = tonumber(args[1] or 0), tonumber(args[2] or 0), tonumber(args[3] or 0)

        ply.FSpectatePos = Vector(x, y, z)

        -- A position update request implies that the spectator is not spectating another player (anymore)
        ply.FSpectatingEnt = nil
    end)
end
concommand.Add("_FSpectatePosUpdate", setSpectatePos)

local function endSpectate(ply, cmd, args)
    ply.FSpectatingEnt = nil
    ply.FSpectating = nil
    ply.FSpectatePos = nil
end
concommand.Add("FSpectate_StopSpectating", endSpectate)

local function playerVoice(listener, talker)
    if not listener.FSpectating then return end

    local canHearLocal, surround = GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)

    if not IsValid(listener.FSpectatingEnt) or not listener.FSpectatingEnt:IsPlayer() then
        local spectatePos = IsValid(listener.FSpectatingEnt) and listener.FSpectatingEnt:GetPos() or listener.FSpectatePos
        if not DarkRP or not GAMEMODE.Config.voiceradius or not spectatePos then return end

        -- Return whether the listener can hear the talker locally or distance smaller than 550
        return canHearLocal or spectatePos:DistToSqr(talker:GetShootPos()) < 302500, surround
    end

    -- You can hear someone if your spectate target can hear them
    local canHear = GAMEMODE:PlayerCanHearPlayersVoice(listener.FSpectatingEnt, talker)

    -- you can always hear the person you're spectating
    return canHear or canHearLocal or listener.FSpectatingEnt == talker, surround
end
hook.Add("PlayerCanHearPlayersVoice", "FSpectate", playerVoice)

local function playerSay(talker, message)
    local split = string.Explode(" ", message)

    if split[1] and (split[1] == "!spectate" or split[1] == "/spectate") then
        Spectate(talker, split[1], {split[2]})
        return ""
    end

    if not DarkRP then return end

    for _, ply in pairs(player.GetAll()) do
        if ply == talker or not ply.FSpectating then continue end


        if
            -- Make sure you don't get it twice
            ply:GetShootPos():Distance(talker:GetShootPos()) > 250 and
            (
                -- the person is saying it close to where you are roaming
                ply.FSpectatePos and talker:GetShootPos():Distance(ply.FSpectatePos) <= 600 or

                -- The person you're spectating or someone near the person you're spectating is saying it
                (IsValid(ply.FSpectatingEnt) and ply.FSpectatingEnt:IsPlayer() and
                talker:GetShootPos():Distance(ply.FSpectatingEnt:GetShootPos()) <= 300) or

                -- Close to the object you're spectating
                (IsValid(ply.FSpectatingEnt) and not ply.FSpectatingEnt:IsPlayer() and
                talker:GetPos():Distance(ply.FSpectatingEnt:GetPos()) <= 300
                )
            ) then

            DarkRP.talkToPerson(ply, team.GetColor(talker:Team()), talker:Nick(), Color(255, 255, 255, 255), message, talker)
            return
        end
    end
end
hook.Add("PlayerSay", "FSpectate", playerSay)

-- ULX' !spectate command conflicts with mine
-- The concommand "ulx spectate" should still work.
local function fixAdminModIncompat()
    if ULib then
        ULib.removeSayCommand("!spectate")
    end

    if serverguard then
        serverguard.command:Remove("spectate")
    end
end
hook.Add("InitPostEntity", "FSpectate", fixAdminModIncompat)
