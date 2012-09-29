hook.Add("PlayerBindPress", "FAdmin_voicemuted", function(ply, bind, pressed)
	if ply:FAdmin_GetGlobal("FAdmin_voicemuted") and string.find(string.lower(bind), "voicerecord") then return true end
	-- The voice muting is not done clientside, this is just so people know they can't talk
end)

FAdmin.StartHooks["Voicemute"] = function()
	FAdmin.Access.AddPrivilege("Voicemute", 2)
	FAdmin.Commands.AddCommand("Voicemute", nil, "<Player>")
	FAdmin.Commands.AddCommand("UnVoicemute", nil, "<Player>")
	
	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
			if ply:FAdmin_GetGlobal("FAdmin_voicemuted") then return "Unmute voice" end
			return "Mute voice"
		end, 
	
	function(ply) 
		if ply:FAdmin_GetGlobal("FAdmin_voicemuted") then return "FAdmin/icons/voicemute" end
		return "FAdmin/icons/voicemute", "FAdmin/icons/disable" 
	end, 
	Color(255, 130, 0, 255), 
	
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Voicemute", ply) end, function(ply, button)
		if not ply:FAdmin_GetGlobal("FAdmin_voicemuted") then
			RunConsoleCommand("_FAdmin", "Voicemute", ply:UserID())
		else
			RunConsoleCommand("_FAdmin", "UnVoicemute", ply:UserID())
		end
		
		if not ply:FAdmin_GetGlobal("FAdmin_voicemuted") then button:SetImage2("null") button:SetText("Unmute voice") button:GetParent():InvalidateLayout() return end
		button:SetImage2("FAdmin/icons/disable")
		button:SetText("Mute voice")
		button:GetParent():InvalidateLayout()
	end)
end