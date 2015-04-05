function fprp.notify(ply, msgtype, len, msg)
	if not IsValid(ply) then return end
	umsg.Start("_Notify", ply)
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end

function fprp.notifyAll(msgtype, len, msg)
	umsg.Start("_Notify")
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end

function fprp.printMessageAll(msgtype, msg)
	for k, v in pairs(player.GetAll()) do
		v:PrintMessage(msgtype, msg)
	end
end

util.AddNetworkString("fprp_Chat")

function fprp.talkToRange(ply, PlayerName, Message, size)
	local ents = ents.FindInSphere(ply:EyePos(), size)
	local col = team.GetColor(ply:Team())
	local filter = {}

	for k, v in pairs(ents) do
		if v:IsPlayer() then
			table.insert(filter, v)
		end
	end

	if PlayerName == ply:Nick() then PlayerName = "" end -- If it's just normal chat, why not cut down on networking and get the name on the client

	net.Start("fprp_Chat")
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

function fprp.talkToPerson(receiver, col1, text1, col2, text2, sender)
	net.Start("fprp_Chat")
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

function fprp.isEmpty(vector, ignore)
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
function fprp.findEmptyPos(pos, ignore, distance, step, area)
	if fprp.isEmpty(pos, ignore) and fprp.isEmpty(pos + area, ignore) then
		return pos
	end

	for j = step, distance, step do
		for i = -1, 1, 2 do -- alternate in direction
			local k = j * i

			-- Look North/South
			if fprp.isEmpty(pos + Vector(k, 0, 0), ignore) and fprp.isEmpty(pos + Vector(k, 0, 0) + area, ignore) then
				return pos + Vector(k, 0, 0)
			end

			-- Look East/West
			if fprp.isEmpty(pos + Vector(0, k, 0), ignore) and fprp.isEmpty(pos + Vector(0, k, 0) + area, ignore) then
				return pos + Vector(0, k, 0)
			end

			-- Look Up/Down
			if fprp.isEmpty(pos + Vector(0, 0, k), ignore) and fprp.isEmpty(pos + Vector(0, 0, k) + area, ignore) then
				return pos + Vector(0, 0, k)
			end
		end
	end

	return pos
end

local function LookPersonUp(ply, cmd, args)
	if not args[1] then
		if ply:EntIndex() == 0 then
			print(fprp.getPhrase("invalid_x", "argument", ""))
		else
			ply:PrintMessage(2, fprp.getPhrase("invalid_x", "argument", ""))
		end
		return
	end
	local P = fprp.findPlayer(args[1])
	if not IsValid(P) then
		if ply:EntIndex() ~= 0 then
			ply:PrintMessage(2, fprp.getPhrase("could_not_find", tostring(args[1])))
		else
			print(fprp.getPhrase("could_not_find", tostring(args[1])))
		end
		return
	end
	if ply:EntIndex() ~= 0 then
		ply:PrintMessage(2, fprp.getPhrase("name", P:Nick()))
		ply:PrintMessage(2, "Steam ".. fprp.getPhrase("name", P:SteamName()))
		ply:PrintMessage(2, "Steam ID: "..P:SteamID())
		ply:PrintMessage(2, fprp.getPhrase("job", team.GetName(P:Team())))
		ply:PrintMessage(2, fprp.getPhrase("kills", P:Frags()))
		ply:PrintMessage(2, fprp.getPhrase("deaths", P:Deaths()))
		if ply:IsAdmin() then
			ply:PrintMessage(2, fprp.getPhrase("wallet", fprp.formatMoney(P:getfprpVar("money")), ""))
		end
	else
		print(fprp.getPhrase("name", P:Nick()))
		print("Steam ".. fprp.getPhrase("name", P:SteamName()))
		print("Steam ID: "..P:SteamID())
		print(fprp.getPhrase("job", team.GetName(P:Team())))
		print(fprp.getPhrase("kills", P:Frags()))
		print(fprp.getPhrase("deaths", P:Deaths()))
		print(fprp.getPhrase("wallet", fprp.formatMoney(P:getfprpVar("money")), ""))
	end
end
concommand.Add("rp_lookup", LookPersonUp)
