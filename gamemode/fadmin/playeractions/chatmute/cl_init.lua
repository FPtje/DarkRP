FAdmin.StartHooks["Chatmute"] = function()
	FAdmin.Access.AddPrivilege("Chatmute", 2)
	FAdmin.Commands.AddCommand("Chatmute", nil, "<Player>")
	FAdmin.Commands.AddCommand("UnChatmute", nil, "<Player>")

	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
		if ply:FAdmin_GetGlobal("FAdmin_chatmuted") then return "Unmute chat" end
		return "Mute chat"
	end, function(ply)
		if ply:FAdmin_GetGlobal("FAdmin_chatmuted") then return "FAdmin/icons/chatmute" end
		return "FAdmin/icons/chatmute", "FAdmin/icons/disable"
	end, Color(255, 130, 0, 255),

	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Chatmute", ply) end, function(ply, button)
		if not ply:FAdmin_GetGlobal("FAdmin_chatmuted") then
			FAdmin.PlayerActions.addTimeMenu(function(secs)
				if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
					RunConsoleCommand("_FAdmin", "chatmute", ply:Nick(), secs)
				else
					RunConsoleCommand("_FAdmin", "chatmute", ply:SteamID(), secs)
				end
				button:SetImage2("null")
				button:SetText("Unmute chat")
				button:GetParent():InvalidateLayout()
			end)
		else
			if ply:SteamID() == "NULL" or ply:SteamID() == "BOT" or ply:SteamID() == "" then -- I'm almost certain its "" but idk... best to cover all bases.
				RunConsoleCommand("_FAdmin", "UnChatmute", ply:Nick())
			else
				RunConsoleCommand("_FAdmin", "UnChatmute", ply:SteamID())
			end
		end

		button:SetImage2("FAdmin/icons/disable")
		button:SetText("Mute chat")
		button:GetParent():InvalidateLayout()
	end)
end
