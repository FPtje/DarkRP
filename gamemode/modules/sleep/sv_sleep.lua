KnockoutTime = 5

local function ResetKnockouts(player)
	player.SleepRagdoll = nil
	player.KnockoutTimer = 0
end
hook.Add("PlayerSpawn", "Knockout", ResetKnockouts)


function KnockoutToggle(player, command, args, caller)
	if not player.SleepSound then
		player.SleepSound = CreateSound(player, "npc/ichthyosaur/water_breath.wav")
	end

	if player:Alive() then
		if (player.KnockoutTimer and player.KnockoutTimer + KnockoutTime < CurTime()) or command == "force" then
			if (player.Sleeping and IsValid(player.SleepRagdoll)) then
				player.OldHunger = player:getDarkRPVar("Energy")
				player.SleepSound:Stop()
				local ragdoll = player.SleepRagdoll
				local health = player:Health()
				player:Spawn()
				player:SetHealth(health)
				player:SetPos(ragdoll:GetPos())
				local model = ragdoll:GetModel()
				// TEMPORARY WORKAROUND
				if string.lower(model) == "models/humans/corpse1.mdl" then
					model = "models/player/corpse1.mdl"
				end
				player:SetModel(model)
				player:SetAngles(Angle(0, ragdoll:GetPhysicsObjectNum(10):GetAngles().Yaw, 0))
				player:UnSpectate()
				player:StripWeapons()
				ragdoll:Remove()
				if player.WeaponsForSleep and player:GetTable().BeforeSleepTeam == player:Team() then
					for k,v in pairs(player.WeaponsForSleep) do
						local wep = player:Give(v[1])
						player:RemoveAllAmmo()
						player:SetAmmo(v[2], v[3], false)
						player:SetAmmo(v[4], v[5], false)

						wep:SetClip1(v[6])
						wep:SetClip2(v[7])

					end
					local cl_defaultweapon = player:GetInfo("cl_defaultweapon")
					if ( player:HasWeapon( cl_defaultweapon )  ) then
						player:SelectWeapon( cl_defaultweapon )
					end
					player:GetTable().BeforeSleepTeam = nil
				else
					GAMEMODE:PlayerLoadout(player)
				end

				SendUserMessage("blackScreen", player, false)

				if command == true then
					player:arrest()
				end
				player.Sleeping = false
				player:SetSelfDarkRPVar("Energy", player.OldHunger)
				player.OldHunger = nil

				if player:isArrested() then
					GAMEMODE:SetPlayerSpeed(player, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed)
				end
			else
				for k,v in pairs(ents.FindInSphere(player:GetPos(), 30)) do
					if v:GetClass() == "func_door" then
						GAMEMODE:Notify(player, 1, 4, DarkRP.getPhrase("unable", "sleep", "func_door exploit"))
						return ""
					end
				end

				if not player:isArrested() then
					player.WeaponsForSleep = {}
					for k,v in pairs(player:GetWeapons()) do
						player.WeaponsForSleep[k] = {v:GetClass(), player:GetAmmoCount(v:GetPrimaryAmmoType()),
						v:GetPrimaryAmmoType(), player:GetAmmoCount(v:GetSecondaryAmmoType()), v:GetSecondaryAmmoType(),
						v:Clip1(), v:Clip2()}
						/*{class, ammocount primary, type primary, ammo count secondary, type secondary, clip primary, clip secondary*/
					end
				end
				local ragdoll = ents.Create("prop_ragdoll")
				ragdoll:SetPos(player:GetPos())
				ragdoll:SetAngles(Angle(0,player:GetAngles().Yaw,0))
				local model = player:GetModel()
				// TEMPORARY WORKAROUND
				if string.lower(model) == "models/player/corpse1.mdl" then
					model = "models/Humans/corpse1.mdl"
				end
				ragdoll:SetModel(model)
				ragdoll:Spawn()
				ragdoll:Activate()
				ragdoll:SetVelocity(player:GetVelocity())
				ragdoll.OwnerINT = player:EntIndex()
				ragdoll.PhysgunPickup = false
				ragdoll.CanTool = false
				player:StripWeapons()
				player:Spectate(OBS_MODE_CHASE)
				player:SpectateEntity(ragdoll)
				player.IsSleeping = true
				player.SleepRagdoll = ragdoll
				player.KnockoutTimer = CurTime()
				player:GetTable().BeforeSleepTeam = player:Team()
				--Make sure noone can pick it up:
				ragdoll:CPPISetOwner(player)

				SendUserMessage("blackScreen", player, true)

				player.SleepSound = CreateSound(ragdoll, "npc/ichthyosaur/water_breath.wav")
				player.SleepSound:PlayEx(0.10, 100)
				player.Sleeping = true
			end
		else
			GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("unable", "/sleep", ""))
		end
		return ""
	else
		GAMEMODE:Notify(player, 1, 4, DarkRP.getPhrase("disabled", "/sleep", ""))
		return ""
	end
end
AddChatCommand("/sleep", KnockoutToggle)
AddChatCommand("/wake", KnockoutToggle)
AddChatCommand("/wakeup", KnockoutToggle)

local function DamageSleepers(ent, dmginfo)
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()

	local ownerint = ent.OwnerINT
	if ownerint and ownerint ~= 0 then
		for k,v in pairs(player.GetAll()) do
			if v:EntIndex() == ownerint then
				if attacker == game.GetWorld() then
					amount = 10
					dmginfo:ScaleDamage(0.1)
				end
				v:SetHealth(v:Health() - amount)
				if v:Health() <= 0 and v:Alive() then
					v:Spawn()
					v:UnSpectate()
					v:SetPos(ent:GetPos())
					v:SetHealth(1)
					v:TakeDamage(1, inflictor, attacker)
					if v.SleepSound then
						v.SleepSound:Stop()
					end
					ent:Remove()
				end
			end
		end
	end
end
hook.Add("EntityTakeDamage", "Sleepdamage", DamageSleepers)
