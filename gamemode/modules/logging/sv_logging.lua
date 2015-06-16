local function AdminLog(message, colour)
	local players = {}
	for k,v in pairs(player.GetAll()) do
		local canHear = hook.Call("canSeeLogMessage", GAMEMODE, v, message, colour)

		if canHear then
			table.insert(players, v)
		end
	end
	net.Start("DRPLogMsg")
		net.WriteUInt(colour.r, 16)
		net.WriteUInt(colour.g, 16)
		net.WriteUInt(colour.b, 16)
		net.WriteString(message)
	net.Send(players)
end

local DarkRPFile
function DarkRP.log(text, colour)
	if colour then
		AdminLog(text, colour)
	end
	if not GAMEMODE.Config.logging or not text then return end
	if not DarkRPFile then -- The log file of this session, if it's not there then make it!
		if not file.IsDir("darkrp_logs", "DATA") then
			file.CreateDir("darkrp_logs")
		end
		DarkRPFile = "darkrp_logs/"..os.date("%m_%d_%Y %I_%M %p")..".txt"
		file.Write(DarkRPFile, os.date().. "\t".. text)
		return
	end
	file.Append(DarkRPFile, "\n"..os.date().. "\t"..(text or ""))
end
