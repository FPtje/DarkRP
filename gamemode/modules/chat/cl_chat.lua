/*---------------------------------------------------------------------------
Gamemode function
---------------------------------------------------------------------------*/
function GM:OnPlayerChat()
end

/*---------------------------------------------------------------------------
Add a message to chat
---------------------------------------------------------------------------*/
local function AddToChat(msg)
	local col1 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

	local prefixText = msg:ReadString()
	local ply = msg:ReadEntity()
	ply = IsValid(ply) and ply or LocalPlayer()

	if prefixText == "" or not prefixText then
		prefixText = ply:Nick()
		prefixText = prefixText ~= "" and prefixText or ply:SteamName()
	end

	local col2 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

	local text = msg:ReadString()
	local shouldShow
	if text and text ~= "" then
		if IsValid(ply) then
			shouldShow = hook.Call("OnPlayerChat", nil, ply, text, false, not ply:Alive(), prefixText, col1, col2)
		end

		if shouldShow ~= true then
			chat.AddText(col1, prefixText, col2, ": "..text)
		end
	else
		shouldShow = hook.Call("ChatText", nil, "0", prefixText, prefixText, "none")
		if shouldShow ~= true then
			chat.AddText(col1, prefixText)
		end
	end
	chat.PlaySound()
end
usermessage.Hook("DarkRP_Chat", AddToChat)

/*---------------------------------------------------------------------------
Credits

Please only ADD to the credits
Removing people from the credits will make at least one person very angry.
---------------------------------------------------------------------------*/
local creds =
[[LightRP:
Rick darkalonio

DarkRP:
Rickster
Picwizdan
Sibre
PhilXYZ
[GNC] Matt
Chromebolt A.K.A. unib5 (STEAM_0:1:19045957)
Falco A.K.A. FPtje (STEAM_0:0:8944068)
Eusion (STEAM_0:0:20450406)
Drakehawke (STEAM_0:0:22342869)]]

local function credits(um)
	chat.AddText(Color(255,0,0,255), "CREDITS FOR DARKRP", Color(0,0,255,255), creds)
end
usermessage.Hook("DarkRP_Credits", credits)
