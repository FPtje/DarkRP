/*---------------------------------------------------------------------------
functions
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")
function meta:addMoney(amount)
	if not amount then return false end
	local total = self:getfprpVar("money") + math.floor(amount)
	total = hook.Call("playerWalletChanged", GAMEMODE, self, amount, self:getfprpVar("money")) or total

	self:setfprpVar("money", total)

	if self.fprpUnInitialized then return end
	fprp.storeMoney(self, total)
end

function fprp.payPlayer(ply1, ply2, amount)
	if not IsValid(ply1) or not IsValid(ply2) then return end
	ply1:addMoney(-amount)
	ply2:addMoney(amount)
end

function meta:payDay()
	if not IsValid(self) then return end
	if not self:isArrested() then
		fprp.retrieveSalary(self, function(amount)
			amount = math.floor(amount or GAMEMODE.Config.normalsalary)
			local suppress, message, hookAmount = hook.Call("playerGetSalary", GAMEMODE, self, amount)
			amount = hookAmount or amount

			if amount == 0 or not amount then
				if not suppress then fprp.notify(self, 4, 4, message or fprp.getPhrase("payday_unemployed")) end
			else
				self:addMoney(amount)
				if not suppress then fprp.notify(self, 4, 4, message or fprp.getPhrase("payday_message", fprp.formatMoney(amount))) end
			end
		end)
	else
		fprp.notify(self, 4, 4, fprp.getPhrase("payday_missed"))
	end
end

function fprp.createMoneyBag(pos, amount)
	local moneybag = ents.Create(GAMEMODE.Config.MoneyClass)
	moneybag:SetPos(pos)
	moneybag:Setamount(math.Min(amount, 2147483647))
	moneybag:Spawn()
	moneybag:Activate()
	if GAMEMODE.Config.moneyRemoveTime and  GAMEMODE.Config.moneyRemoveTime ~= 0 then
		timer.Create("RemoveEnt"..moneybag:EntIndex(), GAMEMODE.Config.moneyRemoveTime, 1, fn.Partial(SafeRemoveEntity, moneybag))
	end
	return moneybag
end

/*---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------*/
local function GiveMoney(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not tonumber(args) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount < 1 then
			fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ">=1"))
			return ""
		end

		if not ply:canAfford(amount) then
			fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", ""))

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
					if not ply:canAfford(amount) then
						fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", ""))

						return ""
					end
					fprp.payPlayer(ply, trace2.Entity, amount)

					fprp.notify(trace2.Entity, 0, 4, fprp.getPhrase("has_given", ply:Nick(), fprp.formatMoney(amount)))
					fprp.notify(ply, 0, 4, fprp.getPhrase("you_gave", trace2.Entity:Nick(), fprp.formatMoney(amount)))
					fprp.log(ply:Nick().. " (" .. ply:SteamID() .. ") has given "..fprp.formatMoney(amount).. " to "..trace2.Entity:Nick() .. " (" .. trace2.Entity:SteamID() .. ")")
				end
			else
				fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/give", ""))
			end
		end)
	else
		fprp.notify(ply, 1, 4, fprp.getPhrase("must_be_looking_at", "player"))
	end
	return ""
end
fprp.defineChatCommand("give", GiveMoney, 0.2)

local function DropMoney(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not tonumber(args) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ">1"))
		return ""
	end

	if amount >= 2147483647 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", "<2,147,483,647"))
		return ""
	end

	if not ply:canAfford(amount) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", ""))

		return ""
	end

	ply:addMoney(-amount)
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
			fprp.createMoneyBag(tr.HitPos, amount)
			fprp.log(ply:Nick().. " (" .. ply:SteamID() .. ") has dropped ".. fprp.formatMoney(amount))
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/dropmoney", ""))
		end
	end)

	return ""
end
fprp.defineChatCommand("dropmoney", DropMoney, 0.3)
fprp.defineChatCommand("moneydrop", DropMoney, 0.3)

local function CreateCheque(ply, args)
	local argt = string.Explode(" ", args)
	local recipient = fprp.findPlayer(argt[1])
	local amount = tonumber(argt[2]) or 0

	if not recipient then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", "recipient (1)"))
		return ""
	end

	if amount <= 1 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", "amount (2)"))
		return ""
	end

	if not ply:canAfford(amount) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("cant_afford", ""))

		return ""
	end

	if IsValid(ply) and IsValid(recipient) then
		ply:addMoney(-amount)
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
			local Cheque = ents.Create("fprp_cheque")
			Cheque:SetPos(tr.HitPos)
			Cheque:Setowning_ent(ply)
			Cheque:Setrecipient(recipient)

			Cheque:Setamount(math.Min(amount, 2147483647))
			Cheque:Spawn()
		else
			fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/cheque", ""))
		end
	end)
	return ""
end
fprp.defineChatCommand("cheque", CreateCheque, 0.3)
fprp.defineChatCommand("check", CreateCheque, 0.3) -- for those of you who can't spell

local function ccSetMoney(ply, cmd, args)
	if not tonumber(args[2]) then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""))
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""))
		end
		return
	end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, fprp.getPhrase("need_sadmin", "rp_setmoney"))
		return
	end

	local target = fprp.findPlayer(args[1])

	if not target then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", "target"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if args[3] then
		amount = args[3] == "-" and math.Max(0, target:getfprpVar("money") - amount) or target:getfprpVar("money") + amount
	end

	if target then
		local nick = ""
		fprp.storeMoney(target, amount)
		target:setfprpVar("money", amount)

		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("you_set_x_money", target:Nick(), fprp.formatMoney(amount), ""))
			nick = "Console"
		else
			ply:PrintMessage(2, fprp.getPhrase("you_set_x_money", target:Nick(), fprp.formatMoney(amount), ""))
			nick = ply:Nick()
		end
		target:PrintMessage(2, fprp.getPhrase("x_set_your_money", nick, fprp.formatMoney(amount), ""))
		if ply:EntIndex() == 0 then
			fprp.log("Console set " .. target:SteamName() .. "'s money to " .. fprp.formatMoney(amount), Color(30, 30, 30))
		else
			fprp.log(ply:Nick() .. " (" .. ply:SteamID() .. ") set " .. target:SteamName() .. "'s money to " ..  fprp.formatMoney(amount), Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", args[1]))
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", args[1]))
		end
	end
end
concommand.Add("rp_setmoney", ccSetMoney, function() return {"rp_setmoney   <ply>   <amount>   [+/-]"} end)

local function ccSetSalary(ply, cmd, args)
	if not tonumber(args[2]) then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""))
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), ""))
		end
		return
	end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, fprp.getPhrase("need_sadmin", "rp_setsalary"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if amount < 0 then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), args[2]))
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), args[2]))
		end
		return
	end

	if amount > 150 then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), args[2].." (<150)"))
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", fprp.getPhrase("arguments"), args[2].." (<150)"))
		end
		return
	end

	local target = fprp.findPlayer(args[1])

	if target then
		local nick = ""
		fprp.storeSalary(target, amount)
		target:setSelffprpVar("salary", amount)

		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("you_set_x_salary", target:Nick(), fprp.formatMoney(amount), ""))
			nick = "Console"
		else
			ply:PrintMessage(2, fprp.getPhrase("you_set_x_salary", target:Nick(), fprp.formatMoney(amount), ""))
			nick = ply:Nick()
		end
		target:PrintMessage(2, fprp.getPhrase("x_set_your_salary", nick, fprp.formatMoney(amount), ""))
		if ply:EntIndex() == 0 then
			fprp.log("Console set " .. target:SteamName() .. "'s salary to " .. fprp.formatMoney(amount), Color(30, 30, 30))
		else
			fprp.log(ply:Nick() .. " (" .. ply:SteamID() .. ") set " .. target:SteamName() .. "'s salary to " .. fprp.formatMoney(amount), Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("could_not_find", tostring(args[1])))
		else
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_setsalary", ccSetSalary)
