sql.Query("CREATE TABLE IF NOT EXISTS FADMIN_RESTRICTEDENTS('TYPE' TEXT NOT NULL, 'ENTITY' TEXT NOT NULL, 'ADMIN_GROUP' TEXT NOT NULL, PRIMARY KEY(TYPE, ENTITY));")

local Restricted = {}
Restricted.Weapons = {}

local function RetrieveRestricted()
	local Query = sql.Query("SELECT * FROM FADMIN_RESTRICTEDENTS") or {}
	for k,v in pairs(Query) do
		if Restricted[v.TYPE] then
			Restricted[v.TYPE][v.ENTITY] = v.ADMIN_GROUP
		end
	end
end RetrieveRestricted()

local function DoRestrictWeapons(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "Restrict") then print("no1") FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	local Weapon = args[1]
	local Group = args[2]
	if not Group or not FAdmin.Access.Groups[Group] or not Weapon then print("no2") return end
	if Restricted.Weapons[Weapon] then
		sql.Query("UPDATE FADMIN_RESTRICTEDENTS SET ADMIN_GROUP = " .. MySQLite.SQLStr(Group).." WHERE ENTITY = " .. MySQLite.SQLStr(Weapon).." AND TYPE = " .. MySQLite.SQLStr("Weapons")..";")
	else
		sql.Query("INSERT INTO FADMIN_RESTRICTEDENTS VALUES(" .. MySQLite.SQLStr("Weapons")..", " .. MySQLite.SQLStr(Weapon)..", " .. MySQLite.SQLStr(Group)..");")
	end
	Restricted.Weapons[Weapon] = Group
	FAdmin.Messages.SendMessage(ply, 4, "Weapon restricted!")
end

local function RestrictWeapons(ply, Weapon, WeaponTable)
	local Group = ply:GetNWString("usergroup")
	if not FAdmin or not FAdmin.Access or not FAdmin.Access.Groups or not FAdmin.Access.Groups[Group]
	or not FAdmin.Access.Groups[Restricted.Weapons[Weapon]] then return end
	local RequiredGroup = Restricted.Weapons[Weapon]

	if Group ~= RequiredGroup and FAdmin.Access.Groups[Group].ADMIN <= FAdmin.Access.Groups[RequiredGroup].ADMIN then return false end
end
hook.Add("PlayerGiveSWEP", "FAdmin_RestrictWeapons", RestrictWeapons)
hook.Add("PlayerSpawnSWEP", "FAdmin_RestrictWeapons", RestrictWeapons)

FAdmin.StartHooks["Restrict"] = function()
	FAdmin.Commands.AddCommand("RestrictWeapon", DoRestrictWeapons)

	FAdmin.Access.AddPrivilege("Restrict", 3)
end