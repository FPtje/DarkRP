local plyMeta = FindMetaTable("Player")

plyMeta.isMedic = fn.Compose{fn.Curry(fn.GetValue, 2)("medic"), plyMeta.getJobTable}
local noMedicExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(plyMeta.isMedic), player.GetAll}
