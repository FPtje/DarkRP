/*---------------------------------------------------------
 Variables
 ---------------------------------------------------------*/
local meta = FindMetaTable("Player")

/*---------------------------------------------------------
 RP names
 ---------------------------------------------------------*/
local function RPName(ply, args)
	if ply.LastNameChange and ply.LastNameChange > (CurTime() - 5) then
		GAMEMODE:Notify( ply, 1, 4, DarkRP.getPhrase("have_to_wait",  math.ceil(5 - (CurTime() - ply.LastNameChange)), "/rpname"))
		return ""
	end

	if not GAMEMODE.Config.allowrpnames then
		GAMEMODE:Notify(ply, 1, 6,  DarkRP.getPhrase("disabled", "RPname", ""))
		return ""
	end

	local len = string.len(args)
	local low = string.lower(args)

	if len > 30 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("unable", "RPname", "<=30"))
		return ""
	elseif len < 3 then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("unable", "RPname", ">2"))
		return ""
	end

	local canChangeName = hook.Call("CanChangeRPName", GAMEMODE, ply, low)
	if canChangeName == false then
		GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("unable", "RPname", ""))
		return ""
	end

	local allowed = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
	'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
	'z', 'x', 'c', 'v', 'b', 'n', 'm', ' ',
	'(', ')', '[', ']', '!', '@', '#', '$', '%', '^', '&', '*', '-', '_', '=', '+', '|', '\\'}

	for k in string.gmatch(args, ".") do
		if not table.HasValue(allowed, string.lower(k)) then
			GAMEMODE:Notify(ply, 1, 4, DarkRP.getPhrase("unable", "RPname", k))
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
				GAMEMODE:Notify(self, 1, 5, DarkRP.getPhrase("unable", "RPname", "it's been taken"))
				return ""
			end
		else
			if not firstRun then -- Don't save the steam name in the database
				GAMEMODE:NotifyAll(2, 6, DarkRP.getPhrase("rpname_changed", self:SteamName(), name))
				DB.StoreRPName(self, name)
			end
		end
	end)
end

function meta:RestorePlayerData()
	if not IsValid(self) then return end
	DB.RetrievePlayerData(self, function(data)
		if not IsValid(self) then return end

		self.DarkRPUnInitialized = nil

		local info = data and data[1] or {}
		if not info.rpname or info.rpname == "NULL" then info.rpname = string.gsub(self:SteamName(), "\\\"", "\"") end

		info.wallet = info.wallet or GAMEMODE.Config.startingmoney
		info.salary = info.salary or GAMEMODE.Config.normalsalary

		self:SetDarkRPVar("money", tonumber(info.wallet))
		self:SetDarkRPVar("salary", tonumber(info.salary))

		self:SetDarkRPVar("rpname", info.rpname)

		if not data then
			DB.CreatePlayerData(self, info.rpname, info.wallet, info.salary)
		end
	end, function() -- Retrieving data failed, go on without it
		self.DarkRPUnInitialized = nil

		self:SetDarkRPVar("money", GAMEMODE.Config.startingmoney)
		self:SetDarkRPVar("salary", GAMEMODE.Config.normalsalary)
		self:SetDarkRPVar(string.gsub(self:SteamName(), "\\\"", "\""))

		error("Failed to retrieve player information from MySQL server")
	end)
end

/*---------------------------------------------------------
 Admin/automatic stuff
 ---------------------------------------------------------*/
function meta:HasPriv(priv)
	if FAdmin then
		return FAdmin.Access.PlayerHasPrivilege(self, priv)
	end
	return self:IsAdmin()
end

function meta:ChangeAllowed(t)
	if not self.bannedfrom then return true end
	if self.bannedfrom[t] == 1 then return false else return true end
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

		local money = self:getDarkRPVar("money")
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

function meta:TeamBan(t, time)
	if not self.bannedfrom then self.bannedfrom = {} end
	t = t or self:Team()
	self.bannedfrom[t] = 1

	if time == 0 then return end
	timer.Simple(time or GAMEMODE.Config.demotetime, function()
		if not IsValid(self) then return end
		self:TeamUnBan(t)
	end)
end

function meta:NewData()
	if not IsValid(self) then return end
	self.DarkRPUnInitialized = true
	self:RestorePlayerData()

	timer.Simple(5, function()
		if not IsValid(self) then return end

		if tobool(GetConVarNumber("DarkRP_Lockdown")) then
			RunConsoleCommand("DarkRP_Lockdown", 1) -- so new players who join know there's a lockdown
		end
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
	local prevTeam = self:Team()

	if self:isArrested() and not force then
		GAMEMODE:Notify(self, 1, 4, DarkRP.getPhrase("unable", team.GetName(t), ""))
		return false
	end

	self:SetDarkRPVar("agenda", nil)

	if t ~= GAMEMODE.DefaultTeam and not self:ChangeAllowed(t) and not force then
		GAMEMODE:Notify(self, 1, 4, DarkRP.getPhrase("unable", team.GetName(t), "banned/demoted"))
		return false
	end

	if self.LastJob and 10 - (CurTime() - self.LastJob) >= 0 and not force then
		GAMEMODE:Notify(self, 1, 4, DarkRP.getPhrase("have_to_wait",  math.ceil(10 - (CurTime() - self.LastJob)), "/job"))
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


	if prevTeam == t then
		GAMEMODE:Notify(self, 1, 4, DarkRP.getPhrase("unable", team.GetName(t), ""))
		return false
	end

	local TEAM = RPExtraTeams[t]
	if not TEAM then return false end

	if TEAM.customCheck and not TEAM.customCheck(self) then
		GAMEMODE:Notify(self, 1, 4, TEAM.CustomCheckFailMsg or DarkRP.getPhrase("unable", team.GetName(t), ""))
		return false
	end

	if not self.DarkRPVars["Priv"..TEAM.command] and not force then
		if type(TEAM.NeedToChangeFrom) == "number" and prevTeam ~= TEAM.NeedToChangeFrom then
			GAMEMODE:Notify(self, 1,4, DarkRP.getPhrase("need_to_be_before", team.GetName(TEAM.NeedToChangeFrom), TEAM.name))
			return false
		elseif type(TEAM.NeedToChangeFrom) == "table" and not table.HasValue(TEAM.NeedToChangeFrom, prevTeam) then
			local teamnames = ""
			for a,b in pairs(TEAM.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
			GAMEMODE:Notify(self, 1,4, string.format(string.sub(teamnames, 5), team.GetName(TEAM.NeedToChangeFrom), TEAM.name))
			return false
		end
		local max = TEAM.max
		if max ~= 0 and -- No limit
		(max >= 1 and team.NumPlayers(t) >= max or -- absolute maximum
		max < 1 and (team.NumPlayers(t) + 1) / #player.GetAll() > max) then -- fractional limit (in percentages)
			GAMEMODE:Notify(self, 1, 4,  DarkRP.getPhrase("team_limit_reached", TEAM.name))
			return false
		end
	end

	if TEAM.PlayerChangeTeam then
		local val = TEAM.PlayerChangeTeam(self, prevTeam, t)
		if val ~= nil then
			return val
		end
	end

	local isMayor = RPExtraTeams[prevTeam] and RPExtraTeams[prevTeam].mayor
	if isMayor and tobool(GetConVarNumber("DarkRP_LockDown")) then
		GAMEMODE:UnLockdown(self)
	end
	self:UpdateJob(TEAM.name)
	self:SetSelfDarkRPVar("salary", TEAM.salary)
	GAMEMODE:NotifyAll(0, 4, DarkRP.getPhrase("job_has_become", self:Nick(), TEAM.name))
	if self:getDarkRPVar("HasGunlicense") then
		self:SetDarkRPVar("HasGunlicense", false)
	end
	if TEAM.hasLicense and GAMEMODE.Config.license then
		self:SetDarkRPVar("HasGunlicense", true)
	end

	self.LastJob = CurTime()

	if GAMEMODE.Config.removeclassitems then
		for k, v in pairs(ents.FindByClass("microwave")) do
			if v.allowed and type(v.allowed) == "table" and table.HasValue(v.allowed, t) then continue end
			if v.SID == self.SID then v:Remove() end
		end
		for k, v in pairs(ents.FindByClass("gunlab")) do
			if v.allowed and type(v.allowed) == "table" and table.HasValue(v.allowed, t) then continue end
			if v.SID == self.SID then v:Remove() end
		end

		for k, v in pairs(ents.FindByClass("drug_lab")) do
			if v.allowed and type(v.allowed) == "table" and table.HasValue(v.allowed, t) then continue end
			if v.SID == self.SID then v:Remove() end
		end

		for k,v in pairs(ents.FindByClass("spawned_shipment")) do
			if v.allowed and type(v.allowed) == "table" and table.HasValue(v.allowed, t) then continue end
			if v.SID == self.SID then v:Remove() end
		end
	end

	if isMayor then
		for _, ent in pairs(self.lawboards or {}) do
			if IsValid(ent) then
				ent:Remove()
			end
		end
	end

	self:SetTeam(t)
	hook.Call("OnPlayerChangedTeam", GAMEMODE, self, prevTeam, t)
	DB.Log(self:Nick().." ("..self:SteamID()..") changed to "..team.GetName(t), nil, Color(100, 0, 255))
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
		hook.Call("UpdatePlayerSpeed", GAMEMODE, self)
		GAMEMODE:PlayerSetModel(self)
		GAMEMODE:PlayerLoadout(self)
	else
		self:KillSilent()
	end

	umsg.Start("OnChangedTeam", self)
		umsg.Short(prevTeam)
		umsg.Short(t)
	umsg.End()
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
function meta:AddMoney(amount)
	if not amount then return false end
	local total = self:getDarkRPVar("money") + math.floor(amount)
	total = hook.Call("PlayerWalletChanged", GAMEMODE, self, amount, self:getDarkRPVar("money")) or total

	self:SetDarkRPVar("money", total)

	if self.DarkRPUnInitialized then return end
	DB.StoreMoney(self, total)
end

function meta:PayDay()
	if not IsValid(self) then return end
	if not self:isArrested() then
		DB.RetrieveSalary(self, function(amount)
			amount = math.floor(amount or GAMEMODE.Config.normalsalary)
			hook.Call("PlayerGetSalary", GAMEMODE, self, amount)
			if amount == 0 or not amount then
				GAMEMODE:Notify(self, 4, 4, DarkRP.getPhrase("payday_unemployed"))
			else
				self:AddMoney(amount)
				GAMEMODE:Notify(self, 4, 4, DarkRP.getPhrase("payday_message", GAMEMODE.Config.currency .. amount))
			end
		end)
	else
		GAMEMODE:Notify(self, 4, 4, DarkRP.getPhrase("payday_missed"))
	end
end

/*---------------------------------------------------------
 Jail/arrest
 ---------------------------------------------------------*/
local function JailPos(ply)
	-- Admin or Chief can set the Jail Position
	if (RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].chief and GAMEMODE.Config.chiefjailpos) or ply:HasPriv("rp_commands") then
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
	if (RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].chief and GAMEMODE.Config.chiefjailpos) or ply:HasPriv("rp_commands") then
		DB.StoreJailPos(ply, true)
	else
		local str = DarkRP.getPhrase("admin_only")
		if GAMEMODE.Config.chiefjailpos then
			str = DarkRP.getPhrase("chief_or") .. str
		end

		GAMEMODE:Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/addjailpos", AddJailPos)

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
			GAMEMODE:Notify(self, 0, 5, DarkRP.getPhrase("property_tax", GAMEMODE.Config.currency .. tax))
		end
	else
		GAMEMODE:Notify(self, 1, 8, DarkRP.getPhrase("property_tax_cant_afford"))
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

	local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())
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
	ent.ammoadd = ammo

	self:RemoveAmmo(ammo, weapon:GetPrimaryAmmoType())

	ent:Spawn()

	weapon:Remove()
end
