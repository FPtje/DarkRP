local function Jail(ply, cmd, args)
	if not args[1] then return end

	local targets = FAdmin.FindPlayer(args[1])
	if not targets or #targets == 1 and not IsValid(targets[1]) then
		FAdmin.Messages.SendMessage(ply, 1, "Player not found")
		return
	end

	local JailType = FAdmin.PlayerActions.JailTypes[tonumber(args[2])] or args[2] or FAdmin.PlayerActions.JailTypes[2]
	JailType = string.lower(JailType)
	local JailTime = tonumber(args[3]) or 0
	local time = ""

	for _, target in pairs(targets) do
		if not FAdmin.Access.PlayerHasPrivilege(ply, "Jail", target) then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
		if IsValid(target) then
			local JailProps = {}
			if JailType == "unjail" or string.lower(cmd) == "unjail" then
				if target.FAdminJailProps then
					for k,v in pairs(target.FAdminJailProps) do
						if IsValid(k) then
							k:SetCanRemove(true)
							k:Remove()
						end
					end
				end

				target.FAdminJailProps = nil
				timer.Destroy("FAdmin_jail"..target:UserID())
				target:FAdmin_SetGlobal("fadmin_jailed", false)

			elseif JailType == "small" then
				table.insert(JailProps, {pos = Vector(0,0,58), ang = Angle(0,0,0), model = "models/props_wasteland/laundry_dryer001.mdl"})
			elseif JailType == "normal" then
				table.insert(JailProps, {pos = Vector(0,0,-5), ang = Angle(90,0,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
				table.insert(JailProps, {pos = Vector(0,0,97), ang = Angle(90,0,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})

				table.insert(JailProps, {pos = Vector(21,31,46), ang = Angle(0,90,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
				table.insert(JailProps, {pos = Vector(21,-31,46), ang = Angle(0,90,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
				table.insert(JailProps, {pos = Vector(-21,31,46), ang = Angle(0,90,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
				table.insert(JailProps, {pos = Vector(-21,-31,46), ang = Angle(0,90,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})

				table.insert(JailProps, {pos = Vector(-52,0,46), ang = Angle(0,0,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})
				table.insert(JailProps, {pos = Vector(52,0,46), ang = Angle(0,0,0), model = "models/props_building_details/Storefront_Template001a_Bars.mdl"})

			elseif JailType == "big" then -- Requires CSS but it's really funny
				table.insert(JailProps, {pos = Vector(0,0,-5), ang = Angle(0,0,0), model = "models/props/cs_havana/gazebo.mdl"})
				table.insert(JailProps, {pos = Vector(70,0,50), ang = Angle(0,0,0), model = "models/props_borealis/borealis_door001a.mdl"})

				table.insert(JailProps, {pos = Vector(-70,0,100), ang = Angle(0,0,90), model = "models/props_lab/lockerdoorleft.mdl"})
				table.insert(JailProps, {pos = Vector(-35,-55,100), ang = Angle(0,60,90), model = "models/props_lab/lockerdoorleft.mdl"})
				table.insert(JailProps, {pos = Vector(-35,55,100), ang = Angle(0,300,90), model = "models/props_lab/lockerdoorleft.mdl"})

				table.insert(JailProps, {pos = Vector(35,-55,100), ang = Angle(0,300,90), model = "models/props_lab/lockerdoorleft.mdl"})
				table.insert(JailProps, {pos = Vector(35,55,100), ang = Angle(0,240,90), model = "models/props_lab/lockerdoorleft.mdl"})
			end
			if not target:FAdmin_GetGlobal("fadmin_jailed") and JailType ~= "unjail" and string.lower(cmd) ~= "unjail"  then
				target:SetMoveType(MOVETYPE_WALK)

				target:FAdmin_SetGlobal("fadmin_jailed", true)
				target.FAdminJailPos = target:GetPos()
				target.FAdminJailProps = {}

				for k,v in pairs(JailProps) do
					local JailProp = ents.Create("fadmin_jail")
					JailProp:SetPos(target.FAdminJailPos + v.pos)
					JailProp:SetAngles(v.ang)
					JailProp:SetModel(v.model)
					JailProp:Spawn()
					JailProp:Activate()

					JailProp.target = target
					JailProp.targetPos = target.FAdminJailPos
					target.FAdminJailProps[JailProp] = true
				end

				if JailTime ~= 0 then
					timer.Create("FAdmin_jail"..target:UserID(), JailTime, 1, function()
						if IsValid(target) and target:FAdmin_GetGlobal("fadmin_jailed") then
							target:FAdmin_SetGlobal("fadmin_jailed", false)
							for k,v in pairs(target.FAdminJailProps) do
								if IsValid(k) then
									k:SetCanRemove(true)
									k:Remove()
								end
							end

							target.FAdminJailProps = nil
						end
					end)
				end

				time = "for ".. JailTime.." seconds"
				if JailTime == 0 then time = "indefinitely" end
			end
		end
	end
	if JailType == "unjail" or string.lower(cmd) == "unjail" then
		FAdmin.Messages.ActionMessage(ply, targets, "Unjailed %s", "You were unjailed by %s", "Unjailed %s")
	else
		FAdmin.Messages.ActionMessage(ply, targets, "Jailed %s in a "..JailType.." jail ".. time, "You were jailed " .. time .. " by %s", "Jailed %s for "..time)
	end
end

FAdmin.StartHooks["Jail"] = function()
	FAdmin.Commands.AddCommand("Jail", Jail)
	FAdmin.Commands.AddCommand("UnJail", Jail)

	FAdmin.Access.AddPrivilege("Jail", 2)
end

hook.Add("PlayerSpawn", "FAdmin_jail", function(ply)
	if ply:FAdmin_GetGlobal("fadmin_jailed") then
		timer.Simple(0.1, function() if IsValid(ply) then ply:SetPos(ply.FAdminJailPos) end end)
	end
end)

hook.Add("PlayerNoClip", "FAdmin_jail", function(ply)
	if ply:FAdmin_GetGlobal("fadmin_jailed") then
		return false
	end
end)

hook.Add("PlayerSpawnObject", "FAdmin_jailed", function(ply)
	if ply:FAdmin_GetGlobal("fadmin_jailed") then
		return false
	end
end)