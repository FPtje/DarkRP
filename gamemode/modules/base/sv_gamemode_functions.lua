/*---------------------------------------------------------------------------
fprp hooks
---------------------------------------------------------------------------*/
function GM:Initialize()
	self.BaseClass:Initialize();
end

function GM:playerBuyDoor(ply, ent)
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].hobo then
		return false, fprp.getPhrase("door_hobo_unable");
	end

	return true
end

function GM:getDoorCost(ply, ent)
	return GAMEMODE.Config.doorcost ~= 0 and GAMEMODE.Config.doorcost or 30
end

function GM:getVehicleCost(ply, ent)
	return GAMEMODE.Config.vehiclecost ~= 0 and  GAMEMODE.Config.vehiclecost or 40
end

local disallowedNames = {["ooc"] = true, ["shared"] = true, ["world"] = true, ["world prop"] = true}
function GM:CanChangeRPName(ply, RPname)
	if disallowedNames[string.lower(RPname)] then return false, "Forbidden name." end
	if not string.match(RPname, "^[a-zA-Z0-9 ]+$") then return false, "Illegal characters." end

	local len = string.len(RPname);
	if len > 30 then return false, "Too long." end
	if len < 3 then return false, "Too short." end
end

function GM:canDemote(ply, target, reason)

end

function GM:canVote(ply, vote)

end

function GM:playerWalletChanged(ply, amount)

end

function GM:playerGetSalary(ply, amount)

end

function GM:fprpVarChanged(ply, var, oldvar, newvalue)

end

function GM:playerBoughtVehicle(ply, ent, cost)

end

function GM:playerBoughtDoor(ply, ent, cost)

end

function GM:canDropWeapon(ply, weapon)
	if not IsValid(weapon) then return false end
	local class = string.lower(weapon:GetClass());
	local team = ply:Team();

	if not GAMEMODE.Config.dropspawnedweapons then
	if RPExtraTeams[team] and RPExtraTeams[team].weapons and table.HasValue(RPExtraTeams[team].weapons, class) then return false end
	end

	if self.Config.DisallowDrop[class] then return false end

	if not GAMEMODE.Config.restrictdrop then return true end

	for k,v in pairs(CustomShipments) do
		if v.entity ~= class then continue end

		return true
	end

	return false
end

function GM:DatabaseInitialized()
	fprp.initDatabase();
end

function GM:canSeeLogMessage(ply, message, colour)
	return ply:hasfprpPrivilege("rp_viewlog") or ply:IsAdmin();
end

function GM:UpdatePlayerSpeed(ply)
	if ply:isArrested() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed);
	elseif ply:isCP() then
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeedcp);
	else
		GAMEMODE:SetPlayerSpeed(ply, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed);
	end
end

/*---------------------------------------------------------
 Gamemode functions
 ---------------------------------------------------------*/

function GM:PlayerSpawnProp(ply, model)
	-- If prop spawning is enabled or the user has admin or prop privileges
	local allowed = ((GAMEMODE.Config.propspawning or (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_prop")) or ply:IsAdmin()) and true) or false

	if ply:isArrested() then return false end
	model = string.gsub(tostring(model), "\\", "/");
	model = string.gsub(tostring(model), "//", "/");

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerSpawnProp then
		RPExtraTeams[ply:Team()].PlayerSpawnProp(ply, model);
	end

	if not allowed then return false end

	return self.BaseClass:PlayerSpawnProp(ply, model);
end

function GM:PlayerSpawnedProp(ply, model, ent)
	self.BaseClass:PlayerSpawnedProp(ply, model, ent);
	ent.SID = ply.SID
	ent:CPPISetOwner(ply);

	local phys = ent:GetPhysicsObject();
	if phys and phys:IsValid() then
		ent.RPOriginalMass = phys:GetMass();
	end

	if GAMEMODE.Config.proppaying then
		if ply:canAfford(GAMEMODE.Config.propcost) then
			fprp.notify(ply, 0, 4, fprp.getPhrase("deducted_shekel", fprp.formatshekel(GAMEMODE.Config.propcost)));
			ply:addshekel(-GAMEMODE.Config.propcost);
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("need_shekel", fprp.formatshekel(GAMEMODE.Config.propcost)));
			SafeRemoveEntity(ent);
			return false
		end
	end
end


local function checkAdminSpawn(ply, configVar, errorStr)
	local config = GAMEMODE.Config[configVar]

	if (config == true or config == 1) and ply:EntIndex() ~= 0 and not ply:IsAdmin() then
		fprp.notify(ply, 1, 5, fprp.getPhrase("need_admin", fprp.getPhrase(errorStr) or errorStr));
		return false
	elseif config == 2 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		fprp.notify(ply, 1, 5, fprp.getPhrase("need_sadmin", fprp.getPhrase(errorStr) or errorStr));
		return false
	elseif config == 3 and ply:EntIndex() ~= 0 then
		fprp.notify(ply, 1, 5, fprp.getPhrase("disabled", fprp.getPhrase(errorStr) or errorStr, fprp.getPhrase("see_settings")));
		return false
	end

	return true
end

function GM:PlayerSpawnSENT(ply, class)
	return true
end

function GM:PlayerSpawnedSENT(ply, ent)
	self.BaseClass:PlayerSpawnedSENT(ply, ent);
	fprp.log(ply:Nick().." ("..ply:SteamID()..") spawned SENT "..ent:GetClass(), Color(255, 255, 0));
end

local function canSpawnWeapon(ply)
	if (GAMEMODE.Config.adminweapons == 0 and ply:IsAdmin()) or
	(GAMEMODE.Config.adminweapons == 1 and ply:IsSuperAdmin()) then
		return true
	end
	fprp.notify(ply, 1, 4, fprp.getPhrase("cant_spawn_weapons"));

	return false
end

function GM:PlayerSpawnSWEP(ply, class, info)
	return true
end

function GM:PlayerGiveSWEP(ply, class, info)
	return true
end

function GM:PlayerSpawnEffect(ply, model)
	return self.BaseClass:PlayerSpawnEffect(ply, model) and not ply:isArrested();
end

function GM:PlayerSpawnVehicle(ply, model, class, info)
	return true
end

function GM:PlayerSpawnedVehicle(ply, ent)
	self.BaseClass:PlayerSpawnedVehicle(ply, ent);
	fprp.log(ply:Nick().." ("..ply:SteamID()..") spawned Vehicle "..ent:GetClass(), Color(255, 255, 0));
end

function GM:PlayerSpawnNPC(ply, type, weapon)
	return checkAdminSpawn(ply, "adminnpcs", "gm_spawnnpc") and self.BaseClass:PlayerSpawnNPC(ply, type, weapon) and not ply:isArrested();
end

function GM:PlayerSpawnedNPC(ply, ent)
	self.BaseClass:PlayerSpawnedNPC(ply, ent);
	fprp.log(ply:Nick().." ("..ply:SteamID()..") spawned NPC "..ent:GetClass(), Color(255, 255, 0));
end

function GM:PlayerSpawnRagdoll(ply, model)
	return self.BaseClass:PlayerSpawnRagdoll(ply, model) and not ply:isArrested();
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	self.BaseClass:PlayerSpawnedRagdoll(ply, model, ent);
	ent.SID = ply.SID
end

function GM:EntityRemoved(ent)
	self.BaseClass:EntityRemoved(ent);
	if ent:IsVehicle() then
		local found = ent:CPPIGetOwner();
		if IsValid(found) then
			found.Vehicles = found.Vehicles or 1
			found.Vehicles = found.Vehicles - 1
		end
	end

	local owner = ent.Getowning_ent and ent:Getowning_ent() or Player(ent.SID or 0);
	if ent.fprpItem and IsValid(owner) then owner:removeCustomEntity(ent.fprpItem) end
	if ent.isKeysOwnable and ent:isKeysOwnable() then ent:removeDoorData() end
end

function GM:ShowSpare1(ply)
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].ShowSpare1 then
		return RPExtraTeams[ply:Team()].ShowSpare1(ply);
	end
end

function GM:ShowSpare2(ply)
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].ShowSpare2 then
		return RPExtraTeams[ply:Team()].ShowSpare2(ply);
	end
end

function GM:ShowTeam(ply)
end

function GM:ShowHelp(ply)
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if not ent then return end

	if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

	-- If it wasn't a player directly, find out who owns the prop that did the killing
	if not ent:IsPlayer() then
		ent = Player(tonumber(ent.SID) or 0);
	end

	-- If we know by now who killed the NPC, pay them.
	if IsValid(ent) and GAMEMODE.Config.npckillpay > 0 then
		ent:addshekel(GAMEMODE.Config.npckillpay);
		fprp.notify(ent, 0, 4, fprp.getPhrase("npc_killpay", fprp.formatshekel(GAMEMODE.Config.npckillpay)));
	end
end

function GM:KeyPress(ply, code)
	self.BaseClass:KeyPress(ply, code);
end

local function IsInRoom(listener, talker) -- IsInRoom function to see if the player is in the same room.
	local tracedata = {}
	tracedata.start = talker:GetShootPos();
	tracedata.endpos = listener:GetShootPos();
	local trace = util.TraceLine(tracedata);

	return not trace.HitWorld
end

local threed = GM.Config.voice3D
local vrad = GM.Config.voiceradius
local dynv = GM.Config.dynamicvoice
-- proxy function to take load from PlayerCanHearPlayersVoice, which is called a quadratic amount of times per tick,
-- causing a lagfest when there are many players
local function calcPlyCanHearPlayerVoice(listener)
	if not IsValid(listener) then return end
	listener.DrpCanHear = listener.DrpCanHear or {}
	for _, talker in pairs(player.GetAll()) do
		listener.DrpCanHear[talker] = not vrad or -- Voiceradius is off, everyone can hear everyone
			(listener:GetShootPos():DistToSqr(talker:GetShootPos()) < 302500 and -- voiceradius is on and the two are within hearing distance
				(not dynv or IsInRoom(listener, talker))) -- Dynamic voice is on and players are in the same room
	end
end
hook.Add("PlayerInitialSpawn", "fprpCanHearVoice", function(ply)
	timer.Create(ply:UserID() .. "fprpCanHearPlayersVoice", 0.5, 0, fn.Curry(calcPlyCanHearPlayerVoice, 2)(ply));
end);
hook.Add("PlayerDisconnected", "fprpCanHearVoice", function(ply)
	if not ply.DrpCanHear then return end
	for k,v in pairs(player.GetAll()) do
		if not v.DrpCanHear then continue end
		v.DrpCanHear[ply] = nil
	end
	timer.Destroy(ply:UserID() .. "fprpCanHearPlayersVoice");
end);

function GM:PlayerCanHearPlayersVoice(listener, talker)
	local canHear = listener.DrpCanHear and listener.DrpCanHear[talker]
	return canHear, threed
end

function GM:CanTool(ply, trace, mode)
	if not self.BaseClass:CanTool(ply, trace, mode) then return false end

	if IsValid(trace.Entity) then
		if trace.Entity.onlyremover then
			if mode == "remover" then
				return (ply:IsAdmin() or ply:IsSuperAdmin());
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
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "suicide", ""));
		return false
	end
	if ply:isArrested() then
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "suicide", ""));
		return false
	end
	if GAMEMODE.Config.wantedsuicide and ply:getfprpVar("wanted") then
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "suicide", ""));
		return false
	end

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].CanPlayerSuicide then
		return RPExtraTeams[ply:Team()].CanPlayerSuicide(ply);
	end
	return true
end

function GM:CanDrive(ply, ent)
	fprp.notify(ply, 1, 4, fprp.getPhrase("drive_disabled"));
	return false -- Disabled until people can't minge with it anymore
end

function GM:CanProperty(ply, property, ent)
	if self.Config.allowedProperties[property] and ent:CPPICanTool(ply, "remover") then
		return true
	end

	if property == "persist" and ply:IsSuperAdmin() then
		return true
	end
	fprp.notify(ply, 1, 4, fprp.getPhrase("property_disabled"));
	return false -- Disabled until antiminge measure is found
end

function GM:PlayerShouldTaunt(ply, actid)
	return false
end

function GM:DoPlayerDeath(ply, attacker, dmginfo, ...)
	local weapon = ply:GetActiveWeapon();
	local canDrop = hook.Call("canDropWeapon", self, ply, weapon);

	if GAMEMODE.Config.dropweapondeath and IsValid(weapon) and canDrop then
		ply:dropDRPWeapon(weapon);
	end
	self.BaseClass:DoPlayerDeath(ply, attacker, dmginfo, ...);
end

function GM:PlayerDeath(ply, weapon, killer)
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerDeath then
		RPExtraTeams[ply:Team()].PlayerDeath(ply, weapon, killer);
	end

	if GAMEMODE.Config.deathblack then
		SendUserMessage("blackScreen", ply, true);
	end

	if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end

	if GAMEMODE.Config.showdeaths then
		self.BaseClass:PlayerDeath(ply, weapon, killer);
	end

	ply:Extinguish();

	if ply:InVehicle() then ply:ExitVehicle() end

	if ply:isArrested() and not GAMEMODE.Config.respawninjail  then
		-- If the player died in jail, make sure they can't respawn until their jail sentance is over
		ply.NextSpawnTime = CurTime() + math.ceil(GAMEMODE.Config.jailtimer - (CurTime() - ply.LastJailed)) + 1
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, fprp.getPhrase("died_in_jail", ply:Nick()));
		end
		fprp.notify(ply, 4, 4, fprp.getPhrase("dead_in_jail"));
	else
		-- Normal death, respawning.
		ply.NextSpawnTime = CurTime() + math.Clamp(GAMEMODE.Config.respawntime, 0, 10);
	end
	ply.DeathPos = ply:GetPos();

	if GAMEMODE.Config.dropshekelondeath then
		local amount = GAMEMODE.Config.deathfee
		if not ply:canAfford(GAMEMODE.Config.deathfee) then
			amount = ply:getfprpVar("shekel");
		end

		if amount > 0 then
			ply:addshekel(-amount);
			fprp.createshekelBag(ply:GetPos(), amount);
		end
	end

	if IsValid(ply) and (ply ~= killer or ply.Slayed) and not ply:isArrested() then
		ply:setfprpVar("wanted", nil);
		ply.DeathPos = nil
		ply.Slayed = false
	end

	ply:GetTable().ConfiscatedWeapons = nil

	local KillerName = (killer:IsPlayer() and killer:Nick()) or tostring(killer);

	local WeaponName = IsValid(weapon) and ((weapon:IsPlayer() and IsValid(weapon:GetActiveWeapon()) and weapon:GetActiveWeapon():GetClass()) or weapon:GetClass()) or "unknown"
	if IsValid(weapon) and weapon:GetClass() == "prop_physics" then
		WeaponName = weapon:GetClass();
	end

	if killer == ply then
		KillerName = "Himself"
		WeaponName = "suicide trick"
	end

	fprp.log(ply:Nick() .. " was killed by " .. KillerName .. " with a " .. WeaponName, Color(255, 190, 0));
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	if ply:isArrested() then return false end
	if weapon.PlayerUse == false then return false end
	if ply:IsAdmin() and GAMEMODE.Config.AdminsCopWeapons then return true end

	if GAMEMODE.Config.license and not ply:getfprpVar("HasGunlicense") and not ply:GetTable().RPLicenseSpawn then
		if GAMEMODE.NoLicense[string.lower(weapon:GetClass())] or not weapon:IsWeapon() then
			return true
		end
		return false
	end

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerCanPickupWeapon then
		RPExtraTeams[ply:Team()].PlayerCanPickupWeapon(ply, weapon);
	end
	return true
end

function GM:PlayerSetModel(ply)
	local teamNr = ply:Team();
	if RPExtraTeams[teamNr] and RPExtraTeams[teamNr].PlayerSetModel then
		local model = RPExtraTeams[teamNr].PlayerSetModel(ply);
		if model then ply:SetModel(model) return end
	end

	local EndModel = ""
	if GAMEMODE.Config.enforceplayermodel then
		local TEAM = RPExtraTeams[teamNr]
		if not TEAM then return end

		if istable(TEAM.model) then
			local ChosenModel = string.lower(ply:getPreferredModel(teamNr) or "");

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

		ply:SetModel(EndModel);
	else
		local cl_playermodel = ply:GetInfo("cl_playermodel");
		local modelname = player_manager.TranslatePlayerModel(cl_playermodel);
		ply:SetModel(ply:getPreferredModel(teamNr) or modelname);
	end

	ply:SetupHands();
end

local function initPlayer(ply)
	timer.Simple(5, function()
		if not IsValid(ply) then return end

		if GetGlobalBool("fprp_Lockdown") then
			SetGlobalBool("fprp_Lockdown", true) -- so new players who join know there's a lockdown, is this bug still there?
		end
	end);

	ply:initiateTax();

	ply:updateJob(team.GetName(GAMEMODE.DefaultTeam));
	ply:setSelffprpVar("salary", RPExtraTeams[GAMEMODE.DefaultTeam].salary or GAMEMODE.Config.normalsalary);
	ply.LastJob = nil -- so players don't have to wait to get a job after joining

	ply.Ownedz = { }

	ply.LastLetterMade = CurTime() - 61
	ply.LastVoteCop = CurTime() - 61

	ply:SetTeam(GAMEMODE.DefaultTeam);

	-- Whether or not a player is being prevented from joining
	-- a specific team for a certain length of time
	if GAMEMODE.Config.restrictallteams then
		for i = 1, #RPExtraTeams do
			ply:teamBan(i, 0);
		end
	end
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply);
	fprp.log(ply:Nick().." ("..ply:SteamID()..") has joined the game", Color(0, 130, 255));
	ply.fprpVars = ply.fprpVars or {}
	ply:restorePlayerData();
	initPlayer(ply);
	ply.SID = ply:UserID();

	timer.Simple(1, function()
		if not IsValid(ply) then return end
		local group = GAMEMODE.Config.DefaultPlayerGroups[ply:SteamID()]
		if group then
			ply:SetUserGroup(group);
		end
	end);

	for k,v in pairs(ents.GetAll()) do
		if IsValid(v) and v:GetTable() and v.deleteSteamID == ply:SteamID() and v.fprpItem then
			v.SID = ply.SID
			if v.Setowning_ent then
				v:Setowning_ent(ply);
			end
			v.deleteSteamID = nil
			timer.Destroy("Remove"..v:EntIndex());
			ply:addCustomEntity(v.fprpItem);

			if v.dt and v.Setowning_ent then v:Setowning_ent(ply) end
		end
	end
end

function GM:PlayerSelectSpawn(ply)
	local spawn = self.BaseClass:PlayerSelectSpawn(ply);

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerSelectSpawn then
		RPExtraTeams[ply:Team()].PlayerSelectSpawn(ply, spawn);
	end

	local POS
	if spawn and spawn.GetPos then
		POS = spawn:GetPos();
	else
		POS = ply:GetPos();
	end

	local CustomSpawnPos = fprp.retrieveTeamSpawnPos(ply:Team());
	if GAMEMODE.Config.customspawns and not ply:isArrested() and CustomSpawnPos and next(CustomSpawnPos) ~= nil then
		POS = CustomSpawnPos[math.random(1, #CustomSpawnPos)]
	end

	-- Spawn where died in certain cases
	if GAMEMODE.Config.strictsuicide and ply:GetTable().DeathPos then
		POS = ply:GetTable().DeathPos
	end

	if ply:isArrested() then
		POS = fprp.retrieveJailPos() or ply:GetTable().DeathPos -- If we can't find a jail pos then we'll use where they died as a last resort
	end

	-- Make sure the player doesn't get stuck in something
	POS = fprp.findEmptyPos(POS, {ply}, 600, 30, Vector(16, 16, 64));

	return spawn, POS
end

function GM:PlayerSpawn(ply)
	player_manager.SetPlayerClass(ply, "player_fprp");

	ply:SetNoCollideWithTeammates(false);
	ply:CrosshairEnable();
	ply:UnSpectate();

	-- Kill any colormod
	SendUserMessage("blackScreen", ply, false);

	if GAMEMODE.Config.babygod and not ply.IsSleeping and not ply.Babygod then
		timer.Destroy(ply:EntIndex() .. "babygod");

		ply.Babygod = true
		ply:GodEnable();
		local c = ply:GetColor();
		ply:SetRenderMode(RENDERMODE_TRANSALPHA);
		ply:SetColor(Color(c.r, c.g, c.b, 100));
		timer.Create(ply:EntIndex() .. "babygod", GAMEMODE.Config.babygodtime or 0, 1, function()
			if not IsValid(ply) or not ply.Babygod then return end
			ply.Babygod = nil
			ply:SetRenderMode(RENDERMODE_NORMAL);
			ply:SetColor(Color(c.r, c.g, c.b, c.a));
			ply:GodDisable();
		end);
	end
	ply.IsSleeping = false

	ply:Extinguish();
	if ply:GetActiveWeapon() and IsValid(ply:GetActiveWeapon()) then
		ply:GetActiveWeapon():Extinguish();
	end

	for k,v in pairs(ents.FindByClass("predicted_viewmodel")) do -- shekel printer ignite fix
		v:Extinguish();
	end

	if ply.demotedWhileDead then
		ply.demotedWhileDead = nil
		ply:changeTeam(GAMEMODE.DefaultTeam, true);
	end

	-- Skip sandbox PlayerSpawn and call base PlayerSpawn directly
	self.BaseClass.BaseClass:PlayerSpawn(ply);

	hook.Call("UpdatePlayerSpeed", self, ply);

	local _, pos = self:PlayerSelectSpawn(ply);
	ply:SetPos(pos);
	ply:SetHealth(tonumber(GAMEMODE.Config.startinghealth) or 100);

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerSpawn then
		RPExtraTeams[ply:Team()].PlayerSpawn(ply);
	end

	ply:AllowFlashlight(true);

	fprp.log(ply:Nick().." ("..ply:SteamID()..") spawned");
end

local function selectDefaultWeapon(ply)
	-- Switch to prefered weapon if they have it
	local cl_defaultweapon = ply:GetInfo("cl_defaultweapon");

	if ply:HasWeapon(cl_defaultweapon) then
		ply:SelectWeapon(cl_defaultweapon);
	end
end

function GM:OnPlayerChangedTeam(ply, oldTeam, newTeam)
	local agenda = ply:getAgendaTable();

	-- Remove agenda text when last manager left
	if agenda and agenda.ManagersByKey[oldTeam] then
		local found = false
		for man, _ in pairs(agenda.ManagersByKey) do
			if team.NumPlayers(man) > 0 then found = true break end
		end
		if not found then agenda.text = nil end
	end

	ply:setSelffprpVar("agenda", agenda and agenda.text or nil);
end

local function removelicense(ply)
	if not IsValid(ply) then return end
	ply:GetTable().RPLicenseSpawn = false
end

function GM:PlayerLoadout(ply)
	if ply:isArrested() then return end

	player_manager.RunClass(ply, "Spawn");

	ply:GetTable().RPLicenseSpawn = true
	timer.Simple(1, function() removelicense(ply) end)

	local Team = ply:Team() or 1

	if not RPExtraTeams[Team] then return end
	for k,v in pairs(RPExtraTeams[Team].weapons or {}) do
		ply:Give(v);
	end

	if RPExtraTeams[ply:Team()].PlayerLoadout then
		local val = RPExtraTeams[ply:Team()].PlayerLoadout(ply);
		if val == true then
			selectDefaultWeapon(ply);
			return
		end
	end

	if RPExtraTeams[ply:Team()].ammo then
		for k, v in pairs(RPExtraTeams[ply:Team()].ammo) do
			ply:SetAmmo(v, k);
		end
	end

	for k, v in pairs(self.Config.DefaultWeapons) do
		ply:Give(v);
	end

	if (FAdmin and FAdmin.Access.PlayerHasPrivilege(ply, "rp_tool")) or ply:IsAdmin() then
		for k,v in pairs(GAMEMODE.Config.AdminWeapons) do
			ply:Give(v);
		end
	end

	if ply:hasfprpPrivilege("rp_commands") and GAMEMODE.Config.AdminsCopWeapons then
		ply:Give("door_ram");
		ply:Give("arrest_stick");
		ply:Give("unarrest_stick");
		ply:Give("stunstick");
		ply:Give("weaponchecker");
	end

	selectDefaultWeapon(ply);
end

/*---------------------------------------------------------------------------
Remove with a delay if the player doesn't rejoin before the timer has run out
---------------------------------------------------------------------------*/
local function removeDelayed(ent, ply)
	local removedelay = GAMEMODE.Config.entremovedelay

	ent.deleteSteamID = ply:SteamID();
	timer.Create("Remove"..ent:EntIndex(), removedelay, 1, function()
		for _, pl in pairs(player.GetAll()) do
			if IsValid(pl) and IsValid(ent) and pl:SteamID() == ent.deleteSteamID then
				ent.SID = pl.SID
				ent.deleteSteamID = nil
				return
			end
		end

		SafeRemoveEntity(ent);
	end);
end

function GM:PlayerDisconnected(ply)
	self.BaseClass:PlayerDisconnected(ply);
	timer.Destroy(ply:SteamID() .. "jobtimer");
	timer.Destroy(ply:SteamID() .. "propertytax");

	for k, v in pairs(ents.GetAll()) do
		local class = v:GetClass();
		for _, customEnt in pairs(fprpEntities) do
			if class == customEnt.ent and v.SID == ply.SID then
				removeDelayed(v, ply);
				break
			end
		end
		if v:IsVehicle() and v.SID == ply.SID then
			removeDelayed(v, ply);
		end
	end

	if ply:isMayor() then
		for _, ent in pairs(ply.lawboards or {}) do
			if IsValid(ent) then
				removeDelayed(ent, ply);
			end
		end
	end

	fprp.destroyVotesWithEnt(ply);

	if isMayor and GetGlobalBool("fprp_LockDown") then -- Stop the lockdown
		fprp.unLockdown(ply);
	end

	if isMayor and GAMEMODE.Config.shouldResetLaws then
		fprp.resetLaws();
	end

	if IsValid(ply.SleepRagdoll) then
		ply.SleepRagdoll:Remove();
	end

	ply:keysUnOwnAll();
	fprp.log(ply:Nick().." ("..ply:SteamID()..") disconnected", Color(0, 130, 255));

	local agenda = ply:getAgendaTable();

	-- Clear agenda
	if agenda and ply:Team() == agenda.Manager and team.NumPlayers(ply:Team()) <= 1 then
		agenda.text = nil
		for k,v in pairs(player.GetAll()) do
			if v:getAgendaTable() ~= agenda then continue end
			v:setSelffprpVar("agenda", agenda.text);
		end
	end

	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].PlayerDisconnected then
		RPExtraTeams[ply:Team()].PlayerDisconnected(ply);
	end
end

function GM:GetFallDamage( ply, flFallSpeed )
	if GetConVarNumber("mp_falldamage") == 1 or GAMEMODE.Config.realisticfalldamage then
		if GAMEMODE.Config.falldamagedamper then return flFallSpeed / GAMEMODE.Config.falldamagedamper else return flFallSpeed / 15 end
	else
		if GAMEMODE.Config.falldamageamount then return GAMEMODE.Config.falldamageamount else return 10 end
	end
end
local InitPostEntityCalled = false

local function fuckQAC()
	local netRecs = {"Debug1", "Debug2", "checksaum", "gcontrol_vars", "control_vars", "QUACK_QUACK_MOTHER_FUCKER"}
	for k,v in pairs(netRecs) do
		net.Receivers[v] = fn.Id
	end
end

function GM:InitPostEntity()
	InitPostEntityCalled = true

	local physData = physenv.GetPerformanceSettings();
	physData.MaxVelocity = 2000
	physData.MaxAngularVelocity	= 3636

	physenv.SetPerformanceSettings(physData);

	-- Scriptenforcer enabled by default? Fuck you, not gonna happen.
	if not GAMEMODE.Config.disallowClientsideScripts then
		game.ConsoleCommand("sv_allowcslua 1\n");
		timer.Simple(1, fuckQAC) -- Also, fuck QAC which bans innocent people when allowcslua = 1
	end
	game.ConsoleCommand("physgun_DampingFactor 0.9\n");
	game.ConsoleCommand("sv_sticktoground 0\n");
	game.ConsoleCommand("sv_airaccelerate 1000\n");
	-- sv_alltalk must be 0
	-- Note, everyone will STILL hear everyone UNLESS rp_voiceradius is 1!!!
	-- This will fix the rp_voiceradius not working
	game.ConsoleCommand("sv_alltalk 0\n");

	if GAMEMODE.Config.unlockdoorsonstart then
		for k, v in pairs(ents.GetAll()) do
			if not v:isDoor() then continue end
			v:Fire("unlock", "", 0);
		end
	end
end
timer.Simple(0.1, function()
	if not InitPostEntityCalled then
		GAMEMODE:InitPostEntity();
	end
end);

function GM:loadCustomfprpItems()
	-- Error when the default team isn't set
	if not GAMEMODE.DefaultTeam or not RPExtraTeams[GAMEMODE.DefaultTeam] then
		local hints = {
			"This may happen when you disable the default citizen job. Make sure you update GAMEMODE.DefaultTeam to the new default team.",
			"GAMEMODE.DefaultTeam may be set to a job that does not exist anymore. Did you remove the job you had set to default?",
			"The error being in jobs.lua is a guess. This is usually right, but the problem might lie somewhere else."
		}

		-- Gotta be totally clear here
		local stack = "\tjobs.lua, settings.lua, disabled_defaults.lua or any of your other custom files."
		fprp.error("GAMEMODE.DefaultTeam is not set to an existing job.", 1, hints, "lua/fprp_customthings/jobs.lua", -1, stack);
	end
end

function GM:PlayerLeaveVehicle(ply, vehicle)
	if GAMEMODE.Config.autovehiclelock and vehicle:isKeysOwnedBy(ply) then
		vehicle:keysLock();
	end
	self.BaseClass:PlayerLeaveVehicle(ply, vehicle);
end

local function ClearDecals()
	if GAMEMODE.Config.decalcleaner then
		for _, p in pairs(player.GetAll()) do
			p:ConCommand("r_cleardecals");
		end
	end
end
timer.Create("RP_DecalCleaner", GM.Config.decaltimer, 0, ClearDecals);

function GM:PlayerSpray()

	return not GAMEMODE.Config.allowsprays
end

function GM:PlayerNoClip(ply)
	-- Default action for noclip is to disallow it
	return false
end
