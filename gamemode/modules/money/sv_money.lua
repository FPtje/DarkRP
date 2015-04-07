/*---------------------------------------------------------------------------
functions
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player");
function meta:addshekel(amount)
	if not amount then return false end
	local total = self:getfprpVar("shekel") + math.floor(amount);
	total = hook.Call("playerWalletChanged", GAMEMODE, self, amount, self:getfprpVar("shekel")) or total

	self:setfprpVar("shekel", total);

	if self.fprpUnInitialized then return end
	fprp.storeshekel(self, total);
end

function fprp.payPlayer(ply1, ply2, amount)
	if not IsValid(ply1) or not IsValid(ply2) then return end
	ply1:addshekel(-amount);
	ply2:addshekel(amount);
end

function meta:payDay()
	if not IsValid(self) then return end
	if not self:isArrested() then
		fprp.retrieveSalary(self, function(amount)
			amount = math.floor(amount or GAMEMODE.Config.normalsalary);
			local suppress, message, hookAmount = hook.Call("playerGetSalary", GAMEMODE, self, amount);
			amount = hookAmount or amount

			if amount == 0 or not amount then
				if not suppress then fprp.notify(self, 4, 4, message or fprp.getPhrase("payday_unemployed")) end
			else
				self:addshekel(amount);
				if not suppress then fprp.notify(self, 4, 4, message or fprp.getPhrase("payday_message", fprp.formatshekel(amount))) end
			end
		end);
	else
		fprp.notify(self, 4, 4, fprp.getPhrase("payday_missed"));
	end
end

function fprp.createshekelBag(pos, amount)
	local shekelbag = ents.Create(GAMEMODE.Config.shekelClass);
	shekelbag:SetPos(pos);
	shekelbag:Setamount(math.Min(amount, 2147483647));
	shekelbag:Spawn();
	shekelbag:Activate();
	if GAMEMODE.Config.shekelRemoveTime and  GAMEMODE.Config.shekelRemoveTime ~= 0 then
		timer.Create("RemoveEnt"..shekelbag:EntIndex(), GAMEMODE.Config.shekelRemoveTime, 1, fn.Partial(SafeRemoveEntity, shekelbag));
	end
	return shekelbag
end

/*---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------*/
local function Giveshekel(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end

	if not tonumber(args) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end
	local trace = ply:GetEyeTrace();

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args));

		if amount < 1 then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ">=1"));
			return ""
		end

		if not ply:canAfford(amount) then
			fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", ""));

			return ""
		end

		local RP = RecipientFilter();
		RP:AddAllPlayers();

		umsg.Start("anim_giveitem", RP);
			umsg.Entity(ply);
		umsg.End();
		ply.anim_GivingItem = true

		timer.Simple(1.2, function()
			if IsValid(ply) then
				local trace2 = ply:GetEyeTrace();
				if IsValid(trace2.Entity) and trace2.Entity:IsPlayer() and trace2.Entity:GetPos():Distance(ply:GetPos()) < 150 then
					if not ply:canAfford(amount) then
						fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", ""));

						return ""
					end
					fprp.payPlayer(ply, trace2.Entity, amount);

					fprp.notify(trace2.Entity, 0, 4, fprp.getPhrase("has_given", ply:Nick(), fprp.formatshekel(amount)));
					fprp.notify(ply, 0, 4, fprp.getPhrase("you_gave", trace2.Entity:Nick(), fprp.formatshekel(amount)));
					fprp.log(ply:Nick().. " (" .. ply:SteamID() .. ") has given "..fprp.formatshekel(amount).. " to "..trace2.Entity:Nick() .. " (" .. trace2.Entity:SteamID() .. ")");
				end
			else
				fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/give", ""));
			end
		end);
	else
		fprp.notify(ply, 1, 4, fprp.getPhrase("must_be_looking_at", "player"));
	end
	return ""
end
fprp.defineChatCommand("give", Giveshekel, 0.2);

local function Dropshekel(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end

	if not tonumber(args) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end
	local amount = math.floor(tonumber(args));

	if amount <= 1 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ">1"));
		return ""
	end

	if amount >= 2147483647 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", "<2,147,483,647"));
		return ""
	end

	if not ply:canAfford(amount) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", ""));

		return ""
	end

	ply:addshekel(-amount);
	local RP = RecipientFilter();
	RP:AddAllPlayers();

	umsg.Start("anim_dropitem", RP);
		umsg.Entity(ply);
	umsg.End();
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) then
			local trace = {}
			trace.start = ply:EyePos();
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply

			local tr = util.TraceLine(trace);
			fprp.createshekelBag(tr.HitPos, amount);
			fprp.log(ply:Nick().. " (" .. ply:SteamID() .. ") has dropped ".. fprp.formatshekel(amount));
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/dropshekel", ""));
		end
	end);

	return ""
end
fprp.defineChatCommand("dropshekel", Dropshekel, 0.3);
fprp.defineChatCommand("shekeldrop", Dropshekel, 0.3);

local function CreateCheque(ply, args)
	local argt = string.Explode(" ", args);
	local recipient = fprp.findPlayer(argt[1]);
	local amount = tonumber(argt[2]) or 0

	if not recipient then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", "recipient (1)"));
		return ""
	end

	if amount <= 1 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", "amount (2)"));
		return ""
	end

	if not ply:canAfford(amount) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", ""));

		return ""
	end

	if IsValid(ply) and IsValid(recipient) then
		ply:addshekel(-amount);
	end

	umsg.Start("anim_dropitem", RecipientFilter():AddAllPlayers());
		umsg.Entity(ply);
	umsg.End();
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) and IsValid(recipient) then
			local trace = {}
			trace.start = ply:EyePos();
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply

			local tr = util.TraceLine(trace);
			local Cheque = ents.Create("fprp_cheque");
			Cheque:SetPos(tr.HitPos);
			Cheque:Setowning_ent(ply);
			Cheque:Setrecipient(recipient);

			Cheque:Setamount(math.Min(amount, 2147483647));
			Cheque:Spawn();
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/cheque", ""));
		end
	end);
	return ""
end
fprp.defineChatCommand("cheque", CreateCheque, 0.3);
fprp.defineChatCommand("check", CreateCheque, 0.3) -- for those of you who can't spell

local function ccSetshekel(ply, cmd, args)
	if not tonumber(args[2]) then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		end
		return
	end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, fprp.getPhrase("need_sadmin", "rp_setshekel"));
		return
	end

	local target = fprp.findPlayer(args[1]);

	if not target then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", "target"));
		return
	end

	local amount = math.floor(tonumber(args[2]));

	if args[3] then
		amount = args[3] == "-" and math.Max(0, target:getfprpVar("shekel") - amount) or target:getfprpVar("shekel") + amount
	end

	if target then
		local nick = ""
		fprp.storeshekel(target, amount);
		target:setfprpVar("shekel", amount);

		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("you_set_x_shekel", target:Nick(), fprp.formatshekel(amount), ""));
			nick = "Console"
		else
			ply:PrintMessage(2, fprp.getPhrase("you_set_x_shekel", target:Nick(), fprp.formatshekel(amount), ""));
			nick = ply:Nick();
		end
		target:PrintMessage(2, fprp.getPhrase("x_set_your_shekel", nick, fprp.formatshekel(amount), ""));
		if ply:EntIndex() == 0 then
			fprp.log("Console set " .. target:SteamName() .. "'s shekel to " .. fprp.formatshekel(amount), Color(30, 30, 30));
		else
			fprp.log(ply:Nick() .. " (" .. ply:SteamID() .. ") set " .. target:SteamName() .. "'s shekel to " ..  fprp.formatshekel(amount), Color(30, 30, 30));
		end
	else
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", args[1]));
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", args[1]));
		end
	end
end
concommand.Add("rp_setshekel", ccSetshekel, function() return {"rp_setshekel   <ply>   <amount>   [+/-]"} end)

local function ccSetSalary(ply, cmd, args)
	if not tonumber(args[2]) then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""));
		end
		return
	end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, fprp.getPhrase("need_sadmin", "rp_setsalary"));
		return
	end

	local amount = math.floor(tonumber(args[2]));

	if amount < 0 then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), args[2]));
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), args[2]));
		end
		return
	end

	if amount > 150 then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), args[2].." (<150)"));
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), args[2].." (<150)"));
		end
		return
	end

	local target = fprp.findPlayer(args[1]);

	if target then
		local nick = ""
		fprp.storeSalary(target, amount);
		target:setSelffprpVar("salary", amount);

		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("you_set_x_salary", target:Nick(), fprp.formatshekel(amount), ""));
			nick = "Console"
		else
			ply:PrintMessage(2, fprp.getPhrase("you_set_x_salary", target:Nick(), fprp.formatshekel(amount), ""));
			nick = ply:Nick();
		end
		target:PrintMessage(2, fprp.getPhrase("x_set_your_salary", nick, fprp.formatshekel(amount), ""));
		if ply:EntIndex() == 0 then
			fprp.log("Console set " .. target:SteamName() .. "'s salary to " .. fprp.formatshekel(amount), Color(30, 30, 30));
		else
			fprp.log(ply:Nick() .. " (" .. ply:SteamID() .. ") set " .. target:SteamName() .. "'s salary to " .. fprp.formatshekel(amount), Color(30, 30, 30));
		end
	else
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", tostring(args[1])));
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])));
		end
		return
	end
end
concommand.Add("rp_setsalary", ccSetSalary);
