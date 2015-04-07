local plyMeta = FindMetaTable("Player");
-- automatically block players from doing certain things with their fprp entities
local blockTypes = {"Physgun1", "Spawning1", "Toolgun1"}

-- Assert function, asserts a property and returns the error if false.
-- Allows f to override err and hints by simply returning them
local ass = function(f, err, hints) return function(...)
	local res = {f(...)}
	table.insert(res, err);
	table.insert(res, hints);

	return unpack(res);
end end

-- Returns whether a value is nil
local isnil = fn.Curry(fn.Eq, 2)(nil);
-- Optional value, when filled in it must meet the conditions
local optional = function(...) return fn.FOr{isnil, ...} end
-- Check the correctness of a model
local checkModel = isstring

-- A table of which each element must meet condition f
local tableOf = function(f) return function(tbl)
	if not istable(tbl) then return false end
	for k,v in pairs(tbl) do if not f(v) then return false end end
	return true
end end

-- Any of the given elements
local oneOf = function(f) return fp{table.HasValue, f} end

-- A table that is nonempty, wrap around tableOf
local nonempty = function(f) return function(tbl) return istable(tbl) and #tbl > 0 and f(tbl) end end

-- A value must be unique amongst all `kind`. Uses optional `hash` function to create custom hashes in the internal table
local unique = function(name, kind, hash)
	return function(v, tbl, env)
		env[name] = env[name] or {}
		local hval = hash and hash(v) or v -- hashed value
		local uEnv = env[name] -- Either specific to `kind` or global

		if kind then
			env[name][kind] = env[name][kind] or {}
			uEnv = env[name][kind]
		end

		if uEnv[hval] then
			return false,
				string.format("This %s does not have a unique value for '%s'.", kind or "thing", name),
				{string.format("There must be some other %s that has the value '%s' for '%s'.", kind or "thing", tostring(v), name)}
		end

		uEnv[hval] = true
		return true
	end
end

local uniqueJob = function(v, tbl)
	local job = fprp.getJobByCommand(v);
	if job then return false, "This job does not have a unique command.", {"There must be some other job that has the same command."} end
	return true
end

-- Template for a correct job
local requiredTeamItems = {
	color       = ass(tableOf(isnumber), "The color must be a Color value.", {"Color values look like this: Color(r, g, b, a), where r, g, b and a are numbers between 0 and 255."}),
	model       = ass(fn.FOr{checkModel, nonempty(tableOf(checkModel))}, "The model must either be a table of correct model strings or a single correct model string.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
	description = ass(isstring, "The description must be a string."),
	weapons     = ass(optional(tableOf(isstring)), "The weapons must be a valid table of strings.", {"Example: weapons = {\"med_kit\", \"weapon_bugbait\"},"}),
	command     = ass(fn.FAnd{isstring, uniqueJob}, "The command must be a string."),
	max         = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}}, "The max must be a number greater than or equal to zero.", {"Zero means infinite.", "A decimal between 0 and 1 is seen as a percentage."}),
	salary      = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}}, "The salary must be a number greater than zero."),
	admin       = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}, fp{fn.Gte, 2}}, "The admin value must be a number greater than or equal to zero and smaller than three."),
	vote        = ass(optional(isbool), "The vote must be either true or false."),

	-- Optional advanced stuff
	category              = ass(optional(isstring), "The category must be the name of an existing category!"),
	sortOrder             = ass(optional(isnumber), "The sortOrder must be a number."),
	buttonColor           = ass(optional(tableOf(isnumber)), "The buttonColor must be a Color value."),
	label                 = ass(optional(isstring), "The label must be a valid string."),
	ammo                  = ass(optional(tableOf(isnumber)), "The ammo must be a table containing numbers.", {"See example on http://wiki.fprp.com/index.php/fprp:CustomJobFields"}),
	hasLicense            = ass(optional(isbool), "The hasLicense must be either true or false."),
	NeedToChangeFrom      = ass(optional(tableOf(isnumber), isnumber), "The NeedToChangeFrom must be either an existing team or a table of existing teams", {"Is there a job here that doesn't exist (anymore)?"}),
	customCheck           = ass(optional(isfunction), "The customCheck must be a function."),
	CustomCheckFailMsg    = ass(optional(isstring, isfunction), "The CustomCheckFailMsg must be either a string or a function."),
	modelScale            = ass(optional(isnumber), "The modelScale must be a number."),
	maxpocket             = ass(optional(isnumber), "The maxPocket must be a number."),
	maps                  = ass(optional(tableOf(isstring)), "The maps value must be a table of valid map names."),
	candemote             = ass(optional(isbool), "The candemote value must be either true or false."),
	mayor                 = ass(optional(isbool), "The mayor value must be either true or false."),
	chief                 = ass(optional(isbool), "The chief value must be either true or false."),
	medic                 = ass(optional(isbool), "The medic value must be either true or false."),
	cook                  = ass(optional(isbool), "The cook value must be either true or false."),
	hobo                  = ass(optional(isbool), "The hobo value must be either true or false."),
	CanPlayerSuicide      = ass(optional(isfunction), "The CanPlayerSuicide must be a function."),
	PlayerCanPickupWeapon = ass(optional(isfunction), "The PlayerCanPickupWeapon must be a function."),
	PlayerDeath           = ass(optional(isfunction), "The PlayerDeath must be a function."),
	PlayerLoadout         = ass(optional(isfunction), "The PlayerLoadout must be a function."),
	PlayerSelectSpawn     = ass(optional(isfunction), "The PlayerSelectSpawn must be a function."),
	PlayerSetModel        = ass(optional(isfunction), "The PlayerSetModel must be a function."),
	PlayerSpawn           = ass(optional(isfunction), "The PlayerSpawn must be a function."),
	PlayerSpawnProp       = ass(optional(isfunction), "The PlayerSpawnProp must be a function."),
	RequiresVote          = ass(optional(isfunction), "The RequiresVote must be a function."),
	ShowSpare1            = ass(optional(isfunction), "The ShowSpare1 must be a function."),
	ShowSpare2            = ass(optional(isfunction), "The ShowSpare2 must be a function."),
	canStartVote          = ass(optional(isfunction), "The canStartVote must be a function."),
	canStartVoteReason    = ass(optional(isstring, isfunction), "The canStartVoteReason must be either a string or a function."),
}

-- Template for correct shipment
local validShipment = {
	model    = ass(checkModel, "The model of the shipment must be a valid model.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
	entity   = ass(isstring, "The entity of the shipment must be a string."),
	price    = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getPrice) end, "The price must be an existing number or (for advanced users) the getPrice field must be a function."),
	amount   = ass(fn.FAnd{isnumber, fp{fn.Lte, 0}}, "The amount must be a number greater than zero."),
	seperate = ass(optional(isbool), "the seperate field must be either true or false.", {"It's spelled as 'seperate' because of a really old mistake."}),
	pricesep = ass(function(v, tbl) return not tbl.seperate or isnumber(v) and v >= 0 end, "The pricesep must be a number greater than or equal to zero."),
	allowed  = ass(optional(tableOf(isnumber), isnumber), "The allowed field must be either an existing team or a table of existing teams", {"Is there a job here that doesn't exist (anymore)?"}),

	category           = ass(optional(isstring), "The category must be the name of an existing category!"),
	sortOrder          = ass(optional(isnumber), "The sortOrder must be a number."),
	buttonColor        = ass(optional(tableOf(isnumber)), "The buttonColor must be a Color value."),
	label              = ass(optional(isstring), "The label must be a valid string."),
	noship             = ass(optional(isbool), "The noship must be either true or false."),
	shipmodel          = ass(optional(checkModel), "The shipmodel must be a valid model.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
	customCheck        = ass(optional(isfunction), "The customCheck must be a function."),
	CustomCheckFailMsg = ass(optional(isstring, isfunction), "The CustomCheckFailMsg must be either a string or a function."),
	weight             = ass(optional(isnumber), "The weight must be a number."),
	spareammo          = ass(optional(isnumber), "The spareammo must be a number."),
	clip1              = ass(optional(isnumber), "The clip1 must be a number."),
	clip2              = ass(optional(isnumber), "The clip2 must be a number."),
	shipmentClass      = ass(optional(isstring), "The shipmentClass must be a string."),
	onBought           = ass(optional(isfunction), "The onBought must be a function."),
	getPrice           = ass(optional(isfunction), "The getPrice must be a function."),
}

-- Template for correct vehicle
local validVehicle = {
	name     = ass(isstring, "The name of the vehicle must be a string."),
	model    = ass(checkModel, "The model of the vehicle must be a valid model.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
	price    = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getPrice) end, "The price must be an existing number or (for advanced users) the getPrice field must be a function."),
	allowed  = ass(optional(tableOf(isnumber), isnumber), "The allowed field must be either an existing team or a table of existing teams", {"Is there a job here that doesn't exist (anymore)?"}),

	category           = ass(optional(isstring), "The category must be the name of an existing category!"),
	sortOrder          = ass(optional(isnumber), "The sortOrder must be a number."),
	distance           = ass(optional(isnumber), "The distance must be a number."),
	angle              = ass(optional(isangle), "The distance must be a valid Angle."),
	buttonColor        = ass(optional(tableOf(isnumber)), "The buttonColor must be a Color value."),
	label              = ass(optional(isstring), "The label must be a valid string."),
	customCheck        = ass(optional(isfunction), "The customCheck must be a function."),
	CustomCheckFailMsg = ass(optional(isstring, isfunction), "The CustomCheckFailMsg must be either a string or a function."),
	getPrice           = ass(optional(isfunction), "The getPrice must be a function."),
}

-- Template for correct entity
local validEntity = {
	ent   = ass(isstring, "The name of the entity must be a string."),
	model = ass(checkModel, "The model of the entity must be a valid model.", {"This error could happens when the model does not exist on the server.", "Are you sure the model path is right?", "Is the model from an addon that is not properly installed?"}),
	price = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getPrice) end, "The price must be an existing number or (for advanced users) the getPrice field must be a function."),
	max   = ass(function(v, tbl) return isnumber(v) or isfunction(tbl.getMax) end, "The max must be an existing number or (for advanced users) the getMax field must be a function."),
	cmd   = ass(fn.FAnd{isstring, unique("cmd", "entity")}, "The cmd must be a valid string."),
	name  = ass(isstring, "The name must be a valid string."),

	category           = ass(optional(isstring), "The category must be the name of an existing category!"),
	sortOrder          = ass(optional(isnumber), "The sortOrder must be a number."),
	buttonColor        = ass(optional(tableOf(isnumber)), "The buttonColor must be a Color value."),
	label              = ass(optional(isstring), "The label must be a valid string."),
	customCheck        = ass(optional(isfunction), "The customCheck must be a function."),
	CustomCheckFailMsg = ass(optional(isstring, isfunction), "The CustomCheckFailMsg must be either a string or a function."),
	getPrice           = ass(optional(isfunction), "The getPrice must be a function."),
}

local validAgenda = {
	Title = ass(isstring, "The title must be a string."),
	Manager = ass(fn.FOr{isnumber, nonempty(tableOf(isnumber))}, "The Manager must either be a single team or a non-empty table of existing teams.", {"Is there a job here that doesn't exist (anymore)?"}),
	Listeners = ass(nonempty(tableOf(isnumber)), "The Listeners must be a non-empty table of existing teams.",
		{
			"Is there a job here that doesn't exist (anymore)?",
			"Are you trying to have multiple manager jobs in this agenda? In that case you must put the list of manager jobs in curly braces.",
			[[Like so: fprp.createAgenda("Some agenda", {TEAM_MANAGER1, TEAM_MANAGER2}, {TEAM_LISTENER1, TEAM_LISTENER2})]]
		});
}

local validCategory = {
	name                      = ass(isstring, "The name must be a string."),
	categorises               = ass(oneOf{"jobs", "entities", "shipments", "weapons", "vehicles", "ammo"},
		[[The categorises must be one of "jobs", "entities", "shipments", "weapons", "vehicles", "ammo"]],
		{"Mind that this is case sensitive.", "Also mind the quotation marks."}),
	startExpanded             = ass(isbool, "The startExpanded must be either true or false."),
	color                     = ass(tableOf(isnumber), "The color must be a Color value."),
	canSee                    = ass(optional(isfunction), "The canSee must be a function."),
	sortOrder                 = ass(optional(isnumber), "The sortOrder must be a number."),
}

-- Check template against actual implementation
local env = {} -- environment used to be check propositions between multiple tables
local function checkValid(tbl, requiredItems, oEnv) -- Allow override environment
	for k,v in pairs(requiredItems) do
		local correct, err, hints = tbl[v] ~= nil
		if isfunction(v) then correct, err, hints = v(tbl[k], tbl, oEnv or env) end
		err = err or string.format("Element '%s' is corrupt!", k);
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
		fprp.declareChatCommand{
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

		fprp.declareChatCommand{
			command = CTeam.command,
			description = "Become " .. CTeam.name .. " and skip the vote.",
			delay = 1.5,
			condition = fn.FAnd {
				fn.FOr {
					fn.Curry(fn.Flip(plyMeta.hasfprpPrivilege), 2)("rp_"..CTeam.command),
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
						)();
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
		fprp.declareChatCommand{
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
		fprp.defineChatCommand("vote"..CTeam.command, function(ply)
			if CTeam.RequiresVote and not CTeam.RequiresVote(ply, k) then
				fprp.notify(ply, 1,4, fprp.getPhrase("job_doesnt_require_vote_currently"));
				return ""
			end

			if CTeam.canStartVote and not CTeam.canStartVote(ply) then
				local reason = isfunction(CTeam.canStartVoteReason) and CTeam.canStartVoteReason(ply, CTeam) or CTeam.canStartVoteReason or ""
				fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/vote"..CTeam.command, reason));
				return ""
			end

			if CTeam.admin == 1 and not ply:IsAdmin() then
				fprp.notify(ply, 1, 4, fprp.getPhrase("need_admin", "/".."vote"..CTeam.command));
				return ""
			elseif CTeam.admin > 1 and not ply:IsSuperAdmin() then
				fprp.notify(ply, 1, 4, fprp.getPhrase("need_sadmin", "/".."vote"..CTeam.command));
				return ""
			end

			if type(CTeam.NeedToChangeFrom) == "number" and ply:Team() ~= CTeam.NeedToChangeFrom then
				fprp.notify(ply, 1,4, fprp.getPhrase("need_to_be_before", team.GetName(CTeam.NeedToChangeFrom), CTeam.name));
				return ""
			elseif type(CTeam.NeedToChangeFrom) == "table" and not table.HasValue(CTeam.NeedToChangeFrom, ply:Team()) then
				local teamnames = ""
				for a,b in pairs(CTeam.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
				fprp.notify(ply, 1,4, fprp.getPhrase("need_to_be_before", string.sub(teamnames, 5), CTeam.name));
				return ""
			end

			if CTeam.customCheck and not CTeam.customCheck(ply) then
				local message = isfunction(CTeam.CustomCheckFailMsg) and CTeam.CustomCheckFailMsg(ply, CTeam) or
					CTeam.CustomCheckFailMsg or
					fprp.getPhrase("unable", team.GetName(t), "");
				fprp.notify(ply, 1, 4, message);
				return ""
			end
			if not ply:changeAllowed(k) then
				fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/vote"..CTeam.command, fprp.getPhrase("banned_or_demoted")));
				return ""
			end
			if ply:Team() == k then
				fprp.notify(ply, 1, 4,  fprp.getPhrase("unable", CTeam.command, ""));
				return ""
			end
			local max = CTeam.max
			if max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / #player.GetAll() > max)) then
				fprp.notify(ply, 1, 4, fprp.getPhrase("team_limit_reached", CTeam.name));
				return ""
			end
			if ply.LastJob and 10 - (CurTime() - ply.LastJob) >= 0 then
				fprp.notify(ply, 1, 4, fprp.getPhrase("have_to_wait", math.ceil(10 - (CurTime() - ply.LastJob)), GAMEMODE.Config.chatCommandPrefix..CTeam.command));
				return ""
			end
			if #player.GetAll() == 1 then
				fprp.notify(ply, 0, 4, fprp.getPhrase("vote_alone"));
				ply:changeTeam(k);
				return ""
			end
			if CurTime() - ply:GetTable().LastVoteCop < 80 then
				fprp.notify(ply, 1, 4, fprp.getPhrase("have_to_wait", math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), GAMEMODE.Config.chatCommandPrefix..CTeam.command));
				return ""
			end
			fprp.createVote(fprp.getPhrase("wants_to_be", ply:Nick(), CTeam.name), "job", ply, 20, function(vote, choice)
				local ply = vote.target

				if not IsValid(ply) then return end
				if choice >= 0 then
					ply:changeTeam(k);
				else
					fprp.notifyAll(1, 4, fprp.getPhrase("has_not_been_made_team", ply:Nick(), CTeam.name));
				end
			end, nil, nil, {targetTeam = k});
			ply:GetTable().LastVoteCop = CurTime();
			return ""
		end);

		fprp.defineChatCommand(CTeam.command, function(ply)
			if ply:hasfprpPrivilege("rp_"..CTeam.command) then
				ply:changeTeam(k);
				return ""
			end

			local a = CTeam.admin
			if a > 0 and not ply:IsAdmin()
			or a > 1 and not ply:IsSuperAdmin()
			then
				fprp.notify(ply, 1, 4, fprp.getPhrase("need_admin", CTeam.name));
				return ""
			end

			if not CTeam.RequiresVote and
				(a == 0 and not ply:IsAdmin()
				or a == 1 and not ply:IsSuperAdmin()
				or a == 2)
			or CTeam.RequiresVote and CTeam.RequiresVote(ply, k)
			then
				fprp.notify(ply, 1, 4, fprp.getPhrase("need_to_make_vote", CTeam.name));
				return ""
			end

			ply:changeTeam(k);
			return ""
		end);
	else
		fprp.defineChatCommand(CTeam.command, function(ply)
			if CTeam.admin == 1 and not ply:IsAdmin() then
				fprp.notify(ply, 1, 4, fprp.getPhrase("need_admin", "/"..CTeam.command));
				return ""
			end
			if CTeam.admin > 1 and not ply:IsSuperAdmin() then
				fprp.notify(ply, 1, 4, fprp.getPhrase("need_sadmin", "/"..CTeam.command));
				return ""
			end
			ply:changeTeam(k);
			return ""
		end);
	end

	concommand.Add("rp_"..CTeam.command, function(ply, cmd, args)
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			ply:PrintMessage(2, fprp.getPhrase("need_admin", cmd));
			return
		end

		if CTeam.admin > 1 and not ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
			ply:PrintMessage(2, fprp.getPhrase("need_sadmin", cmd));
			return
		end

		if CTeam.vote then
			if CTeam.admin >= 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
				ply:PrintMessage(2, fprp.getPhrase("need_sadmin", cmd));
				return
			elseif CTeam.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
				ply:PrintMessage(2, fprp.getPhrase("need_to_make_vote", CTeam.name));
				return
			end
		end

		if not args or not args[1] then
			if ply:EntIndex() == 0 then
				print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
			else
				ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
			end
			return
		end

		local target = fprp.findPlayer(args[1]);

		if (target) then
			target:changeTeam(k, true);
			local nick
			if (ply:EntIndex() ~= 0) then
				nick = ply:Nick();
			else
				nick = "Console"
			end
			target:PrintMessage(2, fprp.getPhrase("x_made_you_a_y", nick, CTeam.name));
		else
			if (ply:EntIndex() == 0) then
				print(fprp.getPhrase("could_not_find", tostring(args[1])));
			else
				ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])));
			end
		end
	end);
end

local function addEntityCommands(tblEnt)
	fprp.declareChatCommand{
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
			fn.Curry(fn.Flip(plyMeta.canAfford), 2)(tblEnt.price);
		}
	}
	if CLIENT then return end

	-- Default spawning function of an entity
	-- used if tblEnt.spawn is not defined
	local function defaultSpawn(ply, tr, tblEnt)
		local ent = ents.Create(tblEnt.ent);
		if not ent:IsValid() then error("Entity '"..tblEnt.ent.."' does not exist or is not valid.") end
		ent.dt = ent.dt or {}
		ent.dt.owning_ent = ply
		if ent.Setowning_ent then ent:Setowning_ent(ply) end
		ent:SetPos(tr.HitPos);
		-- These must be set before :Spawn();
		ent.SID = ply.SID
		ent.allowed = tblEnt.allowed
		ent.fprpItem = tblEnt
		ent:Spawn();

		local phys = ent:GetPhysicsObject();
		if phys:IsValid() then phys:Wake() end

		return ent
	end

	local function buythis(ply, args)
		if ply:isArrested() then return "" end
		if type(tblEnt.allowed) == "table" and not table.HasValue(tblEnt.allowed, ply:Team()) then
			fprp.notify(ply, 1, 4, fprp.getPhrase("incorrect_job", tblEnt.cmd));
			return ""
		end

		if tblEnt.customCheck and not tblEnt.customCheck(ply) then
			local message = isfunction(tblEnt.CustomCheckFailMsg) and tblEnt.CustomCheckFailMsg(ply, tblEnt) or
				tblEnt.CustomCheckFailMsg or
				fprp.getPhrase("not_allowed_to_purchase");
			fprp.notify(ply, 1, 4, message);
			return ""
		end

		if ply:customEntityLimitReached(tblEnt) then
			fprp.notify(ply, 1, 4, fprp.getPhrase("limit", tblEnt.cmd));
			return ""
		end

		local canbuy, suppress, message, price = hook.Call("canBuyCustomEntity", nil, ply, tblEnt);

		local cost = price or tblEnt.getPrice and tblEnt.getPrice(ply, tblEnt.price) or tblEnt.price

		if not ply:canAfford(cost) then
			fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", tblEnt.cmd));
			return ""
		end

		if canbuy == false then
			if not suppress and message then fprp.notify(ply, 1, 4, message) end
			return ""
		end

		ply:addshekel(-cost);

		local trace = {}
		trace.start = ply:EyePos();
		trace.endpos = trace.start + ply:GetAimVector() * 85
		trace.filter = ply

		local tr = util.TraceLine(trace);

		local ent = (tblEnt.spawn or defaultSpawn)(ply, tr, tblEnt);
		ent.onlyremover = true
		-- Repeat these properties to alleviate work in tblEnt.spawn:
		ent.SID = ply.SID
		ent.allowed = tblEnt.allowed
		ent.fprpItem = tblEnt

		hook.Call("playerBoughtCustomEntity", nil, ply, tblEnt, ent, cost);

		fprp.notify(ply, 0, 4, fprp.getPhrase("you_bought", tblEnt.name, fprp.formatshekel(cost), ""));

		ply:addCustomEntity(tblEnt);
		return ""
	end
	fprp.defineChatCommand(tblEnt.cmd, buythis);
end

RPExtraTeams = {}
local jobByCmd = {}
fprp.getJobByCommand = function(cmd)
	if not jobByCmd[cmd] then return nil, nil end
	return RPExtraTeams[jobByCmd[cmd]], jobByCmd[cmd]
end
plyMeta.getJobTable = fn.FOr{fn.Compose{fn.Curry(fn.Flip(fn.GetValue), 2)(RPExtraTeams), plyMeta.Team}, fn.Curry(fn.Id, 2)({})}
local jobCount = 0
function fprp.createJob(Name, colorOrTable, model, Description, Weapons, command, maximum_amount_of_this_class, Salary, admin, Vote, Haslicense, NeedToChangeFrom, CustomCheck)
	local tableSyntaxUsed = not IsColor(colorOrTable);

	local CustomTeam = tableSyntaxUsed and colorOrTable or
		{color = colorOrTable, model = model, description = Description, weapons = Weapons, command = command,
			max = maximum_amount_of_this_class, salary = Salary, admin = admin or 0, vote = tobool(Vote), hasLicense = Haslicense,
			NeedToChangeFrom = NeedToChangeFrom, customCheck = CustomCheck
		}
	CustomTeam.name = Name
	CustomTeam.default = fprp.fprp_LOADING

	-- Disabled job
	if fprp.fprp_LOADING and fprp.disabledDefaults["jobs"][CustomTeam.command] then return end

	local valid, err, hints = checkValid(CustomTeam, requiredTeamItems);
	if not valid then fprp.error(string.format("Corrupt team: %s!\n%s", CustomTeam.name or "", err), 3, hints) end

	jobCount = jobCount + 1
	CustomTeam.team = jobCount

	CustomTeam.salary = math.floor(CustomTeam.salary);

	CustomTeam.customCheck           = CustomTeam.customCheck           and fp{fprp.simplerrRun, CustomTeam.customCheck}
	CustomTeam.CustomCheckFailMsg = isfunction(CustomTeam.CustomCheckFailMsg) and fp{fprp.simplerrRun, CustomTeam.CustomCheckFailMsg} or CustomTeam.CustomCheckFailMsg
	CustomTeam.CanPlayerSuicide      = CustomTeam.CanPlayerSuicide      and fp{fprp.simplerrRun, CustomTeam.CanPlayerSuicide}
	CustomTeam.PlayerCanPickupWeapon = CustomTeam.PlayerCanPickupWeapon and fp{fprp.simplerrRun, CustomTeam.PlayerCanPickupWeapon}
	CustomTeam.PlayerDeath           = CustomTeam.PlayerDeath           and fp{fprp.simplerrRun, CustomTeam.PlayerDeath}
	CustomTeam.PlayerLoadout         = CustomTeam.PlayerLoadout         and fp{fprp.simplerrRun, CustomTeam.PlayerLoadout}
	CustomTeam.PlayerSelectSpawn     = CustomTeam.PlayerSelectSpawn     and fp{fprp.simplerrRun, CustomTeam.PlayerSelectSpawn}
	CustomTeam.PlayerSetModel        = CustomTeam.PlayerSetModel        and fp{fprp.simplerrRun, CustomTeam.PlayerSetModel}
	CustomTeam.PlayerSpawn           = CustomTeam.PlayerSpawn           and fp{fprp.simplerrRun, CustomTeam.PlayerSpawn}
	CustomTeam.PlayerSpawnProp       = CustomTeam.PlayerSpawnProp       and fp{fprp.simplerrRun, CustomTeam.PlayerSpawnProp}
	CustomTeam.RequiresVote          = CustomTeam.RequiresVote          and fp{fprp.simplerrRun, CustomTeam.RequiresVote}
	CustomTeam.ShowSpare1            = CustomTeam.ShowSpare1            and fp{fprp.simplerrRun, CustomTeam.ShowSpare1}
	CustomTeam.ShowSpare2            = CustomTeam.ShowSpare2            and fp{fprp.simplerrRun, CustomTeam.ShowSpare2}
	CustomTeam.canStartVote          = CustomTeam.canStartVote          and fp{fprp.simplerrRun, CustomTeam.canStartVote}

	jobByCmd[CustomTeam.command] = table.insert(RPExtraTeams, CustomTeam);
	fprp.addToCategory(CustomTeam, "jobs", CustomTeam.category);
	team.SetUp(#RPExtraTeams, Name, CustomTeam.color);
	local Team = #RPExtraTeams

	timer.Simple(0, function()
		declareTeamCommands(CustomTeam);
		addTeamCommands(CustomTeam, CustomTeam.max);
	end);

	// Precache model here. Not right before the job change is done
	if type(CustomTeam.model) == "table" then
		for k,v in pairs(CustomTeam.model) do util.PrecacheModel(v) end
	else
		util.PrecacheModel(CustomTeam.model);
	end
	return Team
end
AddExtraTeam = fprp.createJob

function fprp.removeJob(i)
	local job = RPExtraTeams[i]
	RPExtraTeams[i] = nil
	jobByCmd[job.command] = nil
	jobCount = jobCount - 1
	fprp.removeFromCategory(job, "jobs");
	hook.Run("onJobRemoved", i, job);
	if CLIENT and ValidPanel(fprp.getF4MenuPanel()) then fprp.getF4MenuPanel():Remove() end -- Rebuild entire F4 menu frame
end

RPExtraTeamDoors = {}
function fprp.createEntityGroup(name, ...)
	if fprp.fprp_LOADING and fprp.disabledDefaults["doorgroups"][name] then return end
	RPExtraTeamDoors[name] = {...}
end
AddDoorGroup = fprp.createEntityGroup

CustomVehicles = {}
CustomShipments = {}
local shipByName = {}
fprp.getShipmentByName = function(name)
	name = string.lower(name or "");

	if not shipByName[name] then return nil, nil end
	return CustomShipments[shipByName[name]], shipByName[name]
end

function fprp.createShipment(name, model, entity, price, Amount_of_guns_in_one_shipment, Sold_seperately, price_seperately, noshipment, classes, shipmodel, CustomCheck)
	local tableSyntaxUsed = type(model) == "table"

	local AllowedClasses = classes or {}
	if not classes then
		for k,v in pairs(team.GetAllTeams()) do
			table.insert(AllowedClasses, k);
		end
	end

	local price = tonumber(price);
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
	customShipment.default = fprp.fprp_LOADING

	if fprp.fprp_LOADING and fprp.disabledDefaults["shipments"][customShipment.name] then return end

	local valid, err, hints = checkValid(customShipment, validShipment);
	if not valid then fprp.error(string.format("Corrupt shipment: %s!\n%s", name or "", err), 3, hints) end

	customShipment.allowed = isnumber(customShipment.allowed) and {customShipment.allowed} or customShipment.allowed
	customShipment.customCheck = customShipment.customCheck   and fp{fprp.simplerrRun, customShipment.customCheck}
	CustomVehicles.CustomCheckFailMsg = isfunction(CustomVehicles.CustomCheckFailMsg) and fp{fprp.simplerrRun, CustomVehicles.CustomCheckFailMsg} or CustomVehicles.CustomCheckFailMsg

	if not customShipment.noship then fprp.addToCategory(customShipment, "shipments", customShipment.category) end
	if customShipment.seperate then fprp.addToCategory(customShipment, "weapons", customShipment.category) end

	shipByName[string.lower(name or "")] = table.insert(CustomShipments, customShipment);
	util.PrecacheModel(customShipment.model);
end
AddCustomShipment = fprp.createShipment

function fprp.createVehicle(Name_of_vehicle, model, price, Jobs_that_can_buy_it, customcheck)
	local vehicle = istable(Name_of_vehicle) and Name_of_vehicle or
		{name = Name_of_vehicle, model = model, price = price, allowed = Jobs_that_can_buy_it, customCheck = customcheck}

	vehicle.default = fprp.fprp_LOADING

	if fprp.fprp_LOADING and fprp.disabledDefaults["vehicles"][vehicle.name] then return end

	local found = false
	for k,v in pairs(fprp.getAvailableVehicles()) do
		if string.lower(k) == string.lower(vehicle.name) then found = true break end
	end

	local valid, err, hints = checkValid(vehicle, validVehicle);
	if not valid then fprp.error(string.format("Corrupt vehicle: %s!\n%s", vehicle.name or "", err), 3, hints) end

	if not found then fprp.error("Vehicle invalid: " .. vehicle.name .. ". Unknown vehicle name.", 3) end

	CustomVehicles.customCheck = CustomVehicles.customCheck and fp{fprp.simplerrRun, CustomVehicles.customCheck}
	CustomVehicles.CustomCheckFailMsg = isfunction(CustomVehicles.CustomCheckFailMsg) and fp{fprp.simplerrRun, CustomVehicles.CustomCheckFailMsg} or CustomVehicles.CustomCheckFailMsg

	table.insert(CustomVehicles, vehicle);
	fprp.addToCategory(vehicle, "vehicles", vehicle.category);
end
AddCustomVehicle = fprp.createVehicle

/*---------------------------------------------------------------------------
Decides whether a custom job or shipmet or whatever can be used in a certain map
---------------------------------------------------------------------------*/
function GM:CustomObjFitsMap(obj)
	if not obj or not obj.maps then return true end

	local map = string.lower(game.GetMap());
	for k,v in pairs(obj.maps) do
		if string.lower(v) == map then return true end
	end
	return false
end

fprpEntities = {}
function fprp.createEntity(name, entity, model, price, max, command, classes, CustomCheck)
	local tableSyntaxUsed = type(entity) == "table"

	local tblEnt = tableSyntaxUsed and entity or
		{ent = entity, model = model, price = price, max = max,
		cmd = command, allowed = classes, customCheck = CustomCheck}
	tblEnt.name = name
	tblEnt.default = fprp.fprp_LOADING

	if fprp.fprp_LOADING and fprp.disabledDefaults["entities"][tblEnt.name] then return end

	if type(tblEnt.allowed) == "number" then
		tblEnt.allowed = {tblEnt.allowed}
	end

	local valid, err, hints = checkValid(tblEnt, validEntity);
	if not valid then fprp.error(string.format("Corrupt entity: %s!\n%s", name or "", err), 3, hints) end

	tblEnt.customCheck = tblEnt.customCheck and fp{fprp.simplerrRun, tblEnt.customCheck}
	tblEnt.CustomCheckFailMsg = isfunction(tblEnt.CustomCheckFailMsg) and fp{fprp.simplerrRun, tblEnt.CustomCheckFailMsg} or tblEnt.CustomCheckFailMsg
	tblEnt.getPrice    = tblEnt.getPrice    and fp{fprp.simplerrRun, tblEnt.getPrice}
	tblEnt.getMax      = tblEnt.getMax      and fp{fprp.simplerrRun, tblEnt.getMax}
	tblEnt.spawn       = tblEnt.spawn       and fp{fprp.simplerrRun, tblEnt.spawn}

	-- if SERVER and FPP then
	-- 	FPP.AddDefaultBlocked(blockTypes, tblEnt.ent);
	-- end

	table.insert(fprpEntities, tblEnt);
	fprp.addToCategory(tblEnt, "entities", tblEnt.category);
	timer.Simple(0, function() addEntityCommands(tblEnt) end)
end
AddEntity = fprp.createEntity

-- here for backwards compatibility
fprpAgendas = {}

local agendas = {}
-- Returns the agenda managed by the player
plyMeta.getAgenda = fn.Compose{fn.Curry(fn.Flip(fn.GetValue), 2)(fprpAgendas), plyMeta.Team}

-- Returns the agenda this player is member of
function plyMeta:getAgendaTable()
	return agendas[self:Team()]
end

fprp.getAgendas = fp{fn.Id, agendas}

function fprp.createAgenda(Title, Manager, Listeners)
	if fprp.fprp_LOADING and fprp.disabledDefaults["agendas"][Title] then return end

	local agenda = {Manager = Manager, Title = Title, Listeners = Listeners, ManagersByKey = {}}
	agenda.default = fprp.fprp_LOADING

	local valid, err, hints = checkValid(agenda, validAgenda);
	if not valid then fprp.error(string.format("Corrupt agenda: %s!\n%s", agenda.Title or "", err), 2, hints) end

	for k,v in pairs(Listeners) do
		agendas[v] = agenda
	end

	for k,v in pairs(istable(Manager) and Manager or {Manager}) do
		agendas[v] = agenda
		fprpAgendas[v] = agenda -- backwards compat
		agenda.ManagersByKey[v] = true
	end

	if SERVER then
		timer.Simple(0, function()
			-- Run after scripts have loaded
			agenda.text = hook.Run("agendaUpdated", nil, agenda, "");
		end);
	end
end
AddAgenda = fprp.createAgenda

GM.fprpGroupChats = {}
local groupChatNumber = 0
function fprp.createGroupChat(funcOrTeam, ...)
	local gm = GM or GAMEMODE
	gm.fprpGroupChats = gm.fprpGroupChats or {}
	if fprp.fprp_LOADING then
		groupChatNumber = groupChatNumber + 1
		if fprp.disabledDefaults["groupchat"][groupChatNumber] then return end
	end
	-- People can enter either functions or a list of teams as parameter(s)
	if type(funcOrTeam) == "function" then
		table.insert(gm.fprpGroupChats, fp{fprp.simplerrRun, funcOrTeam});
	else
		local teams = {funcOrTeam, ...}
		table.insert(gm.fprpGroupChats, function(ply) return table.HasValue(teams, ply:Team()) end)
	end
end
GM.AddGroupChat = function(GM, ...) fprp.createGroupChat(...) end

GM.AmmoTypes = {}

function fprp.createAmmoType(ammoType, name, model, price, amountGiven, customCheck)
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
	ammo.default = fprp.fprp_LOADING

	if fprp.fprp_LOADING and fprp.disabledDefaults["ammo"][ammo.name] then return end

	ammo.customCheck = ammo.customCheck and fp{fprp.simplerrRun, ammo.customCheck}
	ammo.CustomCheckFailMsg = isfunction(ammo.CustomCheckFailMsg) and fp{fprp.simplerrRun, ammo.CustomCheckFailMsg} or ammo.CustomCheckFailMsg
	ammo.id = table.insert(gm.AmmoTypes, ammo);

	fprp.addToCategory(ammo, "ammo", ammo.category);
end
GM.AddAmmoType = function(GM, ...) fprp.createAmmoType(...) end

local demoteGroups = {}
function fprp.createDemoteGroup(name, tbl)
	if fprp.fprp_LOADING and fprp.disabledDefaults["demotegroups"][name] then return end
	if not tbl or not tbl[1] then error("No members in the demote group!") end

	local set = demoteGroups[tbl[1]] or disjoint.MakeSet(tbl[1]);
	set.name = name
	for i = 2, #tbl do
		set = (demoteGroups[tbl[i]] or disjoint.MakeSet(tbl[i])) + set
		set.name = name
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

function fprp.getDemoteGroup(teamNr)
	demoteGroups[teamNr] = demoteGroups[teamNr] or disjoint.MakeSet(teamNr);
	return disjoint.FindSet(demoteGroups[teamNr]);
end

fprp.getDemoteGroups = fp{fn.Id, demoteGroups}

local categories = {
	jobs = {},
	entities = {},
	shipments = {},
	weapons = {},
	vehicles = {},
	ammo = {},
}
local categoriesMerged = false -- whether categories and custom items are merged.

fprp.getCategories = fp{fn.Id, categories}

local categoryOrder = function(a, b)
	local aso = a.sortOrder or 100
	local bso = b.sortOrder or 100
	return aso < bso or aso == bso and a.name < b.name
end
function fprp.createCategory(tbl)
	local valid, err, hints = checkValid(tbl, validCategory);
	if not valid then fprp.error(string.format("Corrupt category: %s!\n%s", tbl.name or "", err), 2, hints) end
	tbl.members = {}

	local destination = categories[tbl.categorises]

	local i = table.insert(destination, tbl);
	while i > 1 do
		if categoryOrder(destination[i - 1], tbl) then break end
		destination[i - 1], destination[i] = destination[i], destination[i - 1]
		i = i - 1
	end
end

function fprp.addToCategory(item, kind, cat)
	cat = cat or "Other"
	item.category = cat

	-- The merge process will take care of the category:
	if not categoriesMerged then return end

	-- Post-merge: manual insertion into category
	local cats = categories[kind]
	for _, c in ipairs(cats) do
		if c.name ~= cat then continue end
		table.insert(c.members, item);
		local i = #c.members
		while i > 1 do
			if categoryOrder(c.members[i - 1], item) then break end
			c.members[i - 1], c.members[i] = c.members[i], c.members[i - 1]
			i = i - 1
		end

		return
	end

	fprp.error(string.format([[The category of "%s" ("%s") does not exist!]], item.name, cat), 2, {
		"Make sure the category is created with fprp.createCategory.",
		"The category name is case sensitive!",
		"Categories must be created before fprp finished loading.",
		"When you have a shipment that can also have its weapon sold separately, you need two categories: one for shipments and one for weapons.",
	});
end

function fprp.removeFromCategory(item, kind)
	local cats = categories[kind]
	if not cats then fprp.error(string.format("Invalid category kind '%s'.", kind), 2) end
	local cat = item.category
	if not cat then return end
	for _, v in pairs(cats) do
		if v.name ~= item.category then continue end
		for k, mem in pairs(v.members) do
			if mem ~= item then continue end
			table.remove(v.members, k);
			break
		end
		break
	end
end

-- Assign custom stuff to their categories
local function mergeCategories(customs, catKind, path)
	local categories = categories[catKind]
	local catByName = {}
	for k,v in pairs(categories) do catByName[v.name] = v end
	for k,v in pairs(customs) do
		-- Override default thing categories:
		local catName = v.default and GAMEMODE.Config.CategoryOverride[catKind][v.name] or v.category or "Other"
		local cat = catByName[catName]
		if not cat then
			fprp.error(string.format([[The category of "%s" ("%s") does not exist!]], v.name, catName), 1, {
				"Make sure the category is created with fprp.createCategory.",
				"The category name is case sensitive!",
				"Categories must be created before fprp finished loading."
			}, path, -1, path);
		end

		cat.members = cat.members or {}
		table.insert(cat.members, v);
	end

	-- Sort category members
	for k,v in pairs(categories) do table.sort(v.members, categoryOrder) end
end

hook.Add("loadCustomfprpItems", "mergeCategories", function()
	local shipments = fn.Filter(fc{fn.Not, fp{fn.GetValue, "noship"}}, CustomShipments);
	local guns = fn.Filter(fp{fn.GetValue, "seperate"}, CustomShipments);

	mergeCategories(RPExtraTeams, "jobs", "your jobs");
	mergeCategories(fprpEntities, "entities", "your custom entities");
	mergeCategories(shipments, "shipments", "your custom shipments");
	mergeCategories(guns, "weapons", "your custom weapons");
	mergeCategories(CustomVehicles, "vehicles", "your custom vehicles");
	mergeCategories(GAMEMODE.AmmoTypes, "ammo", "your custom ammo");

	categoriesMerged = true
end);
