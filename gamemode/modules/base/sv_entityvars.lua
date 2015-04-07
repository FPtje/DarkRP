local meta = FindMetaTable("Player");

/*---------------------------------------------------------------------------
Pooled networking strings
---------------------------------------------------------------------------*/
util.AddNetworkString("fprp_InitializeVars");
util.AddNetworkString("fprp_PlayerVar");
util.AddNetworkString("fprp_PlayerVarRemoval");
util.AddNetworkString("fprp_fprpVarDisconnect");

/*---------------------------------------------------------------------------
Player vars
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
Remove a player's fprpVar
---------------------------------------------------------------------------*/
function meta:removefprpVar(var, target)
	hook.Call("fprpVarChanged", nil, self, var, (self.fprpVars and self.fprpVars[var]) or nil, nil);
	target = target or player.GetAll();
	self.fprpVars = self.fprpVars or {}
	self.fprpVars[var] = nil


	net.Start("fprp_PlayerVarRemoval");
		net.WriteUInt(self:UserID(), 16);
		fprp.writeNetfprpVarRemoval(var);
	net.Send(target);
end

/*---------------------------------------------------------------------------
Set a player's fprpVar
---------------------------------------------------------------------------*/
function meta:setfprpVar(var, value, target)
	if not IsValid(self) then return end
	target = target or player.GetAll();

	if value == nil then return self:removefprpVar(var, target) end
	hook.Call("fprpVarChanged", nil, self, var, (self.fprpVars and self.fprpVars[var]) or nil, value);

	self.fprpVars = self.fprpVars or {}
	self.fprpVars[var] = value

	net.Start("fprp_PlayerVar");
		net.WriteUInt(self:UserID(), 16);
		fprp.writeNetfprpVar(var, value);
	net.Send(target);
end

/*---------------------------------------------------------------------------
Set a private fprpVar
---------------------------------------------------------------------------*/
function meta:setSelffprpVar(var, value)
	self.privateDRPVars = self.privateDRPVars or {}
	self.privateDRPVars[var] = true

	self:setfprpVar(var, value, self);
end

/*---------------------------------------------------------------------------
Get a fprpVar
---------------------------------------------------------------------------*/
function meta:getfprpVar(var)
	self.fprpVars = self.fprpVars or {}
	return self.fprpVars[var]
end

/*---------------------------------------------------------------------------
Send the fprpVars to a client
---------------------------------------------------------------------------*/
function meta:sendfprpVars()
	if self:EntIndex() == 0 then return end

	local plys = player.GetAll();

	net.Start("fprp_InitializeVars");
		net.WriteUInt(#plys, 8);
		for _, target in pairs(plys) do
			net.WriteUInt(target:UserID(), 16);

			local fprpVars = {}
			for var, value in pairs(target.fprpVars) do
				if self ~= target and (target.privateDRPVars or {})[var] then continue end
				table.insert(fprpVars, var);
			end

			net.WriteUInt(#fprpVars, fprp.fprp_ID_BITS + 2) -- Allow for three times as many unknown fprpVars than the limit
			for i = 1, #fprpVars, 1 do
				fprp.writeNetfprpVar(fprpVars[i], target.fprpVars[fprpVars[i]]);
			end
		end
	net.Send(self);
end
concommand.Add("_sendfprpvars", function(ply)
	if ply.fprpVarsSent and ply.fprpVarsSent > (CurTime() - 3) then return end -- prevent spammers
	ply.fprpVarsSent = CurTime();
	ply:sendfprpVars();
end);

/*---------------------------------------------------------------------------
Admin fprpVar commands
---------------------------------------------------------------------------*/
local function setRPName(ply, cmd, args)
	if not args[2] or string.len(args[2]) < 2 or string.len(args[2]) > 30 then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), "<2/>30"));
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), "<2/>30"));
		end
		return
	end

	if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
		ply:PrintMessage(2, fprp.getPhrase("need_admin", "rp_setname"));
		return
	end

	local target = fprp.findPlayer(args[1]);

	if target then
		local oldname = target:Nick();
		local nick = ""
		fprp.storeRPName(target, args[2]);
		target:setfprpVar("rpname", args[2]);

		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("you_set_x_name", oldname, args[2]));
			nick = "Console"
		else
			ply:PrintMessage(2, fprp.getPhrase("you_set_x_name", oldname, args[2]));
			nick = ply:Nick();
		end
		target:PrintMessage(2, fprp.getPhrase("x_set_your_name", nick, args[2]));
		if ply:EntIndex() == 0 then
			fprp.log("Console set " .. target:SteamName() .. "'s name to " .. args[2], Color(30, 30, 30));
		else
			fprp.log(ply:Nick() .. " (" .. ply:SteamID() .. ") set " .. target:SteamName() .. "'s name to " .. args[2], Color(30, 30, 30));
		end
	else
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", tostring(args[1])));
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])));
		end
	end
end
concommand.Add("rp_setname", setRPName);

local function RPName(ply, args)
	if ply.LastNameChange and ply.LastNameChange > (CurTime() - 5) then
		fprp.notify( ply, 1, 4, fprp.getPhrase("have_to_wait",  math.ceil(5 - (CurTime() - ply.LastNameChange)), "/rpname"));
		return ""
	end

	if not GAMEMODE.Config.allowrpnames then
		fprp.notify(ply, 1, 6,  fprp.getPhrase("disabled", "RPname", ""));
		return ""
	end

	args = args:find'^%s*$' and '' or args:match'^%s*(.*%S)'

	local canChangeName, reason = hook.Call("CanChangeRPName", GAMEMODE, ply, args);
	if canChangeName == false then
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "RPname", reason or ""));
		return ""
	end

	ply:setRPName(args);
	ply.LastNameChange = CurTime();
	return ""
end
fprp.defineChatCommand("rpname", RPName);
fprp.defineChatCommand("name", RPName);
fprp.defineChatCommand("nick", RPName);

/*---------------------------------------------------------------------------
Nickname override to show RP name
---------------------------------------------------------------------------*/
meta.SteamName = meta.SteamName or meta.Name
function meta:Name()
	-- Error level is 1 because this file is somehow left out of the trace.
	if not self:IsValid() then return fprp.error("Attempt to call Name/Nick/GetName on a non-existing player!", 1) end
	return GAMEMODE.Config.allowrpnames and self.fprpVars and self:getfprpVar("rpname")
		or self:SteamName();
end
meta.Nick = meta.Name
meta.GetName = meta.Name

/*---------------------------------------------------------------------------
Setting the RP name
---------------------------------------------------------------------------*/
function meta:setRPName(name, firstRun)
	-- Make sure nobody on this server already has this RP name
	local lowername = string.lower(tostring(name));
	fprp.retrieveRPNames(name, function(taken)
		if string.len(lowername) < 2 and not firstrun then return end
		-- If we found that this name exists for another player
		if taken then
			if firstRun then
				-- If we just connected and another player happens to be using our steam name as their RP name
				-- Put a 1 after our steam name
				fprp.storeRPName(self, name .. " 1");
				fprp.notify(self, 0, 12, fprp.getPhrase("someone_stole_steam_name"));
			else
				fprp.notify(self, 1, 5, fprp.getPhrase("unable", "RPname", fprp.getPhrase("already_taken")));
				return ""
			end
		else
			if not firstRun then -- Don't save the steam name in the database
				fprp.notifyAll(2, 6, fprp.getPhrase("rpname_changed", self:SteamName(), name));
				fprp.storeRPName(self, name);
			end
		end
	end);
end


/*---------------------------------------------------------------------------
Maximum entity values
---------------------------------------------------------------------------*/
local maxEntities = {}
function meta:addCustomEntity(entTable)
	maxEntities[self] = maxEntities[self] or {}
	maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
	maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] + 1
end

function meta:removeCustomEntity(entTable)
	maxEntities[self] = maxEntities[self] or {}
	maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
	maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] - 1
end

function meta:customEntityLimitReached(entTable)
	maxEntities[self] = maxEntities[self] or {}
	maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0

	return maxEntities[self][entTable.cmd] >= (entTable.getMax and entTable.getMax(self) or entTable.max);
end

hook.Add("PlayerDisconnected", "removeLimits", function(ply)
	maxEntities[ply] = nil
	net.Start("fprp_fprpVarDisconnect");
		net.WriteUInt(ply:UserID(), 16);
	net.Broadcast();
end);
