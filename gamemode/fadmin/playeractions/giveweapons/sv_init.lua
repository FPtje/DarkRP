local function GiveWeapon(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "giveweapon") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[2] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	local weapon = weapons.GetStored(args[2])
	if table.HasValue(FAdmin.HL2Guns, args[2]) then weapon = args[2]
	elseif weapon and weapon.ClassName then weapon = weapon.ClassName end

	if not weapon then return end

	for _, target in pairs(targets) do
		if IsValid(target) then
			target:Give(weapon)
		end
	end
	FAdmin.Messages.ActionMessage(ply, targets, "You gave %s a "..weapon, "%s gave you a "..weapon, "Gave %s a "..weapon)
end

local function GiveAmmo(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "giveweapon") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[2] or not FAdmin.AmmoTypes[args[2]] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	local ammo = args[2]
	local amount = tonumber(args[3]) or FAdmin.AmmoTypes[args[2]]

	for _, target in pairs(targets) do
		if IsValid(target) then
			target:GiveAmmo(amount, ammo)
		end
	end
	FAdmin.Messages.ActionMessage(ply, targets, "You gave %s "..amount.." "..ammo.. " ammo", "%s gave you ".. amount.." "..ammo.. " ammo", "Gave %s "..amount.." "..ammo)
end

FAdmin.StartHooks["GiveWeapons"] = function()
	FAdmin.Commands.AddCommand("giveweapon", GiveWeapon)
	FAdmin.Commands.AddCommand("giveammo", GiveAmmo)

	FAdmin.Access.AddPrivilege("giveweapon", 2)
end