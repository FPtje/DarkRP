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
			return
		end

		if not ply:canAfford(amount) then
			DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

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
						DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

						return ""
					end
					DarkRP.payPlayer(ply, trace2.Entity, amount)

					DarkRP.notify(trace2.Entity, 0, 4, DarkRP.getPhrase("has_given", ply:Nick(), GAMEMODE.Config.currency .. tostring(amount)))
					DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_gave", trace2.Entity:Nick(), GAMEMODE.Config.currency .. tostring(amount)))
					DarkRP.log(ply:Nick().. " (" .. ply:SteamID() .. ") has given "..GAMEMODE.Config.currency .. tostring(amount).. " to "..trace2.Entity:Nick() .. " (" .. trace2.Entity:SteamID() .. ")")
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

	if not ply:canAfford(amount) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

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
			DarkRP.log(ply:Nick().. " (" .. ply:SteamID() .. ") has dropped "..GAMEMODE.Config.currency .. tostring(amount))
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
