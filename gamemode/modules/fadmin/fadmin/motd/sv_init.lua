FAdmin.MOTD = {}
local MOTDPage

sql.Query([[CREATE TABLE IF NOT EXISTS FADMIN_MOTD(
    'map' TEXT NOT NULL PRIMARY KEY,
    x INTEGER NOT NULL,
    y INTEGER NOT NULL,
    z INTEGER NOT NULL,
    pitch INTEGER NOT NULL,
    yaw INTEGER NOT NULL,
    roll INTEGER NOT NULL
    );]])

local MOTD = sql.Query("SELECT * FROM FADMIN_MOTD WHERE LOWER(map) = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";")

hook.Add("InitPostEntity", "PlaceMOTD", function()
    if not MOTD or (not MOTD[1] and not MOTD["1"]) then return end
    MOTD = MOTD[1] or MOTD["1"]

    local ent = ents.Create("fadmin_motd")
    ent:SetPos(Vector(MOTD.x, MOTD.y, MOTD.z))
    ent:SetAngles(Angle(MOTD.pitch % 360, MOTD.yaw % 360, MOTD.roll % 360))
    ent:Spawn()
    ent:Activate()

    if file.Exists("FAdmin/CurMOTDPage.txt", "DATA") and file.Read("FAdmin/CurMOTDPage.txt", "DATA") ~= "" then
        game.ConsoleCommand("_FAdmin_MOTDPage \"" .. file.Read("FAdmin/CurMOTDPage.txt", "DATA") .. "\"\n")
    end
end)

function FAdmin.MOTD.SaveMOTD(ent, ply)
    local pos = ent:GetPos()
    local ang = ent:GetAngles()

    local map, x, y, z, pitch, yaw, roll =
        string.lower(game.GetMap()),
        pos.x, pos.y, pos.z,
        ang.p, ang.y, ang.r
    if MOTD then
        sql.Query([[UPDATE FADMIN_MOTD SET ]]
        .. "x = " .. MySQLite.SQLStr(x) .. ", "
        .. "y = " .. MySQLite.SQLStr(y) .. ", "
        .. "z = " .. MySQLite.SQLStr(z) .. ", "
        .. "pitch = " .. MySQLite.SQLStr(pitch) .. ", "
        .. "yaw = " .. MySQLite.SQLStr(yaw) .. ", "
        .. "roll = " .. MySQLite.SQLStr(roll)
        .. " WHERE map = " .. MySQLite.SQLStr(map) .. ";")
    else
        sql.Query([[INSERT INTO FADMIN_MOTD VALUES(]]
        .. MySQLite.SQLStr(map) .. ", "
        .. MySQLite.SQLStr(x) .. ", "
        .. MySQLite.SQLStr(y) .. ", "
        .. MySQLite.SQLStr(z) .. ", "
        .. MySQLite.SQLStr(pitch) .. ", "
        .. MySQLite.SQLStr(yaw) .. ", "
        .. MySQLite.SQLStr(roll)
        .. ");")
    end
    FAdmin.Messages.SendMessage(ply, 4, "MOTD position saved!")
end

function FAdmin.MOTD.RemoveMOTD(ent, ply)
    sql.Query("DELETE FROM FADMIN_MOTD WHERE map = " .. MySQLite.SQLStr(string.lower(game.GetMap())) .. ";")
    FAdmin.Messages.SendMessage(ply, 4, "MOTD removed!")
end

function FAdmin.MOTD.SetMOTDPage(ply, cmd, args)
    if not args[1] then
        FAdmin.Messages.SendMessage(ply, 4, "MOTD is set to: " .. MOTDPage:GetString())
        return false
    end
    if ply:EntIndex() ~= 0 and (not ply.IsSuperAdmin or not ply:IsSuperAdmin()) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    RunConsoleCommand("_FAdmin_MOTDPage", args[1])
    file.Write("FAdmin/CurMOTDPage.txt", args[1])

    return true, args[1]
end

local function CreateMOTD(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then FAdmin.Messages.SendMessage(ply, 5, "No access!") return false end
    local MOTDEnt = ents.Create("fadmin_motd")
    MOTDEnt:SpawnFunction(ply, ply:GetEyeTrace())

    return true, MOTDEnt
end

FAdmin.StartHooks["MOTD"] = function()
    MOTDPage = GetConVar("_FAdmin_MOTDPage")
    FAdmin.Commands.AddCommand("MOTDPage", FAdmin.MOTD.SetMOTDPage)
    FAdmin.Commands.AddCommand("CreateMOTD", CreateMOTD)
end
