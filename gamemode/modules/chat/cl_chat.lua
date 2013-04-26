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

	local name = msg:ReadString()
	local ply = msg:ReadEntity()
	ply = IsValid(ply) and ply or LocalPlayer()

	if name == "" or not name then
		name = ply:Nick()
		name = name ~= "" and name or ply:SteamName()
	end

	local col2 = Color(msg:ReadShort(), msg:ReadShort(), msg:ReadShort())

	local text = msg:ReadString()
	if text and text ~= "" then
		chat.AddText(col1, name, col2, ": "..text)
		if IsValid(ply) then
			hook.Call("OnPlayerChat", nil, ply, text, false, not ply:Alive())
		end
	else
		chat.AddText(col1, name)
		hook.Call("ChatText", nil, "0", name, name, "none")
	end
	chat.PlaySound()
end
usermessage.Hook("DarkRP_Chat", AddToChat)

/*---------------------------------------------------------------------------
Log a message to console
---------------------------------------------------------------------------*/
local function AdminLog(um)
	local colour = Color(um:ReadShort(), um:ReadShort(), um:ReadShort())
	local text = um:ReadString() .. "\n"
	MsgC(Color(255,0,0), "[DarkRP] ")
	MsgC(colour, text)
end
usermessage.Hook("DRPLogMsg", AdminLog)

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