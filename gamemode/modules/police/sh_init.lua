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
	if not if not actor:Alive() then return false, DarkRP.getPhrase("must_be_alive_to_do_x", DarkRP.getPhrase("make_someone_wanted")) end
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
	command = "wanted",
	description = "Remove a player's wanted status.",
	delay = 1.5,
	condition = fn.FAnd{plyMeta.Alive, plyMeta.IsCP, fn.Compose{fn.Not, plyMeta.isArrested}}
}
