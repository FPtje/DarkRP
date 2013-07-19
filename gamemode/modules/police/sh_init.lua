local plyMeta = FindMetaTable("Player")

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function plyMeta:isArrested()
	return self:getDarkRPVar("Arrested")
end

function plyMeta:isWanted()
	return self:getDarkRPVar("wanted")
end

function plyMeta:getWantedReason()
	return self:getDarkRPVar("wantedReason")
end

/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/

function DarkRP.hooks:canRequestWarrant(target, actor, reason)
	if not reason or string.len(reason) == 0 then return false, DarkRP.getPhrase("vote_specify_reason") end
	if not IsValid(target) then return false, DarkRP.getPhrase("suspect_doesnt_exist") end
	if not IsValid(actor) then return false, DarkRP.getPhrase("actor_doesnt_exist") end
	if not actor:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("get_a_warrant")) end
	if target.warranted then return false, DarkRP.getPhrase("already_a_warrant") end
	if not actor:IsCP() then return false, DarkRP.getPhrase("incorrect_job", DarkRP.getPhrase("get_a_warrant")) end
	if not target:Alive() then return false, DarkRP.getPhrase("suspect_must_be_alive_to_do_x", DarkRP.getPhrase("get_a_warrant")) end
	if target:isArrested() then return false, DarkRP.getPhrase("suspect_already_arrested") end
	if string.len(reason) > 22 then return false, DarkRP.getPhrase("unable", DarkRP.getPhrase("get_a_warrant"), "<23") end

	return true
end

function DarkRP.hooks:canWanted(target, actor, reason)
	if not reason or string.len(reason) == 0 then return false, DarkRP.getPhrase("vote_specify_reason") end
	if not IsValid(target) then return false, DarkRP.getPhrase("suspect_doesnt_exist") end
	if not IsValid(actor) then return false, DarkRP.getPhrase("actor_doesnt_exist") end
	if not actor:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("make_someone_wanted")) end
	if not actor:IsCP() then return false, DarkRP.getPhrase("incorrect_job", DarkRP.getPhrase("make_someone_wanted")) end
	if target:isWanted() then return false, DarkRP.getPhrase("already_wanted") end
	if not target:Alive() then return false, DarkRP.getPhrase("suspect_must_be_alive_to_do_x", DarkRP.getPhrase("make_someone_wanted")) end
	if target:isArrested() then return false, DarkRP.getPhrase("suspect_already_arrested") end
	if string.len(reason) > 22 then return false, DarkRP.getPhrase("unable", DarkRP.getPhrase("make_someone_wanted"), "<23") end

	return true
end

function DarkRP.hooks:canUnwant(target, actor)
	if not IsValid(target) then return false, DarkRP.getPhrase("suspect_doesnt_exist") end
	if not IsValid(actor) then return false, DarkRP.getPhrase("actor_doesnt_exist") end
	if not actor:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("remove_wanted_status")) end
	if not actor:IsCP() then return false, DarkRP.getPhrase("incorrect_job", DarkRP.getPhrase("remove_wanted_status")) end
	if not target:isWanted() then return false, DarkRP.getPhrase("not_wanted") end
	if not target:Alive() then return false, DarkRP.getPhrase("suspect_must_be_alive_to_do_x", DarkRP.getPhrase("remove_wanted_status")) end

	return true
end

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
DarkRP.declareChatCommand{
	command = "cr",
	description = "Cry for help, the police will come!",
	delay = 1.5
}

DarkRP.declareChatCommand{
	command = "warrant",
	description = "Get a search warrant for a certain player. With this warrant you can search their house",
	delay = 1.5,
	condition = fn.FAnd{plyMeta.Alive, plyMeta.IsCP, fn.Compose{fn.Not, plyMeta.isArrested}}
}

DarkRP.declareChatCommand{
	command = "wanted",
	description = "Make a player wanted. This is needed to get them arrested.",
	delay = 1.5,
	condition = fn.FAnd{plyMeta.Alive, plyMeta.IsCP, fn.Compose{fn.Not, plyMeta.isArrested}}
}

DarkRP.declareChatCommand{
	command = "unwanted",
	description = "Remove a player's wanted status.",
	delay = 1.5,
	condition = fn.FAnd{plyMeta.Alive, plyMeta.IsCP, fn.Compose{fn.Not, plyMeta.isArrested}}
}

DarkRP.declareChatCommand{
	command = "agenda",
	description = "Set the agenda.",
	delay = 1.5,
	condition = fn.Compose{fn.Not, fn.Curry(fn.Eq, 2)(nil), fn.Curry(fn.Flip(fn.GetValue), 2)(DarkRPAgendas), plyMeta.Team}
}

local getJobTable = fn.Compose{fn.Curry(fn.Flip(fn.GetValue), 2)(RPExtraTeams), plyMeta.Team}
local isMayor = fn.Compose{fn.Curry(fn.GetValue, 2)("mayor"), getJobTable}
local isChief = fn.Compose{fn.Curry(fn.GetValue, 2)("chief"), getJobTable}
DarkRP.declareChatCommand{
	command = "lottery",
	description = "Start a lottery",
	delay = 1.5,
	condition = isMayor
}

DarkRP.declareChatCommand{
	command = "lockdown",
	description = "Start a lockdown. Everyone will have to stay inside",
	delay = 1.5,
	condition = isMayor
}

DarkRP.declareChatCommand{
	command = "unlockdown",
	description = "Stop a lockdown",
	delay = 1.5,
	condition = isMayor
}

DarkRP.declareChatCommand{
	command = "requestlicense",
	description = "Request a gun license.",
	delay = 1.5
}

local noMayorExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(isMayor), player.GetAll}
local noChiefExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(isChief), player.GetAll}
DarkRP.declareChatCommand{
	command = "givelicense",
	description = "Give someone a gun license",
	delay = 1.5,
	condition = fn.FOr{
		isMayor, -- Mayors can hand out licenses
		fn.FAnd{isChief, noMayorExists}, -- Chiefs can if there is no mayor
		fn.FAnd{plyMeta.IsCP, noChiefExists, noMayorExists} -- CP's can if there are no chiefs nor mayors
	}
}

DarkRP.declareChatCommand{
	command = "demotelicense",
	description = "Start a vote to get someone's license revoked.",
	delay = 1.5
}
