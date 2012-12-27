/*---------------------------------------------------------
 Flammable
 ---------------------------------------------------------*/
local FlammableProps = {drug = true,
drug_lab = true,
food = true,
gunlab = true,
letter = true,
microwave = true,
money_printer = true,
spawned_shipment = true,
spawned_weapon = true,
spawned_money = true}

local function IsFlammable(ent)
	return FlammableProps[ent:GetClass()] ~= nil
end

-- FireSpread from SeriousRP
local function FireSpread(e)
	if not e:IsOnFire() then return end

	if e:IsMoneyBag() then
		e:Remove()
	end

	local rand = math.random(0, 300)

	if rand > 1 then return end
	local en = ents.FindInSphere(e:GetPos(), math.random(20, 90))

	for k, v in pairs(en) do
		if not IsFlammable(v) then continue end

		if not v.burned then
			v:Ignite(math.random(5,180), 0)
			v.burned = true
		else
			local color = v:GetColor()
			if (color.r - 51) >= 0 then color.r = color.r - 51 end
			if (color.g - 51) >= 0 then color.g = color.g - 51 end
			if (color.b - 51) >= 0 then color.b = color.b - 51 end
			v:SetColor(color)
			if (color.r + color.g + color.b) < 103 and math.random(1, 100) < 35 then
				v:Fire("enablemotion","",0)
				constraint.RemoveAll(v)
			end
		end
		break -- Don't ignite all entities in sphere at once, just one at a time
	end
end

local function FlammablePropThink()
	for k, v in pairs(FlammableProps) do
		local ens = ents.FindByClass(k)

		for a, b in pairs(ens) do
			FireSpread(b)
		end
	end
end
timer.Create("FlammableProps", 0.1, 0, FlammablePropThink)

/*---------------------------------------------------------
 Shipments
 ---------------------------------------------------------*/
local NoDrop = {} -- Drop blacklist
local function DropWeapon(ply)
	local ent = ply:GetActiveWeapon()
	if not IsValid(ent) then return "" end

	if GAMEMODE.Config.restrictdrop then
		local found = false
		for k,v in pairs(CustomShipments) do
			if v.entity == ent:GetClass() then
				found = true
				break
			end
		end

		if not found then
			GAMEMODE:Notify(ply, 1, 4, LANGUAGE.cannot_drop_weapon)
			return ""
		end
	end

	if table.HasValue(NoDrop, ent:GetClass()) then return "" end

	local RP = RecipientFilter()
	RP:AddAllPlayers()

	umsg.Start("anim_dropitem", RP)
		umsg.Entity(ply)
	umsg.End()
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) and IsValid(ent) and ent:GetModel() then
			local ammohax = false
			local ammotype = ent:GetPrimaryAmmoType()
			local ammo = ply:GetAmmoCount(ammotype)
			local clip = (ent.Primary and ent.Primary.ClipSize) or 0

			ply:DropDRPWeapon(ent)
		end
	end)
	return ""
end
AddChatCommand("/drop", DropWeapon)
AddChatCommand("/dropweapon", DropWeapon)
AddChatCommand("/weapondrop", DropWeapon)

/*---------------------------------------------------------
 Warrants/wanted
 ---------------------------------------------------------*/
local function UnWarrant(ply, target)
	if not target.warranted then return end

	hook.Call("PlayerUnWarranted", GAMEMODE, ply, target)

	target.warranted = false
	GAMEMODE:Notify(ply, 2, 4, string.format(LANGUAGE.warrant_expired, target:Nick()))
end

local function SetWarrant(ply, target, reason)
	if target.warranted then return end
	hook.Call("PlayerWarranted", GAMEMODE, ply, target, reason)

	target.warranted = true
	timer.Simple(GAMEMODE.Config.searchtime, function() UnWarrant(ply, target) end)
	for a, b in pairs(player.GetAll()) do
		b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.warrant_approved, target:Nick()) ..
			"\nReason: " .. tostring(reason) ..
			"\nOrdered by: " .. (IsValid(ply) and ply:Nick() or "Disconnected player"))
		b:PrintMessage(HUD_PRINTCONSOLE, ply:Nick() .. " ordered a search warrant for " .. target:Nick() .. ", reason: " .. tostring(reason))
	end
	GAMEMODE:Notify(ply, 0, 4, LANGUAGE.warrant_approved2)
end

local function FinishWarrant(choice, mayor, initiator, target, reason)
	if choice == 1 then
		SetWarrant(initiator, target, reason)
	else
		GAMEMODE:Notify(initiator, 1, 4, string.format(LANGUAGE.warrant_denied, mayor:Nick()))
	end
	return ""
end

local function TimerUnwanted(ply, target)
	if IsValid(target) and target:Alive() and target.DarkRPVars.wanted then
		target:SetDarkRPVar("wanted", false)
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.wanted_expired, target:Nick()))
			timer.Destroy(target:Nick() .. " wantedtimer")
		end
	else
		return ""
	end
end

local function SearchWarrant(ply, args)
	local t = ply:Team()
	if not ply:IsCP() then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_x, "cop/mayor", "/warrant"))
	else
		local tableargs = string.Explode(" ", args)
		local reason = ""

		if #tableargs == 1 then
			GAMEMODE:Notify(ply, 1, 4, LANGUAGE.vote_specify_reason)
			return ""
		end

		if not ply:Alive() then
			GAMEMODE:Notify(ply, 1, 4, "You must be alive in order to issue a warrant")
			return ""
		end

		for i = 2, #tableargs, 1 do
			reason = reason .. " " .. tableargs[i]
		end
		reason = string.sub(reason, 2)
		if string.len(reason) > 25 then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/warrant", "<25 chars"))
			return ""
		end
		local p = GAMEMODE:FindPlayer(tableargs[1])

		if p and p:Alive() then
			-- If we're the Mayor, set the search warrant
			if t == TEAM_MAYOR then
				SetWarrant(ply, p, reason)
			else -- If we're CP or Chief
				-- Find the mayor
				local m = nil
				for k, v in pairs(player.GetAll()) do
					if v:Team() == TEAM_MAYOR then
						m = v
						break
					end
				end
				-- If we found the mayor
				if m ~= nil and not m.DarkRPVars.AFK then
					-- Request a search warrent for player "p"
					GAMEMODE.ques:Create(string.format(LANGUAGE.warrant_request.."\nReason: "..reason, ply:Nick(), p:Nick()), p:EntIndex() .. "warrant", m, 40, FinishWarrant, ply, p, reason)
					GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.warrant_request2, m:Nick()))
				else
					-- There is no mayor or the mayor is AFK, CPs can set warrants.
					SetWarrant(ply, p, reason)
				end

			end
		else
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end
	return ""
end
AddChatCommand("/warrant", SearchWarrant)
AddChatCommand("/warrent", SearchWarrant) -- Most players can't spell for some reason

local function PlayerWanted(ply, args)
	if not ply:IsCP() then
		GAMEMODE:Notify(ply, 1, 6, string.format(LANGUAGE.must_be_x, "cop/mayor", "/wanted"))
	else
		local tableargs = string.Explode(" ", args)
		local reason = ""

		if #tableargs == 1 then
			GAMEMODE:Notify(ply, 1, 4, LANGUAGE.vote_specify_reason)
			return ""
		end

		if not ply:Alive() then
			GAMEMODE:Notify(ply, 1, 4, "You must be alive in order to make someone wanted")
			return ""
		end

		for i = 2, #tableargs, 1 do
			reason = reason .. " " .. tableargs[i]
		end
		reason = string.sub(reason, 2)
		if string.len(reason) > 22 then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/wanted", "<23 chars"))
			return ""
		end
		local p = GAMEMODE:FindPlayer(tableargs[1])

		if p and p:Alive() and not p:isArrested() and not p.DarkRPVars.wanted then
			hook.Call("PlayerWanted", GAMEMODE, ply, p, reason)

			p:SetDarkRPVar("wanted", true)
			p:SetDarkRPVar("wantedReason", tostring(reason))
			for a, b in pairs(player.GetAll()) do
				b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.wanted_by_police, p:Nick()) ..
					"\nReason: " .. tostring(reason) ..
					"\nOrdered by: " .. (IsValid(ply) and ply:Nick() or "Disconnected player"))
				b:PrintMessage(HUD_PRINTCONSOLE, ply:Nick() .. " has made " .. p:Nick() .. " wanted by police for " ..tostring(reason))
			end
			timer.Create(p:UniqueID() .. " wantedtimer", GAMEMODE.Config.wantedtime, 1, function() TimerUnwanted(ply, p) end)
		else
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		end
	end
	return ""
end
AddChatCommand("/wanted", PlayerWanted)
AddChatCommand("/wantid", PlayerWanted) -- Inspired by the /warrent for people not spelling write. You can rewrite so you can want like this: STEAM_0:0:29257121 stupid kid

local function PlayerUnWanted(ply, args)
	if not ply:IsCP() then
		GAMEMODE:Notify(ply, 1, 6, string.format(LANGUAGE.must_be_x, "cop/mayor", "/unwanted"))
	else
		local p = GAMEMODE:FindPlayer(args)
		if p and p:Alive() and p.DarkRPVars.wanted then
			hook.Call("PlayerUnWanted", GAMEMODE, ply, p)
			p:SetDarkRPVar("wanted", false)
			for a, b in pairs(player.GetAll()) do
				b:PrintMessage(HUD_PRINTCENTER, string.format(LANGUAGE.wanted_expired, p:Nick()) ..
					"\nRevoked by: " .. ply:Nick())
				b:PrintMessage(HUD_PRINTCONSOLE, string.format(LANGUAGE.wanted_expired, p:Nick()) ..
					"\nRevoked by: " .. ply:Nick())
			end
			timer.Destroy(p:UniqueID() .. " wantedtimer")
		else
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "Player: "..tostring(args)))
		end
	end
	return ""
end
AddChatCommand("/unwanted", PlayerUnWanted)
AddChatCommand("/unwantid", PlayerUnWanted) -- Can also do like /wantid but for now it's also for grammar mistakes made by people.


/*---------------------------------------------------------
Spawning
 ---------------------------------------------------------*/
local function SetSpawnPos(ply, args)
	if not ply:HasPriv("rp_commands") then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.created_spawnpos, v.name))
		end
	end

	if t then
		DB.StoreTeamSpawnPos(t, pos)
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: "..tostring(args)))
	end

	return ""
end
AddChatCommand("/setspawn", SetSpawnPos)

local function AddSpawnPos(ply, args)
	if not ply:HasPriv("rp_commands") then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.updated_spawnpos, v.name))
		end
	end

	if t then
		DB.AddTeamSpawnPos(t, pos)
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: "..tostring(args)))
	end

	return ""
end
AddChatCommand("/addspawn", AddSpawnPos)

local function RemoveSpawnPos(ply, args)
	if not ply:HasPriv("rp_commands") then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t

	for k,v in pairs(RPExtraTeams) do
		if args == v.command then
			t = k
			GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.updated_spawnpos, v.name))
		end
	end

	if t then
		DB.RemoveTeamSpawnPos(t)
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "team: "..tostring(args)))
	end

	return ""
end
AddChatCommand("/removespawn", RemoveSpawnPos)

/*---------------------------------------------------------
 Helps
 ---------------------------------------------------------*/
local function HelpCop(ply)
	ply:SetSelfDarkRPVar("helpCop", not ply.DarkRPVars.helpCop)
	return ""
end
AddChatCommand("/cophelp", HelpCop)

local function HelpMayor(ply)
	ply:SetSelfDarkRPVar("helpMayor", not ply.DarkRPVars.helpMayor)
	return ""
end
AddChatCommand("/mayorhelp", HelpMayor)

local function HelpBoss(ply)
	ply:SetSelfDarkRPVar("helpBoss", not ply.DarkRPVars.helpBoss)
	return ""
end
AddChatCommand("/mobbosshelp", HelpBoss)

local function HelpAdmin(ply)
	ply:SetSelfDarkRPVar("helpAdmin", not ply.DarkRPVars.helpAdmin)
	return ""
end
AddChatCommand("/adminhelpmenu", HelpAdmin)

local function closeHelp(ply)
	ply:SetSelfDarkRPVar("helpCop", false)
	ply:SetSelfDarkRPVar("helpBoss", false)
	ply:SetSelfDarkRPVar("helpMayor", false)
	ply:SetSelfDarkRPVar("helpAdmin", false)
	return ""
end
AddChatCommand("/x", closeHelp)

function GM:ShowTeam(ply)
	umsg.Start("KeysMenu", ply)
		umsg.Bool(ply:GetEyeTrace().Entity:IsVehicle())
	umsg.End()
end

function GM:ShowHelp(ply)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
end

local function LookPersonUp(ply, cmd, args)
	if not args[1] then
		ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "argument", ""))
		return
	end
	local P = GAMEMODE:FindPlayer(args[1])
	if not IsValid(P) then
		if ply:EntIndex() ~= 0 then
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end
	if ply:EntIndex() ~= 0 then
		ply:PrintMessage(2, "Nick: ".. P:Nick())
		ply:PrintMessage(2, "Steam name: "..P:SteamName())
		ply:PrintMessage(2, "Steam ID: "..P:SteamID())
	else
		print("Nick: ".. P:Nick())
		print("Steam name: "..P:SteamName())
		print("Steam ID: "..P:SteamID())
	end
end
concommand.Add("rp_lookup", LookPersonUp)

local function GiveHint()
	if not GAMEMODE.Config.advertisements then return end
	local text = LANGUAGE.hints[math.random(1, #LANGUAGE.hints)]

	for k,v in pairs(player.GetAll()) do
		GAMEMODE:TalkToPerson(v, Color(150,150,150,150), text)
	end
end

timer.Create("hints", 60, 0, GiveHint)

/*---------------------------------------------------------
 Items
 ---------------------------------------------------------*/
local function MakeLetter(ply, args, type)
	if not GAMEMODE.Config.letters then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/write / /type", ""))
		return ""
	end

	if ply.maxletters and ply.maxletters >= GAMEMODE.Config.maxletters then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.limit, "letter"))
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)), "/write / /type"))
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime()

	-- Instruct the player's letter window to open

	local ftext = string.gsub(args, "//", "\n")
	ftext = string.gsub(ftext, "\\n", "\n") .. "\n\nYours,\n"..ply:Nick()
	local length = string.len(ftext)

	local numParts = math.floor(length / 39) + 1

	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)

	local letter = ents.Create("letter")
	letter:SetModel("models/props_c17/paper01.mdl")
	letter.dt.owning_ent = ply
	letter.ShareGravgun = true
	letter:SetPos(trace.HitPos)
	letter.nodupe = true
	letter:Spawn()

	letter:GetTable().Letter = true
	letter.type = type
	letter.numPts = numParts

	local startpos = 1
	local endpos = 39
	letter.Parts = {}
	for k=1, numParts do
		table.insert(letter.Parts, string.sub(ftext, startpos, endpos))
		startpos = startpos + 39
		endpos = endpos + 39
	end
	letter.SID = ply.SID

	GAMEMODE:PrintMessageAll(2, string.format(LANGUAGE.created_x, ply:Nick(), "mail"))
	if not ply.maxletters then
		ply.maxletters = 0
	end
	ply.maxletters = ply.maxletters + 1
	timer.Simple(600, function() if IsValid(letter) then letter:Remove() end end)
end

local function WriteLetter(ply, args)
	if args == "" then return "" end
	MakeLetter(ply, args, 1)
	return ""
end
AddChatCommand("/write", WriteLetter)

local function TypeLetter(ply, args)
	if args == "" then return "" end
	MakeLetter(ply, args, 2)
	return ""
end
AddChatCommand("/type", TypeLetter)

local function RemoveLetters(ply)
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	GAMEMODE:Notify(ply, 4, 4, string.format(LANGUAGE.cleaned_up, "mails"))
	return ""
end
AddChatCommand("/removeletters", RemoveLetters)

local function SetPrice(ply, args)
	if args == "" then return "" end

	local a = tonumber(args)
	if not a then return "" end
	local b = math.Clamp(math.floor(a), GAMEMODE.Config.pricemin, (GAMEMODE.Config.pricecap ~= 0 and GAMEMODE.Config.pricecap) or 500)
	local trace = {}

	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if not IsValid(tr.Entity) then GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "gunlab / druglab / microwave")) return "" end

	local class = tr.Entity:GetClass()
	if IsValid(tr.Entity) and (class == "gunlab" or class == "microwave" or class == "drug_lab") and tr.Entity.SID == ply.SID then
		tr.Entity.dt.price = b
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "gunlab / druglab / microwave"))
	end
	return ""
end
AddChatCommand("/price", SetPrice)
AddChatCommand("/setprice", SetPrice)

local function BuyPistol(ply, args)
	if args == "" then return "" end
	if ply:isArrested() then return "" end

	if not GAMEMODE.Config.enablebuypistol then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/buy", ""))
		return ""
	end
	if GAMEMODE.Config.noguns then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/buy", ""))
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local class = nil
	local model = nil

	local custom = false
	local price = 0
	for k,v in pairs(CustomShipments) do
		if v.seperate and string.lower(v.name) == string.lower(args) then
			custom = v
			class = v.entity
			model = v.model
			price = v.pricesep
			local canbuy = false

			if not GAMEMODE.Config.restrictbuypistol or
			(GAMEMODE.Config.restrictbuypistol and (not v.allowed[1] or table.HasValue(v.allowed, ply:Team()))) then
				canbuy = true
			end

			if v.customCheck and not v.customCheck(ply) then
				GAMEMODE:Notify(ply, 1, 4, "You're not allowed to purchase this item")
				return ""
			end

			if not canbuy then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buy"))
				return ""
			end
		end
	end

	if not class then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unavailable, "weapon"))
		return ""
	end

	if not ply:CanAfford(price) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "/buy"))
		return ""
	end

	local weapon = ents.Create("spawned_weapon")
	weapon:SetModel(model)
	weapon.weaponclass = class
	weapon.ShareGravgun = true
	weapon:SetPos(tr.HitPos)
	weapon.ammoadd = weapons.Get(class) and weapons.Get(class).Primary.DefaultClip
	weapon.nodupe = true
	weapon:Spawn()

	if IsValid( weapon ) then
		ply:AddMoney(-price)
		GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, args, tostring(price)))
	end

	return ""
end
AddChatCommand("/buy", BuyPistol)

local function BuyShipment(ply, args)
	if args == "" then return "" end

	if ply.LastShipmentSpawn and ply.LastShipmentSpawn > (CurTime() - GAMEMODE.Config.ShipmentSpamTime) then
		GAMEMODE:Notify(ply, 1, 4, "Please wait before spawning another shipment.")
		return ""
	end
	ply.LastShipmentSpawn = CurTime()

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if ply:isArrested() then return "" end

	local found = false
	local foundKey
	for k,v in pairs(CustomShipments) do
		if string.lower(args) == string.lower(v.name) and not v.noship then
			found = v
			foundKey = k
			local canbecome = false
			for a,b in pairs(v.allowed) do
				if ply:Team() == b then
					canbecome = true
				end
			end

			if v.customCheck and not v.customCheck(ply) then
				GAMEMODE:Notify(ply, 1, 4, "You're not allowed to purchase this item")
				return ""
			end

			if not canbecome then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buyshipment"))
				return ""
			end
		end
	end

	if not found then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyshipment", args))
		return ""
	end

	local cost = found.price

	if not ply:CanAfford(cost) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "shipment"))
		return ""
	end

	local crate = ents.Create("spawned_shipment")
	crate.SID = ply.SID
	crate.dt.owning_ent = ply
	crate:SetContents(foundKey, found.amount, found.weight)

	crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
	crate.nodupe = true
	crate:Spawn()
	crate:SetPlayer(ply)
	if found.shipmodel then
		crate:SetModel(found.shipmodel)
		crate:PhysicsInit(SOLID_VPHYSICS)
		crate:SetMoveType(MOVETYPE_VPHYSICS)
		crate:SetSolid(SOLID_VPHYSICS)
	end

	local phys = crate:GetPhysicsObject()
	phys:Wake()

	if IsValid( crate ) then
		ply:AddMoney(-cost)
		GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, args, CUR .. tostring(cost)))
	end

	return ""
end
AddChatCommand("/buyshipment", BuyShipment)

local function BuyVehicle(ply, args)
	if ply:isArrested() then return "" end
	if args == "" then return "" end
	local found = false
	for k,v in pairs(CustomVehicles) do
		if string.lower(v.name) == string.lower(args) then found = CustomVehicles[k] break end
	end
	if not found then return "" end
	if found.allowed and not table.HasValue(found.allowed, ply:Team()) then GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/buyvehicle")) return "" end

	if not ply.Vehicles then ply.Vehicles = 0 end
	if GAMEMODE.Config.maxvehicles and ply.Vehicles >= GAMEMODE.Config.maxvehicles then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.limit, "vehicle"))
		return ""
	end

	if not ply:CanAfford(found.price) then GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "vehicle")) return "" end
	ply:AddMoney(-found.price)
	GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, found.name, CUR .. found.price))

	local Vehicle = list.Get("Vehicles")[found.name]
	if not Vehicle then GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", "")) return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply
	local tr = util.TraceLine(trace)

	local ent = ents.Create(Vehicle.Class)
	if not ent then return "" end
	ent:SetModel(Vehicle.Model)
	if Vehicle.KeyValues then
		for k, v in pairs(Vehicle.KeyValues) do
			ent:SetKeyValue(k, v)
		end
	end

	local Angles = ply:GetAngles()
	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 180
	ent:SetAngles(Angles)
	ent:SetPos(tr.HitPos)
	ent.VehicleName = found.name
	ent.VehicleTable = Vehicle
	ent.Owner = ply
	ent.OwnerID = ply:SteamID()
	ent:Spawn()
	ent:Activate()
	ent.SID = ply.SID
	ent.ClassOverride = Vehicle.Class
	if Vehicle.Members then
		table.Merge(ent, Vehicle.Members)
	end
	ent:Own(ply)
	gamemode.Call("PlayerSpawnedVehicle", ply, ent) -- VUMod compatability

	return ""
end
AddChatCommand("/buyvehicle", BuyVehicle)

for k,v in pairs(DarkRPEntities) do
	local function buythis(ply, args)
		if ply:isArrested() then return "" end
		if type(v.allowed) == "table" and not table.HasValue(v.allowed, ply:Team()) then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, v.cmd))
			return ""
		end
		local cmdname = string.gsub(v.ent, " ", "_")

		if v.customCheck and not v.customCheck(ply) then
			GAMEMODE:Notify(ply, 1, 4, "You're not allowed to purchase this item")
			return ""
		end

		local max = tonumber(v.max or 3)

		if ply["max"..cmdname] and tonumber(ply["max"..cmdname]) >= tonumber(max) then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.limit, v.cmd))
			return ""
		end

		if not ply:CanAfford(v.price) then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, v.cmd))
			return ""
		end
		ply:AddMoney(-v.price)

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)

		local item = ents.Create(v.ent)
		item.dt = item.dt or {}
		item.dt.owning_ent = ply
		item:SetPos(tr.HitPos)
		item.SID = ply.SID
		item.onlyremover = true
		item:Spawn()
		GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, v.name, CUR..v.price))
		if not ply["max"..cmdname] then
			ply["max"..cmdname] = 0
		end
		ply["max"..cmdname] = ply["max"..cmdname] + 1
		return ""
	end
	AddChatCommand(v.cmd, buythis)
end

local function BuyAmmo(ply, args)
	if args == "" then return "" end

	if ply:isArrested() then return "" end

	if GAMEMODE.Config.noguns then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "ammo", ""))
		return ""
	end

	local found
	for k,v in pairs(GAMEMODE.AmmoTypes) do
		if v.ammoType == args then
			found = v
			break
		end
	end

	if not found or (found.customCheck and not found.customCheck(ply)) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unavailable, "ammo"))
		return ""
	end

	if not ply:CanAfford(found.price) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "ammo"))
		return ""
	end

	GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, found.name, CUR..tostring(found.price)))
	ply:AddMoney(-found.price)

	ply:GiveAmmo(found.amountGiven, args)

	return ""
end
AddChatCommand("/buyammo", BuyAmmo)

local function BuyHealth(ply)
	local cost = GAMEMODE.Config.healthcost
	if not tobool(GAMEMODE.Config.enablebuyhealth) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/buyhealth", ""))
		return ""
	end
	if not ply:Alive() then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyhealth", ""))
		return ""
	end
	if not ply:CanAfford(cost) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, "/buyhealth"))
		return ""
	end
	if ply:Team() ~= TEAM_MEDIC and team.NumPlayers(TEAM_MEDIC) > 0 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyhealth", ""))
		return ""
	end
	if ply.StartHealth and ply:Health() >= ply.StartHealth then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/buyhealth", ""))
		return ""
	end
	ply.StartHealth = ply.StartHealth or 100
	ply:AddMoney(-cost)
	GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.you_bought_x, "health", CUR .. tostring(cost)))
	ply:SetHealth(ply.StartHealth)
	return ""
end
AddChatCommand("/buyhealth", BuyHealth)

/*---------------------------------------------------------
 Jobs
 ---------------------------------------------------------*/
local function CreateAgenda(ply, args)
	if DarkRPAgendas[ply:Team()] then
		ply:SetDarkRPVar("agenda", args)

		GAMEMODE:Notify(ply, 2, 4, LANGUAGE.agenda_updated)
		for k,v in pairs(DarkRPAgendas[ply:Team()].Listeners) do
			for a,b in pairs(team.GetPlayers(v)) do
				GAMEMODE:Notify(b, 2, 4, LANGUAGE.agenda_updated)
			end
		end
	else
		GAMEMODE:Notify(ply, 1, 6, string.format(LANGUAGE.unable, "agenda", "Incorrect team"))
	end
	return ""
end
AddChatCommand("/agenda", CreateAgenda)

local function GetHelp(ply, args)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
	return ""
end
AddChatCommand("/help", GetHelp)

local function ChangeJob(ply, args)
	if args == "" then return "" end

	if ply:isArrested() then
		GAMEMODE:Notify(ply, 1, 5, string.format(LANGUAGE.unable, "/job", ">2"))
		return ""
	end

	if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(10 - (CurTime() - ply.LastJob)), "/job"))
		return ""
	end
	ply.LastJob = CurTime()

	if not ply:Alive() then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", ""))
		return ""
	end

	if not GAMEMODE.Config.customjobs then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/job", ""))
		return ""
	end

	local len = string.len(args)

	if len < 3 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", ">2"))
		return ""
	end

	if len > 25 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/job", "<26"))
		return ""
	end

	local jl = string.lower(args)
	local t = ply:Team()

	for k,v in pairs(RPExtraTeams) do
		if jl == v.name then
			ply:ChangeTeam(k)
		end
	end
	GAMEMODE:NotifyAll(2, 4, string.format(LANGUAGE.job_has_become, ply:Nick(), args))
	ply:UpdateJob(args)
	return ""
end
AddChatCommand("/job", ChangeJob)

local function FinishDemote(choice, v)
	v.IsBeingDemoted = nil
	if choice == 1 then
		v:TeamBan()
		if v:Alive() then
			v:ChangeTeam(TEAM_CITIZEN, true)
			if v:isArrested() then
				v:Arrest()
			end
		else
			v.demotedWhileDead = true
		end

		GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.demoted, v:Nick()))
	else
		GAMEMODE:NotifyAll(1, 4, string.format(LANGUAGE.demoted_not, v:Nick()))
	end
end

local function Demote(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		GAMEMODE:Notify(ply, 1, 4, LANGUAGE.vote_specify_reason)
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 99 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demote", "<100"))
		return ""
	end
	local p = GAMEMODE:FindPlayer(tableargs[1])
	if p == ply then
		GAMEMODE:Notify(ply, 1, 4, "Can't demote yourself.")
		return ""
	end

	if p then
		if CurTime() - ply.LastVoteCop < 80 then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demote"))
			return ""
		end
		if p:Team() == TEAM_CITIZEN then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demote", ""))
		else
			GAMEMODE:TalkToPerson(p, team.GetColor(ply:Team()), "(DEMOTE) "..ply:Nick(),Color(255,0,0,255), "I want to demote you. Reason: "..reason, p)
			GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.demote_vote_started, ply:Nick(), p:Nick()))
			p.IsBeingDemoted = true
			GAMEMODE.vote:Create(p:Nick() .. ":\n"..string.format(LANGUAGE.demote_vote_text, reason), p:EntIndex() .. "votecop"..ply:EntIndex(), p, 20, FinishDemote, true)
			ply:GetTable().LastVoteCop = CurTime()
		end
		return ""
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		return ""
	end
end
AddChatCommand("/demote", Demote)

local function ExecSwitchJob(answer, ent, ply, target)
	if answer ~= 1 then return end
	local Pteam = ply:Team()
	local Tteam = target:Team()

	if not ply:ChangeTeam(Tteam) then return end
	if not target:ChangeTeam(Pteam) then
		ply:ChangeTeam(Pteam, true) -- revert job change
		return
	end
	GAMEMODE:Notify(ply, 2, 4, LANGUAGE.team_switch)
	GAMEMODE:Notify(target, 2, 4, LANGUAGE.team_switch)
end

local function SwitchJob(ply) --Idea by Godness.
	if not GAMEMODE.Config.allowjobswitch then return "" end
	local eyetrace = ply:GetEyeTrace()
	if not eyetrace or not eyetrace.Entity or not eyetrace.Entity:IsPlayer() then return "" end
	GAMEMODE.ques:Create("Switch job with "..ply:Nick().."?", "switchjob"..tostring(ply:EntIndex()), eyetrace.Entity, 30, ExecSwitchJob, ply, eyetrace.Entity)
	return ""
end
AddChatCommand("/switchjob", SwitchJob)
AddChatCommand("/switchjobs", SwitchJob)
AddChatCommand("/jobswitch", SwitchJob)


local function DoTeamBan(ply, args, cmdargs)
	if not args or args == "" then return "" end

	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[1] then
			ply:PrintMessage(HUD_PRINTNOTIFY, "rp_teamban [player name/ID] [team name/id] Use this to ban a player from a certain team")
			return ""
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		local a,b = string.find(args, " ")
		ent = string.sub(args, 1, a - 1)
		Team = string.sub(args, a + 1)
	end

	local target = GAMEMODE:FindPlayer(ent)
	if not target or not IsValid(target) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player!"))
		return ""
	end

	if (not FAdmin or not FAdmin.Access.PlayerHasPrivilege(ply, "rp_commands", target)) and not ply:IsAdmin() then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/teamban"))
		return ""
	end

	local found = false
	for k,v in pairs(RPExtraTeams) do
		if string.lower(v.name) == string.lower(Team) or  string.lower(v.command) == string.lower(Team) then
			Team = k
			found = true
			break
		end
		if k == tonumber(Team or -1) then
			found = true
			break
		end
	end

	if not found then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "job!"))
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[tonumber(Team)] = 1
	GAMEMODE:NotifyAll(0, 5, ply:Nick() .. " has banned " ..target:Nick() .. " from being a " .. team.GetName(tonumber(Team)))
	return ""
end
AddChatCommand("/teamban", DoTeamBan)
concommand.Add("rp_teamban", DoTeamBan)

local function DoTeamUnBan(ply, args, cmdargs)
	if not ply:IsAdmin() then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/teamunban"))
		return ""
	end

	local ent = args
	local Team = args
	if cmdargs then
		if not cmdargs[1] then
			ply:PrintMessage(HUD_PRINTNOTIFY, "rp_teamunban [player name/ID] [team name/id] Use this to unban a player from a certain team")
			return ""
		end
		ent = cmdargs[1]
		Team = cmdargs[2]
	else
		local a,b = string.find(args, " ")
		ent = string.sub(args, 1, a - 1)
		Team = string.sub(args, a + 1)
	end

	local target = GAMEMODE:FindPlayer(ent)
	if not target or not IsValid(target) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player!"))
		return ""
	end

	local found = false
	for k,v in pairs(RPExtraTeams) do
		if string.lower(v.name) == string.lower(Team) or  string.lower(v.command) == string.lower(Team) then
			Team = k
			found = true
			break
		end
		if k == tonumber(Team or -1) then
			found = true
			break
		end
	end

	if not found then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "job!"))
		return ""
	end
	if not target.bannedfrom then target.bannedfrom = {} end
	target.bannedfrom[tonumber(Team)] = nil
	GAMEMODE:NotifyAll(1, 5, ply:Nick() .. " has unbanned " ..target:Nick() .. " from being a " .. team.GetName(tonumber(Team)))
	return ""
end
AddChatCommand("/teamunban", DoTeamUnBan)
concommand.Add("rp_teamunban", DoTeamUnBan)


/*---------------------------------------------------------
Talking
 ---------------------------------------------------------*/
local function PM(ply, args)
	local namepos = string.find(args, " ")
	if not namepos then return "" end

	local name = string.sub(args, 1, namepos - 1)
	local msg = string.sub(args, namepos + 1)
	if msg == "" then return "" end
	target = GAMEMODE:FindPlayer(name)

	if target then
		local col = team.GetColor(ply:Team())
		GAMEMODE:TalkToPerson(target, col, "(PM) "..ply:Nick(), Color(255,255,255,255), msg, ply)
		GAMEMODE:TalkToPerson(ply, col, "(PM) "..ply:Nick(), Color(255,255,255,255), msg, ply)
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(name)))
	end

	return ""
end
AddChatCommand("/pm", PM)

local function Whisper(ply, args)
	local DoSay = function(text)
		if text == "" then return "" end
		GAMEMODE:TalkToRange(ply, "(".. LANGUAGE.whisper .. ") " .. ply:Nick(), text, 90)
	end
	return args, DoSay
end
AddChatCommand("/w", Whisper)

local function Yell(ply, args)
	local DoSay = function(text)
		if text == "" then return "" end
		GAMEMODE:TalkToRange(ply, "(".. LANGUAGE.yell .. ") " .. ply:Nick(), text, 550)
	end
	return args, DoSay
end
AddChatCommand("/y", Yell)

local function Me(ply, args)
	if args == "" then return "" end

	local DoSay = function(text)
		if text == "" then return "" end
		if GAMEMODE.Config.alltalk then
			for _, target in pairs(player.GetAll()) do
				GAMEMODE:TalkToPerson(target, team.GetColor(ply:Team()), ply:Nick() .. " " .. text)
			end
		else
			GAMEMODE:TalkToRange(ply, ply:Nick() .. " " .. text, "", 250)
		end
	end
	return args, DoSay
end
AddChatCommand("/me", Me)

local function OOC(ply, args)
	if not GAMEMODE.Config.ooc then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "OOC", ""))
		return ""
	end

	local DoSay = function(text)
		if text == "" then return "" end
		local col = team.GetColor(ply:Team())
		local col2 = Color(255,255,255,255)
		if not ply:Alive() then
			col2 = Color(255,200,200,255)
			col = col2
		end
		for k,v in pairs(player.GetAll()) do
			GAMEMODE:TalkToPerson(v, col, "(OOC) "..ply:Name(), col2, text, ply)
		end
	end
	return args, DoSay
end
AddChatCommand("//", OOC, true)
AddChatCommand("/a", OOC, true)
AddChatCommand("/ooc", OOC, true)

local function PlayerAdvertise(ply, args)
	if args == "" then return "" end
	local DoSay = function(text)
		if text == "" then return end
		for k,v in pairs(player.GetAll()) do
			local col = team.GetColor(ply:Team())
			GAMEMODE:TalkToPerson(v, col, LANGUAGE.advert .." "..ply:Nick(), Color(255,255,0,255), text, ply)
		end
	end
	return args, DoSay
end
AddChatCommand("/advert", PlayerAdvertise)

local function MayorBroadcast(ply, args)
	if args == "" then return "" end
	if ply:Team() ~= TEAM_MAYOR then GAMEMODE:Notify(ply, 1, 4, "You have to be mayor") return "" end
	local DoSay = function(text)
		if text == "" then return end
		for k,v in pairs(player.GetAll()) do
			local col = team.GetColor(ply:Team())
			GAMEMODE:TalkToPerson(v, col, "[Broadcast!] " ..ply:Nick(), Color(170, 0, 0,255), text, ply)
		end
	end
	return args, DoSay
end
AddChatCommand("/broadcast", MayorBroadcast)

local function SetRadioChannel(ply,args)
	if tonumber(args) == nil or tonumber(args) < 0 or tonumber(args) > 99 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/channel", "0<channel<100"))
		return ""
	end
	GAMEMODE:Notify(ply, 2, 4, "Channel set to "..args.."!")
	ply.RadioChannel = tonumber(args)
	return ""
end
AddChatCommand("/channel", SetRadioChannel)

local function SayThroughRadio(ply,args)
	if not ply.RadioChannel then ply.RadioChannel = 1 end
	if not args or args == "" then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/radio", ""))
		return ""
	end
	local DoSay = function(text)
		if text == "" then return end
		for k,v in pairs(player.GetAll()) do
			if v.RadioChannel == ply.RadioChannel then
				GAMEMODE:TalkToPerson(v, Color(180,180,180,255), "Radio ".. tostring(ply.RadioChannel), Color(180,180,180,255), text, ply)
			end
		end
	end
	return args, DoSay
end
AddChatCommand("/radio", SayThroughRadio)

local function CombineRequest(ply, args)
	if args == "" then return "" end
	local t = ply:Team()

	local DoSay = function(text)
		if text == "" then return end
		for k, v in pairs(player.GetAll()) do
			if v:Team() == TEAM_POLICE or v:Team() == TEAM_CHIEF or v == ply then
				GAMEMODE:TalkToPerson(v, team.GetColor(ply:Team()), LANGUAGE.request ..ply:Nick(), Color(255,0,0,255), text, ply)
			end
		end
	end
	return args, DoSay
end
AddChatCommand("/cr", CombineRequest)

local function GroupMsg(ply, args)
	if args == "" then return "" end
	local DoSay = function(text)
		if text == "" then return end
		local t = ply:Team()
		local audience = {}

		if ply:IsCP() then
			for k, v in pairs(player.GetAll()) do
				if v:IsCP() then table.insert(audience, v) end
			end
		elseif t == TEAM_MOB or t == TEAM_GANG then
			for k, v in pairs(player.GetAll()) do
				local vt = v:Team()
				if vt == TEAM_MOB or vt == TEAM_GANG then table.insert(audience, v) end
			end
		end

		for k, v in pairs(audience) do
			local col = team.GetColor(ply:Team())
			GAMEMODE:TalkToPerson(v, col, LANGUAGE.group..ply:Nick(),Color(255,255,255,255), text, ply)
		end
	end
	return args, DoSay
end
AddChatCommand("/g", GroupMsg)

-- here's the new easter egg. Easier to find, more subtle, doesn't only credit FPtje and unib5
-- WARNING: DO NOT EDIT THIS
-- You can edit DarkRP but you HAVE to credit the original authors!
-- You even have to credit all the previous authors when you rename the gamemode.
local CreditsWait = true
local function GetDarkRPAuthors(ply, args)
	local target = GAMEMODE:FindPlayer(args); -- Only send to one player. Prevents spamming
	if not IsValid(target) then
		GAMEMODE:Notify(ply, 1, 4, "Player does not exist")
		return ""
	end

	if not CreditsWait then GAMEMODE:Notify(ply, 1, 4, "Wait with that") return "" end
	CreditsWait = false
	timer.Simple(60, function() CreditsWait = true end)--so people don't spam it

	local rf = RecipientFilter()
	rf:AddPlayer(target)
	if ply ~= target then
		rf:AddPlayer(ply)
	end

	umsg.Start("DarkRP_Credits", rf)
	umsg.End()

	return ""
end
AddChatCommand("/credits", GetDarkRPAuthors)

/*---------------------------------------------------------
 Money
 ---------------------------------------------------------*/
local function GiveMoney(ply, args)
	if args == "" then return "" end

	if not tonumber(args) then
		return ""
	end
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount < 1 then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", ""))
			return
		end

		if not ply:CanAfford(amount) then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""))
			return ""
		end

		local RP = RecipientFilter()
		RP:AddAllPlayers()

		umsg.Start("anim_giveitem", RP)
			umsg.Entity(ply)
		umsg.End()
		ply.anim_GivingItem = true

		timer.Simple(1.2, function()
			if IsValid(ply) then
				local trace2 = ply:GetEyeTrace()
				if IsValid(trace2.Entity) and trace2.Entity:IsPlayer() and trace2.Entity:GetPos():Distance(ply:GetPos()) < 150 then
					if not ply:CanAfford(amount) then
						GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""))
						return ""
					end
					DB.PayPlayer(ply, trace2.Entity, amount)

					GAMEMODE:Notify(trace2.Entity, 0, 4, string.format(LANGUAGE.has_given, ply:Nick(), CUR .. tostring(amount)))
					GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.you_gave, trace2.Entity:Nick(), CUR .. tostring(amount)))
					DB.Log(ply:Nick().. " (" .. ply:SteamID() .. ") has given "..CUR .. tostring(amount).. " to "..trace2.Entity:Nick() .. " (" .. trace2.Entity:SteamID() .. ")")
				end
			end
		end)
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "player"))
	end
	return ""
end
AddChatCommand("/give", GiveMoney)

local function DropMoney(ply, args)
	if args == "" then return "" end

	if not tonumber(args) then
		return ""
	end
	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", ""))
		return ""
	end

	if not ply:CanAfford(amount) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""))
		return ""
	end

	ply:AddMoney(-amount)
	local RP = RecipientFilter()
	RP:AddAllPlayers()

	umsg.Start("anim_dropitem", RP)
		umsg.Entity(ply)
	umsg.End()
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) then
			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply

			local tr = util.TraceLine(trace)
			DarkRPCreateMoneyBag(tr.HitPos, amount)
			DB.Log(ply:Nick().. " (" .. ply:SteamID() .. ") has dropped "..CUR .. tostring(amount))
		end
	end)

	return ""
end
AddChatCommand("/dropmoney", DropMoney)
AddChatCommand("/moneydrop", DropMoney)

local function CreateCheque(ply, args)
	local argt = string.Explode(" ", args)
	local recipient = GAMEMODE:FindPlayer(argt[1])
	local amount = tonumber(argt[2]) or 0

	if not recipient then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", "recipient (1)"))
		return ""
	end

	if amount <= 1 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "argument", "amount (2)"))
		return ""
	end

	if not ply:CanAfford(amount) then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.cant_afford, ""))
		return ""
	end

	if IsValid(ply) and IsValid(recipient) then
		ply:AddMoney(-amount)
	end

	umsg.Start("anim_dropitem", RecipientFilter():AddAllPlayers())
		umsg.Entity(ply)
	umsg.End()
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) and IsValid(recipient) then
			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply

			local tr = util.TraceLine(trace)
			local Cheque = ents.Create("darkrp_cheque")
			Cheque:SetPos(tr.HitPos)
			Cheque.dt.owning_ent = ply
			Cheque.dt.recipient = recipient

			Cheque.dt.amount = amount
			Cheque:Spawn()
		end
	end)
	return ""
end
AddChatCommand("/cheque", CreateCheque)
AddChatCommand("/check", CreateCheque) -- for those of you who can't spell

local function MakeZombieSoundsAsHobo(ply)
	if not ply.nospamtime then
		ply.nospamtime = CurTime() - 2
	end
	if not TEAM_HOBO or ply:Team() ~= TEAM_HOBO or CurTime() < (ply.nospamtime + 1.3) or (IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "weapon_bugbait") then
		return
	end
	ply.nospamtime = CurTime()
	local ran = math.random(1,3)
	if ran == 1 then
		ply:EmitSound("npc/zombie/zombie_voice_idle"..tostring(math.random(1,14))..".wav", 100,100)
	elseif ran == 2 then
		ply:EmitSound("npc/zombie/zombie_pain"..tostring(math.random(1,6))..".wav", 100,100)
	elseif ran == 3 then
		ply:EmitSound("npc/zombie/zombie_alert"..tostring(math.random(1,3))..".wav", 100,100)
	end
end
concommand.Add("_hobo_emitsound", MakeZombieSoundsAsHobo)

/*---------------------------------------------------------
 Mayor stuff
 ---------------------------------------------------------*/
local LotteryPeople = {}
local LotteryON = false
local LotteryAmount = 0
local CanLottery = CurTime()
local function EnterLottery(answer, ent, initiator, target, TimeIsUp)
	if answer == 1 and not table.HasValue(LotteryPeople, target) then
		if not target:CanAfford(LotteryAmount) then
			GAMEMODE:Notify(target, 1,4, string.format(LANGUAGE.cant_afford, "lottery"))
			return
		end
		table.insert(LotteryPeople, target)
		target:AddMoney(-LotteryAmount)
		GAMEMODE:Notify(target, 0,4, string.format(LANGUAGE.lottery_entered, CUR..tostring(LotteryAmount)))
	elseif answer and not table.HasValue(LotteryPeople, target) then
		GAMEMODE:Notify(target, 1,4, string.format(LANGUAGE.lottery_not_entered, "You"))
	end

	if TimeIsUp then
		LotteryON = false
		CanLottery = CurTime() + 60
		if table.Count(LotteryPeople) == 0 then
			GAMEMODE:NotifyAll(1, 4, LANGUAGE.lottery_noone_entered)
			return
		end
		local chosen = LotteryPeople[math.random(1, #LotteryPeople)]
		chosen:AddMoney(#LotteryPeople * LotteryAmount)
		GAMEMODE:NotifyAll(0,10, string.format(LANGUAGE.lottery_won, chosen:Nick(), CUR .. tostring(#LotteryPeople * LotteryAmount) ))
	end
end

local function DoLottery(ply, amount)
	if ply:Team() ~= TEAM_MAYOR then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/lottery"))
		return ""
	end

	if not GAMEMODE.Config.lottery then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "/lottery", ""))
		return ""
	end

	if #player.GetAll() <= 2 or LotteryON then
		GAMEMODE:Notify(ply, 1, 6, string.format(LANGUAGE.unable, "/lottery", ""))
		return ""
	end

	if CanLottery > CurTime() then
		GAMEMODE:Notify(ply, 1, 5, string.format(LANGUAGE.have_to_wait, tostring(CanLottery - CurTime()), "/lottery"))
		return ""
	end

	amount = tonumber(amount)
	if not amount then
		GAMEMODE:Notify(ply, 1, 5, string.format("Please specify an entry cost ($%i-%i)", GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost))
		return ""
	end

	LotteryAmount = math.Clamp(math.floor(amount), GAMEMODE.Config.minlotterycost, GAMEMODE.Config.maxlotterycost)

	GAMEMODE:NotifyAll(0, 4, "A lottery has started!")

	LotteryON = true
	LotteryPeople = {}
	for k,v in pairs(player.GetAll()) do
		if v ~= ply then
			GAMEMODE.ques:Create("There is a lottery! Participate for " ..CUR.. tostring(LotteryAmount) .. "?", "lottery"..tostring(k), v, 30, EnterLottery, ply, v)
		end
	end
	timer.Create("Lottery", 30, 1, function() EnterLottery(nil, nil, nil, nil, true) end)
	return ""
end
AddChatCommand("/lottery", DoLottery)

local lstat = false
local wait_lockdown = false

local function WaitLock()
	wait_lockdown = false
	lstat = false
	timer.Destroy("spamlock")
end

function GM:Lockdown(ply)
	if not lstat and ply:Team() == TEAM_MAYOR then
		for k,v in pairs(player.GetAll()) do
			v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
		end
		lstat = true
		GAMEMODE:PrintMessageAll(HUD_PRINTTALK , LANGUAGE.lockdown_started)
		RunConsoleCommand("DarkRP_LockDown", 1)
		GAMEMODE:NotifyAll(0, 3, LANGUAGE.lockdown_started)
	end
	return ""
end
concommand.Add("rp_lockdown", function(ply) GAMEMODE:Lockdown(ply) end)
AddChatCommand("/lockdown", function(ply) GAMEMODE:Lockdown(ply) end)

function GM:UnLockdown(ply)
	if lstat and not wait_lockdown and ply:Team() == TEAM_MAYOR then
		GAMEMODE:PrintMessageAll(HUD_PRINTTALK , LANGUAGE.lockdown_ended)
		GAMEMODE:NotifyAll(1, 3, LANGUAGE.lockdown_ended)
		wait_lockdown = true
		RunConsoleCommand("DarkRP_LockDown", 0)
		timer.Create("spamlock", 20, 1, function() WaitLock("") end)
	end
	return ""
end
concommand.Add("rp_unlockdown", function(ply) GAMEMODE:UnLockdown(ply) end)
AddChatCommand("/unlockdown", function(ply) GAMEMODE:UnLockdown(ply) end)

local function MayorSetSalary(ply, cmd, args)
	if ply:EntIndex() == 0 then
		print("Console should use rp_setsalary instead.")
		return
	end

	if not GAMEMODE.Config.enablemayorsetsalary then
		ply:PrintMessage(2, string.format(LANGUAGE.disabled, "rp_setsalary", ""))
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, "rp_setsalary", ""))
		return
	end

	if ply:Team() ~= TEAM_MAYOR then
		ply:PrintMessage(2, string.format(LANGUAGE.incorrect_job, "rp_setsalary"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount or amount < 0 then
		ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "salary", args[2]))
		return
	end

	if amount > GAMEMODE.Config.maxmayorsetsalary then
		ply:PrintMessage(2, string.format(LANGUAGE.invalid_x, "salary", "< " .. GAMEMODE.Config.maxmayorsetsalary))
		return
	end

	local plynick = ply:Nick()
	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local targetteam = target:Team()
		local targetnick = target:Nick()

		if targetteam == TEAM_MAYOR then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "rp_setsalary", ""))
			return
		elseif targetteam == TEAM_POLICE or targetteam == TEAM_CHIEF then
			if amount > GAMEMODE.Config.maxcopsalary then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "salary", "< " .. GAMEMODE.Config.maxcopsalary))
				return
			else
				DB.StoreSalary(target, amount)
				ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount)
				target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount)
			end
		elseif targetteam == TEAM_CITIZEN or targetteam == TEAM_GUN or targetteam == TEAM_MEDIC or targetteam == TEAM_COOK then
			if amount > GAMEMODE.Config.maxnormalsalary then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.invalid_x, "salary", "< " .. GAMEMODE.Config.maxnormalsalary))
				return
			else
				DB.StoreSalary(target, amount)
				ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount)
				target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount)
			end
		elseif targetteam == TEAM_GANG or targetteam == TEAM_MOB then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "rp_setsalary", ""))
			return
		end
	else
		ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
	end
	return
end
concommand.Add("rp_mayor_setsalary", MayorSetSalary)

/*---------------------------------------------------------
 License
 ---------------------------------------------------------*/
local function GrantLicense(answer, Ent, Initiator, Target)
	if answer == 1 then
		GAMEMODE:Notify(Initiator, 0, 4, string.format(LANGUAGE.gunlicense_granted, Target:Nick(), Initiator:Nick()))
		GAMEMODE:Notify(Target, 0, 4, string.format(LANGUAGE.gunlicense_granted, Target:Nick(), Initiator:Nick()))
		Initiator:SetDarkRPVar("HasGunlicense", true)
	else
		GAMEMODE:Notify(Initiator, 1, 4, string.format(LANGUAGE.gunlicense_denied, Target:Nick(), Initiator:Nick()))
	end
end

local function RequestLicense(ply)
	if ply.DarkRPVars.HasGunlicense then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/requestlicense", ""))
		return ""
	end
	local LookingAt = ply:GetEyeTrace().Entity

	local ismayor--first look if there's a mayor
	local ischief-- then if there's a chief
	local iscop-- and then if there's a cop to ask
	for k,v in pairs(player.GetAll()) do
		if v:Team() == TEAM_MAYOR and not v.DarkRPVars.AFK then
			ismayor = true
			break
		end
	end

	if not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_CHIEF and not v.DarkRPVars.AFK then
				ischief = true
				break
			end
		end
	end

	if not ischief and not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_POLICE then
				iscop = true
				break
			end
		end
	end

	if not ismayor and not ischief and not iscop then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/requestlicense", ""))
		return ""
	end

	if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "mayor/chief/cop"))
		return ""
	end

	if ismayor and LookingAt:Team() ~= TEAM_MAYOR then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "mayor"))
		return ""
	elseif ischief and LookingAt:Team() ~= TEAM_CHIEF then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "chief"))
		return ""
	elseif iscop and LookingAt:Team() ~= TEAM_POLICE then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "cop"))
		return ""
	end

	GAMEMODE:Notify(ply, 3, 4, string.format(LANGUAGE.gunlicense_requested, ply:Nick(), LookingAt:Nick()))
	GAMEMODE.ques:Create(string.format(LANGUAGE.gunlicense_question_text, ply:Nick()), "Gunlicense"..ply:EntIndex(), LookingAt, 20, GrantLicense, ply, LookingAt)
	return ""
end
AddChatCommand("/requestlicense", RequestLicense)

local function GiveLicense(ply)
	local ismayor--first look if there's a mayor
	local ischief-- then if there's a chief
	local iscop-- and then if there's a cop to ask
	for k,v in pairs(player.GetAll()) do
		if v:Team() == TEAM_MAYOR and not v.DarkRPVars.AFK then
			ismayor = true
			break
		end
	end

	if not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_CHIEF and not v.DarkRPVars.AFK then
				ischief = true
				break
			end
		end
	end

	if not ischief and not ismayor then
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_POLICE then
				iscop = true
				break
			end
		end
	end

	if ismayor and ply:Team() ~= TEAM_MAYOR then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/givelicense"))
		return ""
	elseif ischief and ply:Team() ~= TEAM_CHIEF then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/givelicense"))
		return ""
	elseif iscop and ply:Team() ~= TEAM_POLICE then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.incorrect_job, "/givelicense"))
		return ""
	end

	local LookingAt = ply:GetEyeTrace().Entity
	if not IsValid(LookingAt) or not LookingAt:IsPlayer() or LookingAt:GetPos():Distance(ply:GetPos()) > 100 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.must_be_looking_at, "player"))
		return ""
	end
	GAMEMODE:Notify(LookingAt, 0, 4, string.format(LANGUAGE.gunlicense_granted, ply:Nick(), LookingAt:Nick()))
	GAMEMODE:Notify(ply, 0, 4, string.format(LANGUAGE.gunlicense_granted, ply:Nick(), LookingAt:Nick()))
	LookingAt:SetDarkRPVar("HasGunlicense", true)
	return ""
end
AddChatCommand("/givelicense", GiveLicense)

local function rp_GiveLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_givelicense"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		target:SetDarkRPVar("HasGunlicense", true)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		GAMEMODE:Notify(target, 1, 4, string.format(LANGUAGE.gunlicense_granted, nick, target:Nick()))
		GAMEMODE:Notify(ply, 2, 4, string.format(LANGUAGE.gunlicense_granted, nick, target:Nick()))
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-gave "..target:Nick().." a gun license")
		if ply:EntIndex() == 0 then
			DB.Log("Console force-gave "..target:Nick().." a gun license", nil, Color(30, 30, 30))
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-gave "..target:Nick().." a gun license", nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_givelicense", rp_GiveLicense)

local function rp_RevokeLicense(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, "rp_revokelicense"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		target:SetDarkRPVar("HasGunlicense", false)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		GAMEMODE:Notify(target, 1, 4, string.format(LANGUAGE.gunlicense_denied, nick, target:Nick()))
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.gunlicense_denied, nick, target:Nick()))
		DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed "..target:Nick().."'s gun license")
		if ply:EntIndex() == 0 then
			DB.Log("Console force-removed "..target:Nick().."'s gun license", nil, Color(30, 30, 30))
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-removed "..target:Nick().."'s gun license", nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_revokelicense", rp_RevokeLicense)

local function FinishRevokeLicense(choice, v)
	if choice == 1 then
		v:SetDarkRPVar("HasGunlicense", false)
		v:StripWeapons()
		GAMEMODE:PlayerLoadout(v)
		GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.gunlicense_removed, v:Nick()))
	else
		GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.gunlicense_not_removed, v:Nick()))
	end
end

local function VoteRemoveLicense(ply, args)
	local tableargs = string.Explode(" ", args)
	if #tableargs == 1 then
		GAMEMODE:Notify(ply, 1, 4, LANGUAGE.vote_specify_reason)
		return ""
	end
	local reason = ""
	for i = 2, #tableargs, 1 do
		reason = reason .. " " .. tableargs[i]
	end
	reason = string.sub(reason, 2)
	if string.len(reason) > 22 then
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demotelicense", "<23"))
		return ""
	end
	local p = GAMEMODE:FindPlayer(tableargs[1])
	if p then
		if CurTime() - ply:GetTable().LastVoteCop < 80 then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), "/demotelicense"))
			return ""
		end
		if ply.DarkRPVars.HasGunlicense then
			GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/demotelicense", ""))
		else
			GAMEMODE:NotifyAll(0, 4, string.format(LANGUAGE.gunlicense_remove_vote_text, ply:Nick(), p:Nick()))
			GAMEMODE.vote:Create(p:Nick() .. ":\n"..string.format(LANGUAGE.gunlicense_remove_vote_text2, reason), p:EntIndex() .. "votecop"..ply:EntIndex(), p, 20, FinishRevokeLicense, true)
			ply:GetTable().LastVoteCop = CurTime()
			GAMEMODE:Notify(ply, 0, 4, LANGUAGE.vote_started)
		end
		return ""
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.could_not_find, "player: "..tostring(args)))
		return ""
	end
end
AddChatCommand("/demotelicense", VoteRemoveLicense)

local function ReportAttacker(ply, cmd, args)

	if cmd != "rp_reportattacker" then // It must be a chat command, so the arguments will be passed to the second argument (cmd)
		args = string.Explode(" ", cmd )
	end

	local name = args[1]
	args[1] = "" // Keep name/reason separate

	local reason = table.concat( args, " ")

	if reason and string.len( reason ) > 22 then GAMEMODE:Notify( ply, 1, 4, string.format( LANGUAGE.unable, "/911", "Reason >22") ) return "" end

	local target = GAMEMODE:FindPlayer( name )
	if target then
		for k, v in pairs(ents.FindByClass("darkrp_console")) do
			v.dt.reporter = ply
			v.dt.reported = target
			v:SetNWString("reason", reason or "(Being) attacked!")
			v:Alarm(30)
			GAMEMODE:Notify(ply, 0, 4, "You have called 911!")
		end
	else
		GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/911", "Enter a player's name"))
	end
	return ""
end
concommand.Add("rp_reportattacker", ReportAttacker)
AddChatCommand("/911", ReportAttacker)

local function ReportEntity(ply, cmd, args)
	local tracedata = {}
	tracedata.start = ply:GetShootPos()
	tracedata.endpos = tracedata.start + ply:GetAimVector() * 1000
	tracedata.filter = ply
	tr = util.TraceLine(tracedata).Entity

	local illegal = {"money_printer", "drug_lab", "drug"}
	if IsValid(tr) and tr.dt and IsValid(tr.dt.owning_ent) and (table.HasValue(illegal, tr:GetClass()) or tr.Illegal) then
		for k, v in pairs(ents.FindByClass("darkrp_console")) do
			v.dt.reporter = ply
			v.dt.reported = tr.dt.owning_ent
			v:SetNWString("reason", tr:GetClass()) -- DTVars dont't handle strings.
			v:Alarm(30)
		end
	end
	return ""
end
concommand.Add("rp_reportentity", ReportEntity)
AddChatCommand("/report", ReportEntity)