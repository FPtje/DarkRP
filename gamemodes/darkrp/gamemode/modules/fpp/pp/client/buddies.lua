FPP = FPP or {}

--Make buddies if not there
sql.Query("CREATE TABLE IF NOT EXISTS FPP_Buddies('steamid' TEXT NOT NULL, 'name' TEXT NOT NULL, 'physgun' INTEGER NOT NULL, 'gravgun' INTEGER NOT NULL, 'toolgun' INTEGER NOT NULL, 'playeruse' INTEGER NOT NULL, 'entitydamage' INTEGER NOT NULL, PRIMARY KEY('steamid'));")

FPP.Buddies = {}
function FPP.LoadBuddies()
    local data = sql.Query("SELECT * FROM FPP_Buddies")
    for _, v in ipairs(data or {}) do
        FPP.Buddies[v.steamid] = {name = v.name, physgun = v.physgun, gravgun = v.gravgun, toolgun = v.toolgun, playeruse = v.playeruse, entitydamage = v.entitydamage} --Put all the buddies in the table
        for _, ply in ipairs(player.GetAll()) do --If the buddies are in the server then add them serverside
            if ply:SteamID() == v.steamid then
                -- update the name
                sql.Query("UPDATE FPP_Buddies SET name = " .. sql.SQLStr(ply:Nick()) .. " WHERE steamid = " .. sql.SQLStr(v.steamid) .. ";")
                FPP.Buddies[v.steamid].name = ply:Nick()
                RunConsoleCommand("FPP_SetBuddy", ply:UserID(), v.physgun, v.gravgun, v.toolgun, v.playeruse, v.entitydamage)
            end
        end
    end
end
hook.Add("InitPostEntity", "FPP_Start", FPP.LoadBuddies)

function FPP.SaveBuddy(SteamID, Name, Type, value)
    if Type == "remove" then
        FPP.Buddies[SteamID] = nil
        sql.Query("DELETE FROM FPP_Buddies WHERE steamid = " .. sql.SQLStr(SteamID) .. ";")
        for _, v in ipairs(player.GetAll()) do
            if v:SteamID() == SteamID then
                RunConsoleCommand("FPP_SetBuddy", v:UserID(), "0", "0", "0", "0", "0")
            end
        end
        return
    end

    FPP.Buddies[SteamID] = FPP.Buddies[SteamID] or {name = Name, physgun = 0, gravgun = 0, toolgun = 0, playeruse = 0, entitydamage = 0} -- Create if not there
    FPP.Buddies[SteamID][Type] = value

    local data = sql.Query("SELECT * FROM FPP_Buddies WHERE steamid = " .. sql.SQLStr(SteamID) .. ";")
    if data then
        sql.Query("UPDATE FPP_Buddies SET " .. Type .. " = " .. value .. " WHERE steamid = " .. sql.SQLStr(SteamID) .. ";")
        -- Oi! update the name!
        sql.Query("UPDATE FPP_Buddies SET name = " .. sql.SQLStr(Name) .. " WHERE steamid = " .. sql.SQLStr(SteamID) .. ";")
        FPP.Buddies[SteamID].name = Name
    else
        sql.Query("INSERT INTO FPP_Buddies VALUES(" .. sql.SQLStr(SteamID) .. ", " .. sql.SQLStr(Name) .. ", " .. FPP.Buddies[SteamID].physgun .. ", " .. FPP.Buddies[SteamID].gravgun .. ", " .. FPP.Buddies[SteamID].toolgun .. ", " .. FPP.Buddies[SteamID].playeruse .. ", " .. FPP.Buddies[SteamID].entitydamage .. ");")
    end

    --Let the server know of your changes
    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == SteamID then -- If the person you're adding is in the server then add him serverside
            RunConsoleCommand("FPP_SetBuddy", v:UserID(), FPP.Buddies[SteamID].physgun, FPP.Buddies[SteamID].gravgun, FPP.Buddies[SteamID].toolgun, FPP.Buddies[SteamID].playeruse, FPP.Buddies[SteamID].entitydamage)
            --Don't break because there can be people(bots actually) with the same steam ID
        end
    end

    local ShouldRemove = true -- Remove the buddy if he isn't buddy in anything anymore
    for _, v in pairs(FPP.Buddies[SteamID]) do
        if v == 1 or v == "1" then
            ShouldRemove = false
            break
        end
    end

    if ShouldRemove then -- If everything = 0 then he's not your friend anymore
        FPP.Buddies[SteamID] = nil
        sql.Query("DELETE FROM FPP_Buddies WHERE steamid = " .. sql.SQLStr(SteamID) .. ";")
        for _, v in ipairs(player.GetAll()) do
            if v:SteamID() == SteamID then
                RunConsoleCommand("FPP_SetBuddy", v:UserID(), "0", "0", "0", "0", "0")
            end
        end
    end
end

function FPP.NewBuddy(um)
    local ply = um:ReadEntity()

    if not IsValid(ply) or not ply:IsPlayer() then return end
    local SteamID = ply:SteamID()

    local data = sql.Query("SELECT * FROM FPP_Buddies")
    for _, v in ipairs(data or {}) do
        -- make the player buddy if they're in your buddies list
        if v.steamid ~= SteamID then continue end

        RunConsoleCommand("FPP_SetBuddy", ply:UserID(), v.physgun, v.gravgun, v.toolgun, v.playeruse, v.entitydamage)
        -- update the name
        sql.Query("UPDATE FPP_Buddies SET name = " .. sql.SQLStr(ply:Nick()) .. " WHERE steamid = " .. sql.SQLStr(SteamID) .. ";")
        FPP.Buddies[SteamID] = FPP.Buddies[SteamID] or {}
        FPP.Buddies[SteamID].name = ply:Nick()
    end
end
usermessage.Hook("FPP_CheckBuddy", FPP.NewBuddy)
