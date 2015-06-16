/*---------------------------------------------------------------------------
functions
---------------------------------------------------------------------------*/
local meta = FindMetaTable("Player")
function meta:addMoney(amount)
	if not amount then return false end
	local total = self:getDarkRPVar("money") + math.floor(amount)
	total = hook.Call("playerWalletChanged", GAMEMODE, self, amount, self:getDarkRPVar("money")) or total

	self:setDarkRPVar("money", total)

	if self.DarkRPUnInitialized then return end
	DarkRP.storeMoney(self, total)
end

function DarkRP.payPlayer(ply1, ply2, amount)
	if not IsValid(ply1) or not IsValid(ply2) then return end
	ply1:addMoney(-amount)
	ply2:addMoney(amount)
end

function meta:payDay()
	if not IsValid(self) then return end
	if not self:isArrested() then
		DarkRP.retrieveSalary(self, function(amount)
			amount = math.floor(amount or GAMEMODE.Config.normalsalary)
			local suppress, message, hookAmount = hook.Call("playerGetSalary", GAMEMODE, self, amount)
			amount = hookAmount or amount

			if amount == 0 or not amount then
				if not suppress then DarkRP.notify(self, 4, 4, message or DarkRP.getPhrase("payday_unemployed")) end
			else
				self:addMoney(amount)
				if not suppress then DarkRP.notify(self, 4, 4, message or DarkRP.getPhrase("payday_message", DarkRP.formatMoney(amount))) end
			end
		end)
	else
		DarkRP.notify(self, 4, 4, DarkRP.getPhrase("payday_missed"))
	end
end

function DarkRP.createMoneyBag(pos, amount)
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
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not tonumber(args) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount < 1 then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ">=1"))
			return ""
		end

		if not ply:canAfford(amount) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

			return ""
		end

		net.Start("anim_giveitem")
			net.WriteEntity(ply)
		net.Broadcast()
		ply.anim_GivingItem = true

		timer.Simple(1.2, function()
			if IsValid(ply) then
				local trace2 = ply:GetEyeTrace()
				if IsValid(trace2.Entity) and trace2.Entity:IsPlayer() and trace2.Entity:GetPos():Distance(ply:GetPos()) < 150 then
					if not ply:canAfford(amount) then
						DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

						return ""
					end
					DarkRP.payPlayer(ply, trace2.Entity, amount)

					DarkRP.notify(trace2.Entity, 0, 4, DarkRP.getPhrase("has_given", ply:Nick(), DarkRP.formatMoney(amount)))
					DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_gave", trace2.Entity:Nick(), DarkRP.formatMoney(amount)))
					DarkRP.log(ply:Nick().. " (" .. ply:SteamID() .. ") has given "..DarkRP.formatMoney(amount).. " to "..trace2.Entity:Nick() .. " (" .. trace2.Entity:SteamID() .. ")")
				end
			else
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/give", ""))
			end
		end)
	else
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "player"))
	end
	return ""
end
DarkRP.defineChatCommand("give", GiveMoney, 0.2)

local function DropMoney(ply, args)
	if args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end

	if not tonumber(args) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
		return ""
	end
	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ">1"))
		return ""
	end

	if amount >= 2147483647 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "<2,147,483,647"))
		return ""
	end

	if not ply:canAfford(amount) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

		return ""
	end

	ply:addMoney(-amount)

	net.Start("anim_dropitem")
		net.WriteEntity(ply)
	net.Broadcast()
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) then
			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector() * 85
			trace.filter = ply

			local tr = util.TraceLine(trace)
			DarkRP.createMoneyBag(tr.HitPos, amount)
			DarkRP.log(ply:Nick().. " (" .. ply:SteamID() .. ") has dropped ".. DarkRP.formatMoney(amount))
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/dropmoney", ""))
		end
	end)

	return ""
end
DarkRP.defineChatCommand("dropmoney", DropMoney, 0.3)
DarkRP.defineChatCommand("moneydrop", DropMoney, 0.3)

local function CreateCheque(ply, args)
	local argt = string.Explode(" ", args)
	local recipient = DarkRP.findPlayer(argt[1])
	local amount = tonumber(argt[2]) or 0

	if not recipient then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "recipient (1)"))
		return ""
	end

	if amount <= 1 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "amount (2)"))
		return ""
	end

	if not ply:canAfford(amount) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

		return ""
	end

	if IsValid(ply) and IsValid(recipient) then
		ply:addMoney(-amount)
	end

	net.Start("anim_dropitem")
		net.WriteEntity(ply)
	net.Broadcast()
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
			Cheque:Setowning_ent(ply)
			Cheque:Setrecipient(recipient)

			Cheque:Setamount(math.Min(amount, 2147483647))
			Cheque:Spawn()
		else
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/cheque", ""))
		end
	end)
	return ""
end
DarkRP.defineChatCommand("cheque", CreateCheque, 0.3)
DarkRP.defineChatCommand("check", CreateCheque, 0.3) -- for those of you who can't spell

local function ccSetMoney(ply, cmd, args)
	if not tonumber(args[2]) then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return
	end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_sadmin", "rp_setmoney"))
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if not target then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("could_not_find", tostring(args[1])))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if args[3] then
		amount = args[3] == "-" and math.Max(0, target:getDarkRPVar("money") - amount) or target:getDarkRPVar("money") + amount
	end

	if target then
		DarkRP.storeMoney(target, amount)
		target:setDarkRPVar("money", amount)

		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("you_set_x_money", target:Nick(), DarkRP.formatMoney(amount), ""))

		local nick = ""
		if ply:EntIndex() == 0 then
			nick = "Console"
		else
			nick = ply:Nick()
		end
		DarkRP.notify(target, 0, 4, DarkRP.getPhrase("x_set_your_money", nick, DarkRP.formatMoney(amount), ""))
		if ply:EntIndex() == 0 then
			DarkRP.log("Console set " .. target:SteamName() .. "'s money to " .. DarkRP.formatMoney(amount), Color(30, 30, 30))
		else
			DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") set " .. target:SteamName() .. "'s money to " ..  DarkRP.formatMoney(amount), Color(30, 30, 30))
		end
	else
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("could_not_find", tostring(args[1])))
	end
end
concommand.Add("rp_setmoney", ccSetMoney, function() return {"rp_setmoney   <ply>   <amount>   [+/-]"} end)

local function ccSetSalary(ply, cmd, args)
	if not tonumber(args[2]) then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return
	end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(HUD_PRINTCONSOLE, DarkRP.getPhrase("need_sadmin", "rp_setsalary"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if amount < 0 or amount > 150 then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), tostring(args[2]).." (0-150)"))
		return
	end

	local target = DarkRP.findPlayer(args[1])

	if target then
		DarkRP.storeSalary(target, amount)
		target:setSelfDarkRPVar("salary", amount)

		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("you_set_x_salary", target:Nick(), DarkRP.formatMoney(amount), ""))

		local nick = ""
		if ply:EntIndex() == 0 then
			nick = "Console"
		else
			nick = ply:Nick()
		end
		DarkRP.notify(target, 0, 4, DarkRP.getPhrase("x_set_your_salary", nick, DarkRP.formatMoney(amount), ""))
		if ply:EntIndex() == 0 then
			DarkRP.log("Console set " .. target:SteamName() .. "'s salary to " .. DarkRP.formatMoney(amount), Color(30, 30, 30))
		else
			DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") set " .. target:SteamName() .. "'s salary to " .. DarkRP.formatMoney(amount), Color(30, 30, 30))
		end
	else
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("could_not_find", tostring(args[1])))
		return
	end
end
concommand.Add("rp_setsalary", ccSetSalary)
