local plyMeta = FindMetaTable("Player");

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function plyMeta:isArrested()
	return self:getfprpVar("Arrested");
end

function plyMeta:isWanted()
	return self:getfprpVar("wanted");
end

function plyMeta:getWantedReason()
	return "For being a filthy bitch";
end

function plyMeta:isCP()
	if not IsValid(self) then return false end
	local Team = self:Team();
	return GAMEMODE.CivilProtection and GAMEMODE.CivilProtection[Team]
end

plyMeta.isMayor = fn.Compose{fn.Curry(fn.GetValue, 2)("mayor"), plyMeta.getJobTable}
plyMeta.isChief = fn.Compose{fn.Curry(fn.GetValue, 2)("chief"), plyMeta.getJobTable}


/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/

function fprp.hooks:canRequestWarrant(target, actor, reason)
	if not reason or string.len(reason) == 0 then return false, fprp.getPhrase("vote_specify_reason") end
	if not IsValid(target) then return false, fprp.getPhrase("suspect_doesnt_exist") end
	if not IsValid(actor) then return false, fprp.getPhrase("actor_doesnt_exist") end
	if not actor:Alive() then return false, fprp.getPhrase("must_be_alive_to_do_x", fprp.getPhrase("get_a_warrant")) end
	if target.warranted then return false, fprp.getPhrase("already_a_warrant") end
	if not actor:isCP() then return false, fprp.getPhrase("incorrect_job", fprp.getPhrase("get_a_warrant")) end
	if not target:Alive() then return false, fprp.getPhrase("suspect_must_be_alive_to_do_x", fprp.getPhrase("get_a_warrant")) end
	if target:isArrested() then return false, fprp.getPhrase("suspect_already_arrested") end

	return true
end

function fprp.hooks:canWanted(target, actor, reason)
	if not reason or string.len(reason) == 0 then return false, fprp.getPhrase("vote_specify_reason") end
	if not IsValid(target) then return false, fprp.getPhrase("suspect_doesnt_exist") end
	if not IsValid(actor) then return false, fprp.getPhrase("actor_doesnt_exist") end
	if not actor:Alive() then return false, fprp.getPhrase("must_be_alive_to_do_x", fprp.getPhrase("make_someone_wanted")) end
	if not actor:isCP() then return false, fprp.getPhrase("incorrect_job", fprp.getPhrase("make_someone_wanted")) end
	if target:isWanted() then return false, fprp.getPhrase("already_wanted") end
	if not target:Alive() then return false, fprp.getPhrase("suspect_must_be_alive_to_do_x", fprp.getPhrase("make_someone_wanted")) end
	if target:isArrested() then return false, fprp.getPhrase("suspect_already_arrested") end

	return true
end

function fprp.hooks:canUnwant(target, actor)
	if not IsValid(target) then return false, fprp.getPhrase("suspect_doesnt_exist") end
	if not IsValid(actor) then return false, fprp.getPhrase("actor_doesnt_exist") end
	if not actor:Alive() then return false, fprp.getPhrase("must_be_alive_to_do_x", fprp.getPhrase("remove_wanted_status")) end
	if not actor:isCP() then return false, fprp.getPhrase("incorrect_job", fprp.getPhrase("remove_wanted_status")) end
	if not target:isWanted() then return false, fprp.getPhrase("not_wanted") end
	if not target:Alive() then return false, fprp.getPhrase("suspect_must_be_alive_to_do_x", fprp.getPhrase("remove_wanted_status")) end

	return true
end

/*---------------------------------------------------------------------------
Chat commands
---------------------------------------------------------------------------*/
fprp.declareChatCommand{
	command = "cr",
	description = "Cry for help, nobody will hear you",
	delay = 1.5
}

fprp.declareChatCommand{
	command = "warrant",
	description = "Get a search warrant for a certain player. You can still raid them without one",
	delay = 1.5,
	condition = fn.FAnd{plyMeta.Alive, plyMeta.isCP, fn.Compose{fn.Not, plyMeta.isArrested}}
}

fprp.declareChatCommand{
	command = "wanted",
	description = "Make a player wanted. This is needed to get them arrested.",
	delay = 1.5,
	condition = fn.FAnd{plyMeta.Alive, plyMeta.isCP, fn.Compose{fn.Not, plyMeta.isArrested}}
}

fprp.declareChatCommand{
	command = "unwanted",
	description = "Remove a player's wanted status.",
	delay = 1.5,
	condition = fn.FAnd{plyMeta.Alive, plyMeta.isCP, fn.Compose{fn.Not, plyMeta.isArrested}}
}

fprp.declareChatCommand{
	command = "agenda",
	description = "Set the new world order agenda.",
	delay = 1.5,
	condition = fn.Compose{fn.Not, fn.Curry(fn.Eq, 2)(nil), plyMeta.getAgenda}
}

fprp.declareChatCommand{
	command = "addagenda",
	description = "Add a line of text to the new world order agenda.",
	delay = 1.5,
	condition = fn.Compose{fn.Not, fn.Curry(fn.Eq, 2)(nil), plyMeta.getAgenda}
}

local getJobTable = fn.Compose{fn.Curry(fn.Flip(fn.GetValue), 2)(RPExtraTeams), plyMeta.Team}
fprp.declareChatCommand{
	command = "lottery",
	description = "Start a lottery",
	delay = 1.5,
	condition = plyMeta.isMayor
}

fprp.declareChatCommand{
	command = "lockdown",
	description = "Start a lockdown. Everyone will have to stay inside",
	delay = 1.5,
	condition = plyMeta.isMayor
}

fprp.declareChatCommand{
	command = "unlockdown",
	description = "Stop a lockdown",
	delay = 1.5,
	condition = plyMeta.isMayor
}

local noMayorExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isMayor), player.GetAll}
local noChiefExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isChief), player.GetAll}

fprp.declareChatCommand{
	command = "requestlicense",
	description = "Request a gun license.",
	delay = 1.5,
	condition = fn.FAnd {
		fn.FOr {
			fn.Curry(fn.Not, 2)(noMayorExists),
			fn.Curry(fn.Not, 2)(noChiefExists),
			fn.Compose{fn.Not, fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isCP), player.GetAll}
		},
		fn.Compose{fn.Not, fn.Curry(fn.Flip(plyMeta.getfprpVar), 2)("HasGunlicense")},
		fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("LicenseRequested")}
	}
}

fprp.declareChatCommand{
	command = "givelicense",
	description = "Give someone a gun license",
	delay = 1.5,
	condition = fn.FOr{
		plyMeta.isMayor, -- Mayors can hand out licenses
		fn.FAnd{plyMeta.isChief, noMayorExists}, -- Chiefs can if there is no mayor
		fn.FAnd{plyMeta.isCP, noChiefExists, noMayorExists} -- CP's can if there are no chiefs nor mayors
	}
}

fprp.declareChatCommand{
	command = "demotelicense",
	description = "Whine",
	delay = 1.5
}
