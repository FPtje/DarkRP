/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local meta = FindMetaTable("Player")

/*---------------------------------------------------------
 RP names
 ---------------------------------------------------------*/
local function RPName(ply, args)
	if ply.LastNameChange and ply.LastNameChange > (CurTime() - 5) then
		GAMEMODE:Notify( ply, 1, 4, string.format( LANGUAGE.have_to_wait,  math.ceil(5 - (CurTime() - ply.LastNameChange)), "/rpname"))
		return ""
	end

	if not GAMEMODE.Config.allowrpnames then
		GAMEMODE:Notify(ply, 1, 6,  string.format(LANGUAGE.disabled, "RPname", ""))
		return ""
	end

	local len = string.len(args)
	local low = string.lower(args)

	if len > 30 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "RPname", "<=30"))
		return ""
	elseif len < 3 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "RPname", ">2"))
		return ""
	end

	local canChangeName = hook.Call("CanChangeRPName", GAMEMODE, ply, low)
	if canChangeName == false then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "RPname", ""))
		return ""
	end

	local allowed = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
	'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
	'z', 'x', 'c', 'v', 'b', 'n', 'm', ' ',
	'(', ')', '[', ']', '!', '@', '#', '$', '%', '^', '&', '*', '-', '_', '=', '+', '|', '\\'}

	for k in string.gmatch(args, ".") do
		if not table.HasValue(allowed, string.lower(k)) then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "RPname", k))
			return ""
		end
	end
	ply:SetRPName(args)
	ply.LastNameChange = CurTime()
	return ""
end
AddChatCommand("/rpname", RPName)
AddChatCommand("/name", RPName)
AddChatCommand("/nick", RPName)

function meta:IsCP()
	if not IsValid(self) then return false end
	local Team = self:Team()
	return Team == TEAM_POLICE or Team == TEAM_CHIEF or Team == TEAM_MAYOR
end

function meta:SetRPName(name, firstRun)
	-- Make sure nobody on this server already has this RP name
	local lowername = string.lower(tostring(name))
	DB.RetrieveRPNames(self, name, function(taken)
		if string.len(lowername) < 2 and not firstrun then return end
		-- If we found that this name exists for another player
		if taken then
			if firstRun then
				-- If we just connected and another player happens to be using our steam name as their RP name
				-- Put a 1 after our steam name
				DB.StoreRPName(self, name .. " 1")
				GAMEMODE:Notify(self, 0, 12, "Someone is already using your Steam name as their RP name so we gave you a '1' after your name.")
			else
				GAMEMODE:Notify(self, 1, 5, string.format(LANGUAGE.unable, "RPname", "it's been taken"))
				return ""
			end
		else
			if not firstRun then -- Don't save the steam name in the database
				GAMEMODE:NotifyAll(2, 6, string.format(LANGUAGE.rpname_changed, self:SteamName(), name))
				DB.StoreRPName(self, name)
			end
		end
	end)
end

function meta:RestorePlayerData()
	if not IsValid(self) then return end
	DB.RetrievePlayerData(self, function(data)
		if not IsValid(self) then return end

		local info = data and data[1] or {}
		if not info.rpname or info.rpname == "NULL" then info.rpname = string.gsub(self:SteamName(), "\\\"", "\"") end

		self:SetDarkRPVar("money", info.wallet or GAMEMODE.Config.startingmoney)
		self:SetDarkRPVar("salary", info.salary or GAMEMODE.Config.normalsalary)

		self:SetDarkRPVar("rpname", info.rpname)
	end)
end

/*---------------------------------------------------------
 Admin/automatic stuff
 ---------------------------------------------------------*/
function meta:HasPriv(priv)
	return (FAdmin and FAdmin.Access.PlayerHasPrivilege(self, priv)) or self:IsAdmin()
end

function meta:ChangeAllowed(t)
	if not self.bannedfrom then return true end
	if self.bannedfrom[t] == 1 then return false else return true end
end

function meta:ResetDMCounter()
	if not IsValid(self) then return end
	self.kills = 0
	return true
end

function meta:InitiateTax()
	local taxtime = GAMEMODE.Config.wallettaxtime
	local uniqueid = self:UniqueID() -- so we can destroy the timer if the player leaves
	timer.Create("rp_tax_"..uniqueid, taxtime or 600, 0, function()
		if not IsValid(self) then
			timer.Destroy("rp_tax_"..uniqueid)
			return
		end

		if not GAMEMODE.Config.wallettax then
			return -- Don't remove the hook in case it's turned on afterwards.
		end

		local money = self.DarkRPVars.money
		local mintax = GAMEMODE.Config.wallettaxmin / 100
		local maxtax = GAMEMODE.Config.wallettaxmax / 100 -- convert to decimals for percentage calculations
		local startMoney = GAMEMODE.Config.startingmoney

		if money < (startMoney * 2) then
			return -- Don't tax players if they have less than twice the starting amount
		end

		-- Variate the taxes between twice the starting money ($1000 by default) and 200 - 2 times the starting money (100.000 by default)
		local tax = (money - (startMoney * 2)) / (startMoney * 198)
			  tax = math.Min(maxtax, mintax + (maxtax - mintax) * tax)

		self:AddMoney(-tax * money)
		GAMEMODE:Notify(self, 3, 7, "Tax day! "..math.Round(tax * 100, 3) .. "% of your income was taken!")

	end)
end

function meta:TeamUnBan(Team)
	if not IsValid(self) then return end
	if not self.bannedfrom then self.bannedfrom = {} end
	self.bannedfrom[Team] = 0
end

function meta:TeamBan(t)
	if not self.bannedfrom then self.bannedfrom = {} end
	t = t or self:Team()
	self.bannedfrom[t] = 1
	timer.Simple(GAMEMODE.Config.demotetime, function()
		if not IsValid(self) then return end
		self:TeamUnBan(t)
	end)
end

function meta:CompleteSentence()
	if not IsValid(self) then return end

	if IsValid(self) and self:isArrested() then
		local time = GAMEMODE.Config.jailtimer
		self:Arrest(time, true)
		GAMEMODE:Notify(self, 0, 5, string.format(LANGUAGE.jail_punishment, time))
	end
end

function meta:NewData()
	if not IsValid(self) then return end

	-- Restoring data delayed the player handle will not be valid on the player otherwise
	timer.Simple(5, function()
		if not IsValid(self) then return end
		self:RestorePlayerData()
	end)

	self:InitiateTax()

	self:UpdateJob(team.GetName(1))

	self:GetTable().Ownedz = { }
	self:GetTable().OwnedNumz = 0

	self:GetTable().LastLetterMade = CurTime() - 61
	self:GetTable().LastVoteCop = CurTime() - 61

	self:SetTeam(1)

	-- Whether or not a player is being prevented from joining
	-- a specific team for a certain length of time
	for i = 1, #RPExtraTeams do
		if GAMEMODE.Config.restrictallteams then
			self.bannedfrom[i] = 1
		else
			self.bannedfrom[i] = 0
		end
	end
end

/*---------------------------------------------------------
 Teams/jobs
 ---------------------------------------------------------*/
function meta:ChangeTeam(t, force)
	if self:isArrested() and not force then
		GAMEMODE:Notify(self, 1, 4, string.format(LANGUAGE.unable, team.GetName(t), ""))
		return false
	end

	self:SetSelfDarkRPVar("helpBoss",false)
	self:SetSelfDarkRPVar("helpCop",false)
	self:SetSelfDarkRPVar("helpMayor",false)

	if t ~= TEAM_CITIZEN and not self:ChangeAllowed(t) and not force then
		GAMEMODE:Notify(self, 1, 4, string.format(LANGUAGE.unable, team.GetName(t), "banned/demoted"))
		return false
	end

	if self.LastJob and 10 - (CurTime() - self.LastJob) >= 0 and not force then
		GAMEMODE:Notify(self, 1, 4, string.format(LANGUAGE.have_to_wait,  math.ceil(10 - (CurTime() - self.LastJob)), "/job"))
		return false
	end

	if self.IsBeingDemoted then
		self:TeamBan()
		self.IsBeingDemoted = false
		self:ChangeTeam(1, true)
		GAMEMODE.vote.DestroyVotesWithEnt(self)
		GAMEMODE:Notify(self, 1, 4, "You tried to escape demotion. You failed, and have been demoted.")

		return false
	end


	if self:Team() == t then
		GAMEMODE:Notify(self, 1, 4, string.format(LANGUAGE.unable, team.GetName(t), ""))
		return false
	end

	local TEAM = RPExtraTeams[t]
	if not TEAM then return false end

	if TEAM.customCheck and not TEAM.customCheck(self) then
		GAMEMODE:Notify(self, 1, 4, string.format(LANGUAGE.unable, team.GetName(t), ""))
		return false
	end

	if not self.DarkRPVars["Priv"..TEAM.command] and not force then
		if type(TEAM.NeedToChangeFrom) == "number" and self:Team() ~= TEAM.NeedToChangeFrom then
			GAMEMODE:Notify(self, 1,4, string.format(LANGUAGE.need_to_be_before, team.GetName(TEAM.NeedToChangeFrom), TEAM.name))
			return false
		elseif type(TEAM.NeedToChangeFrom) == "table" and not table.HasValue(TEAM.NeedToChangeFrom, self:Team()) then
			local teamnames = ""
			for a,b in pairs(TEAM.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
			GAMEMODE:Notify(self, 1,4, string.format(string.sub(teamnames, 5), team.GetName(TEAM.NeedToChangeFrom), TEAM.name))
			return false
		end
		local max = TEAM.max
		if max ~= 0 and ((max % 1 == 0 and team.NumPlayers(t) >= max) or (max % 1 ~= 0 and (team.NumPlayers(t) + 1) / #player.GetAll() > max)) then
			GAMEMODE:Notify(self, 1, 4,  string.format(LANGUAGE.team_limit_reached, TEAM.name))
			return false
		end
	end

	if TEAM.PlayerChangeTeam then
		local val = TEAM.PlayerChangeTeam(self, self:Team(), t)
		if val ~= nil then
			return val
		end
	end

	if self:Team() == TEAM_MAYOR and tobool(GetConVarNumber("DarkRP_LockDown")) then
		GAMEMODE:UnLockdown(self)
	end
	self:UpdateJob(TEAM.name)
	self:SetSelfDarkRPVar("salary", TEAM.salary)
	GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.job_has_become, self:Nick(), TEAM.name))
	if self.DarkRPVars.HasGunlicense then
		self:SetDarkRPVar("HasGunlicense", false)
	end
	if TEAM.hasLicense and GAMEMODE.Config.license then
		self:SetDarkRPVar("HasGunlicense", true)
	end

	self.LastJob = CurTime()

	if t == TEAM_POLICE then
		self:SetSelfDarkRPVar("helpCop", true)
	elseif t == TEAM_MOB then
		self:SetSelfDarkRPVar("helpBoss", true)
	elseif t == TEAM_MAYOR then
		self:SetSelfDarkRPVar("helpMayor", true)
	end

	if GAMEMODE.Config.removeclassitems then
		for k, v in pairs(ents.FindByClass("microwave")) do
			if v.SID == self.SID then v:Remove() end
		end
		for k, v in pairs(ents.FindByClass("gunlab")) do
			if v.SID == self.SID then v:Remove() end
		end

		if t ~= TEAM_MOB and t ~= TEAM_GANG then
			for k, v in pairs(ents.FindByClass("drug_lab")) do
				if v.SID == self.SID then v:Remove() end
			end
		end

		for k,v in pairs(ents.FindByClass("spawned_shipment")) do
			if v.SID == self.SID then v:Remove() end
		end
	end

	if self:Team() == TEAM_MAYOR then
		for _, ent in pairs(self.lawboards or {}) do
			if IsValid(ent) then
				ent:Remove()
			end
		end
	end

	self:SetTeam(t)
	DB.Log(self:SteamName().." ("..self:SteamID()..") changed to "..team.GetName(t), nil, Color(100, 0, 255))
	if self:InVehicle() then self:ExitVehicle() end
	if GAMEMODE.Config.norespawn and self:Alive() then
		self:StripWeapons()
		local vPoint = self:GetShootPos() + Vector(0,0,50)
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetStart( vPoint ) -- Not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale(1)
		util.Effect("entity_remove", effectdata)
		GAMEMODE:PlayerSetModel(self)
		GAMEMODE:PlayerLoadout(self)
	else
		self:KillSilent()
	end
	return true
end

function meta:UpdateJob(job)
	self:SetDarkRPVar("job", job)

	timer.Create(self:UniqueID() .. "jobtimer", GAMEMODE.Config.paydelay, 0, function()
		if not IsValid(self) then return end
		self:PayDay()
	end)
end

/*---------------------------------------------------------
 Money
 ---------------------------------------------------------*/
function meta:CanAfford(amount)
	if not amount then return false end
	return math.floor(amount) >= 0 and self.DarkRPVars.money - math.floor(amount) >= 0
end

function meta:AddMoney(amount)
	if not amount then return false end
	hook.Call("PlayerWalletChanged", GAMEMODE, ply, amount)
	DB.StoreMoney(self, self.DarkRPVars.money + math.floor(amount))
end

function meta:PayDay()
	if not IsValid(self) then return end
	if not self:isArrested() then
		DB.RetrieveSalary(self, function(amount)
			amount = math.floor(amount or GAMEMODE.Config.normalsalary)
			hook.Call("PlayerGetSalary", GAMEMODE, self, amount)
			if amount == 0 or not amount then
				GAMEMODE:Notify(self, 4, 4, LANGUAGE.payday_unemployed)
			else
				self:AddMoney(amount)
				GAMEMODE:Notify(self, 4, 4, string.format(LANGUAGE.payday_message, CUR .. amount))
			end
		end)
	else
		GAMEMODE:Notify(self, 4, 4, LANGUAGE.payday_missed)
	end
end

/*---------------------------------------------------------
 Jail/arrest
 ---------------------------------------------------------*/
local function JailPos(ply)
	-- Admin or Chief can set the Jail Position
	if (ply:Team() == TEAM_CHIEF and GAMEMODE.Config.chiefjailpos) or ply:HasPriv("rp_commands") then
		DB.StoreJailPos(ply)
	else
		local str = "Admin only!"
		if GAMEMODE.Config.chiefjailpos then
			str = "Chief or " .. str
		end

		GAMEMODE:Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/jailpos", JailPos)

local function AddJailPos(ply)
	-- Admin or Chief can add Jail Positions
	if (ply:Team() == TEAM_CHIEF and GAMEMODE.Config.chiefjailpos) or ply:HasPriv("rp_commands") then
		DB.StoreJailPos(ply, true)
	else
		local str = LANGUAGE.admin_only
		if GAMEMODE.Config.chiefjailpos then
			str = LANGUAGE.chief_or .. str
		end

		GAMEMODE:Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/addjailpos", AddJailPos)

local arrestedPlayers = {}
function meta:isArrested()
	return arrestedPlayers[self:SteamID()]
end

function meta:setArrested(bool)
	arrestedPlayers[self:SteamID()] = bool or nil
end

function meta:Arrest(time, rejoin)
	hook.Call("PlayerArrested", GAMEMODE, self, time)
	self:SetDarkRPVar("wanted", false)
	self.warranted = false
	self:SetSelfDarkRPVar("HasGunlicense", false)
	self:SetDarkRPVar("Arrested", true)
	GAMEMODE:SetPlayerSpeed(self, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed)
	self:StripWeapons()

	if GAMEMODE.Config.droppocketarrest and self.Pocket then
		for k, v in pairs(self.Pocket) do
			if IsValid(v) then
				v:SetMoveType(MOVETYPE_VPHYSICS)
				v:SetNoDraw(false)
				v:SetCollisionGroup(4)
				v:SetPos(self:GetPos() + Vector(0,0,10))
				local phys = v:GetPhysicsObject()
				phys:EnableCollisions(true)
				phys:Wake()
			end
		end
		self.Pocket = nil
	end

	-- Always get sent to jail when Arrest() is called, even when already under arrest
	if GAMEMODE.Config.teletojail and DB.CountJailPos() and DB.CountJailPos() ~= 0 then
		local jailpos = DB.RetrieveJailPos()
		if jailpos then
			jailpos = GAMEMODE:FindEmptyPos(jailpos, {ply}, 300, 30, Vector(16, 16, 64))
			self:SetPos(jailpos)
		end
	end

	if not self:isArrested() or rejoin then
		self:setArrested(true)
		self.LastJailed = CurTime()

		-- If the player has no remaining jail time,
		-- set it back to the max for this new sentence
		if not time or time == 0 then
			time = GAMEMODE.Config.jailtimer or 120
		end

		self:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.youre_arrested, time))
		for k, v in pairs(player.GetAll()) do
			if v ~= self then
				v:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.hes_arrested, self:Name(), time))
			end
		end

		timer.Create(self:UniqueID() .. "jailtimer", time, 1, function() if IsValid(self) then self:Unarrest() end end)
		umsg.Start("GotArrested", self)
			umsg.Float(time)
		umsg.End()
	end
end

function meta:Unarrest()
	hook.Call("PlayerUnarrested", GAMEMODE, self)

	self:SetDarkRPVar("Arrested", false)
	if not IsValid(self) then
		return
	end

	if self.Sleeping and GAMEMODE.KnockoutToggle then
		GAMEMODE:KnockoutToggle(self, "force")
	end

	if self:isArrested() then
		self:setArrested(false)

		GAMEMODE:SetPlayerSpeed(self, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed)
		GAMEMODE:PlayerLoadout(self)
		if GAMEMODE.Config.telefromjail and (not FAdmin or not self:FAdmin_GetGlobal("fadmin_jailed")) then
			local _, pos = GAMEMODE:PlayerSelectSpawn(self)
			self:SetPos(pos)
		elseif FAdmin and self:FAdmin_GetGlobal("fadmin_jailed") then
			self:SetPos(self.FAdminJailPos)
		end

		timer.Destroy(self:SteamID() .. "jailtimer")
		GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.hes_unarrested, self:Name()))
	end
end

/*---------------------------------------------------------
 Items
 ---------------------------------------------------------*/
function meta:UnownAll()
	for k, v in pairs(ents.GetAll()) do
		if v:IsOwnable() and v:OwnedBy(self) == true then
			v:Fire("unlock", "", 0.6)
		end
	end

	if self:GetTable().Ownedz then
		for k, v in pairs(self:GetTable().Ownedz) do
			v:UnOwn(self)
			self:GetTable().Ownedz[v:EntIndex()] = nil
		end
	end

	for k, v in pairs(player.GetAll()) do
		if v:GetTable().Ownedz then
			for n, m in pairs(v:GetTable().Ownedz) do
				if IsValid(m) and m:AllowedToOwn(self) then
					m:RemoveAllowed(self)
				end
			end
		end
	end

	self:GetTable().OwnedNumz = 0
end

function meta:DoPropertyTax()
	if not GAMEMODE.Config.propertytax then return end
	if self:IsCP() and GAMEMODE.Config.cit_propertytax then return end

	local numowned = self.OwnedNumz

	if not numowned or numowned <= 0 then return end

	local price = 10
	local tax = price * numowned + math.random(-5, 5)

	if self:CanAfford(tax) then
		if tax ~= 0 then
			self:AddMoney(-tax)
			GAMEMODE:Notify(self, 0, 5, string.format(LANGUAGE.property_tax, CUR .. tax))
		end
	else
		GAMEMODE:Notify(self, 1, 8, LANGUAGE.property_tax_cant_afford)
		self:UnownAll()
	end
end

function meta:DropDRPWeapon(weapon)
	if GAMEMODE.Config.RestrictDrop then
		local found = false
		for k,v in pairs(CustomShipments) do
			if v.entity == weapon:GetClass() then
				found = true
				break
			end
		end

		if not found then return end
	end

	self:DropWeapon(weapon) -- Drop it so the model isn't the viewmodel

	local ent = ents.Create("spawned_weapon")
	local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()

	ent.ShareGravgun = true
	ent:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
	ent:SetModel(model)
	ent:SetSkin(weapon:GetSkin())
	ent.weaponclass = weapon:GetClass()
	ent.nodupe = true
	ent.clip1 = weapon:Clip1()
	ent.clip2 = weapon:Clip2()

	ent:Spawn()

	weapon:Remove()
end