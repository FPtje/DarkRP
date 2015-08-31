local plyMeta = FindMetaTable("Player")
-- automatically block players from doing certain things with their DarkRP entities
local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}

-- Assert function, asserts a property and returns the error if false.
-- Allows f to override err and hints by simply returning them
local ass = function(f, err, hints) return function(...)
    local res = {f(...)}
    table.insert(res, err)
    table.insert(res, hints)

    return unpack(res)
end end

-- Returns whether a value is nil
local isnil = fn.Curry(fn.Eq, 2)(nil)
-- Optional value, when filled in it must meet the conditions
local optional = function(...) return fn.FOr{isnil, ...} end
-- Check the correctness of a model
local checkModel = isstring

-- A table of which each element must meet condition f
local tableOf = function(f) return function(tbl)
    if not istable(tbl) then return false end
    for k,v in pairs(tbl) do if not f(v) then return false end end
    return true
end end

-- Any of the given elements
local oneOf = function(f) return fp{table.HasValue, f} end

-- A table that is nonempty, wrap around tableOf
local nonempty = function(f) return function(tbl) return istable(tbl) and #tbl > 0 and f(tbl) end end

-- A value must be unique amongst all `kind`. Uses optional `hash` function to create custom hashes in the internal table
local uniqueEntity = function(cmd, tbl)
    for k, v in pairs(DarkRPEntities) do
        if v.cmd ~= cmd then continue end
        return false, "This entity does not have a unique command.", {"There must be some other end that has the same thing for 'cmd'.", "Fix this by changing the 'cmd' field of your entity to something else."}
    end
    return true
end

local uniqueJob = function(v, tbl)
    local job = DarkRP.getJobByCommand(v)
    if job then return false, "This job does not have a unique command.", {"There must be some other job that has the same command.", "Fix this by changing the 'command' of your job to something else."} end
    return true
end

-- Template for a correct job
local requiredTeamItems = {
    color       = ass(tableOf(isnumber), "The color must be a Color value.", {"Color values look like this: Color(r, g, b, a), where r, g, b and a are numbers between 0 and 255."}),
    model       = ass(fn.FOr{checkModel, nonempty(tableOf(checkModel))}, "The model must either be a table of correct model strings or a single correct model string.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
    description = ass(isstring, "The description must be a string."),
    weapons     = ass(optional(tableOf(isstring)), "The weapons must be a valid table of strings.", {"Example: weapons = {\"med_kit\", \"weapon_bugbait\"},"}),
    command     = ass(fn.FAnd{isstring, uniqueJob}, "The command must be a string."),
    max         = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}}, "The max must be a number greater than or equal to zero.", {"Zero means infinite.", "A decimal between 0 and 1 is seen as a percentage."}),
    salary      = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}}, "The salary must be a number greater than zero."),
    admin       = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}, fp{fn.Gte, 2}}, "The admin value must be a number greater than or equal to zero and smaller than three."),
    vote        = ass(optional(isbool), "The vote must be either true or false."),

    -- Optional advanced stuff
    category              = ass(optional(isstring), "The category must be the name of an existing category!"),
    sortOrder             = ass(optional(isnumber), "The sortOrder must be a number."),
    buttonColor           = ass(optional(tableOf(isnumber)), "The buttonColor must be a Color value."),
    label                 = ass(optional(isstring), "The label must be a valid string."),
    ammo                  = ass(optional(tableOf(isnumber)), "The ammo must be a table containing numbers.", {"See example on http://wiki.darkrp.com/index.php/DarkRP:CustomJobFields"}),
    hasLicense            = ass(optional(isbool), "The hasLicense must be either true or false."),
    NeedToChangeFrom      = ass(optional(tableOf(isnumber), isnumber), "The NeedToChangeFrom must be either an existing team or a table of existing teams", {"Is there a job here that doesn't exist (anymore)?"}),
    customCheck           = ass(optional(isfunction), "The customCheck must be a function."),
    CustomCheckFailMsg    = ass(optional(isstring, isfunction), "The CustomCheckFailMsg must be either a string or a function."),
    modelScale            = ass(optional(isnumber), "The modelScale must be a number."),
    maxpocket             = ass(optional(isnumber), "The maxPocket must be a number."),
    maps                  = ass(optional(tableOf(isstring)), "The maps value must be a table of valid map names."),
    candemote             = ass(optional(isbool), "The candemote value must be either true or false."),
    mayor                 = ass(optional(isbool), "The mayor value must be either true or false."),
    chief                 = ass(optional(isbool), "The chief value must be either true or false."),
    medic                 = ass(optional(isbool), "The medic value must be either true or false."),
    cook                  = ass(optional(isbool), "The cook value must be either true or false."),
    hobo                  = ass(optional(isbool), "The hobo value must be either true or false."),
    playerClass           = ass(optional(isstring), "The playerClass must be a valid string."),
    CanPlayerSuicide      = ass(optional(isfunction), "The CanPlayerSuicide must be a function."),
    PlayerCanPickupWeapon = ass(optional(isfunction), "The PlayerCanPickupWeapon must be a function."),
    PlayerDeath           = ass(optional(isfunction), "The PlayerDeath must be a function."),
    PlayerLoadout         = ass(optional(isfunction), "The PlayerLoadout must be a function."),
    PlayerSelectSpawn     = ass(optional(isfunction), "The PlayerSelectSpawn must be a function."),
    PlayerSetModel        = ass(optional(isfunction), "The PlayerSetModel must be a function."),
    PlayerSpawn           = ass(optional(isfunction), "The PlayerSpawn must be a function."),
    PlayerSpawnProp       = ass(optional(isfunction), "The PlayerSpawnProp must be a function."),
    RequiresVote          = ass(optional(isfunction), "The RequiresVote must be a function."),
    ShowSpare1            = ass(optional(isfunction), "The ShowSpare1 must be a function."),
    ShowSpare2            = ass(optional(isfunction), "The ShowSpare2 must be a function."),
    canStartVote          = ass(optional(isfunction), "The canStartVote must be a function."),
    canStartVoteReason    = ass(optional(isstring, isfunction), "The canStartVoteReason must be either a string or a function."),
}

-- Template for correct shipment
local validShipment = {
    model    = ass(checkModel, "The model of the shipment must be a valid model.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
    entity   = ass(isstring, "The entity of the shipment must be a string."),
    price    = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getPrice) end, "The price must be an existing number or (for advanced users) the getPrice field must be a function."),
    amount   = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}}, "The amount must be a number greater than zero."),
    separate = ass(optional(isbool), "the separate field must be either true or false."),
    pricesep = ass(function(v, tbl) return not tbl.separate or isnumber(v) and v >= 0 end, "The pricesep must be a number greater than or equal to zero."),
    allowed  = ass(optional(tableOf(isnumber), isnumber), "The allowed field must be either an existing team or a table of existing teams", {"Is there a job here that doesn't exist (anymore)?"}),

    category           = ass(optional(isstring), "The category must be the name of an existing category!"),
    sortOrder          = ass(optional(isnumber), "The sortOrder must be a number."),
    buttonColor        = ass(optional(tableOf(isnumber)), "The buttonColor must be a Color value."),
    label              = ass(optional(isstring), "The label must be a valid string."),
    noship             = ass(optional(isbool), "The noship must be either true or false."),
    shipmodel          = ass(optional(checkModel), "The shipmodel must be a valid model.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
    customCheck        = ass(optional(isfunction), "The customCheck must be a function."),
    CustomCheckFailMsg = ass(optional(isstring, isfunction), "The CustomCheckFailMsg must be either a string or a function."),
    weight             = ass(optional(isnumber), "The weight must be a number."),
    spareammo          = ass(optional(isnumber), "The spareammo must be a number."),
    clip1              = ass(optional(isnumber), "The clip1 must be a number."),
    clip2              = ass(optional(isnumber), "The clip2 must be a number."),
    shipmentClass      = ass(optional(isstring), "The shipmentClass must be a string."),
    onBought           = ass(optional(isfunction), "The onBought must be a function."),
    getPrice           = ass(optional(isfunction), "The getPrice must be a function."),
    spawn              = ass(optional(isfunction), "The spawn must be a function."),
}

-- Template for correct vehicle
local validVehicle = {
    name     = ass(isstring, "The name of the vehicle must be a string."),
    model    = ass(checkModel, "The model of the vehicle must be a valid model.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
    price    = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getPrice) end, "The price must be an existing number or (for advanced users) the getPrice field must be a function."),
    allowed  = ass(optional(tableOf(isnumber), isnumber), "The allowed field must be either an existing team or a table of existing teams", {"Is there a job here that doesn't exist (anymore)?"}),

    category           = ass(optional(isstring), "The category must be the name of an existing category!"),
    sortOrder          = ass(optional(isnumber), "The sortOrder must be a number."),
    distance           = ass(optional(isnumber), "The distance must be a number."),
    angle              = ass(optional(isangle), "The distance must be a valid Angle."),
    buttonColor        = ass(optional(tableOf(isnumber)), "The buttonColor must be a Color value."),
    label              = ass(optional(isstring), "The label must be a valid string."),
    customCheck        = ass(optional(isfunction), "The customCheck must be a function."),
    CustomCheckFailMsg = ass(optional(isstring, isfunction), "The CustomCheckFailMsg must be either a string or a function."),
    getPrice           = ass(optional(isfunction), "The getPrice must be a function."),
}

-- Template for correct entity
local validEntity = {
    ent   = ass(isstring, "The name of the entity must be a string."),
    model = ass(checkModel, "The model of the entity must be a valid model.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
    price = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getPrice) end, "The price must be an existing number or (for advanced users) the getPrice field must be a function."),
    max   = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getMax) end, "The max must be an existing number or (for advanced users) the getMax field must be a function."),
    cmd   = ass(fn.FAnd{isstring, uniqueEntity}, "The cmd must be a valid string."),
    name  = ass(isstring, "The name must be a valid string."),

    category           = ass(optional(isstring), "The category must be the name of an existing category!"),
    sortOrder          = ass(optional(isnumber), "The sortOrder must be a number."),
    buttonColor        = ass(optional(tableOf(isnumber)), "The buttonColor must be a Color value."),
    label              = ass(optional(isstring), "The label must be a valid string."),
    customCheck        = ass(optional(isfunction), "The customCheck must be a function."),
    CustomCheckFailMsg = ass(optional(isstring, isfunction), "The CustomCheckFailMsg must be either a string or a function."),
    getPrice           = ass(optional(isfunction), "The getPrice must be a function."),
    spawn              = ass(optional(isfunction), "The spawn must be a function."),
}

local validAgenda = {
    Title = ass(isstring, "The title must be a string."),
    Manager = ass(fn.FOr{isnumber, nonempty(tableOf(isnumber))}, "The Manager must either be a single team or a non-empty table of existing teams.", {"Is there a job here that doesn't exist (anymore)?"}),
    Listeners = ass(nonempty(tableOf(isnumber)), "The Listeners must be a non-empty table of existing teams.",
        {
            "Is there a job here that doesn't exist (anymore)?",
            "Are you trying to have multiple manager jobs in this agenda? In that case you must put the list of manager jobs in curly braces.",
            [[Like so: DarkRP.createAgenda("Some agenda", {TEAM_MANAGER1, TEAM_MANAGER2}, {TEAM_LISTENER1, TEAM_LISTENER2})]]
        })
}

local validCategory = {
    name                      = ass(isstring, "The name must be a string."),
    categorises               = ass(oneOf{"jobs", "entities", "shipments", "weapons", "vehicles", "ammo"},
        [[The categorises must be one of "jobs", "entities", "shipments", "weapons", "vehicles", "ammo"]],
        {"Mind that this is case sensitive.", "Also mind the quotation marks."}),
    startExpanded             = ass(isbool, "The startExpanded must be either true or false."),
    color                     = ass(tableOf(isnumber), "The color must be a Color value."),
    canSee                    = ass(optional(isfunction), "The canSee must be a function."),
    sortOrder                 = ass(optional(isnumber), "The sortOrder must be a number."),
}

-- Check template against actual implementation
local env = {} -- environment used to be check propositions between multiple tables
local function checkValid(tbl, requiredItems, oEnv) -- Allow override environment
    for k,v in pairs(requiredItems) do
        local correct, err, hints = tbl[v] ~= nil
        if isfunction(v) then correct, err, hints = v(tbl[k], tbl, oEnv or env) end
        err = err or string.format("Element '%s' is corrupt!", k)
        if not correct then return correct, err, hints end
    end

    return true
end

-----------------------------------------------------------
-- Job commands --
-----------------------------------------------------------
local function declareTeamCommands(CTeam)
    local k = 0
    for num,v in pairs(RPExtraTeams) do
        if v.command == CTeam.command then
            k = num
        end
    end

    if CTeam.vote or CTeam.RequiresVote then
        DarkRP.declareChatCommand{
            command = "vote" .. CTeam.command,
            description = "Vote to become " .. CTeam.name .. ".",
            delay = 1.5,
            condition = fn.FAnd
            {
                fn.If(
                    fn.Curry(isfunction, 2)(CTeam.RequiresVote),
                    fn.Curry(fn.Flip(fn.FOr{fn.Curry(fn.Const, 2)(CTeam.RequiresVote), fn.Curry(fn.Const, 2)(-1)}()), 2)(k),
                    fn.Curry(fn.Const, 2)(true)
                )(),
                fn.If(
                    fn.Curry(isnumber, 2)(CTeam.NeedToChangeFrom),
                    fn.Compose{fn.Curry(fn.Eq, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
                    fn.If(
                        fn.Curry(istable, 2)(CTeam.NeedToChangeFrom),
                        fn.Compose{fn.Curry(table.HasValue, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
                        fn.Curry(fn.Const, 2)(true)
                    )()
                )(),
                fn.If(
                    fn.Curry(isfunction, 2)(CTeam.customCheck),
                    CTeam.customCheck,
                    fn.Curry(fn.Const, 2)(true)
                )(),
                fn.Compose{fn.Curry(fn.Neq, 2)(k), plyMeta.Team},
                fn.FOr {
                    fn.Curry(fn.Lte, 3)(CTeam.admin)(0),
                    fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(1), plyMeta.IsAdmin},
                    fn.FAnd{fn.Curry(fn.Gte, 3)(CTeam.admin)(2), plyMeta.IsSuperAdmin}
                }
            }
        }

        DarkRP.declareChatCommand{
            command = CTeam.command,
            description = "Become " .. CTeam.name .. " and skip the vote.",
            delay = 1.5,
            condition = fn.FAnd {
                fn.FOr {
                    fn.FAnd {
                        fn.FOr {
                            fn.Curry(fn.Lte, 3)(CTeam.admin)(0),
                            fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(1), plyMeta.IsAdmin},
                            fn.FAnd{fn.Curry(fn.Gte, 3)(CTeam.admin)(2), plyMeta.IsSuperAdmin}
                        },
                        fn.If(
                            fn.Curry(isfunction, 2)(CTeam.RequiresVote),
                            fn.Curry(fn.Flip(fn.FOr{fn.Curry(fn.Const, 2)(CTeam.RequiresVote), fn.Curry(fn.Const, 2)(-1)}()), 2)(k),
                            fn.FOr {
                                fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(0), plyMeta.IsAdmin},
                                fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(1), plyMeta.IsSuperAdmin}
                            }
                        )()
                    }
                },
                fn.Compose{fn.Not, plyMeta.isArrested},
                fn.If(
                    fn.Curry(isnumber, 2)(CTeam.NeedToChangeFrom),
                    fn.Compose{fn.Curry(fn.Eq, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
                    fn.If(
                        fn.Curry(istable, 2)(CTeam.NeedToChangeFrom),
                        fn.Compose{fn.Curry(table.HasValue, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
                        fn.Curry(fn.Const, 2)(true)
                    )()
                )(),
                fn.If(
                    fn.Curry(isfunction, 2)(CTeam.customCheck),
                    CTeam.customCheck,
                    fn.Curry(fn.Const, 2)(true)
                )(),
                fn.Compose{fn.Curry(fn.Neq, 2)(k), plyMeta.Team}
            }
        }
    else
        DarkRP.declareChatCommand{
            command = CTeam.command,
            description = "Become " .. CTeam.name .. ".",
            delay = 1.5,
            condition = fn.FAnd
            {
                fn.Compose{fn.Not, plyMeta.isArrested},
                fn.If(
                    fn.Curry(isnumber, 2)(CTeam.NeedToChangeFrom),
                    fn.Compose{fn.Curry(fn.Eq, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
                    fn.If(
                        fn.Curry(istable, 2)(CTeam.NeedToChangeFrom),
                        fn.Compose{fn.Curry(table.HasValue, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
                        fn.Curry(fn.Const, 2)(true)
                    )()
                )(),
                fn.If(
                    fn.Curry(isfunction, 2)(CTeam.customCheck),
                    CTeam.customCheck,
                    fn.Curry(fn.Const, 2)(true)
                )(),
                fn.Compose{fn.Curry(fn.Neq, 2)(k), plyMeta.Team},
                fn.FOr {
                    fn.Curry(fn.Lte, 3)(CTeam.admin)(0),
                    fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(1), plyMeta.IsAdmin},
                    fn.FAnd{fn.Curry(fn.Gte, 3)(CTeam.admin)(2), plyMeta.IsSuperAdmin}
                }
            }
        }
    end
end

local function addTeamCommands(CTeam, max)
    if CLIENT then return end

    if not GAMEMODE:CustomObjFitsMap(CTeam) then return end
    local k = 0
    for num,v in pairs(RPExtraTeams) do
        if v.command == CTeam.command then
            k = num
        end
    end

    if CTeam.vote or CTeam.RequiresVote then
        DarkRP.defineChatCommand("vote" .. CTeam.command, function(ply)
            if CTeam.RequiresVote and not CTeam.RequiresVote(ply, k) then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("job_doesnt_require_vote_currently"))

                return ""
            end

            if CTeam.canStartVote and not CTeam.canStartVote(ply) then
                local reason = isfunction(CTeam.canStartVoteReason) and CTeam.canStartVoteReason(ply, CTeam) or CTeam.canStartVoteReason or ""
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/vote" .. CTeam.command, reason))

                return ""
            end

            if CTeam.admin == 1 and not ply:IsAdmin() then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/" .. "vote" .. CTeam.command))

                return ""
            elseif CTeam.admin > 1 and not ply:IsSuperAdmin() then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_sadmin", "/" .. "vote" .. CTeam.command))

                return ""
            end

            if type(CTeam.NeedToChangeFrom) == "number" and ply:Team() ~= CTeam.NeedToChangeFrom then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_to_be_before", team.GetName(CTeam.NeedToChangeFrom), CTeam.name))

                return ""
            elseif type(CTeam.NeedToChangeFrom) == "table" and not table.HasValue(CTeam.NeedToChangeFrom, ply:Team()) then
                local teamnames = ""

                for a, b in pairs(CTeam.NeedToChangeFrom) do
                    teamnames = teamnames .. " or " .. team.GetName(b)
                end

                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_to_be_before", string.sub(teamnames, 5), CTeam.name))

                return ""
            end

            if CTeam.customCheck and not CTeam.customCheck(ply) then
                local message = isfunction(CTeam.CustomCheckFailMsg) and CTeam.CustomCheckFailMsg(ply, CTeam) or CTeam.CustomCheckFailMsg or DarkRP.getPhrase("unable", team.GetName(t), "")
                DarkRP.notify(ply, 1, 4, message)

                return ""
            end

            if not ply:changeAllowed(k) then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/vote" .. CTeam.command, DarkRP.getPhrase("banned_or_demoted")))

                return ""
            end

            if ply:Team() == k then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", CTeam.command, ""))

                return ""
            end

            if max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / #player.GetAll() > max)) then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("team_limit_reached", CTeam.name))

                return ""
            end

            if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(10 - (CurTime() - ply.LastJob)), GAMEMODE.Config.chatCommandPrefix .. CTeam.command))

                return ""
            end

            ply.LastVoteCop = ply.LastVoteCop or -80

            if CurTime() - ply.LastVoteCop < 80 then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), GAMEMODE.Config.chatCommandPrefix .. CTeam.command))

                return ""
            end

            DarkRP.createVote(DarkRP.getPhrase("wants_to_be", ply:Nick(), CTeam.name), "job", ply, 20, function(vote, choice)
                local target = vote.target
                if not IsValid(target) then return end

                if choice >= 0 then
                    target:changeTeam(k)
                else
                    DarkRP.notifyAll(1, 4, DarkRP.getPhrase("has_not_been_made_team", target:Nick(), CTeam.name))
                end
            end, nil, nil, {
                targetTeam = k
            })

            ply.LastVoteCop = CurTime()

            return ""
        end)

        local function onJobCommand(ply, hasPriv)
            if hasPriv then
                ply:changeTeam(k)
                return
            end

            local a = CTeam.admin
            if a > 0 and not ply:IsAdmin()
            or a > 1 and not ply:IsSuperAdmin()
            then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", CTeam.name))
                return
            end

            if not CTeam.RequiresVote and
                (a == 0 and not ply:IsAdmin()
                or a == 1 and not ply:IsSuperAdmin()
                or a == 2)
            or CTeam.RequiresVote and CTeam.RequiresVote(ply, k)
            then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_to_make_vote", CTeam.name))
                return
            end

            ply:changeTeam(k)
        end
        DarkRP.defineChatCommand(CTeam.command, function(ply)
            CAMI.PlayerHasAccess(ply, "DarkRP_GetJob_" .. CTeam.command, fp{onJobCommand, ply})

            return ""
        end)
    else
        DarkRP.defineChatCommand(CTeam.command, function(ply)
            if CTeam.admin == 1 and not ply:IsAdmin() then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/" .. CTeam.command))

                return ""
            end

            if CTeam.admin > 1 and not ply:IsSuperAdmin() then
                DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_sadmin", "/" .. CTeam.command))

                return ""
            end

            ply:changeTeam(k)

            return ""
        end)
    end

    concommand.Add("rp_" .. CTeam.command, function(ply, cmd, args)
        if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_admin", cmd))
            return
        end

        if CTeam.admin > 1 and not ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
            ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_sadmin", cmd))
            return
        end

        if CTeam.vote then
            if CTeam.admin >= 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
                ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_sadmin", cmd))
                return
            elseif CTeam.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
                ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_to_make_vote", CTeam.name))
                return
            end
        end

        if not args or not args[1] then
            DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
            return
        end

        local target = DarkRP.findPlayer(args[1])

        if (target) then
            target:changeTeam(k, true)
            local nick
            if (ply:EntIndex() ~= 0) then
                nick = ply:Nick()
            else
                nick = "Console"
            end
            DarkRP.notify(target, 0, 4, DarkRP.getPhrase("x_made_you_a_y", nick, CTeam.name))
        else
            DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("could_not_find", tostring(args[1])))
        end
    end)
end

local function addEntityCommands(tblEnt)
    DarkRP.declareChatCommand{
        command = tblEnt.cmd,
        description = "Purchase a " .. tblEnt.name,
        delay = 2,
        condition = fn.FAnd
        {
            fn.Compose{fn.Not, plyMeta.isArrested},
            fn.If(
                fn.Curry(istable, 2)(tblEnt.allowed),
                fn.Compose{fn.Curry(table.HasValue, 2)(tblEnt.allowed), plyMeta.Team},
                fn.Curry(fn.Const, 2)(true)
            )(),
            fn.If(
                fn.Curry(isfunction, 2)(tblEnt.customCheck),
                tblEnt.customCheck,
                fn.Curry(fn.Const, 2)(true)
            )(),
            fn.Curry(fn.Flip(plyMeta.canAfford), 2)(tblEnt.price)
        }
    }
    if CLIENT then return end

    -- Default spawning function of an entity
    -- used if tblEnt.spawn is not defined
    local function defaultSpawn(ply, tr, tblE)
        local ent = ents.Create(tblE.ent)
        if not ent:IsValid() then error("Entity '" .. tblE.ent .. "' does not exist or is not valid.") end
        ent.dt = ent.dt or {}
        ent.dt.owning_ent = ply
        if ent.Setowning_ent then ent:Setowning_ent(ply) end
        ent:SetPos(tr.HitPos)
        -- These must be set before :Spawn()
        ent.SID = ply.SID
        ent.allowed = tblE.allowed
        ent.DarkRPItem = tblE
        ent:Spawn()

        local phys = ent:GetPhysicsObject()
        if phys:IsValid() then phys:Wake() end

        return ent
    end

    local function buythis(ply, args)
        if ply:isArrested() then return "" end
        if type(tblEnt.allowed) == "table" and not table.HasValue(tblEnt.allowed, ply:Team()) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", tblEnt.cmd))
            return ""
        end

        if tblEnt.customCheck and not tblEnt.customCheck(ply) then
            local message = isfunction(tblEnt.CustomCheckFailMsg) and tblEnt.CustomCheckFailMsg(ply, tblEnt) or
                tblEnt.CustomCheckFailMsg or
                DarkRP.getPhrase("not_allowed_to_purchase")
            DarkRP.notify(ply, 1, 4, message)
            return ""
        end

        if ply:customEntityLimitReached(tblEnt) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", tblEnt.cmd))
            return ""
        end

        local canbuy, suppress, message, price = hook.Call("canBuyCustomEntity", nil, ply, tblEnt)

        local cost = price or tblEnt.getPrice and tblEnt.getPrice(ply, tblEnt.price) or tblEnt.price

        if not ply:canAfford(cost) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", tblEnt.cmd))
            return ""
        end

        if canbuy == false then
            if not suppress and message then DarkRP.notify(ply, 1, 4, message) end
            return ""
        end

        ply:addMoney(-cost)

        local trace = {}
        trace.start = ply:EyePos()
        trace.endpos = trace.start + ply:GetAimVector() * 85
        trace.filter = ply

        local tr = util.TraceLine(trace)

        local ent = (tblEnt.spawn or defaultSpawn)(ply, tr, tblEnt)
        ent.onlyremover = true
        -- Repeat these properties to alleviate work in tblEnt.spawn:
        ent.SID = ply.SID
        ent.allowed = tblEnt.allowed
        ent.DarkRPItem = tblEnt

        hook.Call("playerBoughtCustomEntity", nil, ply, tblEnt, ent, cost)

        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", tblEnt.name, DarkRP.formatMoney(cost), ""))

        ply:addCustomEntity(tblEnt)
        return ""
    end
    DarkRP.defineChatCommand(tblEnt.cmd, buythis)
end

RPExtraTeams = {}
local jobByCmd = {}
DarkRP.getJobByCommand = function(cmd)
    if not jobByCmd[cmd] then return nil, nil end
    return RPExtraTeams[jobByCmd[cmd]], jobByCmd[cmd]
end
plyMeta.getJobTable = fn.FOr{fn.Compose{fn.Curry(fn.Flip(fn.GetValue), 2)(RPExtraTeams), plyMeta.Team}, fn.Curry(fn.Id, 2)({})}
local jobCount = 0
function DarkRP.createJob(Name, colorOrTable, model, Description, Weapons, command, maximum_amount_of_this_class, Salary, admin, Vote, Haslicense, NeedToChangeFrom, CustomCheck)
    local tableSyntaxUsed = not IsColor(colorOrTable)

    local CustomTeam = tableSyntaxUsed and colorOrTable or
        {color = colorOrTable, model = model, description = Description, weapons = Weapons, command = command,
            max = maximum_amount_of_this_class, salary = Salary, admin = admin or 0, vote = tobool(Vote), hasLicense = Haslicense,
            NeedToChangeFrom = NeedToChangeFrom, customCheck = CustomCheck
        }
    CustomTeam.name = Name
    CustomTeam.default = DarkRP.DARKRP_LOADING

    -- Disabled job
    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["jobs"][CustomTeam.command] then return end

    local valid, err, hints = checkValid(CustomTeam, requiredTeamItems)
    if not valid then DarkRP.error(string.format("Corrupt team: %s!\n%s", CustomTeam.name or "", err), 3, hints) end

    jobCount = jobCount + 1
    CustomTeam.team = jobCount

    CustomTeam.salary = math.floor(CustomTeam.salary)

    CustomTeam.customCheck           = CustomTeam.customCheck           and fp{DarkRP.simplerrRun, CustomTeam.customCheck}
    CustomTeam.CustomCheckFailMsg = isfunction(CustomTeam.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, CustomTeam.CustomCheckFailMsg} or CustomTeam.CustomCheckFailMsg
    CustomTeam.CanPlayerSuicide      = CustomTeam.CanPlayerSuicide      and fp{DarkRP.simplerrRun, CustomTeam.CanPlayerSuicide}
    CustomTeam.PlayerCanPickupWeapon = CustomTeam.PlayerCanPickupWeapon and fp{DarkRP.simplerrRun, CustomTeam.PlayerCanPickupWeapon}
    CustomTeam.PlayerDeath           = CustomTeam.PlayerDeath           and fp{DarkRP.simplerrRun, CustomTeam.PlayerDeath}
    CustomTeam.PlayerLoadout         = CustomTeam.PlayerLoadout         and fp{DarkRP.simplerrRun, CustomTeam.PlayerLoadout}
    CustomTeam.PlayerSelectSpawn     = CustomTeam.PlayerSelectSpawn     and fp{DarkRP.simplerrRun, CustomTeam.PlayerSelectSpawn}
    CustomTeam.PlayerSetModel        = CustomTeam.PlayerSetModel        and fp{DarkRP.simplerrRun, CustomTeam.PlayerSetModel}
    CustomTeam.PlayerSpawn           = CustomTeam.PlayerSpawn           and fp{DarkRP.simplerrRun, CustomTeam.PlayerSpawn}
    CustomTeam.PlayerSpawnProp       = CustomTeam.PlayerSpawnProp       and fp{DarkRP.simplerrRun, CustomTeam.PlayerSpawnProp}
    CustomTeam.RequiresVote          = CustomTeam.RequiresVote          and fp{DarkRP.simplerrRun, CustomTeam.RequiresVote}
    CustomTeam.ShowSpare1            = CustomTeam.ShowSpare1            and fp{DarkRP.simplerrRun, CustomTeam.ShowSpare1}
    CustomTeam.ShowSpare2            = CustomTeam.ShowSpare2            and fp{DarkRP.simplerrRun, CustomTeam.ShowSpare2}
    CustomTeam.canStartVote          = CustomTeam.canStartVote          and fp{DarkRP.simplerrRun, CustomTeam.canStartVote}

    jobByCmd[CustomTeam.command] = table.insert(RPExtraTeams, CustomTeam)
    DarkRP.addToCategory(CustomTeam, "jobs", CustomTeam.category)
    team.SetUp(#RPExtraTeams, Name, CustomTeam.color)
    local Team = #RPExtraTeams

    timer.Simple(0, function()
        declareTeamCommands(CustomTeam)
        addTeamCommands(CustomTeam, CustomTeam.max)
    end)

    -- Precache model here. Not right before the job change is done
    if type(CustomTeam.model) == "table" then
        for k,v in pairs(CustomTeam.model) do util.PrecacheModel(v) end
    else
        util.PrecacheModel(CustomTeam.model)
    end
    return Team
end
AddExtraTeam = DarkRP.createJob

local function removeCustomItem(tbl, category, hookName, reloadF4, i)
    local item = tbl[i]
    tbl[i] = nil
    if category then DarkRP.removeFromCategory(item, category) end
    if istable(item) and (item.command or item.cmd) then DarkRP.removeChatCommand(item.command or item.cmd) end
    hook.Run(hookName, i, item)
    if CLIENT and reloadF4 and IsValid(DarkRP.getF4MenuPanel()) then DarkRP.getF4MenuPanel():Remove() end -- Rebuild entire F4 menu frame
end

function DarkRP.removeJob(i)
    local job = RPExtraTeams[i]
    jobByCmd[job.command] = nil
    jobCount = jobCount - 1

    DarkRP.removeChatCommand("vote" .. job.command)
    removeCustomItem(RPExtraTeams, "jobs", "onJobRemoved", true, i)
end

RPExtraTeamDoors = {}
function DarkRP.createEntityGroup(name, ...)
    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["doorgroups"][name] then return end
    RPExtraTeamDoors[name] = {...}
    RPExtraTeamDoors[name].name = name
end
AddDoorGroup = DarkRP.createEntityGroup

DarkRP.removeEntityGroup = fp{removeCustomItem, RPExtraTeamDoors, nil, "onEntityGroupRemoved", false}

CustomVehicles = {}
CustomShipments = {}
local shipByName = {}
DarkRP.getShipmentByName = function(name)
    name = string.lower(name or "")

    if not shipByName[name] then return nil, nil end
    return CustomShipments[shipByName[name]], shipByName[name]
end

function DarkRP.createShipment(name, model, entity, price, Amount_of_guns_in_one_shipment, Sold_separately, price_separately, noshipment, classes, shipmodel, CustomCheck)
    local tableSyntaxUsed = type(model) == "table"

    price = tonumber(price)
    local shipmentmodel = shipmodel or "models/Items/item_item_crate.mdl"

    local customShipment = tableSyntaxUsed and model or
        {model = model, entity = entity, price = price, amount = Amount_of_guns_in_one_shipment,
        seperate = Sold_separately, pricesep = price_separately, noship = noshipment, allowed = classes,
        shipmodel = shipmentmodel, customCheck = CustomCheck, weight = 5}

    -- The pains of backwards compatibility when dealing with ancient spelling errors...
    if customShipment.separate ~= nil then
        customShipment.seperate = customShipment.separate
    end
    customShipment.separate = customShipment.seperate

    if customShipment.allowed == nil then
        customShipment.allowed = {}
        for k,v in pairs(team.GetAllTeams()) do
            table.insert(customShipment.allowed, k)
        end
    end

    customShipment.name = name
    customShipment.default = DarkRP.DARKRP_LOADING
    customShipment.shipmodel = customShipment.shipmodel or shipmentmodel

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["shipments"][customShipment.name] then return end

    local valid, err, hints = checkValid(customShipment, validShipment)
    if not valid then DarkRP.error(string.format("Corrupt shipment: %s!\n%s", name or "", err), 3, hints) end

    customShipment.spawn = customShipment.spawn and fp{DarkRP.simplerrRun, customShipment.spawn}
    customShipment.allowed = isnumber(customShipment.allowed) and {customShipment.allowed} or customShipment.allowed
    customShipment.customCheck = customShipment.customCheck   and fp{DarkRP.simplerrRun, customShipment.customCheck}
    customShipment.CustomCheckFailMsg = isfunction(customShipment.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, customShipment.CustomCheckFailMsg} or customShipment.CustomCheckFailMsg

    if not customShipment.noship then DarkRP.addToCategory(customShipment, "shipments", customShipment.category) end
    if customShipment.separate then DarkRP.addToCategory(customShipment, "weapons", customShipment.category) end

    shipByName[string.lower(name or "")] = table.insert(CustomShipments, customShipment)
    util.PrecacheModel(customShipment.model)
end
AddCustomShipment = DarkRP.createShipment

function DarkRP.removeShipment(i)
    local ship = CustomShipments[i]
    shipByName[ship.name] = nil
    removeCustomItem(CustomShipments, "shipments", "onShipmentRemoved", true, i)
end

function DarkRP.createVehicle(Name_of_vehicle, model, price, Jobs_that_can_buy_it, customcheck)
    local vehicle = istable(Name_of_vehicle) and Name_of_vehicle or
        {name = Name_of_vehicle, model = model, price = price, allowed = Jobs_that_can_buy_it, customCheck = customcheck}

    vehicle.default = DarkRP.DARKRP_LOADING

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["vehicles"][vehicle.name] then return end

    local found = false
    for k,v in pairs(DarkRP.getAvailableVehicles()) do
        if string.lower(k) == string.lower(vehicle.name) then found = true break end
    end

    local valid, err, hints = checkValid(vehicle, validVehicle)
    if not valid then DarkRP.error(string.format("Corrupt vehicle: %s!\n%s", vehicle.name or "", err), 3, hints) end

    if not found then DarkRP.error("Vehicle invalid: " .. vehicle.name .. ". Unknown vehicle name.", 3) end

    vehicle.customCheck = vehicle.customCheck and fp{DarkRP.simplerrRun, vehicle.customCheck}
    vehicle.CustomCheckFailMsg = isfunction(vehicle.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, vehicle.CustomCheckFailMsg} or vehicle.CustomCheckFailMsg

    table.insert(CustomVehicles, vehicle)
    DarkRP.addToCategory(vehicle, "vehicles", vehicle.category)
end
AddCustomVehicle = DarkRP.createVehicle

DarkRP.removeVehicle = fp{removeCustomItem, CustomVehicles, "vehicles", "onVehicleRemoved", true}

/*---------------------------------------------------------------------------
Decides whether a custom job or shipmet or whatever can be used in a certain map
---------------------------------------------------------------------------*/
function GM:CustomObjFitsMap(obj)
    if not obj or not obj.maps then return true end

    local map = string.lower(game.GetMap())
    for k,v in pairs(obj.maps) do
        if string.lower(v) == map then return true end
    end
    return false
end

DarkRPEntities = {}
function DarkRP.createEntity(name, entity, model, price, max, command, classes, CustomCheck)
    local tableSyntaxUsed = type(entity) == "table"

    local tblEnt = tableSyntaxUsed and entity or
        {ent = entity, model = model, price = price, max = max,
        cmd = command, allowed = classes, customCheck = CustomCheck}
    tblEnt.name = name
    tblEnt.default = DarkRP.DARKRP_LOADING

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["entities"][tblEnt.name] then return end

    if type(tblEnt.allowed) == "number" then
        tblEnt.allowed = {tblEnt.allowed}
    end

    local valid, err, hints = checkValid(tblEnt, validEntity)
    if not valid then DarkRP.error(string.format("Corrupt entity: %s!\n%s", name or "", err), 3, hints) end

    tblEnt.customCheck = tblEnt.customCheck and fp{DarkRP.simplerrRun, tblEnt.customCheck}
    tblEnt.CustomCheckFailMsg = isfunction(tblEnt.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, tblEnt.CustomCheckFailMsg} or tblEnt.CustomCheckFailMsg
    tblEnt.getPrice    = tblEnt.getPrice    and fp{DarkRP.simplerrRun, tblEnt.getPrice}
    tblEnt.getMax      = tblEnt.getMax      and fp{DarkRP.simplerrRun, tblEnt.getMax}
    tblEnt.spawn       = tblEnt.spawn       and fp{DarkRP.simplerrRun, tblEnt.spawn}

    -- if SERVER and FPP then
    --  FPP.AddDefaultBlocked(blockTypes, tblEnt.ent)
    -- end

    table.insert(DarkRPEntities, tblEnt)
    DarkRP.addToCategory(tblEnt, "entities", tblEnt.category)
    timer.Simple(0, function() addEntityCommands(tblEnt) end)
end
AddEntity = DarkRP.createEntity

DarkRP.removeEntity = fp{removeCustomItem, DarkRPEntities, "entities", "onEntityRemoved", true}

-- here for backwards compatibility
DarkRPAgendas = {}

local agendas = {}
-- Returns the agenda managed by the player
plyMeta.getAgenda = fn.Compose{fn.Curry(fn.Flip(fn.GetValue), 2)(DarkRPAgendas), plyMeta.Team}

-- Returns the agenda this player is member of
function plyMeta:getAgendaTable()
    return agendas[self:Team()]
end

DarkRP.getAgendas = fp{fn.Id, agendas}

function DarkRP.createAgenda(Title, Manager, Listeners)
    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["agendas"][Title] then return end

    local agenda = {Manager = Manager, Title = Title, Listeners = Listeners, ManagersByKey = {}}
    agenda.default = DarkRP.DARKRP_LOADING

    local valid, err, hints = checkValid(agenda, validAgenda)
    if not valid then DarkRP.error(string.format("Corrupt agenda: %s!\n%s", agenda.Title or "", err), 2, hints) end

    for k,v in pairs(Listeners) do
        agendas[v] = agenda
    end

    for k,v in pairs(istable(Manager) and Manager or {Manager}) do
        agendas[v] = agenda
        DarkRPAgendas[v] = agenda -- backwards compat
        agenda.ManagersByKey[v] = true
    end

    if SERVER then
        timer.Simple(0, function()
            -- Run after scripts have loaded
            agenda.text = hook.Run("agendaUpdated", nil, agenda, "")
        end)
    end
end
AddAgenda = DarkRP.createAgenda

function DarkRP.removeAgenda(title)
    local agenda
    for k,v in pairs(agendas) do
        if v.Title == title then
            agenda = v
            agendas[k] = nil
        end
    end

    for k,v in pairs(DarkRPAgendas) do
        if v.Title == title then agendas[k] = nil end
    end
    hook.Run("onAgendaRemoved", title, agenda)
end

GM.DarkRPGroupChats = {}
local groupChatNumber = 0
function DarkRP.createGroupChat(funcOrTeam, ...)
    local gm = GM or GAMEMODE
    gm.DarkRPGroupChats = gm.DarkRPGroupChats or {}
    if DarkRP.DARKRP_LOADING then
        groupChatNumber = groupChatNumber + 1
        if DarkRP.disabledDefaults["groupchat"][groupChatNumber] then return end
    end
    -- People can enter either functions or a list of teams as parameter(s)
    if type(funcOrTeam) == "function" then
        table.insert(gm.DarkRPGroupChats, fp{DarkRP.simplerrRun, funcOrTeam})
    else
        local teams = {funcOrTeam, ...}
        table.insert(gm.DarkRPGroupChats, function(ply) return table.HasValue(teams, ply:Team()) end)
    end
end
GM.AddGroupChat = function(_, ...) DarkRP.createGroupChat(...) end

DarkRP.removeGroupChat = fp{removeCustomItem, GM.DarkRPGroupChats, nil, "onGroupChatRemoved", false}

DarkRP.getGroupChats = fp{fn.Id, GM.DarkRPGroupChats}

GM.AmmoTypes = {}

function DarkRP.createAmmoType(ammoType, name, model, price, amountGiven, customCheck)
    local gm = GM or GAMEMODE
    gm.AmmoTypes = gm.AmmoTypes or {}
    local ammo = istable(name) and name or {
        name = name,
        model = model,
        price = price,
        amountGiven = amountGiven,
        customCheck = customCheck
    }
    ammo.ammoType = ammoType
    ammo.default = DarkRP.DARKRP_LOADING

    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["ammo"][ammo.name] then return end

    ammo.customCheck = ammo.customCheck and fp{DarkRP.simplerrRun, ammo.customCheck}
    ammo.CustomCheckFailMsg = isfunction(ammo.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, ammo.CustomCheckFailMsg} or ammo.CustomCheckFailMsg
    ammo.id = table.insert(gm.AmmoTypes, ammo)

    DarkRP.addToCategory(ammo, "ammo", ammo.category)
end
GM.AddAmmoType = function(_, ...) DarkRP.createAmmoType(...) end

DarkRP.removeAmmoType = fp{removeCustomItem, GM.AmmoTypes, "ammo", "onAmmoTypeRemoved", true}

local demoteGroups = {}
function DarkRP.createDemoteGroup(name, tbl)
    if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["demotegroups"][name] then return end
    if not tbl or not tbl[1] then error("No members in the demote group!") end

    local set = demoteGroups[tbl[1]] or disjoint.MakeSet(tbl[1])
    set.name = name
    for i = 2, #tbl do
        set = (demoteGroups[tbl[i]] or disjoint.MakeSet(tbl[i])) + set
        set.name = name
    end

    for _, teamNr in pairs(tbl) do
        if demoteGroups[teamNr] then
            -- Unify the sets if there was already one there
            demoteGroups[teamNr] = demoteGroups[teamNr] + set
        else
            demoteGroups[teamNr] = set
        end
    end
end

function DarkRP.removeDemoteGroup(name)
    local foundSet
    for k,v in pairs(demoteGroups) do
        local set = disjoint.FindSet(v)
        if set.name == name then
            foundSet = set
            demoteGroups[k] = nil
        end
    end
    hook.Run("onDemoteGroupRemoved", name, foundSet)
end

function DarkRP.getDemoteGroup(teamNr)
    demoteGroups[teamNr] = demoteGroups[teamNr] or disjoint.MakeSet(teamNr)
    return disjoint.FindSet(demoteGroups[teamNr])
end

DarkRP.getDemoteGroups = fp{fn.Id, demoteGroups}

local categories = {
    jobs = {},
    entities = {},
    shipments = {},
    weapons = {},
    vehicles = {},
    ammo = {},
}
local categoriesMerged = false -- whether categories and custom items are merged.

DarkRP.getCategories = fp{fn.Id, categories}

local categoryOrder = function(a, b)
    local aso = a.sortOrder or 100
    local bso = b.sortOrder or 100
    return aso < bso or aso == bso and a.name < b.name
end

local function insertCategory(destination, tbl)
    -- Override existing category of applicable
    for k, cat in pairs(destination) do
        if cat.name ~= tbl.name then continue end

        destination[k] = tbl
        tbl.members = cat.members
        return
    end

    table.insert(destination, tbl)
    local i = #destination

    while i > 1 do
        if categoryOrder(destination[i - 1], tbl) then break end
        destination[i - 1], destination[i] = destination[i], destination[i - 1]
        i = i - 1
    end
end

function DarkRP.createCategory(tbl)
    local valid, err, hints = checkValid(tbl, validCategory)
    if not valid then DarkRP.error(string.format("Corrupt category: %s!\n%s", tbl.name or "", err), 2, hints) end
    tbl.members = {}

    local destination = categories[tbl.categorises]
    insertCategory(destination, tbl)

    -- Too many people made the mistake of not creating a category for weapons as well as shipments
    -- when having shipments that can also be sold separately.
    if tbl.categorises == "shipments" then
        insertCategory(categories.weapons, table.Copy(tbl))
    end
end

function DarkRP.addToCategory(item, kind, cat)
    cat = cat or "Other"
    item.category = cat

    -- The merge process will take care of the category:
    if not categoriesMerged then return end

    -- Post-merge: manual insertion into category
    local cats = categories[kind]
    for _, c in ipairs(cats) do
        if c.name ~= cat then continue end

        insertCategory(c.members, item)
        return
    end

    DarkRP.errorNoHalt(string.format([[The category of "%s" ("%s") does not exist!]], item.name, cat), 2, {
        "Make sure the category is created with DarkRP.createCategory.",
        "The category name is case sensitive!",
        "Categories must be created before DarkRP finished loading.",
    })
end

function DarkRP.removeFromCategory(item, kind)
    local cats = categories[kind]
    if not cats then DarkRP.error(string.format("Invalid category kind '%s'.", kind), 2) end
    local cat = item.category
    if not cat then return end
    for _, v in pairs(cats) do
        if v.name ~= item.category then continue end
        for k, mem in pairs(v.members) do
            if mem ~= item then continue end
            table.remove(v.members, k)
            break
        end
        break
    end
end

-- Assign custom stuff to their categories
local function mergeCategories(customs, catKind, path)
    local cats = categories[catKind]
    local catByName = {}
    for k,v in pairs(cats) do catByName[v.name] = v end
    for k,v in pairs(customs) do
        -- Override default thing categories:
        local catName = v.default and GAMEMODE.Config.CategoryOverride[catKind][v.name] or v.category or "Other"
        local cat = catByName[catName]
        if not cat then
            DarkRP.errorNoHalt(string.format([[The category of "%s" ("%s") does not exist!]], v.name, catName), 1, {
                "Make sure the category is created with DarkRP.createCategory.",
                "The category name is case sensitive!",
                "Categories must be created before DarkRP finished loading."
            }, path, -1, path)
            cat = catByName.Other
        end

        cat.members = cat.members or {}
        table.insert(cat.members, v)
    end

    -- Sort category members
    for k,v in pairs(cats) do table.sort(v.members, categoryOrder) end
end

hook.Add("loadCustomDarkRPItems", "mergeCategories", function()
    local shipments = fn.Filter(fc{fn.Not, fp{fn.GetValue, "noship"}}, CustomShipments)
    local guns = fn.Filter(fp{fn.GetValue, "separate"}, CustomShipments)

    mergeCategories(RPExtraTeams, "jobs", "your jobs")
    mergeCategories(DarkRPEntities, "entities", "your custom entities")
    mergeCategories(shipments, "shipments", "your custom shipments")
    mergeCategories(guns, "weapons", "your custom weapons")
    mergeCategories(CustomVehicles, "vehicles", "your custom vehicles")
    mergeCategories(GAMEMODE.AmmoTypes, "ammo", "your custom ammo")

    categoriesMerged = true
end)
