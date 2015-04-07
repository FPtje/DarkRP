function FAdmin.Messages.SendMessage(ply, MsgType, text)
	if ply:EntIndex() == 0 then
		ServerLog("FAdmin: "..text .. "\n");
		print("FAdmin: "..text);
		return
	end

	umsg.Start("FAdmin_SendMessage", ply);
		umsg.Short(MsgType);
		umsg.String(text);
	umsg.End();
	ply:PrintMessage(HUD_PRINTCONSOLE, text);
end

function FAdmin.Messages.SendMessageAll(text, MsgType)
	FAdmin.Log("FAdmin message to everyone: "..text);
	umsg.Start("FAdmin_SendMessage");
		umsg.Short(MsgType);
		umsg.String(text);
	umsg.End();
	for _,ply in pairs(player.GetAll()) do
		ply:PrintMessage(HUD_PRINTCONSOLE, text);
	end
end

function FAdmin.Messages.ConsoleNotify(ply, message)
	umsg.Start("FAdmin_ConsoleMessage", ply);
		umsg.String(message);
	umsg.End();
end

function FAdmin.Messages.ActionMessage(ply, target, messageToPly, MessageToTarget, LogMSG)
	if not target then return end
	local Targets = (target.IsPlayer and target:IsPlayer() and target:Nick()) or ""

	local plyNick = IsValid(ply) and ply:IsPlayer() and ply:Nick() or "Console"
	local plySteamID = IsValid(ply) and ply:IsPlayer() and ply:SteamID() or "Console"
	local bad = false

	if ply ~= target then
		if type(target) == "table" then
			if #target == 0 then Targets = "no one" bad = true end
			for k,v in pairs(target) do
				local suffix = ((k == #target-1) and " and ") or (k ~= #target and ", ") or ""
				local Name = (v == ply and "yourself") or v:Nick();

				if v ~= ply then FAdmin.Messages.SendMessage(v, 2, string.format(MessageToTarget, plyNick)) end
				Targets = Targets..Name..suffix
			end
		else
			FAdmin.Messages.SendMessage(target, 2, string.format(MessageToTarget, plyNick));
		end

		FAdmin.Messages.SendMessage(ply, bad and 1 or 4, string.format(messageToPly, Targets));

	else
		FAdmin.Messages.SendMessage(ply, bad and 1 or 4, string.format(messageToPly, "yourself"));
	end

	local action = plyNick.." (".. plySteamID .. ") ".. string.format(LogMSG, Targets:gsub("yourself", "themselves"));
	FAdmin.Log("FAdmin Action: " .. action);

	local haspriv = fn.Partial(fn.Flip(FAdmin.Access.PlayerHasPrivilege), "SeeAdmins");
	local plys = fn.Filter(haspriv, player.GetAll());
	FAdmin.Messages.ConsoleNotify(plys, action);
end
