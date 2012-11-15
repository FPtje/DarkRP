GM.Version = "2.4.3"
GM.Name = "DarkRP"
GM.Author = "By Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt, Chrome Bolt, FPtje Falco, Eusion, Drakehawke"

DeriveGamemode("sandbox")
util.PrecacheSound("earthquake.mp3")
CUR = "$"

/*---------------------------------------------------------------------------
Fonts
---------------------------------------------------------------------------*/
surface.CreateFont ("DarkRPHUD1", {
	size = 16,
	weight = 600,
	antialias = true,
	shadow = true,
	font = "DejaVu Sans"})
surface.CreateFont ("DarkRPHUD2", {
	size = 23,
	weight = 400,
	antialias = true,
	shadow = false,
	font = "coolvetica"})

/*---------------------------------------------------------------------------
Names
---------------------------------------------------------------------------*/
-- Make sure the client sees the RP name where they expect to see the name
local pmeta = FindMetaTable("Player")

pmeta.SteamName = pmeta.SteamName or pmeta.Name
function pmeta:Name()
	if not self or not self.IsValid or not IsValid(self) then return "" end

	self.DarkRPVars = self.DarkRPVars or {}
	if not GAMEMODE.Config.allowrpnames then
		return self:SteamName()
	end
	return self.DarkRPVars.rpname and tostring(self.DarkRPVars.rpname) or self:SteamName()
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name
-- End

function GM:DrawDeathNotice(x, y)
	if not GAMEMODE.Config.showdeaths then return end
	self.BaseClass:DrawDeathNotice(x, y)
end

local function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	surface.PlaySound("buttons/lightswitch2.wav")

	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

local function LoadModules()
	local root = GAMEMODE.FolderName.."/gamemode/modules/"

	local _, folders = file.Find(root.."*", "LUA")

	for _, folder in SortedPairs(folders, true) do
		for _, File in SortedPairs(file.Find(root .. folder .."/cl_*.lua", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end
		for _, File in SortedPairs(file.Find(root .. folder .."/sh_*.lua", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end
	end
end

LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
for k,v in pairs(player.GetAll()) do
	v.DarkRPVars = v.DarkRPVars or {}
end

GM.Config = {} -- config table

include("config.lua")
include("client/help.lua")

include("client/DRPDermaSkin.lua")
include("client/helpvgui.lua")
include("client/hud.lua")
include("client/showteamtabs.lua")
include("client/vgui.lua")

include("shared/animations.lua")
include("shared/commands.lua")
include("shared/entity.lua")
include("shared/language.lua")
include("shared/MakeThings.lua")
include("shared/Workarounds.lua")

include("shared.lua")
include("addentities.lua")
include("ammotypes.lua")

include("fpp/sh_settings.lua")
include("fpp/client/FPP_Menu.lua")
include("fpp/client/FPP_HUD.lua")
include("fpp/client/FPP_Buddies.lua")
include("fpp/sh_CPPI.lua")

surface.CreateFont("AckBarWriting", {
	size = 20,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "akbar"})

-- Copy from FESP(made by FPtje Falco)
-- This is no stealing since I made FESP myself.
local vector = FindMetaTable("Vector")
function vector:RPIsInSight(v, ply)
	ply = ply or LocalPlayer()
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = self
	trace.filter = v
	trace.mask = -1
	local TheTrace = util.TraceLine(trace)
	if TheTrace.Hit then
		return false, TheTrace.HitPos
	else
		return true, TheTrace.HitPos
	end
end

function GM:HUDShouldDraw(name)
	if name == "CHudHealth" or
		name == "CHudBattery" or
		name == "CHudSuitPower" or
		(HelpToggled and name == "CHudChat") then
			return false
	else
		return true
	end
end

function GM:HUDDrawTargetID()
    return false
end

function GM:FindPlayer(info)
	if not info or info == "" then return nil end
	local pls = player.GetAll()

	for k = 1, #pls do -- Proven to be faster than pairs loop.
		local v = pls[k]
		if tonumber(info) == v:UserID() then
			return v
		end

		if info == v:SteamID() then
			return v
		end

		if string.find(string.lower(v:SteamName()), string.lower(tostring(info)), 1, true) ~= nil then
			return v
		end

		if string.find(string.lower(v:Name()), string.lower(tostring(info)), 1, true) ~= nil then
			return v
		end
	end
	return nil
end

local GUIToggled = false
local HelpToggled = false

local HelpVGUI
local function ToggleHelp()
	if not HelpVGUI then
		HelpVGUI = vgui.Create("HelpVGUI")
	end

	HelpToggled = not HelpToggled

	HelpVGUI.HelpX = HelpVGUI.StartHelpX
	HelpVGUI:SetVisible(HelpToggled)
	gui.EnableScreenClicker(HelpToggled)
end
usermessage.Hook("ToggleHelp", ToggleHelp)

local function ToggleClicker()
	GUIToggled = not GUIToggled
	gui.EnableScreenClicker(GUIToggled)
end
usermessage.Hook("ToggleClicker", ToggleClicker)

local function DoSpecialEffects(Type)
	local thetype = string.lower(Type:ReadString())
	local toggle = tobool(Type:ReadString())
	if toggle then
		if thetype == "motionblur" then
			hook.Add("RenderScreenspaceEffects", thetype, function()
				DrawMotionBlur(0.05, 1.00, 0.035)
			end)
		elseif thetype == "dof" then
			DOF_SPACING = 8
			DOF_OFFSET = 9
			DOF_Start()
		elseif thetype == "colormod" then
			hook.Add("RenderScreenspaceEffects", thetype, function()
				local settings = {}
				settings[ "$pp_colour_addr" ] = 0
			 	settings[ "$pp_colour_addg" ] = 0
			 	settings[ "$pp_colour_addb" ] = 0
			 	settings[ "$pp_colour_brightness" ] = -1
			 	settings[ "$pp_colour_contrast" ] = 0
			 	settings[ "$pp_colour_colour" ] =0
			 	settings[ "$pp_colour_mulr" ] = 0
			 	settings[ "$pp_colour_mulg" ] = 0
			 	settings[ "$pp_colour_mulb" ] = 0
				DrawColorModify(settings)
			end)
		elseif thetype == "drugged" then
			hook.Add("RenderScreenspaceEffects", thetype, function()
				DrawSharpen(-1, 2)
				DrawMaterialOverlay("models/props_lab/Tank_Glass001", 0)
				DrawMotionBlur(0.13, 1, 0.00)
			end)
		elseif thetype == "deathpov" then
			hook.Add("CalcView", "rp_deathPOV", function(ply, origin, angles, fov)
				local Ragdoll = ply:GetRagdollEntity()
				if not IsValid(Ragdoll) then return end

				local head = Ragdoll:LookupAttachment("eyes")
				head = Ragdoll:GetAttachment(head)
				if not head or not head.Pos then return end

				local view = {}
				view.origin = head.Pos
				view.angles = head.Ang
				view.fov = fov
				return view
			end)
		end
	elseif toggle == false then
		if thetype == "dof" then
			DOF_Kill()
			return
		elseif thetype == "deathpov" then
			if hook.GetTable().CalcView and hook.GetTable().CalcView.rp_deathPOV then
				hook.Remove("CalcView", "rp_deathPOV")
			end
			return
		end
		hook.Remove("RenderScreenspaceEffects", thetype)
	end
end
usermessage.Hook("DarkRPEffects", DoSpecialEffects)

local Messagemode = false
local playercolors = {}
local HearMode = "talk"
local isSpeaking = false
local GroupChat = false

local function RPStopMessageMode()
	Messagemode = false
	hook.Remove("Think", "RPGetRecipients")
	hook.Remove("HUDPaint", "RPinstructionsOnSayColors")
	playercolors = {}
end

local function CL_IsInRoom(listener) -- IsInRoom function to see if the player is in the same room.
	local tracedata = {}
	tracedata.start = LocalPlayer():GetShootPos()
	tracedata.endpos = listener:GetShootPos()
	local trace = util.TraceLine( tracedata )

	return not trace.HitWorld
end

local PlayerColorsOn = CreateClientConVar("rp_showchatcolors", 1, true, false)
local function RPSelectwhohearit(group)
	if PlayerColorsOn:GetInt() == 0 then return end
	Messagemode = true
	GroupChat = group
	hook.Add("HUDPaint", "RPinstructionsOnSayColors", function()
		local w, l = ScrW()/80, ScrH() /1.75
		local h = l - (#playercolors * 20) - 20
		local AllTalk = GAMEMODE.Config.alltalk
		if #playercolors <= 0 and ((HearMode ~= "talk through OOC" and HearMode ~= "advert" and not AllTalk) or (AllTalk and HearMode ~= "talk" and HearMode ~= "me") or HearMode == "speak") then
			draw.WordBox(2, w, h, string.format(LANGUAGE.hear_noone, HearMode), "DarkRPHUD1", Color(0,0,0,160), Color(255,0,0,255))
		elseif HearMode == "talk through OOC" or HearMode == "advert" then
			draw.WordBox(2, w, h, LANGUAGE.hear_everyone, "DarkRPHUD1", Color(0,0,0,160), Color(0,255,0,255))
		elseif not AllTalk or (AllTalk and HearMode ~= "talk" and HearMode ~= "me") then
			draw.WordBox(2, w, h, string.format(LANGUAGE.hear_certain_persons, HearMode), "DarkRPHUD1", Color(0,0,0,160), Color(0,255,0,255))
		end

		for k,v in pairs(playercolors) do
			if v.Nick then
				draw.WordBox(2, w, h + k*20, v:Nick(), "DarkRPHUD1", Color(0,0,0,160), Color(255,255,255,255))
			end
		end
	end)

	hook.Add("Think", "RPGetRecipients", function()
		if not Messagemode then RPStopMessageMode() hook.Remove("Think", "RPGetRecipients") return end
		if HearMode ~= "whisper" and HearMode ~= "yell" and HearMode ~= "talk" and HearMode ~= "speak" and HearMode ~= "me" then return end
		playercolors = {}
		for k,v in pairs(player.GetAll()) do
			if v ~= LocalPlayer() then
				local distance = LocalPlayer():GetPos():Distance(v:GetPos())
				if HearMode == "whisper" and distance < 90 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				elseif HearMode == "yell" and distance < 550 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				elseif HearMode == "speak" and distance < 550 and not table.HasValue(playercolors, v) then
					if GAMEMODE.Config.dynamicvoice then
						if CL_IsInRoom( v ) then
							table.insert(playercolors, v)
						end
					else
						table.insert(playercolors, v)
					end
				elseif HearMode == "talk" and not GAMEMODE.Config.alltalk and distance < 250 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				elseif HearMode == "me" and not GAMEMODE.Config.alltalk and distance < 250 and not table.HasValue(playercolors, v) then
					table.insert(playercolors, v)
				end
			end
		end
	end)
end
hook.Add("StartChat", "RPDoSomethingWithChat", RPSelectwhohearit)
hook.Add("FinishChat", "RPCloseRadiusDetection", function()
	if not isSpeaking then
		Messagemode = false
		RPStopMessageMode()
	else
		HearMode = "speak"
	end
end)

function GM:OnPlayerChat()
end

function GM:ChatTextChanged(text)
	if PlayerColorsOn:GetInt() == 0 then return end
	if not Messagemode or HearMode == "speak" then return end
	local old = HearMode
	HearMode = "talk"
	if not GAMEMODE.Config.alltalk then
		if string.sub(text, 1, 2) == "//" or string.sub(string.lower(text), 1, 4) == "/ooc" or string.sub(string.lower(text), 1, 4) == "/a" then
			HearMode = "talk through OOC"
		elseif string.sub(string.lower(text), 1, 7) == "/advert" then
			HearMode = "advert"
		end
	end

	if string.sub(string.lower(text), 1, 3) == "/pm" then
		local plyname = string.sub(text, 5)
		if string.find(plyname, " ") then
			plyname = string.sub(plyname, 1, string.find(plyname, " ") - 1)
		end
		HearMode = "pm"
		playercolors = {}
		if plyname ~= "" and self:FindPlayer(plyname) then
			playercolors = {self:FindPlayer(plyname)}
		end
	elseif string.sub(string.lower(text), 1, 5) == "/call" then
		local plyname = string.sub(text, 7)
		if string.find(plyname, " ") then
			plyname = string.sub(plyname, 1, string.find(plyname, " ") - 1)
		end
		HearMode = "call"
		playercolors = {}
		if plyname ~= "" and self:FindPlayer(plyname) then
			playercolors = {self:FindPlayer(plyname)}
		end
	elseif string.sub(string.lower(text), 1, 3) == "/g " or GroupChat then
		HearMode = "group chat"
		local t = LocalPlayer():Team()
		playercolors = {}
		if t == TEAM_POLICE or t == TEAM_CHIEF or t == TEAM_MAYOR then
			for k, v in pairs(player.GetAll()) do
				if v ~= LocalPlayer() then
					local vt = v:Team()
					if vt == TEAM_POLICE or vt == TEAM_CHIEF or vt == TEAM_MAYOR then table.insert(playercolors, v) end
				end
			end
		elseif t == TEAM_MOB or t == TEAM_GANG then
			for k, v in pairs(player.GetAll()) do
				if v ~= LocalPlayer() then
					local vt = v:Team()
					if vt == TEAM_MOB or vt == TEAM_GANG then table.insert(playercolors, v) end
				end
			end
		end
	elseif string.sub(string.lower(text), 1, 3) == "/w " then
		HearMode = "whisper"
	elseif string.sub(string.lower(text), 1, 2) == "/y" then
		HearMode = "yell"
	elseif string.sub(string.lower(text), 1, 3) == "/me" then
		HearMode = "me"
	end
	if old ~= HearMode then
		playercolors = {}
	end
end

function GM:PlayerStartVoice(ply)
	isSpeaking = true
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	if ply == LocalPlayer() and not GAMEMODE.Config.sv_alltalk and GAMEMODE.Config.voiceradius then
		HearMode = "speak"
		RPSelectwhohearit()
	end

	if ply == LocalPlayer() then
		ply.DRPIsTalking = true
		return -- Not the original rectangle for yourself! ugh!
	end
	self.BaseClass:PlayerStartVoice(ply)
end

function GM:PlayerEndVoice(ply) //voice/icntlk_pl.vtf
	isSpeaking = false

	if ply == LocalPlayer() and not GAMEMODE.Config.sv_alltalk and GAMEMODE.Config.voiceradius then
		HearMode = "talk"
		hook.Remove("Think", "RPGetRecipients")
		hook.Remove("HUDPaint", "RPinstructionsOnSayColors")
		Messagemode = false
		playercolors = {}
	end

	if ply == LocalPlayer() then
		ply.DRPIsTalking = false
		return
	end
	self.BaseClass:PlayerEndVoice(ply)
end

function GM:PlayerBindPress(ply,bind,pressed)
	self.BaseClass:PlayerBindPress(ply, bind, pressed)
	if ply == LocalPlayer() and IsValid(ply:GetActiveWeapon()) and string.find(string.lower(bind), "attack2") and ply:GetActiveWeapon():GetClass() == "weapon_bugbait" then
		LocalPlayer():ConCommand("_hobo_emitsound")
	end
	return
end

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

local function GetAvailableVehicles()
	print("Available vehicles for custom vehicles:")
	for k,v in pairs(list.Get("Vehicles")) do
		print("\""..k.."\"")
	end
end
concommand.Add("rp_getvehicles", GetAvailableVehicles)

local function AdminLog(um)
	local colour = Color(um:ReadShort(), um:ReadShort(), um:ReadShort())
	local text = um:ReadString() .. "\n"
	MsgC(Color(255,0,0), "[DarkRP] ")
	MsgC(colour, text)
end
usermessage.Hook("DRPLogMsg", AdminLog)

local function RetrieveDoorData(len)
	local door = net.ReadEntity()
	local doorData = net.ReadTable()
	if not door or not door.IsValid or not IsValid(door) or not doorData then return end

	if doorData.TeamOwn then
		local tdata = {}
		for k, v in pairs(string.Explode("\n", doorData.TeamOwn or "")) do
			if v and v != "" then
				tdata[tonumber(v)] = true
			end
		end
		doorData.TeamOwn = tdata
	else
		doorData.TeamOwn = nil
	end

	door.DoorData = doorData
end
net.Receive("DarkRP_DoorData", RetrieveDoorData)

local function UpdateDoorData(um)
	local door = um:ReadEntity()
	if not IsValid(door) then return end

	local var, value = um:ReadString(), um:ReadString()
	value = tonumber(value) or value

	if string.match(tostring(value), "Entity .([0-9]*)") then
		value = Entity(string.match(value, "Entity .([0-9]*)"))
	end

	if string.match(tostring(value), "Player .([0-9]*)") then
		value = Entity(string.match(value, "Player .([0-9]*)"))
	end

	if value == "true" or value == "false" then value = tobool(value) end

	if value == "nil" then value = nil end

	if var == "TeamOwn" then
		local decoded = {}
		for k, v in pairs(string.Explode("\n", value or "")) do
			if v and v != "" then
				decoded[tonumber(v)] = true
			end
		end
		if table.Count(decoded) == 0 then
			value = nil
		else
			value = decoded
		end
	end

	door.DoorData = door.DoorData or {}
	door.DoorData[var] = value
end
usermessage.Hook("DRP_UpdateDoorData", UpdateDoorData)

local function RetrievePlayerVar(um)
	local ply = um:ReadEntity()
	if not IsValid(ply) then return end

	ply.DarkRPVars = ply.DarkRPVars or {}

	local var, value = um:ReadString(), um:ReadString()
	local stringvalue = value
	value = tonumber(value) or value

	if string.match(stringvalue, "Entity .([0-9]*)") then
		value = Entity(string.match(stringvalue, "Entity .([0-9]*)"))
	end

	if string.match(stringvalue, [[(-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+)]]) then
		local x,y,z = string.match(value, [[(-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+) (-?[0-9]+.[0-9]+)]])
		value = Vector(x,y,z)
	end

	if stringvalue == "true" or stringvalue == "false" then value = tobool(value) end

	if stringvalue == "nil" then value = nil end

	hook.Call("DarkRPVarChanged", nil, ply, var, ply.DarkRPVars[var], value)
	ply.DarkRPVars[var] = value
end
usermessage.Hook("DarkRP_PlayerVar", RetrievePlayerVar)

local function InitializeDarkRPVars(len)
	local vars = net.ReadTable()

	if not vars then return end
	for k,v in pairs(vars) do
		if not IsValid(k) then continue end
		k.DarkRPVars = k.DarkRPVars or {}

		-- Merge the tables
		for a, b in pairs(v) do
			k.DarkRPVars[a] = b
		end
	end
end
net.Receive("DarkRP_InitializeVars", InitializeDarkRPVars)

function GM:InitPostEntity()
	LoadModules()

	RunConsoleCommand("_sendDarkRPvars")
	timer.Create("DarkRPCheckifitcamethrough", 15, 0, function()
		for k,v in pairs(player.GetAll()) do
			if v.DarkRPVars and v.DarkRPVars.rpname then continue end

			RunConsoleCommand("_sendDarkRPvars")
			return
		end
	end)
end

-- Please only ADD to the credits
-- Removing people from the credits will make at least one person very angry.
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

-- DarkRP plugin for FAdmin. It's this simple to make a plugin. If FAdmin isn't installed, this code won't bother anyone
include(GM.FolderName.."/gamemode/shared/fadmin_darkrp.lua")

if not FAdmin or not FAdmin.StartHooks then return end
FAdmin.StartHooks["DarkRP"] = function()
	-- DarkRP information:
	FAdmin.ScoreBoard.Player:AddInformation("Steam name", function(ply) return ply:SteamName() end, true)
	FAdmin.ScoreBoard.Player:AddInformation("Money", function(ply) if LocalPlayer():IsAdmin() and ply.DarkRPVars and ply.DarkRPVars.money then return "$"..ply.DarkRPVars.money end end)
	FAdmin.ScoreBoard.Player:AddInformation("Wanted", function(ply) if ply.DarkRPVars and ply.DarkRPVars.wanted then return tostring(ply.DarkRPVars["wantedReason"] or "N/A") end end)
	FAdmin.ScoreBoard.Player:AddInformation("Community link", function(ply) return FAdmin.SteamToProfile(ply:SteamID()) end)

	-- Warrant
	FAdmin.ScoreBoard.Player:AddActionButton("Warrant", "FAdmin/icons/Message",	Color(0, 0, 200, 255),
		function(ply) local t = LocalPlayer():Team() return t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF end,
		function(ply, button)
			Derma_StringRequest("Warrant reason", "Enter the reason for the warrant", "", function(Reason)
				LocalPlayer():ConCommand("say /warrant ".. ply:UserID().." ".. Reason)
			end)
		end)

	--wanted
	FAdmin.ScoreBoard.Player:AddActionButton(function(ply)
			return ((ply.DarkRPVars.wanted and "Unw") or "W") .. "anted"
		end,
		function(ply) return "FAdmin/icons/jail", ply.DarkRPVars.wanted and "FAdmin/icons/disable" end,
		Color(0, 0, 200, 255),
		function(ply) local t = LocalPlayer():Team() return t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF end,
		function(ply, button)
			if not ply.DarkRPVars.wanted  then
				Derma_StringRequest("wanted reason", "Enter the reason to arrest this player", "", function(Reason)
					LocalPlayer():ConCommand("say /wanted ".. ply:UserID().." ".. Reason)
				end)
			else
				LocalPlayer():ConCommand("say /unwanted ".. ply:UserID())
			end
		end)

	--Teamban
	local function teamban(ply, button)

		local menu = DermaMenu()
		local Title = vgui.Create("DLabel")
		Title:SetText("  Jobs:\n")
		Title:SetFont("UiBold")
		Title:SizeToContents()
		Title:SetTextColor(color_black)
		local command = (button.TextLabel:GetText() == "Unban from job") and "rp_teamunban" or "rp_teamban"

		menu:AddPanel(Title)
		for k,v in SortedPairsByMemberValue(RPExtraTeams, "name") do
			menu:AddOption(v.name, function() RunConsoleCommand(command, ply:UserID(), k) end)
		end
		menu:Open()
	end
	FAdmin.ScoreBoard.Player:AddActionButton("Ban from job", "FAdmin/icons/changeteam", Color(200, 0, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_commands", ply) end, teamban)

	FAdmin.ScoreBoard.Player:AddActionButton("Unban from job", function() return "FAdmin/icons/changeteam", "FAdmin/icons/disable" end, Color(200, 0, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "rp_commands", ply) end, teamban)
end

-- These fonts used to exist in GMod 12 but were removed in 13.
surface.CreateFont("Trebuchet18", {
	size = 18,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("Trebuchet19", {
	size = 19,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("Trebuchet20", {
	size = 20,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("Trebuchet22", {
	size = 22,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("Trebuchet24", {
	size = 24,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("TabLarge", {
	size = 17,
	weight = 700,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})
surface.CreateFont("UiBold", {
	size = 16,
	weight = 800,
	antialias = true,
	shadow = false,
	font = "Default"})
surface.CreateFont("HUDNumber5", {
	size = 30,
	weight = 800,
	antialias = true,
	shadow = false,
	font = "Default"})
surface.CreateFont("ScoreboardHeader", {
	size = 32,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardSubtitle", {
	size = 22,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardPlayerName", {
	size = 19,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardPlayerName2", {
	size = 15,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})
surface.CreateFont("ScoreboardPlayerNameBig", {
	size = 22,
	weight = 500,
	antialias = true,
	shadow = false,
	font = "coolvetica"})