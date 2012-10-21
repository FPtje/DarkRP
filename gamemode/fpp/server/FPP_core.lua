FPP = FPP or {}
FPP.DisconnectedPlayers = {}


/*---------------------------------------------------------------------------
Checks is a model is blocked
---------------------------------------------------------------------------*/
local function isBlocked(model)
	if model == "" or not FPP.Settings or not FPP.Settings.FPP_BLOCKMODELSETTINGS1 or
		not tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.toggle)
		or not FPP.BlockedModels or not model then return end

	model = string.lower(model or "")
	model = string.Replace(model, "\\", "/")
	model = string.gsub(model, "[\\/]+", "/")

	local found = FPP.BlockedModels[model]
	if tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.iswhitelist) and not found then
		-- Prop is not in the white list
		return true, "The model of this entity is not in the white list!"
	elseif not tobool(FPP.Settings.FPP_BLOCKMODELSETTINGS1.iswhitelist) and found then
		-- prop is in the black list
		return true, "The model of this entity is in the black list!"
	end
	return false
end

/*---------------------------------------------------------------------------
Prevents spawning a prop when its model is blocked
---------------------------------------------------------------------------*/
hook.Add("PlayerSpawnProp", "FPP_SpawnProp", function(ply, model)
	local blocked, msg = isBlocked(model)
	if blocked then
		FPP.Notify(ply, msg, false)
		return false
	end
end)

/*---------------------------------------------------------------------------
Setting owner when someone spawns something
---------------------------------------------------------------------------*/
if cleanup then
	FPP.oldcleanup = FPP.oldcleanup or cleanup.Add
	function cleanup.Add(ply, Type, ent)
		if IsValid(ply) and IsValid(ent) then
			--Set the owner of the entity
			ent.Owner = ply
			ent.OwnerID = ply:SteamID()

			local blocked, msg = isBlocked(model)
			if blocked then
				FPP.Notify(ply, msg, false)
				ent:Remove()
				return
			end

			if FPP.AntiSpam and Type ~= "constraints" and Type ~= "stacks" and Type ~= "AdvDupe2" and (not ent.IsVehicle() or not ent:IsVehicle()) then
				FPP.AntiSpam.CreateEntity(ply, ent, Type == "duplicates")
			end

			if ent:GetClass() == "gmod_wire_expression2" then
				ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end
		return FPP.oldcleanup(ply, Type, ent)
	end
end

FPP.ApplyForceCenter = FPP.ApplyForceCenter or debug.getregistry().PhysObj.ApplyForceCenter
debug.getregistry().PhysObj.ApplyForceCenter = function(self, force, ...)
	local i = 0
	while true and tobool(FPP.Settings.FPP_GLOBALSETTINGS1.antie2minge) do
		i = i + 1
		local DebugLevel = debug.getinfo(i, "Sln")
		if not DebugLevel then break end
		if DebugLevel and string.find(DebugLevel.short_src, "gmod_wire_expression2") and IsValid(self:GetEntity()) and tobool(FPP.Settings.FPP_GLOBALSETTINGS1.antie2minge) then
			self:GetEntity():SetCollisionGroup(COLLISION_GROUP_WEAPON)
			local ConstrainedEnts = constraint.GetAllConstrainedEntities(self:GetEntity())

			if ConstrainedEnts then -- All its constrained entities as well!
				for k,v in pairs(ConstrainedEnts) do
					v:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				end
			end
		end
	end
	return FPP.ApplyForceCenter(self, force, ...)
end

local PLAYER = FindMetaTable("Player")

if PLAYER.AddCount then
	FPP.oldcount = FPP.oldcount or PLAYER.AddCount
	function PLAYER:AddCount(Type, ent)
		if not IsValid(self) or not IsValid(ent) then return FPP.oldcount(self, Type, ent) end
		--Set the owner of the entity
		ent.Owner = self
		ent.OwnerID = self:SteamID()
		return FPP.oldcount(self, Type, ent)
	end
end

if undo then
	local AddEntity, SetPlayer, Finish =  undo.AddEntity, undo.SetPlayer, undo.Finish
	local Undo = {}
	local UndoPlayer
	function undo.AddEntity(ent, ...)
		if type(ent) ~= "boolean" and IsValid(ent) then table.insert(Undo, ent) end
		AddEntity(ent, ...)
	end

	function undo.SetPlayer(ply, ...)
		UndoPlayer = ply
		SetPlayer(ply, ...)
	end

	function undo.Finish(...)
		if IsValid(UndoPlayer) then
			for k,v in pairs(Undo) do
				v.Owner = UndoPlayer
			end
		end
		Undo = {}
		UndoPlayer = nil

		Finish(...)
	end
end


--------------------------------------------------------------------------------------
--When you can't touch something
--------------------------------------------------------------------------------------
function FPP.CanTouch(ply, Type, Owner, Toggle)
	if not IsValid(ply) or not FPP.Settings[Type] or not tobool(FPP.Settings[Type].shownocross) or tobool(ply:GetInfo("FPP_PrivateSettings_ShowIcon")) then return false end
	if ply.FPP_LastCanTouch and ply.FPP_LastCanTouch > CurTime() - 1 then return end
	ply.FPP_LastCanTouch = CurTime()

	umsg.Start("FPP_CanTouch", ply)
		if type(Owner) == "string" then
			umsg.String(Owner)
		elseif IsValid(Owner) then
			umsg.String(Owner:Nick())
		else
			umsg.String("No owner!")
		end
		umsg.Bool(Toggle)
	umsg.End()

	return Toggle, Owner
end


--------------------------------------------------------------------------------------
--The protecting itself
--------------------------------------------------------------------------------------

FPP.Protect = {}

local function cantouchsingleEnt(ply, ent, Type1, Type2, TryingToShare)
	if not IsValid( ply ) then
		return false
	end
	local OnlyMine = tobool(ply:GetInfo("FPP_PrivateSettings_OtherPlayerProps"))
	-- prevent player pickup when you don't want to
	if IsValid(ent) and ent:IsPlayer() and not tobool(ply:GetInfo("FPP_PrivateSettings_Players")) and Type1 == "Physgun1" then
		return false
	end
	-- Blocked entity
	local Returnal
	if not FPP.Blocked[Type1] then
		debug.Trace()
		Error(Type1.." Is not a valid settings type!")
	end

	-- Blacklist checks
	for k,v in pairs(FPP.Blocked[Type1]) do
		if (not tobool(FPP.Settings[Type2].iswhitelist) and string.find(string.lower(ent:GetClass()), string.lower(v))) then
			if ply:IsAdmin() and tobool(FPP.Settings[Type2].admincanblocked) then
				Returnal = true
			elseif tobool(FPP.Settings[Type2].canblocked) then
				Returnal = true
			else
				Returnal = false
			end
		end
	end

	Returnal = Returnal and IsValid(ply) and not tobool(ply:GetInfo("FPP_PrivateSettings_BlockedProps"))
	if Returnal ~= nil then return Returnal, "Blocked!" end

	-- Shared entity
	if ent["Share"..Type1] then return not OnlyMine, ent.Owner end

	if not TryingToShare and ent.AllowedPlayers and table.HasValue(ent.AllowedPlayers, ply) then
		return not OnlyMine, ent.Owner
	end

	-- Whitelist checks
	if tobool(FPP.Settings[Type2].iswhitelist) then
		for k,v in pairs(FPP.Blocked[Type1]) do
			if string.find(string.lower(ent:GetClass()), string.lower(v)) then --If it's a whitelist and the entity is found in the whitelist
				Returnal = true
				break
			end
		end
		-- If the whitelist says you can't touch it, then you can't
		if not Returnal and (not tobool(FPP.Settings[Type2].canblocked) and (not ply:IsAdmin() or not tobool(FPP.Settings[Type2].admincanblocked))) then
			return false, "Blocked!"
		end
		-- if the whitelist says you can, then we'll look further.
	end

	-- Misc.
	if ent.Owner ~= ply and IsValid(ply) then
		-- A buddy's prop
		if not TryingToShare and IsValid(ent.Owner) and ent.Owner.Buddies and ent.Owner.Buddies[ply] and ent.Owner.Buddies[ply][string.lower(Type1)] then
			return not OnlyMine, ent.Owner
		-- An admin touching it
		elseif ent.Owner and ply:IsAdmin() and tobool(FPP.Settings[Type2].adminall) then -- if not world prop AND admin allowed
			return not OnlyMine, ent.Owner
		-- Misc entities
		elseif ent == game.GetWorld() or ent:GetClass() == "gmod_anchor" then
			return true
		--If world prop or a prop belonging to someone who left
		elseif not IsValid(ent.Owner) then
			local world = "World prop"
			local Restrict = "WorldProps"
			if ent.Owner then
				world = "Disconnected player's prop"
				Restrict =  "OtherPlayerProps"
			end
			if ply:IsAdmin() and tobool(FPP.Settings[Type2].adminworldprops) then -- if admin and admin allowed
				return not tobool(ply:GetInfo("FPP_PrivateSettings_"..Restrict)), world
			elseif tobool(FPP.Settings[Type2].worldprops) then -- if worldprop allowed
				return not tobool(ply:GetInfo("FPP_PrivateSettings_"..Restrict)), world
			end -- if not allowed then
			return false, world
		else -- You don't own this, simple
			return false, ent.Owner
		end
	end

	return true and not tobool(ply:GetInfo("FPP_PrivateSettings_OwnProps"))
end

--Global cantouch function
function FPP.PlayerCanTouchEnt(ply, ent, Type1, Type2, TryingToShare, antiloop)
	local CanTouchSingleEnt, WHY = cantouchsingleEnt(ply, ent, Type1, Type2, TryingToShare)
	if not CanTouchSingleEnt then return CanTouchSingleEnt, WHY end

	if tobool(FPP.Settings[Type2].checkconstrained) then-- if we're ought to check the constraints, check every entity at once.
		local constrainted = constraint.GetAllConstrainedEntities(ent)
		if constrainted then
			for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
				if v ~= ent then
					local cantouch, why = cantouchsingleEnt(ply, v, Type1, Type2, false)
					why = why or "World prop"
					if not cantouch then
						if type(why) == "Player" then why = why:Nick() end
						return false, "Constrained entity: "..why
					end
				end
			end
		end
	end
	return CanTouchSingleEnt, WHY
end

local function DoShowOwner(ply, ent, cantouch, why)
	umsg.Start("FPP_Owner", ply)
		umsg.Entity(ent)
		umsg.Bool(cantouch)
		umsg.String(tostring(why))
	umsg.End()
end

function FPP.ShowOwner()
	for _, ply in pairs(player.GetAll()) do
		local wep = ply:GetActiveWeapon()
		local trace = ply:GetEyeTrace()
		if IsValid(wep) and IsValid(trace.Entity) and trace.Entity ~= game.GetWorld() and not trace.Entity:IsPlayer() and ply.FPP_LOOKINGAT ~= trace.Entity then
			ply.FPP_LOOKINGAT = trace.Entity -- Easy way to prevent spamming the usermessages
			local class, cantouch, why = wep:GetClass()
			if class == "weapon_physgun" then
				cantouch, why = FPP.PlayerCanTouchEnt(ply, trace.Entity, "Physgun1", "FPP_PHYSGUN1")
				why = why or trace.Entity.Owner or "World prop"
			elseif class == "weapon_physcannon" then
				cantouch, why = FPP.PlayerCanTouchEnt(ply, trace.Entity, "Gravgun1", "FPP_GRAVGUN1")
				why = why or trace.Entity.Owner or "World prop"
			elseif class == "gmod_tool" then
				cantouch, why = FPP.PlayerCanTouchEnt(ply, trace.Entity, "Toolgun1", "FPP_TOOLGUN1")
				why = why or trace.Entity.Owner or "World prop"
			else
				cantouch, why = FPP.PlayerCanTouchEnt(ply, trace.Entity, "EntityDamage1", "FPP_ENTITYDAMAGE1")
				why = why or trace.Entity.Owner or "World prop"
			end
			if type(why) == "Player" and why:IsValid() then why = why:Nick() end
			DoShowOwner(ply, trace.Entity, cantouch, why)
		elseif ply.FPP_LOOKINGAT ~= trace.Entity then
			ply.FPP_LOOKINGAT = nil
		end
	end
end
timer.Create("FPP_ShowOwner", 0.1, 0, FPP.ShowOwner)


--Physgun Pickup
function FPP.Protect.PhysgunPickup(ply, ent)
	if not tobool(FPP.Settings.FPP_PHYSGUN1.toggle) then if FPP.UnGhost then FPP.UnGhost(ply, ent) end return end
	if not ent:IsValid() then return FPP.CanTouch(ply, "FPP_PHYSGUN1", "Not valid!", false) end

	if type(ent.PhysgunPickup) == "function" then
		local val = ent:PhysgunPickup(ply, ent)
		if val ~= nil then return val end
	elseif ent.PhysgunPickup ~= nil then
		return ent.PhysgunPickup
	end

	if ent:IsPlayer() then return end

	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Physgun1", "FPP_PHYSGUN1")
	if why then
		FPP.CanTouch(ply, "FPP_PHYSGUN1", why, cantouch)
	end

	if cantouch and FPP.UnGhost then
		FPP.UnGhost(ply, ent)
	end

	if not cantouch then return false end
end
hook.Add("PhysgunPickup", "FPP.Protect.PhysgunPickup", FPP.Protect.PhysgunPickup)

--Physgun reload
function FPP.Protect.PhysgunReload(weapon, ply)
	if not tobool(FPP.Settings.FPP_PHYSGUN1.reloadprotection) then return end

	local ent = ply:GetEyeTrace().Entity

	if not IsValid(ent) then return end

	if type(ent.OnPhysgunReload) == "function" then
		local val = ent:OnPhysgunReload(weapon, ply)
		if val ~= nil then return val end
	elseif ent.OnPhysgunReload ~= nil then
		return ent.OnPhysgunReload
	end

	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Physgun1", "FPP_PHYSGUN1")
	if why then
		FPP.CanTouch(ply, "FPP_PHYSGUN1", why, cantouch)
	end

	if not cantouch then return false end
	return --If I return true, I will break the double reload
end
hook.Add("OnPhysgunReload", "FPP.Protect.PhysgunReload", FPP.Protect.PhysgunReload)

function FPP.PhysgunFreeze(weapon, phys, ent, ply)
	if type(ent.OnPhysgunFreeze) == "function" then
		local val = ent:OnPhysgunFreeze(weapon, phys, ent, ply)
		if val ~= nil then return val end
	elseif ent.OnPhysgunFreeze ~= nil then
		return ent.OnPhysgunFreeze
	end
end
hook.Add("OnPhysgunFreeze", "FPP.Protect.PhysgunFreeze", FPP.PhysgunFreeze)

--Gravgun pickup
function FPP.Protect.GravGunPickup(ply, ent)
	if not tobool(FPP.Settings.FPP_GRAVGUN1.toggle) then return end

	if not IsValid(ent) then return false end-- You don't want a cross when looking at the floor while holding right mouse

	if ent:IsPlayer() then return false end

	if type(ent.GravGunPickup) == "function" then
		local val = ent:GravGunPickup(ply, ent)
		if val ~= nil then
			if val == false then DropEntityIfHeld(ent) end
			return val
		end
	elseif ent.GravGunPickup ~= nil then
		if ent.GravGunPickup == false then DropEntityIfHeld(ent) end
		return ent.GravGunPickup
	end

	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Gravgun1", "FPP_GRAVGUN1")
	if why then
		FPP.CanTouch(ply, "FPP_GRAVGUN1", why, cantouch)
	end

	if FPP.UnGhost and cantouch then FPP.UnGhost(ply, ent) end
	if cantouch == false then DropEntityIfHeld(ent) end
	return cantouch
end
hook.Add("GravGunOnPickedUp", "FPP.Protect.GravGunPickup", FPP.Protect.GravGunPickup)

--Gravgun punting
function FPP.Protect.GravGunPunt(ply, ent)
	if tobool(FPP.Settings.FPP_GRAVGUN1.noshooting) then DropEntityIfHeld(ent) return false end

	if not IsValid(ent) then DropEntityIfHeld(ent) return FPP.CanTouch(ply, "FPP_GRAVGUN1", "Not valid!", false) end

	if type(ent.GravGunPunt) == "function" then
		local val = ent:GravGunPunt(ply, ent)
		if val ~= nil then
			if val == false then DropEntityIfHeld(ent) end
			return val
		end
	elseif ent.GravGunPunt ~= nil then
		if ent.GravGunPunt == false then DropEntityIfHeld(ent) end
		return ent.GravGunPunt
	end

	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Gravgun1", "FPP_GRAVGUN1")
	if why then
		FPP.CanTouch(ply, "FPP_GRAVGUN1", why, cantouch)
	end

	if FPP.UnGhost and cantouch then FPP.UnGhost(ply, ent) end
	if cantouch == false then DropEntityIfHeld(ent) end
	return cantouch
end
hook.Add("GravGunPunt", "FPP.Protect.GravGunPunt", FPP.Protect.GravGunPunt)

--PlayerUse
function FPP.Protect.PlayerUse(ply, ent)
	if not tobool(FPP.Settings.FPP_PLAYERUSE1.toggle) then return end

	if not IsValid(ent) then return FPP.CanTouch(ply, "FPP_PLAYERUSE1", "Not valid!", false) end

	if type(ent.PlayerUse) == "function" then
		local val = ent:PlayerUse(ply, ent)
		if val ~= nil then return val end
	elseif ent.PlayerUse ~= nil then
		return ent.PlayerUse
	end

	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "PlayerUse1", "FPP_PLAYERUSE1")
	if why then
		FPP.CanTouch(ply, "FPP_PLAYERUSE1", why, cantouch)
	end

	if FPP.UnGhost and cantouch then FPP.UnGhost(ply, ent) end
	return cantouch
end
hook.Add("PlayerUse", "FPP.Protect.PlayerUse", FPP.Protect.PlayerUse)

--EntityDamage
function FPP.Protect.EntityDamage(ent, dmginfo)
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()

	if type(ent.EntityDamage) == "function" then
		local val = ent:EntityDamage(ent, inflictor, attacker, amount, dmginfo)
		if val ~= nil then return val end
	elseif ent.EntityDamage ~= nil then
		return ent.EntityDamage
	end

	if not tobool(FPP.Settings.FPP_ENTITYDAMAGE1.toggle) then return end

	if not attacker:IsPlayer() then
		if IsValid(attacker.Owner) and IsValid(ent.Owner) then
			local cantouch, why = FPP.PlayerCanTouchEnt(attacker.Owner, ent, "EntityDamage1", "FPP_ENTITYDAMAGE1")
			if why then
				FPP.CanTouch(attacker.Owner, "FPP_ENTITYDAMAGE1", why, cantouch)
			end
			if not cantouch then
				dmginfo:SetDamage(0)
				ent.FPPAntiDamageWorld = ent.FPPAntiDamageWorld or 0
				ent.FPPAntiDamageWorld = ent.FPPAntiDamageWorld + 1
				timer.Simple(1, function()
					if not ent.FPPAntiDamageWorld then return end
					ent.FPPAntiDamageWorld = ent.FPPAntiDamageWorld - 1
					if ent.FPPAntiDamageWorld == 0 then
						ent.FPPAntiDamageWorld = nil
					end
				end)
			end
			return
		end

		if attacker == game.GetWorld() and ent.FPPAntiDamageWorld then
			dmginfo:SetDamage(0)
		end
		return
	end

	if not IsValid(ent) then return FPP.CanTouch(attacker, "FPP_ENTITYDAMAGE1", "Not valid!", false) end

	local cantouch, why = FPP.PlayerCanTouchEnt(attacker, ent, "EntityDamage1", "FPP_ENTITYDAMAGE1")
	if why /*and (not IsValid(attacker:GetActiveWeapon()) or (IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "weapon_physcannon")) */then
		FPP.CanTouch(attacker, "FPP_ENTITYDAMAGE1", why, cantouch)
	end

	if not cantouch then dmginfo:SetDamage(0) end
	return
end
hook.Add("EntityTakeDamage", "FPP.Protect.EntityTakeDamage", FPP.Protect.EntityDamage)

--Toolgun
local allweapons = {"weapon_crowbar", "weapon_physgun", "weapon_physcannon", "weapon_pistol", "weapon_stunstick", "weapon_357", "weapon_smg1",
	"weapon_ar2", "weapon_shotgun", "weapon_crossbow", "weapon_frag", "weapon_rpg", "gmod_camera", "gmod_tool", "weapon_bugbait"} --for advanced duplicator, you can't use any IsWeapon...
timer.Simple(5, function()
	for k,v in pairs(weapons.GetList()) do
		if v.ClassName then table.insert(allweapons, v.ClassName) end
	end
end)

local invalidToolData = {
	["model"] = {
		"*",
		"\\"
	},
	["material"] = {
		"*",
		"\\",
		" ",
		"effects/highfive_red"
	},
	["sound"] = {
		"?",
		" "
	},
	["soundname"] = {
		" ",
		"?"
	},
	["tracer"] = {
		"dof_node"
	},
	["door_class"] = {
		"env_laser"
	},
	-- Limit wheel torque
	["rx"] = 360,
	["ry"] = 360,
	["rz"] = 360
}

function FPP.Protect.CanTool(ply, trace, tool, ENT)
	-- Toolgun restrict

	if GravHull and not ENT then // Compatability with the Gravity Hull Designator, the creator hasn't yet implemented an override for util.TraceLine (which CanTool uses)
		trace = ply:GetEyeTrace() // However he has implemented one for player.GetEyeTrace, which for all intents and purposes will do the same thing.
		ENT = trace.Entity
	end

	local ignoreGeneralRestrictTool = false
	local SteamID = ply:SteamID()

	FPP.RestrictedToolsPlayers = FPP.RestrictedToolsPlayers or {}
	if FPP.RestrictedToolsPlayers[tool] and FPP.RestrictedToolsPlayers[tool][SteamID] ~= nil then--Player specific
		if FPP.RestrictedToolsPlayers[tool][SteamID] == false then
			FPP.CanTouch(ply, "FPP_TOOLGUN1", "Toolgun restricted for you!", false)
			return false
		elseif FPP.RestrictedToolsPlayers[tool][SteamID] == true then
			ignoreGeneralRestrictTool = true --If someone is allowed, then he's allowed even though he's not admin, so don't check for further restrictions
		end
	end

	if not ignoreGeneralRestrictTool then
		local Group = FPP.Groups[FPP.GroupMembers[SteamID]] or FPP.Groups[ply:GetNWString("usergroup")] or FPP.Groups.default  -- What group is the player in. If not in a special group, then he's in default group

		local CanGroup = true
		if Group and ((Group.allowdefault and table.HasValue(Group.tools, tool)) or -- If the tool is on the BLACKLIST or
			(not Group.allowdefault and not table.HasValue(Group.tools, tool))) then -- If the tool is NOT on the WHITELIST
			CanGroup = false
		end

		if FPP.RestrictedTools[tool] then
			if tonumber(FPP.RestrictedTools[tool].admin) == 1 and not ply:IsAdmin() then
				FPP.CanTouch(ply, "FPP_TOOLGUN1", "Toolgun restricted! Admin only!", false)
				return false
			elseif tonumber(FPP.RestrictedTools[tool].admin) == 2 and not ply:IsSuperAdmin() then
				FPP.CanTouch(ply, "FPP_TOOLGUN1", "Toolgun restricted! Superadmin only!", false)
				return false
			elseif (tonumber(FPP.RestrictedTools[tool].admin) == 1 and ply:IsAdmin()) or (tonumber(FPP.RestrictedTools[tool].admin) == 2 and ply:IsSuperAdmin()) then
				CanGroup = true -- If the person is not in the BUT has admin access, he should be able to use the tool
			end

			if FPP.RestrictedTools[tool]["team"] and #FPP.RestrictedTools[tool]["team"] > 0 and not table.HasValue(FPP.RestrictedTools[tool]["team"], ply:Team()) then
				FPP.CanTouch(ply, "FPP_TOOLGUN1", "Toolgun restricted! incorrect team!", false)
				return false
			end
		end

		if not CanGroup then
			FPP.CanTouch(ply, "FPP_TOOLGUN1", "Toolgun restricted! incorrect group!", false)
			return false
		end
	end

	-- Anti server crash
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().GetToolObject and ply:GetActiveWeapon():GetToolObject() then
		local tool = ply:GetActiveWeapon():GetToolObject()
		for t, block in pairs(invalidToolData) do
			local clientInfo = string.lower(tool:GetClientInfo(t) or "")
			-- Check for number limits
			if type(block) == "number" then
				local num = tonumber(clientInfo) or 0
				if num > block or num < -block then
					FPP.Notify(ply, "The client settings of the tool are invalid!", false)
					FPP.CanTouch(ply, "FPP_TOOLGUN1", "The client settings of the tool are invalid!", false)
					return false
				end
				continue
			end

			for _, item in pairs(block) do
				if string.find(clientInfo, item, 1, true) then
					FPP.Notify(ply, "The client settings of the tool are invalid!", false)
					FPP.CanTouch(ply, "FPP_TOOLGUN1", "The client settings of the tool are invalid!", false)
					return false
				end
			end
		end
	end

	local ent = ENT or trace.Entity

	if IsEntity(ent) and type(ent.CanTool) == "function" then
		local val = ent:CanTool(ply, trace, tool, ENT)
		if val ~= nil then return val end
	elseif IsEntity(ent) and ent.CanTool ~= nil then
		return ent.CanTool
	end

	if tobool(FPP.Settings.FPP_TOOLGUN1.toggle) and IsValid(ent) then

		local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Toolgun1", "FPP_TOOLGUN1")
		if why then
			FPP.CanTouch(ply, "FPP_TOOLGUN1", why, cantouch)
		end
		if not cantouch then return false end
	end

	if tool ~= "adv_duplicator" and tool ~= "duplicator" and tool ~= "advdupe2" then return end
	if not ENT and not FPP.AntiSpam.DuplicatorSpam(ply) then return false end

	if tool == "adv_duplicator" and ply:GetActiveWeapon():GetToolObject().Entities then
		for k,v in pairs(ply:GetActiveWeapon():GetToolObject().Entities) do
			if tobool(FPP.Settings.FPP_TOOLGUN1.duplicatenoweapons) and (not ply:IsAdmin() or (ply:IsAdmin() and not tobool(FPP.Settings.FPP_TOOLGUN1.spawnadmincanweapon))) then
				for c, d in pairs(allweapons) do
					if string.lower(v.Class) == string.lower(d) or string.find(v.Class:lower(), "ai_") == 1 or string.find(v.Class:lower(), "item_ammo_") == 1 then
						FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
						ply:GetActiveWeapon():GetToolObject().Entities[k] = nil
					end
				end
			end
			if tobool(FPP.Settings.FPP_TOOLGUN1.duplicatorprotect) and (not ply:IsAdmin() or (ply:IsAdmin() and not tobool(FPP.Settings.FPP_TOOLGUN1.spawnadmincanblocked))) then
				local setspawning = tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist)
				for c, d in pairs(FPP.Blocked.Spawning1) do
					if not tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist) and string.find(v.Class, d) then
						FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
						ply:GetActiveWeapon():GetToolObject().Entities[k] = nil
						break
					end
					if tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist) and string.find(v.Class, d) then -- if the whitelist is on you can't spawn it unless it's found
						setspawning = false
						break
					end
				end
				if setspawning then
					FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
					ply:GetActiveWeapon():GetToolObject().Entities[k] = nil
				end
			end
		end
		return --No further questions sir!
	end

	if tool == "advdupe2" and ply.AdvDupe2 and ply.AdvDupe2.Entities then
		for k,v in pairs(ply.AdvDupe2.Entities) do
			if tobool(FPP.Settings.FPP_TOOLGUN1.duplicatenoweapons) and (not ply:IsAdmin() or (ply:IsAdmin() and not tobool(FPP.Settings.FPP_TOOLGUN1.spawnadmincanweapon))) then
				for c, d in pairs(allweapons) do
					if string.lower(v.Class) == string.lower(d) or string.find(v.Class:lower(), "ai_") == 1 or string.find(v.Class:lower(), "item_ammo_") == 1 then
						FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
						ply.AdvDupe2.Entities[k] = nil
					end
				end
			end
			if tobool(FPP.Settings.FPP_TOOLGUN1.duplicatorprotect) and (not ply:IsAdmin() or (ply:IsAdmin() and not tobool(FPP.Settings.FPP_TOOLGUN1.spawnadmincanblocked))) then
				local setspawning = tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist)
				for c, d in pairs(FPP.Blocked.Spawning1) do
					if not tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist) and string.find(v.Class, d) then
						FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
						ply.AdvDupe2.Entities[k] = nil
						break
					end
					if tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist) and string.find(v.Class, d) then -- if the whitelist is on you can't spawn it unless it's found
						setspawning = false
						break
					end
				end
				if setspawning then
					FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
					ply.AdvDupe2.Entities[k] = nil
				end
			end
		end
		return --No further questions sir!
	end

	if tool == "duplicator" and ply:UniqueIDTable("Duplicator").Entities then
		local Ents = ply:UniqueIDTable("Duplicator").Entities
		for k,v in pairs(Ents) do
			if tobool(FPP.Settings.FPP_TOOLGUN1.duplicatenoweapons) and (not ply:IsAdmin() or (ply:IsAdmin() and not tobool(FPP.Settings.FPP_TOOLGUN1.spawnadmincanweapon))) then
				for c, d in pairs(allweapons) do
					if string.lower(v.Class) == string.lower(d) or string.find(v.Class:lower(), "ai_") == 1 or string.find(v.Class:lower(), "item_ammo_") == 1 then
						FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
						ply:UniqueIDTable("Duplicator").Entities[k] = nil
					end
				end
			end
			if tobool(FPP.Settings.FPP_TOOLGUN1.duplicatorprotect) and (not ply:IsAdmin() or (ply:IsAdmin() and not tobool(FPP.Settings.FPP_TOOLGUN1.spawnadmincanblocked))) then
				local setspawning = tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist)
				for c, d in pairs(FPP.Blocked.Spawning1) do
					if not tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist) and string.find(v.Class, d) then
						FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
						ply:UniqueIDTable("Duplicator").Entities[k] = nil
						break
					end
					if tobool(FPP.Settings.FPP_TOOLGUN1.spawniswhitelist) and string.find(v.Class, d) then -- if the whitelist is on you can't spawn it unless it's found
						FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
						setspawning = false
						break
					end
				end
				if setspawning then
					FPP.CanTouch(ply, "FPP_TOOLGUN1", "Duplicating blocked entity", false)
					ply:UniqueIDTable("Duplicator").Entities[k] = nil
				end
			end
		end
	end
	return
end
hook.Add("CanTool", "FPP.Protect.CanTool", FPP.Protect.CanTool)

function FPP.Protect.CanProperty(ply, property, ent)
	-- Use physgun because I'm way too lazy to make a new type
	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Physgun1", "FPP_PHYSGUN1")
	if why then
		FPP.CanTouch(ply, "FPP_PHYSGUN1", why, cantouch)
	end
	if not cantouch then return false end
end
hook.Add("CanProperty", "FPP.Protect.CanProperty", FPP.Protect.CanProperty)

function FPP.Protect.CanDrive(ply, ent)
	-- Use physgun because I'm way too lazy to make a new type
	local cantouch, why = FPP.PlayerCanTouchEnt(ply, ent, "Physgun1", "FPP_PHYSGUN1")
	if why then
		FPP.CanTouch(ply, "FPP_PHYSGUN1", why, cantouch)
	end
	if not cantouch then return false end
end
hook.Add("CanDrive", "FPP.Protect.CanDrive", FPP.Protect.CanDrive)

--Player disconnect, not part of the Protect table.
function FPP.PlayerDisconnect(ply)
	if IsValid(ply) and tobool(FPP.Settings.FPP_GLOBALSETTINGS1.cleanupdisconnected) and FPP.Settings.FPP_GLOBALSETTINGS1.cleanupdisconnectedtime then
		if ply:IsAdmin() and not tobool(FPP.Settings.FPP_GLOBALSETTINGS1.cleanupadmin) then return end

		FPP.DisconnectedPlayers[ply:SteamID()] = true

		local SteamID = ply:SteamID()
		timer.Simple(FPP.Settings.FPP_GLOBALSETTINGS1.cleanupdisconnectedtime, function()
			if not tobool(FPP.Settings.FPP_GLOBALSETTINGS1.cleanupdisconnected) then return end -- Settings can change in time.
			for k,v in pairs(player.GetAll()) do
				if v:SteamID() == SteamID then
					return
				end
			end
			for k,v in pairs(ents.GetAll()) do
				if IsValid(v) and v.OwnerID == SteamID then
					v:Remove()
				end
			end
			FPP.DisconnectedPlayers[SteamID] = nil -- Player out of the Disconnect table
		end)
	end
end
hook.Add("PlayerDisconnected", "FPP.PlayerDisconnect", FPP.PlayerDisconnect)

--PlayerInitialspawn, the props he had left before will now be his again
function FPP.PlayerInitialSpawn(ply)
	local RP = RecipientFilter()

	timer.Simple(5, function()
		if not IsValid(ply) then return end
		RP:AddAllPlayers()
		RP:RemovePlayer(ply)
		umsg.Start("FPP_CheckBuddy", RP)--Message everyone that a new player has joined
			umsg.Entity(ply)
		umsg.End()
	end)

	if FPP.DisconnectedPlayers[ply:SteamID()] then -- Check if the player has rejoined within the auto remove time
		for k,v in pairs(ents.GetAll()) do
			if IsValid(v) and v.OwnerID == ply:SteamID() then
				v.Owner = ply
			end
		end
	end
end
hook.Add("PlayerInitialSpawn", "FPP.PlayerInitialSpawn", FPP.PlayerInitialSpawn)

local ENTITY = FindMetaTable("Entity")
local backup = ENTITY.FireBullets
local blockedEffects = {"particleeffect", "smoke", "vortdispel", "helicoptermegabomb"}

function ENTITY:FireBullets(bullet, ...)
	if not bullet.TracerName then return backup(self, bullet, ...) end
	if table.HasValue(blockedEffects, string.lower(bullet.TracerName)) then
		bullet.TracerName = ""
	end
	return backup(self, bullet, ...)
end

hook.Add("EntityRemoved","jeepWorkaround",function(ent)
    if IsValid(ent) and ent:IsVehicle() and IsValid(ent:GetPassenger(1)) then
        ent:GetPassenger(1):ExitVehicle()
    end
end)