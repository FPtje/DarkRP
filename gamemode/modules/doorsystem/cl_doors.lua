local meta = FindMetaTable("Entity")
local lastDataRequested = 0
function meta:DrawOwnableInfo()
	if LocalPlayer():InVehicle() then return end

	local pos = {x = ScrW()/2, y = ScrH() / 2}

	local ownerstr = ""

	if self.DoorData == nil and lastDataRequested < (CurTime() - 0.7) then
		RunConsoleCommand("_RefreshDoorData", self:EntIndex())
		lastDataRequested = CurTime()

		return
	end

	for k,v in pairs(player.GetAll()) do
		if self:OwnedBy(v) then
			ownerstr = ownerstr .. v:Nick() .. "\n"
		end
	end

	if type(self.DoorData.AllowedToOwn) == "string" and self.DoorData.AllowedToOwn ~= "" and self.DoorData.AllowedToOwn ~= ";" then
		local names = {}
		for a,b in pairs(string.Explode(";", self.DoorData.AllowedToOwn)) do
			if b ~= "" and IsValid(Player(tonumber(b))) then
				table.insert(names, Player(tonumber(b)):Nick())
			end
		end
		ownerstr = ownerstr .. DarkRP.getPhrase("keys_other_allowed", table.concat(names, "\n"))
	elseif type(self.DoorData.AllowedToOwn) == "number" and IsValid(Player(self.DoorData.AllowedToOwn)) then
		ownerstr = ownerstr .. DarkRP.getPhrase("keys_other_allowed", Player(self.DoorData.AllowedToOwn):Nick())
	end

	self.DoorData.title = self.DoorData.title or ""

	local blocked = self.DoorData.NonOwnable
	local st = self.DoorData.title .. "\n"
	local superadmin = LocalPlayer():IsSuperAdmin()
	local whiteText = true -- false for red, true for white text

	if superadmin and blocked then
		st = st .. DarkRP.getPhrase("keys_allow_ownership") .. "\n"
	end

	if self.DoorData.TeamOwn then
		st = st .. DarkRP.getPhrase("keys_owned_by") .."\n"

		for k, v in pairs(self.DoorData.TeamOwn) do
			if v then
				st = st .. RPExtraTeams[k].name .. "\n"
			end
		end
	elseif self.DoorData.GroupOwn then
		st = st .. DarkRP.getPhrase("keys_owned_by") .."\n"
		st = st .. self.DoorData.GroupOwn .. "\n"
	end

	if self:IsOwned() then
		if superAdmin then
			if ownerstr ~= "" then
				st = st .. DarkRP.getPhrase("keys_owned_by") .."\n" .. ownerstr
			end
			st = st ..DarkRP.getPhrase("keys_disallow_ownership") .. "\n"
		elseif not blocked and ownerstr ~= "" then
			st = st .. DarkRP.getPhrase("keys_owned_by") .. "\n" .. ownerstr
		end
	elseif not blocked then
		if superAdmin then
			st = DarkRP.getPhrase("keys_unowned") .."\n".. DarkRP.getPhrase("keys_disallow_ownership")
			if not self:IsVehicle() then
				st = st .. "\n"..DarkRP.getPhrase("keys_cops")
			end
		elseif not self.DoorData.GroupOwn and not self.DoorData.TeamOwn then
			whiteText = false
			st = DarkRP.getPhrase("keys_unowned")
		end
	end

	if self:IsVehicle() then
		for k,v in pairs(player.GetAll()) do
			if v:GetVehicle() == self then
				whiteText = true
				st = st .. "\n" .. DarkRP.getPhrase("driver", v:Nick())
			end
		end
	end

	if whiteText then
		draw.DrawText(st, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
		draw.DrawText(st, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
	else
		draw.DrawText(st, "TargetID", pos.x , pos.y+1 , Color(0, 0, 0, 255), 1)
		draw.DrawText(st, "TargetID", pos.x, pos.y, Color(128, 30, 30, 255), 1)
	end
end
