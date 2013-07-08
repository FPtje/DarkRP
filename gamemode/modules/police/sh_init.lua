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
	if not IsValid(target) then return false, "Suspect does not exist" end
	if not IsValid(actor) then return false, "Actor does not exist" end
	if not actor:Alive() then return false, "You must be alive in order to get a warrant" end
	if target.warranted then return false, "There already is a search warrant for this suspect" end
	if not actor:IsCP() then return false, "You have to be a member of the police force" end
	if not target:Alive() then return false, "The suspect must be alive in order to get a warrant" end
	if target:isArrested() then return false, "The suspect is already in jail" end
	if string.len(reason) > 22 then return false, "The reason has to be fewer than 23 characters long" end

	return true
end

function DarkRP.hooks:canWanted(target, actor, reason)
	if not reason or string.len(reason) == 0 then return false, DarkRP.getPhrase("vote_specify_reason") end
	if not IsValid(target) then return false, "Suspect does not exist" end
	if not IsValid(actor) then return false, "Actor does not exist" end
	if not actor:Alive() then return false, "You must be alive in order to make someone wanted" end
	if not actor:IsCP() then return false, "You have to be a member of the police force" end
	if target:isWanted() then return false, "This suspect is already wanted" end
	if not target:Alive() then return false, "The suspect must be alive in order to make someone wanted" end
	if target:isArrested() then return false, "The suspect is already in jail" end
	if string.len(reason) > 22 then return false, "The reason has to be fewer than 23 characters long" end

	return true
end

function DarkRP.hooks:canUnwant(target, actor)
	if not IsValid(target) then return false, "Suspect does not exist" end
	if not IsValid(actor) then return false, "Actor does not exist" end
	if not actor:Alive() then return false, "You must be alive in order to remove wanted status" end
	if not actor:IsCP() then return false, "You have to be a member of the police force" end
	if not target:isWanted() then return false, "This suspect is not wanted" end
	if not target:Alive() then return false, "The suspect must be alive in order to remove the wanted status" end

	return true
end
