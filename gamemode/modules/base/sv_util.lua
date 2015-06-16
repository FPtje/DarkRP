function DarkRP.notify(ply, msgtype, len, msg)
	net.Start("_Notify")
		net.WriteString(msg)
		net.WriteUInt(msgtype, 16)
		net.WriteUInt(len, 32)
	net.Send(ply)
end

function DarkRP.notifyAll(msgtype, len, msg)
	net.Start("_Notify")
		net.WriteString(msg)
		net.WriteUInt(msgtype, 16)
		net.WriteUInt(len, 32)
	net.Broadcast()
end

function DarkRP.printMessageAll(msgtype, msg)
	for k, v in pairs(player.GetAll()) do
		v:PrintMessage(msgtype, msg)
	end
end

function DarkRP.printConsoleMessage(ply, msg)
	if ply:EntIndex() == 0 then
		print(msg)
	else
		ply:PrintMessage(HUD_PRINTCONSOLE, msg)
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

		sender = sender or Entity(0)
		net.WriteEntity(sender)

		col2 = col2 or Color(0, 0, 0)
		net.WriteUInt(col2.r, 8)
		net.WriteUInt(col2.g, 8)
		net.WriteUInt(col2.b, 8)
		net.WriteString(text2 or "")
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
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("invalid_x", "argument", ""))
		return
	end
	local P = DarkRP.findPlayer(args[1])
	if not IsValid(P) then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("could_not_find", tostring(args[1])))
		return
	end
	DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("name", P:Nick()))
	DarkRP.printConsoleMessage(ply, "Steam ".. DarkRP.getPhrase("name", P:SteamName()))
	DarkRP.printConsoleMessage(ply, "Steam ID: "..P:SteamID())
	DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("job", team.GetName(P:Team())))
	DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("kills", P:Frags()))
	DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("deaths", P:Deaths()))
	if ply:EntIndex() == 0 or ply:IsAdmin() then
		DarkRP.printConsoleMessage(ply, DarkRP.getPhrase("wallet", DarkRP.formatMoney(P:getDarkRPVar("money")), ""))
	end
end
concommand.Add("rp_lookup", LookPersonUp)
