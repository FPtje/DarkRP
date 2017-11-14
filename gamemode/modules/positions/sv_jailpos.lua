local function storeJail(ply, add, hasAccess)
    if not IsValid(ply) then return end

    -- Admin or Chief can set the Jail Position
    local Team = ply:Team()
    if (RPExtraTeams[Team] and RPExtraTeams[Team].chief and GAMEMODE.Config.chiefjailpos) or hasAccess then
        DarkRP.storeJailPos(ply, add)
    else
        local str = DarkRP.getPhrase("admin_only")
        if GAMEMODE.Config.chiefjailpos then
            str = DarkRP.getPhrase("chief_or") .. str
        end

        DarkRP.notify(ply, 1, 4, str)
    end
end
local function JailPos(ply)
    CAMI.PlayerHasAccess(ply, "DarkRP_AdminCommands", fp{storeJail, ply, false})

    return ""
end
DarkRP.defineChatCommand("jailpos", JailPos)
DarkRP.defineChatCommand("setjailpos", JailPos)

local function AddJailPos(ply)
    CAMI.PlayerHasAccess(ply, "DarkRP_AdminCommands", fp{storeJail, ply, true})

    return ""
end
DarkRP.defineChatCommand("addjailpos", AddJailPos)
