local plyMeta = FindMetaTable("Player")
plyMeta.isMedic = fn.Compose{fn.Curry(fn.GetValue, 2)("medic"), plyMeta.getJobTable}
