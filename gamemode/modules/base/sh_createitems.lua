local plyMeta = FindMetaTable("Player")
-- automatically block players from doing certain things with their DarkRP entities
local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}

-- Assert function, asserts a property and returns the error if false
local ass = function(f, err, hints) return function(...) return f(...), err, hints end end
-- Returns whether a value is nil
local isnil = fp{fn.Eq, nil}
-- Optional value, when filled in it must meet the conditions
local optional = function(...) return fn.FOr{isnil, ...} end
-- Check the correctness of a model
local checkModel = function(model) return isstring(model) and (CLIENT or util.IsValidModel(model)) end

-- A table of which each element must meet condition f
local tableOf = function(f) return function(tbl)
	if not istable(tbl) then return false end
	for k,v in pairs(tbl) do if not f(v) then return false end end
	return true
end end

-- A table that is nonempty, wrap around tableOf
local nonempty = function(f) return function(tbl) return istable(tbl) and #tbl > 0 and f(tbl) end end

-- Template for a correct job
local requiredTeamItems = {
	color       = ass(tableOf(isnumber), "The color must be a Color value.", {"Color values look like this: Color(r, g, b, a), where r, g, b and a are numbers between 0 and 255."}),
	model       = ass(fn.FOr{checkModel, nonempty(tableOf(checkModel))}, "The model must either be a table of correct model strings or a single correct model string."),
	description = ass(isstring, "The description must be a string."),
	weapons     = ass(optional(tableOf(isstring)), "The weapons must be a valid table of strings.", {"Example: weapons = {\"med_kit\", \"weapon_bugbait\"},"}),
	command     = ass(isstring, "The command must be a string."),
	max         = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}}, "The max must be a number greater than or equal to zero.", {"Zero means infinite.", "A decimal between 0 and 1 is seen as a percentage."}),
	salary      = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}}, "The salary must be a number greater than zero."),
	admin       = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}, fp{fn.Gte, 2}}, "The admin value must be a number greater than or equal to zero and smaller than three."),
	vote        = ass(optional(isbool), "The vote must be either true or false."),
}

-- Template for correct shipment
local validShipment = {
	model    = ass(checkModel, "The model of the shipment must be a valid model."),
	entity   = ass(isstring, "The entity of the shipment must be a string."),
	price    = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getPrice) end, "The price must be an existing number or (for advanced users) the getPrice field must be a function."),
	amount   = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}}, "The amount must be a number greater than zero."),
	seperate = ass(optional(isbool), "the seperate field must be either true or false.", {"It's spelled as 'seperate' because of a really old mistake."}),
	allowed  = ass(optional(tableOf(isnumber), isnumber), "The allowed field must be either an existing team or a table of existing teams", {"Is there a job here that doesn't exist (anymore)?"}),
}

-- Template for correct vehicle
local validVehicle = {
	name     = ass(isstring, "The name of the vehicle must be a string."),
	model    = ass(checkModel, "The model of the vehicle must be a valid model."),
	price    = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getPrice) end, "The price must be an existing number or (for advanced users) the getPrice field must be a function."),
	allowed  = ass(optional(tableOf(isnumber), isnumber), "The allowed field must be either an existing team or a table of existing teams", {"Is there a job here that doesn't exist (anymore)?"}),
}

-- Template for correct entity
local validEntity = {
	ent   = ass(isstring, "The name of the entity must be a string."),
	model = ass(checkModel, "The model of the entity must be a valid model."),
	price = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getPrice) end, "The price must be an existing number or (for advanced users) the getPrice field must be a function."),
	max   = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getMax) end, "The max must be an existing number or (for advanced users) the getMax field must be a function."),
	cmd   = ass(isstring, "The cmd must be a valid string."),
	name  = ass(isstring, "The name must be a valid string."),
}

-- Check template against actual implementation
local function checkValid(tbl, requiredItems)
	for k,v in pairs(requiredItems) do
		local correct, err, hints = tbl[v] ~= nil

		if isfunction(v) then correct, err, hints = v(tbl[k], tbl) end

		if not correct then return correct, err, hints end
	end

	return true
end

-----------------------------------------------------------
-- Job commands --
-----------------------------------------------------------
local function declareTeamCommands(CTeam)
	local k = 0
	for num,v in pairs(RPExtraTeams) do
		if v.command == CTeam.command then
			k = num
		end
	end

	if CTeam.vote or CTeam.RequiresVote then
		DarkRP.declareChatCommand{
			command = "vote"..CTeam.command,
			description = "Vote to become " .. CTeam.name .. ".",
			delay = 1.5,
			condition = fn.FAnd
			{
				fn.If(
					fn.Curry(isfunction, 2)(CTeam.RequiresVote),
					fn.Curry(fn.Flip(fn.FOr{fn.Curry(fn.Const, 2)(CTeam.RequiresVote), fn.Curry(fn.Const, 2)(-1)}()), 2)(k),
					fn.Curry(fn.Const, 2)(true)
				)(),
				fn.If(
					fn.Curry(isnumber, 2)(CTeam.NeedToChangeFrom),
					fn.Compose{fn.Curry(fn.Eq, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
					fn.If(
						fn.Curry(istable, 2)(CTeam.NeedToChangeFrom),
						fn.Compose{fn.Curry(table.HasValue, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
						fn.Curry(fn.Const, 2)(true)
					)()
				)(),
				fn.If(
					fn.Curry(isfunction, 2)(CTeam.customCheck),
					CTeam.customCheck,
					fn.Curry(fn.Const, 2)(true)
				)(),
				fn.Compose{fn.Curry(fn.Neq, 2)(k), plyMeta.Team},
				fn.FOr {
					fn.Curry(fn.Lte, 3)(CTeam.admin)(0),
					fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(1), plyMeta.IsAdmin},
					fn.FAnd{fn.Curry(fn.Gte, 3)(CTeam.admin)(2), plyMeta.IsSuperAdmin}
				}
			}
		}

		DarkRP.declareChatCommand{
			command = CTeam.command,
			description = "Become " .. CTeam.name .. " and skip the vote.",
			delay = 1.5,
			condition = fn.FAnd {
				fn.FOr {
					fn.Curry(fn.Flip(plyMeta.hasDarkRPPrivilege), 2)("rp_"..CTeam.command),
					fn.FAnd {
						fn.FOr {
							fn.Curry(fn.Lte, 3)(CTeam.admin)(0),
							fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(1), plyMeta.IsAdmin},
							fn.FAnd{fn.Curry(fn.Gte, 3)(CTeam.admin)(2), plyMeta.IsSuperAdmin}
						},
						fn.If(
							fn.Curry(isfunction, 2)(CTeam.RequiresVote),
							fn.Curry(fn.Flip(fn.FOr{fn.Curry(fn.Const, 2)(CTeam.RequiresVote), fn.Curry(fn.Const, 2)(-1)}()), 2)(k),
							fn.FOr {
								fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(0), plyMeta.IsAdmin},
								fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(1), plyMeta.IsSuperAdmin}
							}
						)()
					}
				},
				fn.Compose{fn.Not, plyMeta.isArrested},
				fn.If(
					fn.Curry(isnumber, 2)(CTeam.NeedToChangeFrom),
					fn.Compose{fn.Curry(fn.Eq, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
					fn.If(
						fn.Curry(istable, 2)(CTeam.NeedToChangeFrom),
						fn.Compose{fn.Curry(table.HasValue, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
						fn.Curry(fn.Const, 2)(true)
					)()
				)(),
				fn.If(
					fn.Curry(isfunction, 2)(CTeam.customCheck),
					CTeam.customCheck,
					fn.Curry(fn.Const, 2)(true)
				)(),
				fn.Compose{fn.Curry(fn.Neq, 2)(k), plyMeta.Team}
			}
		}
	else
		DarkRP.declareChatCommand{
			command = CTeam.command,
			description = "Become " .. CTeam.name .. ".",
			delay = 1.5,
			condition = fn.FAnd
			{
				fn.Compose{fn.Not, plyMeta.isArrested},
				fn.If(
					fn.Curry(isnumber, 2)(CTeam.NeedToChangeFrom),
					fn.Compose{fn.Curry(fn.Eq, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
					fn.If(
						fn.Curry(istable, 2)(CTeam.NeedToChangeFrom),
						fn.Compose{fn.Curry(table.HasValue, 2)(CTeam.NeedToChangeFrom), plyMeta.Team},
						fn.Curry(fn.Const, 2)(true)
					)()
				)(),
				fn.If(
					fn.Curry(isfunction, 2)(CTeam.customCheck),
					CTeam.customCheck,
					fn.Curry(fn.Const, 2)(true)
				)(),
				fn.Compose{fn.Curry(fn.Neq, 2)(k), plyMeta.Team},
				fn.FOr {
					fn.Curry(fn.Lte, 3)(CTeam.admin)(0),
					fn.FAnd{fn.Curry(fn.Eq, 3)(CTeam.admin)(1), plyMeta.IsAdmin},
					fn.FAnd{fn.Curry(fn.Gte, 3)(CTeam.admin)(2), plyMeta.IsSuperAdmin}
				}
			}
		}
	end
end

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

			if CTeam.canStartVote and not CTeam.canStartVote(ply) then
				local reason = isfunction(CTeam.canStartVoteReason) and CTeam.canStartVoteReason(ply, CTeam) or CTeam.canStartVoteReason or ""
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/vote"..CTeam.command, reason))
				return ""
			end

			if CTeam.admin == 1 and not ply:IsAdmin() then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_admin", "/".."vote"..CTeam.command))
				return ""
			elseif CTeam.admin > 1 and not ply:IsSuperAdmin() then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("need_sadmin", "/".."vote"..CTeam.command))
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
				local message = isfunction(CTeam.CustomCheckFailMsg) and CTeam.CustomCheckFailMsg(ply, CTeam) or
					CTeam.CustomCheckFailMsg or
					DarkRP.getPhrase("unable", team.GetName(t), "")
				DarkRP.notify(ply, 1, 4, message)
				return ""
			end
			if not ply:changeAllowed(k) then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/vote"..CTeam.command, DarkRP.getPhrase("banned_or_demoted")))
				return ""
			end
			if ply:Team() == k then
				DarkRP.notify(ply, 1, 4,  DarkRP.getPhrase("unable", CTeam.command, ""))
				return ""
			end
			local max = CTeam.max
			if max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / #player.GetAll() > max)) then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("team_limit_reached", CTeam.name))
				return ""
			end
			if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(10 - (CurTime() - ply.LastJob)), GAMEMODE.Config.chatCommandPrefix..CTeam.command))
				return ""
			end
			if #player.GetAll() == 1 then
				DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("vote_alone"))
				ply:changeTeam(k)
				return ""
			end
			if CurTime() - ply:GetTable().LastVoteCop < 80 then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), GAMEMODE.Config.chatCommandPrefix..CTeam.command))
				return ""
			end
			DarkRP.createVote(DarkRP.getPhrase("wants_to_be", ply:Nick(), CTeam.name), "job", ply, 20, function(vote, choice)
				local ply = vote.target

				if not IsValid(ply) then return end
				if choice >= 0 then
					ply:changeTeam(k)
				else
					DarkRP.notifyAll(1, 4, DarkRP.getPhrase("has_not_been_made_team", ply:Nick(), CTeam.name))
				end
			end, nil, nil, {targetTeam = k})
			ply:GetTable().LastVoteCop = CurTime()
			return ""
		end)

		DarkRP.defineChatCommand(CTeam.command, function(ply)
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
		DarkRP.defineChatCommand(CTeam.command, function(ply)
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

		if CTeam.admin > 1 and not ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
			ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", cmd))
			return
		end

		if CTeam.vote then
			if CTeam.admin >= 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
				ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", cmd))
				return
			elseif CTeam.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
				ply:PrintMessage(2, DarkRP.getPhrase("need_to_make_vote", CTeam.name))
				return
			end
		end

		if not args or not args[1] then
			if ply:EntIndex() == 0 then
				print(DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
			else
				ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
			end
			return
		end

		local target = DarkRP.findPlayer(args[1])

		if (target) then
			target:changeTeam(k, true)
			local nick
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
		end
	end)
end

local function addEntityCommands(tblEnt)
	DarkRP.declareChatCommand{
		command = tblEnt.cmd,
		description = "Purchase a " .. tblEnt.name,
		delay = 2,
		condition = fn.FAnd
		{
			fn.Compose{fn.Not, plyMeta.isArrested},
			fn.If(
				fn.Curry(istable, 2)(tblEnt.allowed),
				fn.Compose{fn.Curry(table.HasValue, 2)(tblEnt.allowed), plyMeta.Team},
				fn.Curry(fn.Const, 2)(true)
			)(),
			fn.If(
				fn.Curry(isfunction, 2)(tblEnt.customCheck),
				tblEnt.customCheck,
				fn.Curry(fn.Const, 2)(true)
			)(),
			fn.Curry(fn.Flip(plyMeta.canAfford), 2)(tblEnt.price)
		}
	}
	if CLIENT then return end

	-- Default spawning function of an entity
	-- used if tblEnt.spawn is not defined
	local function defaultSpawn(ply, tr, tblEnt)
		local ent = ents.Create(tblEnt.ent)
		if not ent:IsValid() then error("Entity '"..tblEnt.ent.."' does not exist or is not valid.") end
		ent.dt = ent.dt or {}
		ent.dt.owning_ent = ply
		if ent.Setowning_ent then ent:Setowning_ent(ply) end
		ent:SetPos(tr.HitPos)
		-- These must be set before :Spawn()
		ent.SID = ply.SID
		ent.allowed = tblEnt.allowed
		ent.DarkRPItem = tblEnt
		ent:Spawn()

		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then phys:Wake() end

		return ent
	end

	local function buythis(ply, args)
		if ply:isArrested() then return "" end
		if type(tblEnt.allowed) == "table" and not table.HasValue(tblEnt.allowed, ply:Team()) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", tblEnt.cmd))
			return ""
		end

		if tblEnt.customCheck and not tblEnt.customCheck(ply) then
			local message = isfunction(tblEnt.CustomCheckFailMsg) and tblEnt.CustomCheckFailMsg(ply, tblEnt) or
				tblEnt.CustomCheckFailMsg or
				DarkRP.getPhrase("not_allowed_to_purchase")
			DarkRP.notify(ply, 1, 4, message)
			return ""
		end

		if ply:customEntityLimitReached(tblEnt) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", tblEnt.cmd))
			return ""
		end

		local canbuy, suppress, message, price = hook.Call("canBuyCustomEntity", nil, ply, tblEnt)

		local cost = price or tblEnt.getPrice and tblEnt.getPrice(ply, tblEnt.price) or tblEnt.price

		if not ply:canAfford(cost) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", tblEnt.cmd))
			return ""
		end

		if canbuy == false then
			if not suppress and message then DarkRP.notify(ply, 1, 4, message) end
			return ""
		end

		ply:addMoney(-cost)

		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace)

		local ent = (tblEnt.spawn or defaultSpawn)(ply, tr, tblEnt)
		ent.onlyremover = true
		-- Repeat these properties to alleviate work in tblEnt.spawn:
		ent.SID = ply.SID
		ent.allowed = tblEnt.allowed
		ent.DarkRPItem = tblEnt

		hook.Call("playerBoughtCustomEntity", nil, ply, tblEnt, ent, cost)

		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_bought", tblEnt.name, DarkRP.formatMoney(cost), ""))

		ply:addCustomEntity(tblEnt)
		return ""
	end
	DarkRP.defineChatCommand(tblEnt.cmd, buythis)
end

RPExtraTeams = {}
local jobByCmd = {}
DarkRP.getJobByCommand = function(cmd)
	if not jobByCmd[cmd] then return nil, nil end
	return RPExtraTeams[jobByCmd[cmd]], jobByCmd[cmd]
end
plyMeta.getJobTable = fn.FOr{fn.Compose{fn.Curry(fn.Flip(fn.GetValue), 2)(RPExtraTeams), plyMeta.Team}, fn.Curry(fn.Id, 2)({})}
local jobCount = 0
function DarkRP.createJob(Name, colorOrTable, model, Description, Weapons, command, maximum_amount_of_this_class, Salary, admin, Vote, Haslicense, NeedToChangeFrom, CustomCheck)
	local tableSyntaxUsed = not IsColor(colorOrTable)

	local CustomTeam = tableSyntaxUsed and colorOrTable or
		{color = colorOrTable, model = model, description = Description, weapons = Weapons, command = command,
			max = maximum_amount_of_this_class, salary = Salary, admin = admin or 0, vote = tobool(Vote), hasLicense = Haslicense,
			NeedToChangeFrom = NeedToChangeFrom, customCheck = CustomCheck
		}
	CustomTeam.name = Name

	-- Disabled job
	if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["jobs"][CustomTeam.command] then return end

	local valid, err, hints = checkValid(CustomTeam, requiredTeamItems)
	if not valid then DarkRP.error(string.format("Corrupt team: %s!\n%s", CustomTeam.name or "", err), 3, hints) end

	jobCount = jobCount + 1
	CustomTeam.team = jobCount

	CustomTeam.salary = math.floor(CustomTeam.salary)

	CustomTeam.customCheck           = CustomTeam.customCheck           and fp{DarkRP.simplerrRun, CustomTeam.customCheck}
	CustomTeam.CustomCheckFailMsg = isfunction(CustomTeam.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, CustomTeam.CustomCheckFailMsg} or CustomTeam.CustomCheckFailMsg
	CustomTeam.CanPlayerSuicide      = CustomTeam.CanPlayerSuicide      and fp{DarkRP.simplerrRun, CustomTeam.CanPlayerSuicide}
	CustomTeam.PlayerCanPickupWeapon = CustomTeam.PlayerCanPickupWeapon and fp{DarkRP.simplerrRun, CustomTeam.PlayerCanPickupWeapon}
	CustomTeam.PlayerDeath           = CustomTeam.PlayerDeath           and fp{DarkRP.simplerrRun, CustomTeam.PlayerDeath}
	CustomTeam.PlayerLoadout         = CustomTeam.PlayerLoadout         and fp{DarkRP.simplerrRun, CustomTeam.PlayerLoadout}
	CustomTeam.PlayerSelectSpawn     = CustomTeam.PlayerSelectSpawn     and fp{DarkRP.simplerrRun, CustomTeam.PlayerSelectSpawn}
	CustomTeam.PlayerSetModel        = CustomTeam.PlayerSetModel        and fp{DarkRP.simplerrRun, CustomTeam.PlayerSetModel}
	CustomTeam.PlayerSpawn           = CustomTeam.PlayerSpawn           and fp{DarkRP.simplerrRun, CustomTeam.PlayerSpawn}
	CustomTeam.PlayerSpawnProp       = CustomTeam.PlayerSpawnProp       and fp{DarkRP.simplerrRun, CustomTeam.PlayerSpawnProp}
	CustomTeam.RequiresVote          = CustomTeam.RequiresVote          and fp{DarkRP.simplerrRun, CustomTeam.RequiresVote}
	CustomTeam.ShowSpare1            = CustomTeam.ShowSpare1            and fp{DarkRP.simplerrRun, CustomTeam.ShowSpare1}
	CustomTeam.ShowSpare2            = CustomTeam.ShowSpare2            and fp{DarkRP.simplerrRun, CustomTeam.ShowSpare2}
	CustomTeam.canStartVote          = CustomTeam.canStartVote          and fp{DarkRP.simplerrRun, CustomTeam.canStartVote}

	jobByCmd[CustomTeam.command] = table.insert(RPExtraTeams, CustomTeam)
	team.SetUp(#RPExtraTeams, Name, CustomTeam.color)
	local Team = #RPExtraTeams

	timer.Simple(0, function()
		declareTeamCommands(CustomTeam)
		addTeamCommands(CustomTeam, CustomTeam.max)
	end)

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
function DarkRP.createEntityGroup(name, ...)
	if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["doorgroups"][name] then return end
	RPExtraTeamDoors[name] = {...}
end
AddDoorGroup = DarkRP.createEntityGroup

CustomVehicles = {}
CustomShipments = {}
local shipByName = {}
DarkRP.getShipmentByName = function(name)
	name = string.lower(name or "")

	if not shipByName[name] then return nil, nil end
	return CustomShipments[shipByName[name]], shipByName[name]
end

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

	if customShipment.separate ~= nil then
		customShipment.seperate = customShipment.separate
	end
	customShipment.name = name
	customShipment.allowed = customShipment.allowed or {}

	if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["shipments"][customShipment.name] then return end

	local valid, err, hints = checkValid(customShipment, validShipment)
	if not valid then DarkRP.error(string.format("Corrupt shipment: %s!\n%s", name or "", err), 3, hints) end

	customShipment.allowed = isnumber(customShipment.allowed) and {customShipment.allowed} or customShipment.allowed
	customShipment.customCheck = customShipment.customCheck   and fp{DarkRP.simplerrRun, customShipment.customCheck}
	CustomVehicles.CustomCheckFailMsg = isfunction(CustomVehicles.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, CustomVehicles.CustomCheckFailMsg} or CustomVehicles.CustomCheckFailMsg

	-- if SERVER and FPP then
	-- 	FPP.AddDefaultBlocked(blockTypes, customShipment.entity)
	-- end

	shipByName[string.lower(name or "")] = table.insert(CustomShipments, customShipment)
	util.PrecacheModel(customShipment.model)
end
AddCustomShipment = DarkRP.createShipment

function DarkRP.createVehicle(Name_of_vehicle, model, price, Jobs_that_can_buy_it, customcheck)
	local vehicle = istable(Name_of_vehicle) and Name_of_vehicle or
		{name = Name_of_vehicle, model = model, price = price, allowed = Jobs_that_can_buy_it, customCheck = customcheck}

	if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["vehicles"][vehicle.name] then return end

	local found = false
	for k,v in pairs(DarkRP.getAvailableVehicles()) do
		if string.lower(k) == string.lower(vehicle.name) then found = true break end
	end

	local valid, err, hints = checkValid(vehicle, validVehicle)
	if not valid then DarkRP.error(string.format("Corrupt vehicle: %s!\n%s", vehicle.name or "", err), 3, hints) end

	if not found then DarkRP.error("Vehicle invalid: " .. vehicle.name .. ". Unknown vehicle name.", 3) end

	CustomVehicles.customCheck = CustomVehicles.customCheck and fp{DarkRP.simplerrRun, CustomVehicles.customCheck}
	CustomVehicles.CustomCheckFailMsg = isfunction(CustomVehicles.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, CustomVehicles.CustomCheckFailMsg} or CustomVehicles.CustomCheckFailMsg

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

	if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["entities"][tblEnt.name] then return end

	if type(tblEnt.allowed) == "number" then
		tblEnt.allowed = {tblEnt.allowed}
	end

	local valid, err, hints = checkValid(tblEnt, validEntity)
	if not valid then DarkRP.error(string.format("Corrupt entity: %s!\n%s", name or "", err), 3, hints) end

	tblEnt.customCheck = tblEnt.customCheck and fp{DarkRP.simplerrRun, tblEnt.customCheck}
	tblEnt.CustomCheckFailMsg = isfunction(tblEnt.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, tblEnt.CustomCheckFailMsg} or tblEnt.CustomCheckFailMsg
	tblEnt.getPrice    = tblEnt.getPrice    and fp{DarkRP.simplerrRun, tblEnt.getPrice}
	tblEnt.getMax      = tblEnt.getMax      and fp{DarkRP.simplerrRun, tblEnt.getMax}
	tblEnt.spawn       = tblEnt.spawn       and fp{DarkRP.simplerrRun, tblEnt.spawn}

	-- if SERVER and FPP then
	-- 	FPP.AddDefaultBlocked(blockTypes, tblEnt.ent)
	-- end

	table.insert(DarkRPEntities, tblEnt)
	timer.Simple(0, function() addEntityCommands(tblEnt) end)
end
AddEntity = DarkRP.createEntity

-- here for backwards compatibility
DarkRPAgendas = {}

local agendas = {}
plyMeta.getAgenda = fn.Compose{fn.Curry(fn.Flip(fn.GetValue), 2)(DarkRPAgendas), plyMeta.Team}

function plyMeta:getAgendaTable()
	local set = agendas[self:Team()]
	return set and disjoint.FindSet(set).value or nil
end

function DarkRP.createAgenda(Title, Manager, Listeners)
	if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["agendas"][Title] then return end

	if not Manager then
		hook.Add("PlayerSpawn", "AgendaError", function(ply)
		if ply:IsAdmin() then ply:ChatPrint("WARNING: Agenda made incorrectly, there is no manager! failed to load!") end end)
		return
	end

	DarkRPAgendas[Manager] = {Manager = Manager, Title = Title, Listeners = Listeners} -- backwards compat

	agendas[Manager] = disjoint.MakeSet(DarkRPAgendas[Manager])

	for k,v in pairs(Listeners) do
		agendas[v] = disjoint.MakeSet(v, agendas[Manager]) -- have the manager as parent
	end

	if SERVER then
		timer.Simple(0, function()
			-- Run after scripts have loaded
			local set = agendas[Manager]
			set = set and disjoint.FindSet(set).value or {}
			set.text = hook.Run("agendaUpdated", nil, DarkRPAgendas[Manager], "")
		end)
	end
end
AddAgenda = DarkRP.createAgenda

GM.DarkRPGroupChats = {}
local groupChatNumber = 0
function DarkRP.createGroupChat(funcOrTeam, ...)
	local gm = GM or GAMEMODE
	gm.DarkRPGroupChats = gm.DarkRPGroupChats or {}
	if DarkRP.DARKRP_LOADING then
		groupChatNumber = groupChatNumber + 1
		if DarkRP.disabledDefaults["groupchat"][groupChatNumber] then return end
	end
	-- People can enter either functions or a list of teams as parameter(s)
	if type(funcOrTeam) == "function" then
		table.insert(gm.DarkRPGroupChats, fp{DarkRP.simplerrRun, funcOrTeam})
	else
		local teams = {funcOrTeam, ...}
		table.insert(gm.DarkRPGroupChats, function(ply) return table.HasValue(teams, ply:Team()) end)
	end
end
GM.AddGroupChat = function(GM, ...) DarkRP.createGroupChat(...) end

GM.AmmoTypes = {}

function DarkRP.createAmmoType(ammoType, name, model, price, amountGiven, customCheck)
	local gm = GM or GAMEMODE
	gm.AmmoTypes = gm.AmmoTypes or {}
	local ammo = istable(name) and name or {
		name = name,
		model = model,
		price = price,
		amountGiven = amountGiven,
		customCheck = customCheck
	}
	ammo.ammoType = ammoType

	if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["ammo"][ammo.name] then return end

	ammo.customCheck = ammo.customCheck and fp{DarkRP.simplerrRun, ammo.customCheck}
	ammo.CustomCheckFailMsg = isfunction(ammo.CustomCheckFailMsg) and fp{DarkRP.simplerrRun, ammo.CustomCheckFailMsg} or ammo.CustomCheckFailMsg
	table.insert(gm.AmmoTypes, ammo)
end
GM.AddAmmoType = function(GM, ...) DarkRP.createAmmoType(...) end

local demoteGroups = {}
function DarkRP.createDemoteGroup(name, tbl)
	if DarkRP.DARKRP_LOADING and DarkRP.disabledDefaults["demotegroups"][name] then return end
	if not tbl or not tbl[1] then error("No members in the demote group!") end

	local set = demoteGroups[tbl[1]] or disjoint.MakeSet(tbl[1])
	for i = 2, #tbl do
		set = set + (demoteGroups[tbl[i]] or disjoint.MakeSet(tbl[i]))
	end

	for _, teamNr in pairs(tbl) do
		if demoteGroups[teamNr] then
			-- Unify the sets if there was already one there
			demoteGroups[teamNr] = demoteGroups[teamNr] + set
		else
			demoteGroups[teamNr] = set
		end
	end
end

function DarkRP.getDemoteGroup(teamNr)
	demoteGroups[teamNr] = demoteGroups[teamNr] or disjoint.MakeSet(teamNr)
	return disjoint.FindSet(demoteGroups[teamNr])
end
