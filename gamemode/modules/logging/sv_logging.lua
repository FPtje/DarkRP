local function AdminLog(message, colour)
	local RF = RecipientFilter()
	for k,v in pairs(player.GetAll()) do
		local canHear = hook.Call("canSeeLogMessage", GAMEMODE, v, message, colour)

		if canHear then
			RF:AddPlayer(v)
		end
	end
	umsg.Start("DRPLogMsg", RF)
		umsg.Short(colour.r)
		umsg.Short(colour.g)
		umsg.Short(colour.b) -- Alpha is not needed
		umsg.String(message)
	umsg.End()
end

local fprpFile
function fprp.log(text, colour)
	if colour then
		AdminLog(text, colour)
	end
	if not GAMEMODE.Config.logging or not text then return end
	if not fprpFile then -- The log file of this session, if it's not there then make it!
		if not file.IsDir("fprp_logs", "DATA") then
			file.CreateDir("fprp_logs")
		end
		fprpFile = "fprp_logs/"..os.date("%m_%d_%Y %I_%M %p")..".txt"
		file.Write(fprpFile, os.date().. "\t".. text)
		return
	end
	file.Append(fprpFile, "\n"..os.date().. "\t"..(text or ""))
end
