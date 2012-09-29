local function SetNoclip(ply, cmd, args)
	if not FAdmin.Access.PlayerHasPrivilege(ply, "SetNoclip") then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end
	local Toggle = util.tobool(tonumber(args[2])) or false


	for _, target in pairs(targets) do
		if IsValid(target) then
			if Toggle then
				target:FAdmin_SetGlobal("FADmin_CanNoclip", true)
				target:FAdmin_SetGlobal("FADmin_DisableNoclip", false)

				if not FAdmin.Access.PlayerHasPrivilege(target, "Noclip") then
					FAdmin.Messages.SendMessage(ply, 3, "This is not permanent! Make it permanent with a custom group in SetAccess!")
				end
			else
				target:FAdmin_SetGlobal("FADmin_CanNoclip", false)
				target:FAdmin_SetGlobal("FADmin_DisableNoclip", true)

				if target:GetMoveType() == MOVETYPE_NOCLIP then
					target:SetMoveType(MOVETYPE_WALK)
				end
			end
		end
	end
	if Toggle then
		FAdmin.Messages.ActionMessage(ply, targets, "You have enabled noclip for %s", "%s has enabled noclip for you", "Enabled noclip for %s")
	else
		FAdmin.Messages.ActionMessage(ply, targets, "You have disabled noclip for %s", "%s has disabled noclip for you", "Disabled noclip for %s")
	end
end

FAdmin.StartHooks["Noclip"] = function()
	FAdmin.Access.AddPrivilege("Noclip", 2)
	FAdmin.Access.AddPrivilege("SetNoclip", 2)

	FAdmin.Commands.AddCommand("SetNoclip", SetNoclip)
end

hook.Add("PlayerNoClip", "FAdmin_noclip", function(ply)
	if not util.tobool(GetConVarNumber("sbox_noclip")) and
	((FAdmin.Access.PlayerHasPrivilege(ply, "Noclip") and not ply:FAdmin_GetGlobal("FADmin_DisableNoclip")) or ply:FAdmin_GetGlobal("FADmin_CanNoclip")) then
		-- If Other hooks explicitly say the user can't noclip, then disallow him the noclip unless FAdmin explicitly says the user can Noclip.
		if not ply:FAdmin_GetGlobal("FADmin_CanNoclip") then
			for k, v in pairs(hook.GetTable().PlayerNoClip) do
				if k ~= "FAdmin_noclip" then
					local Val = v(ply)
					if Val == false then return false end
				end
			end
		end
		if not ply.FADmin_HasGotNoclipMessage then
			FAdmin.Messages.SendMessage(ply, 4, "Noclip allowed")
			ply.FADmin_HasGotNoclipMessage = true
		end

		return true
	elseif ply:FAdmin_GetGlobal("FADmin_DisableNoclip") then
		FAdmin.Messages.SendMessage(ply, 5, "Noclip disallowed!")
		return false
	end
end)