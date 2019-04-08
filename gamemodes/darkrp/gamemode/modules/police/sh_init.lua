local plyMeta = FindMetaTable("Player")

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function plyMeta:isArrested()
    return self:getDarkRPVar("Arrested")
end

function plyMeta:isWanted()
    return self:getDarkRPVar("wanted")
end

function plyMeta:getWantedReason()
    return self:getDarkRPVar("wantedReason")
end

function plyMeta:isCP()
    return GAMEMODE.CivilProtection and GAMEMODE.CivilProtection[self:Team()] or false
end

plyMeta.isMayor = fn.Compose{fn.Curry(fn.GetValue, 2)("mayor"), plyMeta.getJobTable}
plyMeta.isChief = fn.Compose{fn.Curry(fn.GetValue, 2)("chief"), plyMeta.getJobTable}


--[[---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]

function DarkRP.hooks:canRequestWarrant(target, actor, reason)
    if not IsValid(target) then return false, DarkRP.getPhrase("suspect_doesnt_exist") end
    if not reason or string.len(reason) == 0 then return false, DarkRP.getPhrase("vote_specify_reason") end
    if string.len(reason) > 200 then return false, DarkRP.getPhrase("too_long") end
    if not IsValid(actor) then return false, DarkRP.getPhrase("actor_doesnt_exist") end
    if not actor:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("get_a_warrant")) end
    if target.warranted then return false, DarkRP.getPhrase("already_a_warrant") end
    if not actor:isCP() then return false, DarkRP.getPhrase("incorrect_job", DarkRP.getPhrase("get_a_warrant")) end

    return true
end

function DarkRP.hooks:canRemoveWarrant(target, actor)
    if not IsValid(target) then return false, DarkRP.getPhrase("suspect_doesnt_exist") end
    if not IsValid(actor) then return false, DarkRP.getPhrase("actor_doesnt_exist") end
    if not actor:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("remove_a_warrant")) end
    if not target.warranted then return false, DarkRP.getPhrase("not_warranted") end
    if not actor:isCP() then return false, DarkRP.getPhrase("incorrect_job", DarkRP.getPhrase("remove_a_warrant")) end
    if actor:isArrested() then return false, DarkRP.getPhrase("unable", DarkRP.getPhrase("remove_a_warrant"), "") end

    return true
end

function DarkRP.hooks:canWanted(target, actor, reason)
    if not IsValid(target) then return false, DarkRP.getPhrase("suspect_doesnt_exist") end
    if not reason or string.len(reason) == 0 then return false, DarkRP.getPhrase("vote_specify_reason") end
    if string.len(reason) > 200 then return false, DarkRP.getPhrase("too_long") end
    if not IsValid(actor) then return false, DarkRP.getPhrase("actor_doesnt_exist") end
    if not actor:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("make_someone_wanted")) end
    if not actor:isCP() then return false, DarkRP.getPhrase("incorrect_job", DarkRP.getPhrase("make_someone_wanted")) end
    if target:isWanted() then return false, DarkRP.getPhrase("already_wanted") end
    if not target:Alive() then return false, DarkRP.getPhrase("suspect_must_be_alive_to_do_x", DarkRP.getPhrase("make_someone_wanted")) end
    if target:isArrested() then return false, DarkRP.getPhrase("suspect_already_arrested") end

    return true
end

function DarkRP.hooks:canUnwant(target, actor)
    if not IsValid(target) then return false, DarkRP.getPhrase("suspect_doesnt_exist") end
    if not IsValid(actor) then return false, DarkRP.getPhrase("actor_doesnt_exist") end
    if not actor:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("remove_wanted_status")) end
    if not actor:isCP() then return false, DarkRP.getPhrase("incorrect_job", DarkRP.getPhrase("remove_wanted_status")) end
    if not target:isWanted() then return false, DarkRP.getPhrase("not_wanted") end
    if not target:Alive() then return false, DarkRP.getPhrase("suspect_must_be_alive_to_do_x", DarkRP.getPhrase("remove_wanted_status")) end

    return true
end

--[[---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------]]
for _, cmd in pairs{"cr", "911", "999", "112", "000"} do
    DarkRP.declareChatCommand{
        command = cmd,
        description = "Cry for help, the police will come (hopefully)!",
        delay = 1.5
    }
end

DarkRP.declareChatCommand{
    command = "warrant",
    description = "Get a search warrant for a certain player. With this warrant you can search their house.",
    delay = 1.5,
    condition = fn.FAnd{plyMeta.Alive, plyMeta.isCP, fn.Compose{fn.Not, plyMeta.isArrested}},
    tableArgs = true
}

DarkRP.declareChatCommand{
    command = "unwarrant",
    description = "Remove a search warrant for a certain player. With a warrant you can search their house.",
    delay = 1.5,
    condition = fn.FAnd{plyMeta.Alive, plyMeta.isCP, fn.Compose{fn.Not, plyMeta.isArrested}},
    tableArgs = true
}

DarkRP.declareChatCommand{
    command = "wanted",
    description = "Make a player wanted. This is needed to get them arrested.",
    delay = 1.5,
    condition = fn.FAnd{plyMeta.Alive, plyMeta.isCP, fn.Compose{fn.Not, plyMeta.isArrested}},
    tableArgs = true
}

DarkRP.declareChatCommand{
    command = "unwanted",
    description = "Remove a player's wanted status.",
    delay = 1.5,
    condition = fn.FAnd{plyMeta.Alive, plyMeta.isCP, fn.Compose{fn.Not, plyMeta.isArrested}}
}

DarkRP.declareChatCommand{
    command = "agenda",
    description = "Set the agenda.",
    delay = 1.5,
    condition = fn.Compose{fn.Not, fn.Curry(fn.Eq, 2)(nil), plyMeta.getAgenda}
}

DarkRP.declareChatCommand{
    command = "addagenda",
    description = "Add a line of text to the agenda.",
    delay = 1.5,
    condition = fn.Compose{fn.Not, fn.Curry(fn.Eq, 2)(nil), plyMeta.getAgenda}
}

DarkRP.declareChatCommand{
    command = "lottery",
    description = "Start a lottery.",
    delay = 1.5,
    condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
    command = "lockdown",
    description = "Start a lockdown. Everyone will have to stay inside.",
    delay = 1.5,
    condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
    command = "unlockdown",
    description = "Stop a lockdown.",
    delay = 1.5,
    condition = plyMeta.isMayor
}

DarkRP.declareChatCommand{
    command = "arrest",
    description = "Forcefully arrest a player.",
    delay = 0.5,
    tableArgs = true
}

DarkRP.declareChatCommand{
    command = "unarrest",
    description = "Forcefully unarrest a player.",
    delay = 0.5,
    tableArgs = true
}

local noMayorExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isMayor), player.GetAll}
local noChiefExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isChief), player.GetAll}

DarkRP.declareChatCommand{
    command = "requestlicense",
    description = "Request a gun license.",
    delay = 1.5,
    condition = fn.FAnd {
        fn.FOr {
            fn.Curry(fn.Not, 2)(noMayorExists),
            fn.Curry(fn.Not, 2)(noChiefExists),
            fn.Compose{fn.Not, fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isCP), player.GetAll}
        },
        fn.Compose{fn.Not, fn.Curry(fn.Flip(plyMeta.getDarkRPVar), 2)("HasGunlicense")},
        fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("LicenseRequested")}
    }
}

DarkRP.declareChatCommand{
    command = "givelicense",
    description = "Give someone a gun license",
    delay = 1.5,
    condition = fn.FOr{
        plyMeta.isMayor, -- Mayors can hand out licenses
        fn.FAnd{plyMeta.isChief, noMayorExists}, -- Chiefs can if there is no mayor
        fn.FAnd{plyMeta.isCP, noChiefExists, noMayorExists} -- CP's can if there are no chiefs nor mayors
    }
}

DarkRP.declareChatCommand{
    command = "demotelicense",
    description = "Start a vote to get someone's license revoked.",
    delay = 1.5,
    tableArgs = true
}

DarkRP.declareChatCommand{
    command = "setlicense",
    description = "Forcefully give a player a license.",
    delay = 1.5
}

DarkRP.declareChatCommand{
    command = "unsetlicense",
    description = "Forcefully revoke a player's license.",
    delay = 1.5
}
