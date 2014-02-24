function DarkRP.notify(ply, msgtype, len, msg)
	if not IsValid(ply) then return end
	umsg.Start("_Notify", ply)
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end

function DarkRP.notifyAll(msgtype, len, msg)
	umsg.Start("_Notify")
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end

function DarkRP.printMessageAll(msgtype, msg)
	for k, v in pairs(player.GetAll()) do
		v:PrintMessage(msgtype, msg)
	end
end

util.AddNetworkString("DarkRP_Chat")

function DarkRP.talkToRange(ply, PlayerName, Message, size)
	local ents = ents.FindInSphere(ply:EyePos(), size)
	local col = team.GetColor(ply:Team())
	local filter = {}

	for k, v in pairs(ents) do
		if v:IsPlayer() then
			table.insert(filter, v)
		end
	end

	if PlayerName == ply:Nick() then PlayerName = "" end -- If it's just normal chat, why not cut down on networking and get the name on the client

	net.Start("DarkRP_Chat")
		net.WriteUInt(col.r, 8)
		net.WriteUInt(col.g, 8)
		net.WriteUInt(col.b, 8)
		net.WriteString(PlayerName)
		net.WriteEntity(ply)
		net.WriteUInt(255, 8)
		net.WriteUInt(255, 8)
		net.WriteUInt(255, 8)
		net.WriteString(Message)
	net.Send(filter)
end

function DarkRP.talkToPerson(receiver, col1, text1, col2, text2, sender)
	net.Start("DarkRP_Chat")
		net.WriteUInt(col1.r, 8)
		net.WriteUInt(col1.g, 8)
		net.WriteUInt(col1.b, 8)
		net.WriteString(text1)

		if sender then
			net.WriteEntity(sender)
		end

		if col2 and text2 then
			net.WriteUInt(col2.r, 8)
			net.WriteUInt(col2.g, 8)
			net.WriteUInt(col2.b, 8)
			net.WriteString(text2)
		end
	net.Send(receiver)
end

function DarkRP.isEmpty(vector, ignore)
	ignore = ignore or {}

	local point = util.PointContents(vector)
	local a = point ~= CONTENTS_SOLID
		and point ~= CONTENTS_MOVEABLE
		and point ~= CONTENTS_LADDER
		and point ~= CONTENTS_PLAYERCLIP
		and point ~= CONTENTS_MONSTERCLIP

	local b = true

	for k,v in pairs(ents.FindInSphere(vector, 35)) do
		if (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics") and not table.HasValue(ignore, v) then
			b = false
			break
		end
	end

	return a and b
end


/*---------------------------------------------------------------------------
Find an empty position near the position given in the first parameter
pos - The position to use as a center for looking around
ignore - what entities to ignore when looking for the position (the position can be within the entity)
distance - how far to look
step - how big the steps are
area - the position relative to pos that should also be free

Performance: O(N^2) (The Lua part, that is, I don't know about the C++ counterpart)
Don't call this function too often or with big inputs.
---------------------------------------------------------------------------*/
function DarkRP.findEmptyPos(pos, ignore, distance, step, area)
	if DarkRP.isEmpty(pos, ignore) and DarkRP.isEmpty(pos + area, ignore) then
		return pos
	end

	for j = step, distance, step do
		for i = -1, 1, 2 do -- alternate in direction
			local k = j * i

			-- Look North/South
			if DarkRP.isEmpty(pos + Vector(k, 0, 0), ignore) and DarkRP.isEmpty(pos + Vector(k, 0, 0) + area, ignore) then
				return pos + Vector(k, 0, 0)
			end

			-- Look East/West
			if DarkRP.isEmpty(pos + Vector(0, k, 0), ignore) and DarkRP.isEmpty(pos + Vector(0, k, 0) + area, ignore) then
				return pos + Vector(0, k, 0)
			end

			-- Look Up/Down
			if DarkRP.isEmpty(pos + Vector(0, 0, k), ignore) and DarkRP.isEmpty(pos + Vector(0, 0, k) + area, ignore) then
				return pos + Vector(0, 0, k)
			end
		end
	end

	return pos
end

local function LookPersonUp(ply, cmd, args)
	if not args[1] then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("invalid_x", "argument", ""))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", "argument", ""))
		end
		return
	end
	local P = DarkRP.findPlayer(args[1])
	if not IsValid(P) then
		if ply:EntIndex() ~= 0 then
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", tostring(args[1])))
		else
			print(DarkRP.getPhrase("could_not_find", tostring(args[1])))
		end
		return
	end
	if ply:EntIndex() ~= 0 then
		ply:PrintMessage(2, DarkRP.getPhrase("name", P:Nick()))
		ply:PrintMessage(2, "Steam ".. DarkRP.getPhrase("name", P:SteamName()))
		ply:PrintMessage(2, "Steam ID: "..P:SteamID())
		ply:PrintMessage(2, DarkRP.getPhrase("job", team.GetName(P:Team())))
		ply:PrintMessage(2, DarkRP.getPhrase("kills", P:Frags()))
		ply:PrintMessage(2, DarkRP.getPhrase("deaths", P:Deaths()))
		if ply:IsAdmin() then
			ply:PrintMessage(2, DarkRP.getPhrase("wallet", DarkRP.formatMoney(P:getDarkRPVar("money")), ""))
		end
	else
		print(DarkRP.getPhrase("name", P:Nick()))
		print("Steam ".. DarkRP.getPhrase("name", P:SteamName()))
		print("Steam ID: "..P:SteamID())
		print(DarkRP.getPhrase("job", team.GetName(P:Team())))
		print(DarkRP.getPhrase("kills", P:Frags()))
		print(DarkRP.getPhrase("deaths", P:Deaths()))
		print(DarkRP.getPhrase("wallet", DarkRP.formatMoney(P:getDarkRPVar("money")), ""))
	end
end
concommand.Add("rp_lookup", LookPersonUp)
