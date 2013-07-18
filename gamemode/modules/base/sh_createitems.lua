-- automatically block players from doing certain things with their DarkRP entities
local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}


local checkModel = function(model) return model ~= nil and (CLIENT or util.IsValidModel(model)) end
local requiredTeamItems = {"color", "model", "description", "weapons", "command", "max", "salary", "admin", "vote"}
local validShipment = {model = checkModel, "entity", "price", "amount", "seperate", "allowed"}
local validVehicle = {"name", model = checkModel, "price"}
local validEntity = {"ent", model = checkModel, "price", "max", "cmd", "name"}
local function checkValid(tbl, requiredItems)
	for k,v in pairs(requiredItems) do
		local isFunction = type(v) == "function"

		if (isFunction and not v(tbl[k])) or (not isFunction and tbl[v] == nil) then
			return isFunction and k or v
		end
	end
end

-----------------------------------------------------------
-- Job commands --
-----------------------------------------------------------
local function addTeamCommands(CTeam, max)
	if CLIENT then return end

	if not GAMEMODE:CustomObjFitsMap(CTeam) then return end
	local k = 0
	for num,v in pairs(RPExtraTeams) do
		if v.command == CTeam.command then
			k = num
		end
	end

	if CTeam.vote or CTeam.RequiresVote then
		DarkRP.defineChatCommand("vote"..CTeam.command, function(ply)
			if CTeam.RequiresVote and not CTeam.RequiresVote(ply, k) then
				DarkRP.notify(ply, 1,4, DarkRP.getPhrase("job_doesnt_require_vote_currently"))
				return ""
			end
			if type(CTeam.NeedToChangeFrom) == "number" and ply:Team() ~= CTeam.NeedToChangeFrom then
				DarkRP.notify(ply, 1,4, DarkRP.getPhrase("need_to_be_before", team.GetName(CTeam.NeedToChangeFrom), CTeam.name))
				return ""
			elseif type(CTeam.NeedToChangeFrom) == "table" and not table.HasValue(CTeam.NeedToChangeFrom, ply:Team()) then
				local teamnames = ""
				for a,b in pairs(CTeam.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
				DarkRP.notify(ply, 1,4, DarkRP.getPhrase("need_to_be_before", string.sub(teamnames, 5), CTeam.name))
				return ""
			end

			if CTeam.customCheck and not CTeam.customCheck(ply) then
				DarkRP.notify(ply, 1, 4, CTeam.CustomCheckFailMsg or DarkRP.getPhrase("unable", team.GetName(t), ""))
				return ""
			end
			if #player.GetAll() == 1 then
				DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("vote_alone"))
				ply:changeTeam(k)
				return ""
			end
			if not ply:ChangeAllowed(k) then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/vote"..CTeam.command, DarkRP.getPhrase("banned_or_demoted")))
				return ""
			end
			if CurTime() - ply:GetTable().LastVoteCop < 80 then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), CTeam.command))
				return ""
			end
			if ply:Team() == k then
				DarkRP.notify(ply, 1, 4,  DarkRP.getPhrase("unable", CTeam.command, ""))
				return ""
			end
			local max = CTeam.max
			if max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / #player.GetAll() > max)) then
				DarkRP.notify(ply, 1, 4,  DarkRP.getPhrase("team_limit_reached", CTeam.name))
				return ""
			end
			GAMEMODE.vote:create(DarkRP.getPhrase("wants_to_be", ply:Nick(), CTeam.name), "job", ply, 20, function(vote, choice)
				local ply = vote.target

				if not IsValid(ply) then return end
				if choice >= 0 then
					ply:changeTeam(k)
				else
					DarkRP.notifyAll(1, 4, DarkRP.getPhrase("has_not_been_made_team", ply:Nick(), CTeam.name))
				end
			end)
			ply:GetTable().LastVoteCop = CurTime()
			return ""
		end)
		DarkRP.defineChatCommand(""..CTeam.command, function(ply)
			if ply:hasDarkRPPrivilege("rp_"..CTeam.command) then
				ply:changeTeam(k)
				return ""
			end

			local a = CTeam.admin
			if a > 0 and not ply:IsAdmin()
			or a > 1 and not ply:IsSuperAdmin()
			then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", CTeam.name))
				return ""
			end

			if not CTeam.RequiresVote and
				(a == 0 and not ply:IsAdmin()
				or a == 1 and not ply:IsSuperAdmin()
				or a == 2)
			or CTeam.RequiresVote and CTeam.RequiresVote(ply, k)
			then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_to_make_vote", CTeam.name))
				return ""
			end

			ply:changeTeam(k)
			return ""
		end)
	else
		DarkRP.defineChatCommand(""..CTeam.command, function(ply)
			if CTeam.admin == 1 and not ply:IsAdmin() then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/"..CTeam.command))
				return ""
			end
			if CTeam.admin > 1 and not ply:IsSuperAdmin() then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_sadmin", "/"..CTeam.command))
				return ""
			end
			ply:changeTeam(k)
			return ""
		end)
	end

	concommand.Add("rp_"..CTeam.command, function(ply, cmd, args)
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			ply:PrintMessage(2, DarkRP.getPhrase("need_admin", cmd))
			return
		end

		if CTeam.admin > 1 and not ply:IsSuperAdmin() then
			ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", cmd))
			return
		end

		if CTeam.vote then
			if CTeam.admin >= 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
				ply:PrintMessage(2, DarkRP.getPhrase("need_admin", cmd))
				return
			elseif CTeam.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
				ply:PrintMessage(2, DarkRP.getPhrase("need_to_make_vote", CTeam.name))
				return
			end
		end

		if not args[1] then return end
		local target = DarkRP.findPlayer(args[1])

		if (target) then
			target:changeTeam(k, true)
			if (ply:EntIndex() ~= 0) then
				nick = ply:Nick()
			else
				nick = "Console"
			end
			target:PrintMessage(2, DarkRP.getPhrase("x_made_you_a_y", nick, CTeam.name))
		else
			if (ply:EntIndex() == 0) then
				print(DarkRP.getPhrase("could_not_find", tostring(args[1])))
			else
				ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", tostring(args[1])))
			end
			return
		end
	end)
end

local function addEntityCommands(tblEnt)
	if CLIENT then return end

	local function buythis(ply, args)
		if ply:isArrested() then return "" end
		if type(tblEnt.allowed) == "table" and not table.HasValue(tblEnt.allowed, ply:Team()) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", tblEnt.cmd))
			return ""
		end
		local cmdname = string.gsub(tblEnt.ent, " ", "_")

		if tblEnt.customCheck and not tblEnt.customCheck(ply) then
			DarkRP.notify(ply, 1, 4, tblEnt.CustomCheckFailMsg or DarkRP.getPhrase("not_allowed_to_purchase"))
			return ""
		end

		local max = tonumber(tblEnt.max or 3)

		if ply["max"..cmdname] and tonumber(ply["max"..cmdname]) >= tonumber(max) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", tblEnt.cmd))
			return ""
		end

		if not ply:canAfford(tblEnt.price) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", tblEnt.cmd))

			return ""
		end
		ply:AddMoney(-tblEnt.price)

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)

		local item = ents.Create(tblEnt.ent)
		item.dt = item.dt or {}
		item.dt.owning_ent = ply
		if item.Setowning_ent then item:Setowning_ent(ply) end
		item:SetPos(tr.HitPos)
		item.SID = ply.SID
		item.onlyremover = true
		item.allowed = tblEnt.allowed
		item:Spawn()
		local phys = item:GetPhysicsObject()
		if phys:IsValid() then phys:Wake() end

		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought_x", tblEnt.name, GAMEMODE.Config.currency, tblEnt.price))
		if not ply["max"..cmdname] then
			ply["max"..cmdname] = 0
		end
		ply["max"..cmdname] = ply["max"..cmdname] + 1
		return ""
	end
	DarkRP.defineChatCommand(tblEnt.cmd, buythis)
end

RPExtraTeams = {}
function DarkRP.createJob(Name, colorOrTable, model, Description, Weapons, command, maximum_amount_of_this_class, Salary, admin, Vote, Haslicense, NeedToChangeFrom, CustomCheck)
	local tableSyntaxUsed = colorOrTable.r == nil -- the color is not a color table.

	local CustomTeam = tableSyntaxUsed and colorOrTable or
		{color = colorOrTable, model = model, description = Description, weapons = Weapons, command = command,
			max = maximum_amount_of_this_class, salary = Salary, admin = admin or 0, vote = tobool(Vote), hasLicense = Haslicense,
			NeedToChangeFrom = NeedToChangeFrom, customCheck = CustomCheck
		}
	CustomTeam.name = Name

	local corrupt = checkValid(CustomTeam, requiredTeamItems)
	if corrupt then ErrorNoHalt("Corrupt team \"" ..(CustomTeam.name or "") .. "\": element " .. corrupt .. " is incorrect.\n") end

	table.insert(RPExtraTeams, CustomTeam)
	team.SetUp(#RPExtraTeams, Name, CustomTeam.color)
	local Team = #RPExtraTeams

	timer.Simple(0, function() addTeamCommands(CustomTeam, CustomTeam.max) end)

	// Precache model here. Not right before the job change is done
	if type(CustomTeam.model) == "table" then
		for k,v in pairs(CustomTeam.model) do util.PrecacheModel(v) end
	else
		util.PrecacheModel(CustomTeam.model)
	end
	return Team
end
AddExtraTeam = DarkRP.createJob

RPExtraTeamDoors = {}
function AddDoorGroup(name, ...)
	RPExtraTeamDoors[name] = {...}
end

CustomVehicles = {}
CustomShipments = {}
function DarkRP.createShipment(name, model, entity, price, Amount_of_guns_in_one_shipment, Sold_seperately, price_seperately, noshipment, classes, shipmodel, CustomCheck)
	local tableSyntaxUsed = type(model) == "table"

	local AllowedClasses = classes or {}
	if not classes then
		for k,v in pairs(team.GetAllTeams()) do
			table.insert(AllowedClasses, k)
		end
	end

	local price = tonumber(price)
	local shipmentmodel = shipmodel or "models/Items/item_item_crate.mdl"

	local customShipment = tableSyntaxUsed and model or
		{model = model, entity = entity, price = price, amount = Amount_of_guns_in_one_shipment,
		seperate = Sold_seperately, pricesep = price_seperately, noship = noshipment, allowed = AllowedClasses,
		shipmodel = shipmentmodel, customCheck = CustomCheck, weight = 5}

	customShipment.name = name
	customShipment.allowed = customShipment.allowed or {}

	local corrupt = checkValid(customShipment, validShipment)
	if corrupt then ErrorNoHalt("Corrupt shipment \"" .. (name or "") .. "\": element " .. corrupt .. " is corrupt.\n") end

	if SERVER and FPP then
		FPP.AddDefaultBlocked(blockTypes, customShipment.entity)
	end

	table.insert(CustomShipments, customShipment)
	util.PrecacheModel(customShipment.model)
end
AddCustomShipment = DarkRP.createShipment

function DarkRP.createVehicle(Name_of_vehicle, model, price, Jobs_that_can_buy_it, customcheck)
	local vehicle = istable(Name_of_vehicle) and Name_of_vehicle or
		{name = Name_of_vehicle, model = model, price = price, allowed = Jobs_that_can_buy_it, customCheck = customcheck}

	local found = false
	for k,v in pairs(list.Get("Vehicles")) do
		if string.lower(k) == string.lower(vehicle.name) then found = true break end
	end

	local corrupt = checkValid(vehicle, validVehicle)
	if corrupt then ErrorNoHalt("Corrupt vehicle \"" .. (vehicle.name or "") .. "\": element " .. corrupt .. " is corrupt.\n") end
	if not found then ErrorNoHalt("Vehicle invalid: " .. vehicle.name .. ". Unknown vehicle name.") end

	table.insert(CustomVehicles, vehicle)
end
AddCustomVehicle = DarkRP.createVehicle

/*---------------------------------------------------------------------------
Decides whether a custom job or shipmet or whatever can be used in a certain map
---------------------------------------------------------------------------*/
function GM:CustomObjFitsMap(obj)
	if not obj or not obj.maps then return true end

	local map = string.lower(game.GetMap())
	for k,v in pairs(obj.maps) do
		if string.lower(v) == map then return true end
	end
	return false
end

DarkRPEntities = {}
function DarkRP.createEntity(name, entity, model, price, max, command, classes, CustomCheck)
	local tableSyntaxUsed = type(entity) == "table"

	local tblEnt = tableSyntaxUsed and entity or
		{ent = entity, model = model, price = price, max = max,
		cmd = command, allowed = classes, customCheck = CustomCheck}
	tblEnt.name = name

	if type(tblEnt.allowed) == "number" then
		tblEnt.allowed = {tblEnt.allowed}
	end

	local corrupt = checkValid(tblEnt, validEntity)
	if corrupt then ErrorNoHalt("Corrupt Entity \"" .. (name or "") .. "\": element " .. corrupt .. " is corrupt.\n") end

	if SERVER and FPP then
		FPP.AddDefaultBlocked(blockTypes, tblEnt.ent)
	end

	table.insert(DarkRPEntities, tblEnt)
	timer.Simple(0, function() addEntityCommands(tblEnt) end)
end
AddEntity = DarkRP.createEntity

DarkRPAgendas = {}

function DarkRP.createAgenda(Title, Manager, Listeners)
	if not Manager then
		hook.Add("PlayerSpawn", "AgendaError", function(ply)
		if ply:IsAdmin() then ply:ChatPrint("WARNING: Agenda made incorrectly, there is no manager! failed to load!") end end)
		return
	end
	DarkRPAgendas[Manager] = {Title = Title, Listeners = Listeners}
end
AddAgenda = DarkRP.createAgenda

GM.DarkRPGroupChats = {}
function DarkRP.createGroupChat(funcOrTeam, ...)
	-- People can enter either functions or a list of teams as parameter(s)
	if type(funcOrTeam) == "function" then
		table.insert(GM.DarkRPGroupChats, funcOrTeam)
	else
		local teams = {funcOrTeam, ...}
		table.insert(GM.DarkRPGroupChats, function(ply) return table.HasValue(teams, ply:Team()) end)
	end
end
GM.AddGroupChat = function(GM, ...) DarkRP.createGroupChat(...) end

GM.AmmoTypes = {}

function DarkRP.createAmmoType(ammoType, name, model, price, amountGiven, customCheck)
	table.insert(GM.AmmoTypes, istable(name) and name or {
		ammoType = ammoType,
		name = name,
		model = model,
		price = price,
		amountGiven = amountGiven,
		customCheck = customCheck
	})
end
GM.AddAmmoType = function(GM, ...) DarkRP.createAmmoType(...) end
