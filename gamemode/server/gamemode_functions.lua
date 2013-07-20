
/*---------------------------------------------------------------------------
DarkRP hooks
---------------------------------------------------------------------------*/
function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:PlayerBuyDoor( objPl, objEnt )
	return true;
end

function GM:PlayerSellDoor( objPl, objEnt )
	return false;
end

function GM:GetDoorCost( objPl, objEnt )
	return GAMEMODE.Config.doorcost ~= 0 and  GAMEMODE.Config.doorcost or 30;
end

function GM:GetVehicleCost( objPl, objEnt )
	return GAMEMODE.Config.vehiclecost ~= 0 and  GAMEMODE.Config.vehiclecost or 40;
end

function GM:CanChangeRPName(ply, RPname)
	if string.find(RPname, "\160") or string.find(RPname, " ") == 1 then -- disallow system spaces
		return false
	end

	if table.HasValue({"ooc", "shared", "world", "n/a", "world prop"}, RPname) then
		return false
	end
end

function GM:CanDemote(ply, target, reason)

end

function GM:CanVote(ply, vote)

end

function GM:PlayerWalletChanged(ply, amount)

end

function GM:PlayerGetSalary(ply, amount)

end

function GM:DarkRPVarChanged(ply, var, oldvar, newvalue)

end

function GM:PlayerBoughtVehicle(ply, ent, cost)

end

function GM:PlayerBoughtDoor(ply, ent, cost)

end

function GM:CanDropWeapon(ply, weapon)
	if not IsValid(weapon) then return false end
	local class = string.lower(weapon:GetClass())
	if self.Config.DisallowDrop[class] then return false end

	if not GAMEMODE.Config.restrictdrop then return true end

	for k,v in pairs(CustomShipments) do
		if v.entity ~= class then continue end

		return true
	end

	return false
end

function GM:DatabaseInitialized()
	FPP.Init()
	DarkRP.initDatabase()
end

function GM:CanSeeLogMessage(ply, message, colour)
	return ply:IsAdmin()
end

function GM:UpdatePlayerSpeed(ply)
	if ply:isArrested() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed)
	elseif ply:IsCP() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeedcp)
	else
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed)
	end
end

/*---------------------------------------------------------
 Gamemode functions
 ---------------------------------------------------------*/

function GM:PlayerSpawnProp(ply, model)
	-- If prop spawning is enabled or the user has admin or prop privileges
	local allowed = ((GAMEMODE.Config.propspawning or (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_prop")) or ply:IsAdmin()) and true) or false

	if ply:isArrested() then return false end
	model = string.gsub(tostring(model), "\\", "/")
	model = string.gsub(tostring(model), "//", "/")

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerSpawnProp then
		RPExtraTeams[ply:Team()].PlayerSpawnProp(ply, model)
	end

	if not allowed then return false end

	return self.BaseClass:PlayerSpawnProp(ply, model)
end

function GM:PlayerSpawnSENT(ply, model)
	if GAMEMODE.Config.adminsents then
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			GAMEMODE:Notify(ply, 1, 2, DarkRP.getPhrase("need_admin", "gm_spawnsent"))
			return
		end
	end
	return self.BaseClass:PlayerSpawnSENT(ply, model) and not ply:isArrested()
end

local function canSpawnWeapon(ply, class)
	if (not GAMEMODE.Config.adminweapons == 0 and ply:IsAdmin()) or
	(GAMEMODE.Config.adminweapons == 1 and ply:IsSuperAdmin()) then
		return true
	end
	GAMEMODE:Notify(ply, 1, 4, "You can't spawn weapons")

	return false
end

function GM:PlayerSpawnSWEP(ply, class, model)
	return canSpawnWeapon(ply, class) and self.BaseClass:PlayerSpawnSWEP(ply, class, model) and not ply:isArrested()
end

function GM:PlayerGiveSWEP(ply, class, model)
	return canSpawnWeapon(ply, class) and self.BaseClass:PlayerGiveSWEP(ply, class, model) and not ply:isArrested()
end

function GM:PlayerSpawnEffect(ply, model)
	return self.BaseClass:PlayerSpawnEffect(ply, model) and not ply:isArrested()
end

function GM:PlayerSpawnVehicle(ply, model)
	return self.BaseClass:PlayerSpawnVehicle(ply, model) and not ply:isArrested()
end

function GM:PlayerSpawnNPC(ply, model)
	if GAMEMODE.Config.adminnpcs and not ply:IsAdmin() then return false end

	return self.BaseClass:PlayerSpawnNPC(ply, model) and not ply:isArrested()
end

function GM:PlayerSpawnRagdoll(ply, model)
	return self.BaseClass:PlayerSpawnRagdoll(ply, model) and not ply:isArrested()
end

function GM:PlayerSpawnedProp(ply, model, ent)
	self.BaseClass:PlayerSpawnedProp(ply, model, ent)
	ent.SID = ply.SID
	ent:CPPISetOwner(ply)

	local phys = ent:GetPhysicsObject()
	if phys and phys:IsValid() then
		ent.RPOriginalMass = phys:GetMass()
	end

	if GAMEMODE.Config.proppaying then
		if ply:CanAfford(GAMEMODE.Config.propcost) then
			GAMEMODE:Notify(ply, 0, 4, "Deducted " .. GAMEMODE.Config.currency .. GAMEMODE.Config.propcost)
			ply:AddMoney(-GAMEMODE.Config.propcost)
		else
			GAMEMODE:Notify(ply, 1, 4, "Need " .. GAMEMODE.Config.currency .. GAMEMODE.Config.propcost)
			return false
		end
	end
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	self.BaseClass:PlayerSpawnedRagdoll(ply, model, ent)
	ent.SID = ply.SID
end

function GM:EntityRemoved(ent)
	self.BaseClass:EntityRemoved(ent)
	if ent:IsVehicle() then
		local found = ent:CPPIGetOwner()
		if IsValid(found) then
			found.Vehicles = found.Vehicles or 1
			found.Vehicles = found.Vehicles - 1
		end
	end

	for k,v in pairs(DarkRPEntities or {}) do
		if ent:IsValid() and ent:GetClass() == v.ent and ent.dt and IsValid(ent.dt.owning_ent) and not ent.IsRemoved then
			local ply = ent.dt.owning_ent
			local cmdname = string.gsub(v.ent, " ", "_")
			if not ply["max"..cmdname] then
				ply["max"..cmdname] = 1
			end
			ply["max"..cmdname] = ply["max"..cmdname] - 1
			ent.IsRemoved = true
		end
	end
end

function GM:ShowSpare1(ply)
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].ShowSpare1 then
		return RPExtraTeams[ply:Team()].ShowSpare1(ply)
	end
end

function GM:ShowSpare2(ply)
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].ShowSpare2 then
		return RPExtraTeams[ply:Team()].ShowSpare2(ply)
	end
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if ent then
		if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

		-- If it wasn't a player directly, find out who owns the prop that did the killing
		if not ent:IsPlayer() then
			ent = Player(tonumber(ent.SID) or 0)
		end

		-- If we know by now who killed the NPC, pay them.
		if IsValid(ent) and GAMEMODE.Config.npckillpay > 0 then
			ent:AddMoney(GAMEMODE.Config.npckillpay)
			GAMEMODE:Notify(ent, 0, 4, DarkRP.getPhrase("npc_killpay", GAMEMODE.Config.currency .. GAMEMODE.Config.npckillpay))
		end
	end
end

function GM:KeyPress(ply, code)
	self.BaseClass:KeyPress(ply, code)
end

local function IsInRoom(listener, talker) -- IsInRoom function to see if the player is in the same room.
	local tracedata = {}
	tracedata.start = talker:GetShootPos()
	tracedata.endpos = listener:GetShootPos()
	local trace = util.TraceLine(tracedata)

	return not trace.HitWorld
end

local threed = GM.Config.voice3D
local vrad = GM.Config.voiceradius
local dynv = GM.Config.dynamicvoice
-- proxy function to take load from PlayerCanHearPlayersVoice, which is called a quadratic amount of times per tick,
-- causing a lagfest when there are many players
local function calcPlyCanHearPlayerVoice(listener)
	listener.DrpCanHear = listener.DrpCanHear or {}
	for _, talker in pairs(player.GetAll()) do
		listener.DrpCanHear[talker] = not vrad or -- Voiceradius is off, everyone can hear everyone
			(listener:GetShootPos():Distance(talker:GetShootPos()) < 550 and -- voiceradius is on and the two are within hearing distance
				(not dynv or IsInRoom(listener, talker))) -- Dynamic voice is on and players are in the same room
	end
end
hook.Add("PlayerInitialSpawn", "DarkRPCanHearVoice", function(ply)
	timer.Create(ply:UserID() .. "DarkRPCanHearPlayersVoice", 0.5, 0, fn.Curry(calcPlyCanHearPlayerVoice, 2)(ply))
end)
hook.Add("PlayerDisconnected", "DarkRPCanHearVoice", function(ply)
	for k,v in pairs(player.GetAll()) do
		v.DrpCanHear[ply] = nil
	end
	timer.Destroy(ply:UserID() .. "DarkRPCanHearPlayersVoice")
end)

function GM:PlayerCanHearPlayersVoice(listener, talker)
	local canHear = listener.DrpCanHear and listener.DrpCanHear[talker]
	return canHear, threed
end

function GM:CanTool(ply, trace, mode)
	if not self.BaseClass:CanTool(ply, trace, mode) then return false end

	if IsValid(trace.Entity) then
		if trace.Entity.onlyremover then
			if mode == "remover" then
				return (ply:IsAdmin() or ply:IsSuperAdmin())
			else
				return false
			end
		end

		if trace.Entity.nodupe and (mode == "weld" or
					mode == "weld_ez" or
					mode == "spawner" or
					mode == "duplicator" or
					mode == "adv_duplicator") then
			return false
		end

		if trace.Entity:IsVehicle() and mode == "nocollide" and not GAMEMODE.Config.allowvnocollide then
			return false
		end
	end
	return true
end

function GM:CanPlayerSuicide(ply)
	if ply.IsSleeping then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("unable", "suicide", ""))
		return false
	end
	if ply:isArrested() then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("unable", "suicide", ""))
		return false
	end
	if GAMEMODE.Config.wantedsuicide and ply:getDarkRPVar("wanted") then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("unable", "suicide", ""))
		return false
	end

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].CanPlayerSuicide then
		return RPExtraTeams[ply:Team()].CanPlayerSuicide(ply)
	end
	return true
end

function GM:CanDrive(ply, ent)
	GAMEMODE:Notify(ply, 1, 4, "Drive disabled for now.")
	return false -- Disabled until people can't minge with it anymore
end

local allowedProperty = {
	remover = true,
	ignite = false,
	extinguish = true,
	keepupright = true,
	gravity = true,
	collision = true,
	skin = true,
	bodygroups = true
}
function GM:CanProperty(ply, property, ent)
	if allowedProperty[property] and ent:CPPICanTool(ply, "remover") then
		return true
	end

	if property == "persist" and ply:IsSuperAdmin() then
		return true
	end
	GAMEMODE:Notify(ply, 1, 4, "Property disabled for now.")
	return false -- Disabled until antiminge measure is found
end

function GM:PlayerShouldTaunt(ply, actid)
	return false
end

function GM:DoPlayerDeath(ply, attacker, dmginfo, ...)
	local weapon = ply:GetActiveWeapon()
	local canDrop = hook.Call("CanDropWeapon", self, ply, weapon)

	if GAMEMODE.Config.dropweapondeath and IsValid(weapon) and canDrop then
		ply:DropDRPWeapon(weapon)
	end
	self.BaseClass:DoPlayerDeath(ply, attacker, dmginfo, ...)
end

function GM:PlayerDeath(ply, weapon, killer)
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerDeath then
		RPExtraTeams[ply:Team()].PlayerDeath(ply, weapon, killer)
	end

	if GAMEMODE.Config.deathblack then
		SendUserMessage("blackScreen", ply, true)
	end

	if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end

	if GAMEMODE.Config.showdeaths then
		self.BaseClass:PlayerDeath(ply, weapon, killer)
	end

	ply:Extinguish()

	if ply:InVehicle() then ply:ExitVehicle() end

	if ply:isArrested() and not GAMEMODE.Config.respawninjail  then
		-- If the player died in jail, make sure they can't respawn until their jail sentance is over
		ply.NextSpawnTime = CurTime() + math.ceil(GAMEMODE.Config.jailtimer - (CurTime() - ply.LastJailed)) + 1
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, DarkRP.getPhrase("died_in_jail", ply:Nick()))
		end
		GAMEMODE:Notify(ply, 4, 4, DarkRP.getPhrase("dead_in_jail"))
	else
		-- Normal death, respawning.
		ply.NextSpawnTime = CurTime() + math.Clamp(GAMEMODE.Config.respawntime, 0, 10)
	end
	ply.DeathPos = ply:GetPos()

	if GAMEMODE.Config.dropmoneyondeath then
		local amount = GAMEMODE.Config.deathfee
		if not ply:CanAfford(GAMEMODE.Config.deathfee) then
			amount = ply:getDarkRPVar("money")
		end

		if amount > 0 then
			ply:AddMoney(-amount)
			DarkRPCreateMoneyBag(ply:GetPos(), amount)
		end
	end

	if IsValid(ply) and (ply ~= killer or ply.Slayed) and not ply:isArrested() then
		ply:SetDarkRPVar("wanted", false)
		ply.DeathPos = nil
		ply.Slayed = false
	end

	ply:GetTable().ConfiscatedWeapons = nil

	local KillerName = (killer:IsPlayer() and killer:Nick()) or tostring(killer)

	local WeaponName = IsValid(weapon) and ((weapon:IsPlayer() and IsValid(weapon:GetActiveWeapon()) and weapon:GetActiveWeapon():GetClass()) or weapon:GetClass()) or "unknown"
	if IsValid(weapon) and weapon:GetClass() == "prop_physics" then
		WeaponName = weapon:GetClass() .. " (" .. (weapon:GetModel() or "unknown") .. ")"
	end

	if killer == ply then
		KillerName = "Himself"
		WeaponName = "suicide trick"
	end

	DB.Log(ply:Nick() .. " was killed by " .. KillerName .. " with a " .. WeaponName, nil, Color(255, 190, 0))
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	if ply:isArrested() then return false end
	if weapon.PlayerUse == false then return false end
	if ply:IsAdmin() and GAMEMODE.Config.AdminsCopWeapons then return true end

	if GAMEMODE.Config.license and not ply:getDarkRPVar("HasGunlicense") and not ply:GetTable().RPLicenseSpawn then
		if GAMEMODE.NoLicense[string.lower(weapon:GetClass())] or not weapon:IsWeapon() then
			return true
		end
		return false
	end

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerCanPickupWeapon then
		RPExtraTeams[ply:Team()].PlayerCanPickupWeapon(ply, weapon)
	end
	return true
end

local function removelicense(ply)
	if not IsValid(ply) then return end
	ply:GetTable().RPLicenseSpawn = false
end

local function SetPlayerModel(ply, cmd, args)
	if not args[1] then return end
	ply.rpChosenModel = args[1]
end
concommand.Add("_rp_ChosenModel", SetPlayerModel)

function GM:PlayerSetModel(ply)
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerSetModel then
		return RPExtraTeams[ply:Team()].PlayerSetModel(ply)
	end

	local EndModel = ""
	if GAMEMODE.Config.enforceplayermodel then
		local TEAM = RPExtraTeams[ply:Team()]
		if not TEAM then return end

		if type(TEAM.model) == "table" then
			local ChosenModel = ply.rpChosenModel or ply:GetInfo("rp_playermodel")
			ChosenModel = string.lower(ChosenModel)

			local found
			for _,Models in pairs(TEAM.model) do
				if ChosenModel == string.lower(Models) then
					EndModel = Models
					found = true
					break
				end
			end

			if not found then
				EndModel = TEAM.model[math.random(#TEAM.model)]
			end
		else
			EndModel = TEAM.model
		end

		ply:SetModel(EndModel)
	else
		local cl_playermodel = ply:GetInfo("cl_playermodel")
        local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
        ply:SetModel( modelname )
	end
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply)
	DB.Log(ply:Nick().." ("..ply:SteamID()..") has joined the game", nil, Color(0, 130, 255))
	ply.bannedfrom = {}
	ply.DarkRPVars = ply.DarkRPVars or {}
	ply:NewData()
	ply.SID = ply:UserID()

	for k,v in pairs(ents.GetAll()) do
		if IsValid(v) and v.deleteSteamID == ply:SteamID() and v.dt then
			v.SID = ply.SID
			if v.Setowning_ent then
				v:Setowning_ent(ply)
			end
			v.deleteSteamID = nil
			timer.Destroy("Remove"..v:EntIndex())
			ply["max"..v:GetClass()] = (ply["max"..v:GetClass()] or 0) + 1
			if v.dt and v.Setowning_ent then v:Setowning_ent(ply) end
		end
	end
end

local function formatDarkRPValue(value)
	if value == nil then return "nil" end

	if isentity(value) and not IsValid(value) then return "NULL" end
	if isentity(value) and value:IsPlayer() then return string.format("Entity [%s][Player]", value:EntIndex()) end

	return tostring(value)
end

local meta = FindMetaTable("Player")
function meta:SetDarkRPVar(var, value, target)
	if not IsValid(self) then return end
	target = target or RecipientFilter():AddAllPlayers()

	hook.Call("DarkRPVarChanged", nil, self, var, (self.DarkRPVars and self.DarkRPVars[var]) or nil, value)

	self.DarkRPVars = self.DarkRPVars or {}
	self.DarkRPVars[var] = value

	value = formatDarkRPValue(value)

	umsg.Start("DarkRP_PlayerVar", target)
		-- The index because the player handle might not exist clientside yet
		umsg.Short(self:EntIndex())
		umsg.String(var)
		umsg.String(value)
	umsg.End()
end

function meta:SetSelfDarkRPVar(var, value)
	self.privateDRPVars = self.privateDRPVars or {}
	self.privateDRPVars[var] = true

	self:SetDarkRPVar(var, value, self)
end

function meta:getDarkRPVar(var)
	self.DarkRPVars = self.DarkRPVars or {}
	return self.DarkRPVars[var]
end

local function SendDarkRPVars(ply)
	if ply.DarkRPVarsSent and ply.DarkRPVarsSent > (CurTime() - 1) then return end --prevent spammers
	ply.DarkRPVarsSent = CurTime()

	local sendtable = {}
	for k,v in pairs(player.GetAll()) do
		sendtable[v] = {}
		for a,b in pairs(v.DarkRPVars or {}) do
			if not (v.privateDRPVars or {})[a] or ply == v then
				sendtable[v][a] = b
			end
		end
	end
	net.Start("DarkRP_InitializeVars")
		net.WriteTable(sendtable)
	net.Send(ply)
end
concommand.Add("_sendDarkRPvars", SendDarkRPVars)

local function refreshDoorData(ply, _, args)
	if ply.DoorDataSent and ply.DoorDataSent > (CurTime() - 0.5) then return end
	ply.DoorDataSent = CurTime()

	local ent = Entity(tonumber(args[1]) or -1)
	if not IsValid(ent) or not ent.DoorData then return end

	net.Start("DarkRP_DoorData")
		net.WriteEntity(ent)
		net.WriteTable(ent.DoorData)
	net.Send(ply)
	ply.DRP_DoorMemory = ply.DRP_DoorMemory or {}
	ply.DRP_DoorMemory[ent] = table.Copy(ent.DoorData)
end
concommand.Add("_RefreshDoorData", refreshDoorData)

function GM:PlayerSelectSpawn(ply)
	local spawn = self.BaseClass:PlayerSelectSpawn(ply)

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerSelectSpawn then
		RPExtraTeams[ply:Team()].PlayerSelectSpawn(ply, spawn)
	end

	local POS
	if spawn and spawn.GetPos then
		POS = spawn:GetPos()
	else
		POS = ply:GetPos()
	end

	local CustomSpawnPos = DB.RetrieveTeamSpawnPos(ply)
	if GAMEMODE.Config.customspawns and not ply:isArrested() and CustomSpawnPos then
		POS = CustomSpawnPos[math.random(1, #CustomSpawnPos)]
	end

	-- Spawn where died in certain cases
	if GAMEMODE.Config.strictsuicide and ply:GetTable().DeathPos then
		POS = ply:GetTable().DeathPos
	end

	if ply:isArrested() then
		POS = DB.RetrieveJailPos() or ply:GetTable().DeathPos -- If we can't find a jail pos then we'll use where they died as a last resort
	end

	-- Make sure the player doesn't get stuck in something
	POS = GAMEMODE:FindEmptyPos(POS, {ply}, 600, 30, Vector(16, 16, 64))

	return spawn, POS
end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)

	player_manager.SetPlayerClass(ply, "player_DarkRP")

	ply:SetNoCollideWithTeammates(false)
	ply:CrosshairEnable()
	ply:UnSpectate()
	ply:SetHealth(tonumber(GAMEMODE.Config.startinghealth) or 100)

	if not GAMEMODE.Config.showcrosshairs then
		ply:CrosshairDisable()
	end

	-- Kill any colormod
	SendUserMessage("blackScreen", ply, false)

	if GAMEMODE.Config.babygod and not ply.IsSleeping and not ply.Babygod then
		timer.Destroy(ply:EntIndex() .. "babygod")

		ply.Babygod = true
		ply:GodEnable()
		local c = ply:GetColor()
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
		ply:SetColor(Color(c.r, c.g, c.b, 100))
		ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
		timer.Create(ply:EntIndex() .. "babygod", GAMEMODE.Config.babygodtime or 0, 1, function()
			if not IsValid(ply) or not ply.Babygod then return end
			ply.Babygod = nil
			ply:SetColor(Color(c.r, c.g, c.b, c.a))
			ply:GodDisable()
			ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		end)
	end
	ply.IsSleeping = false

	GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed)
	if ply:IsCP() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeedcp)
	end

	if ply:isArrested() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed)
	end

	ply:Extinguish()
	if ply:GetActiveWeapon() and IsValid(ply:GetActiveWeapon()) then
		ply:GetActiveWeapon():Extinguish()
	end

	for k,v in pairs(ents.FindByClass("predicted_viewmodel")) do -- Money printer ignite fix
		v:Extinguish()
	end

	if ply.demotedWhileDead then
		ply.demotedWhileDead = nil
		ply:ChangeTeam(GAMEMODE.DefaultTeam)
	end

	ply:GetTable().StartHealth = ply:Health()
	gamemode.Call("PlayerSetModel", ply)
	gamemode.Call("PlayerLoadout", ply)

	local _, pos = self:PlayerSelectSpawn(ply)
	ply:SetPos(pos)

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerSpawn then
		RPExtraTeams[ply:Team()].PlayerSpawn(ply)
	end

	ply:AllowFlashlight(true)
	DB.Log(ply:Nick().." ("..ply:SteamID()..") spawned")
end

local function selectDefaultWeapon(ply)
	-- Switch to prefered weapon if they have it
	local cl_defaultweapon = ply:GetInfo("cl_defaultweapon")

	if ply:HasWeapon(cl_defaultweapon) then
		ply:SelectWeapon(cl_defaultweapon)
	end
end

function GM:OnPlayerChangedTeam(ply, oldTeam, newTeam)
end

function GM:PlayerLoadout(ply)
	if ply:isArrested() then return end

	player_manager.RunClass(ply, "Spawn")

	ply:GetTable().RPLicenseSpawn = true
	timer.Simple(1, function() removelicense(ply) end)

	local Team = ply:Team() or 1

	if not RPExtraTeams[Team] then return end
	for k,v in pairs(RPExtraTeams[Team].weapons or {}) do
		ply:Give(v)
	end

	if RPExtraTeams[ply:Team()].PlayerLoadout then
		local val = RPExtraTeams[ply:Team()].PlayerLoadout(ply)
		if val == true then
			selectDefaultWeapon(ply)
			return
		end
	end

	for k, v in pairs(self.Config.DefaultWeapons) do
		ply:Give(v)
	end

	if (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_tool")) or ply:IsAdmin()  then
		ply:Give("gmod_tool")
	end

	if (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_tool")) or ply:IsAdmin() then
		ply:Give("weapon_keypadchecker")
	end

	if ply:HasPriv("rp_commands") and GAMEMODE.Config.AdminsCopWeapons then
		ply:Give("door_ram")
		ply:Give("arrest_stick")
		ply:Give("unarrest_stick")
		ply:Give("stunstick")
		ply:Give("weaponchecker")
	end

	selectDefaultWeapon(ply)
end

local function removeDelayed(ent, ply)
	local removedelay = GAMEMODE.Config.entremovedelay

	ent.deleteSteamID = ply:SteamID()
	timer.Create("Remove"..ent:EntIndex(), removedelay, 1, function()
		for _, pl in pairs(player.GetAll()) do
			if IsValid(pl) and IsValid(ent) and pl:SteamID() == ent.deleteSteamID then
				ent.SID = pl.SID
				ent.deleteSteamID = nil
				return
			end
		end

		SafeRemoveEntity(ent)
	end)
end

function GM:PlayerDisconnected(ply)
	self.BaseClass:PlayerDisconnected(ply)
	timer.Destroy(ply:SteamID() .. "jobtimer")
	timer.Destroy(ply:SteamID() .. "propertytax")

	for k, v in pairs(ents.GetAll()) do
		local class = v:GetClass()
		for _, customEnt in pairs(DarkRPEntities) do
			if class == customEnt.ent and v.SID == ply.SID then
				removeDelayed(v, ply)
				break
			end
		end
		if v:IsVehicle() and v.SID == ply.SID then
			removeDelayed(v, ply)
		end
	end

	local isMayor = RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].mayor
	if isMayor then
		for _, ent in pairs(ply.lawboards or {}) do
			if IsValid(ent) then
				removeDelayed(ent, ply)
			end
		end
	end

	GAMEMODE.vote.DestroyVotesWithEnt(ply)

	if isMayor and tobool(GetConVarNumber("DarkRP_LockDown")) then -- Stop the lockdown
		GAMEMODE:UnLockdown(ply)
	end

	if IsValid(ply.SleepRagdoll) then
		ply.SleepRagdoll:Remove()
	end

	ply:UnownAll()
	DB.Log(ply:Nick().." ("..ply:SteamID()..") disconnected", nil, Color(0, 130, 255))

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerDisconnected then
		RPExtraTeams[ply:Team()].PlayerDisconnected(ply)
	end
end

local function PlayerDoorCheck()
	for k, ply in pairs(player.GetAll()) do
		local trace = ply:GetEyeTrace()
		if IsValid(trace.Entity) and (trace.Entity:IsDoor() or trace.Entity:IsVehicle()) and ply.LookingAtDoor ~= trace.Entity and trace.HitPos:Distance(ply:GetShootPos()) < 410 then
			ply.LookingAtDoor = trace.Entity -- Variable that prevents streaming to clients every frame

			trace.Entity.DoorData = trace.Entity.DoorData or {}

			local DoorString = "Data:\n"
			for key, v in pairs(trace.Entity.DoorData) do
				DoorString = DoorString .. key.."\t\t".. tostring(v) .. "\n"
			end

			if not ply.DRP_DoorMemory or not ply.DRP_DoorMemory[trace.Entity] then
				net.Start("DarkRP_DoorData")
					net.WriteEntity(trace.Entity)
					net.WriteTable(trace.Entity.DoorData)
				net.Send(ply)
				ply.DRP_DoorMemory = ply.DRP_DoorMemory or {}
				ply.DRP_DoorMemory[trace.Entity] = table.Copy(trace.Entity.DoorData)
			else
				for key, v in pairs(trace.Entity.DoorData) do
					if not ply.DRP_DoorMemory[trace.Entity][key] or ply.DRP_DoorMemory[trace.Entity][key] ~= v then
						ply.DRP_DoorMemory[trace.Entity][key] = v
						umsg.Start("DRP_UpdateDoorData", ply)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String(tostring(v))
						umsg.End()
					end
				end

				for key, v in pairs(ply.DRP_DoorMemory[trace.Entity]) do
					if not trace.Entity.DoorData[key] then
						ply.DRP_DoorMemory[trace.Entity][key] = nil
						umsg.Start("DRP_UpdateDoorData", ply)
							umsg.Entity(trace.Entity)
							umsg.String(key)
							umsg.String("nil")
						umsg.End()
					end
				end
			end
		elseif ply.LookingAtDoor ~= trace.Entity then
			ply.LookingAtDoor = nil
		end
	end
end
timer.Create("RP_DoorCheck", 0.1, 0, PlayerDoorCheck)

function GM:GetFallDamage( ply, flFallSpeed )
	if GetConVarNumber("mp_falldamage") == 1 then
		return flFallSpeed / 15
	end
	return 10
end

local InitPostEntityCalled = false
function GM:InitPostEntity()
	InitPostEntityCalled = true

	local physData = physenv.GetPerformanceSettings()
	physData.MaxVelocity = 2000
	physData.MaxAngularVelocity	= 3636

	physenv.SetPerformanceSettings(physData)

	-- Scriptenforcer enabled by default? Fuck you, not gonna happen.
	game.ConsoleCommand("sv_allowcslua 1\n")
	game.ConsoleCommand("physgun_DampingFactor 0.9\n")
	game.ConsoleCommand("sv_sticktoground 0\n")
	game.ConsoleCommand("sv_airaccelerate 100\n")

	for k, v in pairs(ents.GetAll()) do
		local class = v:GetClass()
		if GAMEMODE.Config.unlockdoorsonstart and v:IsDoor() then
			v:Fire("unlock", "", 0)
		end
    end

    self:ReplaceChatHooks()
end
timer.Simple(0.1, function()
	if not InitPostEntityCalled then
		GAMEMODE:InitPostEntity()
	end
end)

function GM:PlayerLeaveVehicle(ply, vehicle)
	if GAMEMODE.Config.autovehiclelock and vehicle:OwnedBy(ply) then
		vehicle:KeysLock()
	end
	self.BaseClass:PlayerLeaveVehicle(ply, vehicle)
end

local function ClearDecals()
	if GAMEMODE.Config.decalcleaner then
		for _, p in pairs( player.GetAll() ) do
			p:ConCommand("r_cleardecals")
		end
	end
end
timer.Create("RP_DecalCleaner", GM.Config.decaltimer, 0, ClearDecals)

function GM:PlayerSpray()

	return not GAMEMODE.Config.allowsprays
end

function GM:PlayerNoClip(ply)
	-- Default action for noclip is to disallow it
	return false
end
