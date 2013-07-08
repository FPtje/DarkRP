hook.Add("PlayerBindPress", "FAdmin_voicemuted", function(ply, bind, pressed)
	if ply:FAdmin_GetGlobal("FAdmin_voicemuted") and string.find(string.lower(bind), "voicerecord") then return true end
	-- The voice muting is not done clientside, this is just so people know they can't talk
end)

FAdmin.StartHooks["Voicemute"] = function()
	FAdmin.Access.AddPrivilege("Voicemute", 2)
	FAdmin.Commands.AddCommand("Voicemute", nil, "<Player>")
	FAdmin.Commands.AddCommand("UnVoicemute", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
			if ply:FAdmin_GetGlobal("FAdmin_voicemuted") then return "Unmute globally" end
			return "Mute globally"
		end,

	function(ply)
		if ply:FAdmin_GetGlobal("FAdmin_voicemuted") then return "FAdmin/icons/voicemute" end
		return "FAdmin/icons/voicemute", "FAdmin/icons/disable"
	end,
	Color(255, 130, 0, 255),

	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Voicemute", ply) end,
	function(ply, button)
		if not ply:FAdmin_GetGlobal("FAdmin_voicemuted") then
			FAdmin.PlayerActions.addTimeMenu(function(secs)
				RunConsoleCommand("_FAdmin", "Voicemute", ply:SteamID(), secs)
				button:SetImage2("null")
				button:SetText("Unmute voice")
				button:GetParent():InvalidateLayout()
			end)
		else
			RunConsoleCommand("_FAdmin", "UnVoicemute", ply:SteamID())
		end

		button:SetImage2("FAdmin/icons/disable")
		button:SetText("Mute voice")
		button:GetParent():InvalidateLayout()
	end)

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
		return ply.FAdminMuted and "Unmute" or "Mute"
	end,
	function(ply)
		if ply.FAdminMuted then return "FAdmin/icons/voicemute" end
		return "FAdmin/icons/voicemute", "FAdmin/icons/disable"
	end,
	Color(255, 130, 0, 255),

	true,

	function(ply, button)
		ply:SetMuted(not ply.FAdminMuted)
		ply.FAdminMuted = not ply.FAdminMuted

		if ply.FAdminMuted then button:SetImage2("null") button:SetText("Unmute") button:GetParent():InvalidateLayout() return end

		button:SetImage2("FAdmin/icons/disable")
		button:SetText("Mute")
		button:GetParent():InvalidateLayout()
	end)

	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Mute/Unmute", function(ply, Panel)
		ply:SetMuted(not ply.FAdminMuted)
		ply.FAdminMuted = not ply.FAdminMuted
	end)
end
