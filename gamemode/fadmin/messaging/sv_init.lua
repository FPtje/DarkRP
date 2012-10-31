function FAdmin.Messages.SendMessage(ply, MsgType, text)
	if ply:EntIndex() == 0 then
		ServerLog("FAdmin: "..text .. "\n")
		print("FAdmin: "..text)
		return
	end

	umsg.Start("FAdmin_SendMessage", ply)
		umsg.Short(MsgType)
		umsg.String(text)
	umsg.End()
	ply:PrintMessage(HUD_PRINTCONSOLE, text)
end

function FAdmin.Messages.SendMessageAll(text, MsgType)
	FAdmin.Log("FAdmin message to everyone: "..text)
	umsg.Start("FAdmin_SendMessage")
		umsg.Short(MsgType)
		umsg.String(text)
	umsg.End()
	for _,ply in pairs(player.GetAll()) do
		ply:PrintMessage(HUD_PRINTCONSOLE, text)
	end
end

function FAdmin.Messages.ActionMessage(ply, target, messageToPly, MessageToTarget, LogMSG)
	if not target then return end
	local Targets = (target.IsPlayer and target:IsPlayer() and target:Nick()) or ""
	if ply ~= target then
		if type(target) == "table" then
			for k,v in pairs(target) do
				local suffix = ((k == #target-1) and " and ") or (k ~= #target and ", ") or ""
				local Name = (v == ply and "yourself") or v:Nick()

				if v ~= ply then FAdmin.Messages.SendMessage(v, 2, string.format(MessageToTarget, ply:Nick())) end
				Targets = Targets..Name..suffix
				break
			end
		end

		FAdmin.Messages.SendMessage(ply, 4, string.format(messageToPly, Targets))

	else
		FAdmin.Messages.SendMessage(ply, 4, string.format(messageToPly, "yourself"))
	end

	FAdmin.Log("FAdmin Action: "..ply:Nick().." (".. ply:SteamID() .. ") ".. string.format(LogMSG, Targets:gsub("yourself", "themselves")))
end