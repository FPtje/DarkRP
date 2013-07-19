local plyMeta = FindMetaTable("Player")
local getJobTable = fn.Compose{fn.Curry(fn.Flip(fn.GetValue), 2)(RPExtraTeams), plyMeta.Team}

plyMeta.isMedic = fn.Compose{fn.Curry(fn.GetValue, 2)("medic"), getJobTable}
local noMedicExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isMedic), player.GetAll}

DarkRP.declareChatCommand{
	command = "buyhealth",
	description = "Buy health (only possible if there's no medic!)",
	delay = 1.5,
	condition = fn.FOr{isMedic, noMedicExists}
}
