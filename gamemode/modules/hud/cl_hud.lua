/*---------------------------------------------------------------------------
HUD ConVars
---------------------------------------------------------------------------*/
local ConVars = {}
local HUDWidth
local HUDHeight

local Color = Color
local CurTime = CurTime
local cvars = cvars
local fprp = fprp
local draw = draw
local GetConVar = GetConVar
local hook = hook
local IsValid = IsValid
local Lerp = Lerp
local localplayer
local math = math
local pairs = pairs
local ScrW, ScrH = ScrW, ScrH
local SortedPairs = SortedPairs
local string = string
local surface = surface
local table = table
local timer = timer
local tostring = tostring
local plyMeta = FindMetaTable("Player")

local colors = {}
colors.black = Color(0, 0, 0, 255)
colors.blue = Color(0, 0, 255, 255)
colors.brightred = Color(200, 30, 30, 255)
colors.darkred = Color(0, 0, 70, 100)
colors.darkblack = Color(0, 0, 0, 200)
colors.gray1 = Color(0, 0, 0, 155)
colors.gray2 = Color(51, 58, 51,100)
colors.red = Color(255, 0, 0, 255)
colors.white = Color(255, 255, 255, 255)
colors.white1 = Color(255, 255, 255, 200)

local function ReloadConVars()
	ConVars = {
		background = {0,0,0,100},
		Healthbackground = {0,0,0,200},
		Healthforeground = {140,0,0,180},
		HealthText = {255,255,255,200},
		Job1 = {0,0,150,200},
		Job2 = {0,0,0,255},
		salary1 = {0,150,0,200},
		salary2 = {0,0,0,255}
	}

	for name, Colour in pairs(ConVars) do
		ConVars[name] = {}
		for num, rgb in SortedPairs(Colour) do
			local CVar = GetConVar(name..num) or CreateClientConVar(name..num, rgb, true, false)
			table.insert(ConVars[name], CVar:GetInt())

			if not cvars.GetConVarCallbacks(name..num, false) then
				cvars.AddChangeCallback(name..num, function() timer.Simple(0,ReloadConVars) end)
			end
		end
		ConVars[name] = Color(unpack(ConVars[name]))
	end


	HUDWidth = (GetConVar("HudW") or  CreateClientConVar("HudW", 240, true, false)):GetInt()
	HUDHeight = (GetConVar("HudH") or CreateClientConVar("HudH", 115, true, false)):GetInt()

	if not cvars.GetConVarCallbacks("HudW", false) and not cvars.GetConVarCallbacks("HudH", false) then
		cvars.AddChangeCallback("HudW", function() timer.Simple(0,ReloadConVars) end)
		cvars.AddChangeCallback("HudH", function() timer.Simple(0,ReloadConVars) end)
	end
end
ReloadConVars()

local Scrw, Scrh, RelativeX, RelativeY
/*---------------------------------------------------------------------------
HUD Seperate Elements
---------------------------------------------------------------------------*/
local Health = 0
local function DrawHealth()
	local startingHealth = GAMEMODE.Config.startinghealth
	local myHealth = localplayer:Health()
	Health = math.min(startingHealth, (Health == myHealth and Health) or Lerp(0.1, Health, myHealth))

	local DrawHealth = math.Min(Health / startingHealth, 1)
	local rounded = math.Round(3*DrawHealth)
	local Border = math.Min(6, rounded * rounded)
	draw.RoundedBox(Border, RelativeX + 4, RelativeY - 30, HUDWidth - 8, 20, ConVars.Healthbackground)
	draw.RoundedBox(Border, RelativeX + 5, RelativeY - 29, (HUDWidth - 9) * DrawHealth, 18, ConVars.Healthforeground)

	draw.DrawNonParsedText(math.Max(0, math.Round(myHealth)), "fprpHUD2", RelativeX + 4 + (HUDWidth - 8)/2, RelativeY - 32, ConVars.HealthText, 1)

	-- Armor
	local armor = localplayer:Armor()
	if armor ~= 0 then
		draw.RoundedBox(2, RelativeX + 4, RelativeY - 15, (HUDWidth - 8) * armor / 100, 5, colors.blue)
	end
end

local salaryText, JobWalletText
local function DrawInfo()
	salaryText = salaryText or fprp.getPhrase("salary", fprp.formatMoney(localplayer:getfprpVar("salary")), "")

	JobWalletText = JobWalletText or string.format("%s\n%s",
		fprp.getPhrase("job", localplayer:getfprpVar("job") or ""),
		fprp.getPhrase("wallet", fprp.formatMoney(localplayer:getfprpVar("money")), "")
	)

	draw.DrawNonParsedText(salaryText, "fprpHUD2", RelativeX + 5, RelativeY - HUDHeight + 6, ConVars.salary1, 0)
	draw.DrawNonParsedText(salaryText, "fprpHUD2", RelativeX + 4, RelativeY - HUDHeight + 5, ConVars.salary2, 0)

	surface.SetFont("fprpHUD2")
	local w, h = surface.GetTextSize(salaryText)

	draw.DrawNonParsedText(JobWalletText, "fprpHUD2", RelativeX + 5, RelativeY - HUDHeight + h + 6, ConVars.Job1, 0)
	draw.DrawNonParsedText(JobWalletText, "fprpHUD2", RelativeX + 4, RelativeY - HUDHeight + h + 5, ConVars.Job2, 0)
end

local Page = Material("icon16/page_white_text.png")
local function GunLicense()
	if localplayer:getfprpVar("HasGunlicense") then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(RelativeX + HUDWidth, Scrh - 34, 32, 32)
	end
end

local agendaText
local function Agenda()
	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "fprp_Agenda")
	if shouldDraw == false then return end

	local agenda = localplayer:getAgendaTable()
	if not agenda then return end
	agendaText = agendaText or fprp.textWrap((localplayer:getfprpVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "fprpHUD1", 440)

	draw.RoundedBox(10, 10, 10, 460, 110, colors.gray1)
	draw.RoundedBox(10, 12, 12, 456, 106, colors.gray2)
	draw.RoundedBox(10, 12, 12, 456, 20, colors.darkred)

	draw.DrawNonParsedText(agenda.Title, "fprpHUD1", 30, 12, colors.red, 0)
	draw.DrawNonParsedText(agendaText, "fprpHUD1", 30, 35, colors.white, 0)
end

hook.Add("fprpVarChanged", "agendaHUD", function(ply, var, _, new)
	if ply ~= localplayer then return end
	if var == "agenda" and new then
		agendaText = fprp.textWrap(new:gsub("//", "\n"):gsub("\\n", "\n"), "fprpHUD1", 440)
	else
		agendaText = nil
	end

	if var == "salary" then
		salaryText = fprp.getPhrase("salary", fprp.formatMoney(new), "")
	end

	if var == "job" or var == "money" then
		JobWalletText = string.format("%s\n%s",
			fprp.getPhrase("job", var == "job" and new or localplayer:getfprpVar("job") or ""),
			fprp.getPhrase("wallet", var == "money" and fprp.formatMoney(new) or fprp.formatMoney(localplayer:getfprpVar("money")), "")
		)
	end
end)

local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
	if localplayer.DRPIsTalking then
		local chbxX, chboxY = chat.GetChatBoxPos()

		local Rotating = math.sin(CurTime()*3)
		local backwards = 0
		if Rotating < 0 then
			Rotating = 1-(1+Rotating)
			backwards = 180
		end
		surface.SetTexture(VoiceChatTexture)
		surface.SetDrawColor(ConVars.Healthforeground)
		surface.DrawTexturedRectRotated(Scrw - 100, chboxY, Rotating*96, 96, backwards)
	end
end

local function LockDown()
	local chbxX, chboxY = chat.GetChatBoxPos()
	if GetGlobalBool("fprp_LockDown") then
		local cin = (math.sin(CurTime()) + 1) / 2
		local chatBoxSize = math.floor(Scrh / 4)
		draw.DrawNonParsedText(fprp.getPhrase("lockdown_started"), "ScoreboardSubtitle", chbxX, chboxY + chatBoxSize, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_LEFT)
	end
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)
	local StartArrested = CurTime()
	local ArrestedUntil = msg:ReadFloat()

	Arrested = function()
		if CurTime() - StartArrested <= ArrestedUntil and localplayer:getfprpVar("Arrested") then
			draw.DrawNonParsedText(fprp.getPhrase("youre_arrested", math.ceil(ArrestedUntil - (CurTime() - StartArrested))), "fprpHUD1", Scrw/2, Scrh - Scrh/12, colors.white, 1)
		elseif not localplayer:getfprpVar("Arrested") then
			Arrested = function() end
		end
	end
end)

local AdminTell = function() end

usermessage.Hook("AdminTell", function(msg)
	timer.Destroy("fprp_AdminTell")
	local Message = msg:ReadString()

	AdminTell = function()
		draw.RoundedBox(4, 10, 10, Scrw - 20, 110, colors.darkblack)
		draw.DrawNonParsedText(fprp.getPhrase("listen_up"), "GModToolName", Scrw / 2 + 10, 10, colors.white, 1)
		draw.DrawNonParsedText(Message, "ChatFont", Scrw / 2 + 10, 90, colors.brightred, 1)
	end

	timer.Create("fprp_AdminTell", 10, 1, function()
		AdminTell = function() end
	end)
end)

/*---------------------------------------------------------------------------
Drawing the HUD elements such as Health etc.
---------------------------------------------------------------------------*/
local function DrawHUD()
	localplayer = localplayer and IsValid(localplayer) and localplayer or LocalPlayer()
	if not IsValid(localplayer) then return end

	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "fprp_HUD")
	if shouldDraw == false then return end

	Scrw, Scrh = ScrW(), ScrH()
	RelativeX, RelativeY = 0, Scrh

	Agenda()
	DrawVoiceChat()
	LockDown()

	Arrested()
	AdminTell()
end

/*---------------------------------------------------------------------------
Entity HUDPaint things
---------------------------------------------------------------------------*/
-- Draw a player's name, health and/or job above the head
-- This syntax allows for easy overriding
plyMeta.drawPlayerInfo = plyMeta.drawPlayerInfo or function(self)
	local pos = self:EyePos()

	pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
	pos = pos:ToScreen()
	if not self:getfprpVar("wanted") then
		-- Move the text up a few pixels to compensate for the height of the text
		pos.y = pos.y - 50
	end

	if GAMEMODE.Config.showname then
		local nick, plyTeam = self:Nick(), self:Team()
		draw.DrawNonParsedText(nick, "fprpHUD2", pos.x + 1, pos.y + 1, colors.black, 1)
		draw.DrawNonParsedText(nick, "fprpHUD2", pos.x, pos.y, RPExtraTeams[plyTeam] and RPExtraTeams[plyTeam].color or team.GetColor(plyTeam) , 1)
	end

	if GAMEMODE.Config.showhealth then
		local health = fprp.getPhrase("health", self:Health())
		draw.DrawNonParsedText(health, "fprpHUD2", pos.x + 1, pos.y + 21, colors.black, 1)
		draw.DrawNonParsedText(health, "fprpHUD2", pos.x, pos.y + 20, colors.white1, 1)
	end

	if GAMEMODE.Config.showjob then
		local teamname = self:getfprpVar("job") or team.GetName(self:Team())
		draw.DrawNonParsedText(teamname, "fprpHUD2", pos.x + 1, pos.y + 41, colors.black, 1)
		draw.DrawNonParsedText(teamname, "fprpHUD2", pos.x, pos.y + 40, colors.white1, 1)
	end

	if self:getfprpVar("HasGunlicense") then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(pos.x-16, pos.y + 60, 32, 32)
	end
end

-- Draw wanted information above a player's head
-- This syntax allows for easy overriding
plyMeta.drawWantedInfo = plyMeta.drawWantedInfo or function(self)
	if not self:Alive() then return end

	local pos = self:EyePos()
	if not pos:isInSight({localplayer, self}) then return end

	pos.z = pos.z + 10
	pos = pos:ToScreen()

	if GAMEMODE.Config.showname then
		local nick, plyTeam = self:Nick(), self:Team()
		draw.DrawNonParsedText(nick, "fprpHUD2", pos.x + 1, pos.y + 1, colors.black, 1)
		draw.DrawNonParsedText(nick, "fprpHUD2", pos.x, pos.y, RPExtraTeams[plyTeam] and RPExtraTeams[plyTeam].color or team.GetColor(plyTeam) , 1)
	end

	local wantedText = fprp.getPhrase("wanted", tostring(self:getfprpVar("wantedReason")))

	draw.DrawNonParsedText(wantedText, "fprpHUD2", pos.x, pos.y - 40, colors.white1, 1)
	draw.DrawNonParsedText(wantedText, "fprpHUD2", pos.x + 1, pos.y - 41, colors.red, 1)
end

/*---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------*/
local function DrawEntityDisplay()
	local shouldDraw, players = hook.Call("HUDShouldDraw", GAMEMODE, "fprp_EntityDisplay")
	if shouldDraw == false then return end

	local shootPos = localplayer:GetShootPos()
	local aimVec = localplayer:GetAimVector()

	for k, ply in pairs(players or player.GetAll()) do
		if ply == localplayer or not ply:Alive() or ply:GetNoDraw() then continue end
		local hisPos = ply:GetShootPos()
		if ply:getfprpVar("wanted") then ply:drawWantedInfo() end

		if GAMEMODE.Config.globalshow then
			ply:drawPlayerInfo()
		-- Draw when you're (almost) looking at him
		elseif hisPos:DistToSqr(shootPos) < 160000 then
			local pos = hisPos - shootPos
			local unitPos = pos:GetNormalized()
			if unitPos:Dot(aimVec) > 0.95 then
				local trace = util.QuickTrace(shootPos, pos, localplayer)
				if trace.Hit and trace.Entity ~= ply then return end
				ply:drawPlayerInfo()
			end
		end
	end

	local tr = localplayer:GetEyeTrace()

	if IsValid(tr.Entity) and tr.Entity:isKeysOwnable() and tr.Entity:GetPos():DistToSqr(localplayer:GetPos()) < 40000 then
		tr.Entity:drawOwnableInfo()
	end
end

/*---------------------------------------------------------------------------
Drawing death notices
---------------------------------------------------------------------------*/
function GM:DrawDeathNotice(x, y)
	if not GAMEMODE.Config.showdeaths then return end
	self.BaseClass:DrawDeathNotice(x, y)
end

/*---------------------------------------------------------------------------
Display notifications
---------------------------------------------------------------------------*/
local function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	surface.PlaySound("buttons/lightswitch2.wav")

	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

/*---------------------------------------------------------------------------
Remove some elements from the HUD in favour of the fprp HUD
---------------------------------------------------------------------------*/
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

/*---------------------------------------------------------------------------
Disable players' names popping up when looking at them
---------------------------------------------------------------------------*/
function GM:HUDDrawTargetID()
    return false
end

/*---------------------------------------------------------------------------
Actual HUDPaint hook
---------------------------------------------------------------------------*/
local inspiration = Material("materials/fprp/inspiration.png")
local insw, insh = 298, 600
local insx = 600
local mod = 1

g_hud = Material("materials/fprp/hud.png") -- make it global so its faster

function GM:HUDPaint()
	DrawHUD()
	DrawEntityDisplay()

	self.BaseClass:HUDPaint()
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial(inspiration)
	surface.DrawTexturedRect(ScrW() - insw, ScrH() - insx, insw, insh)
	insx = insx + (mod * 200 * FrameTime())
	if (insx >= 600) or (insx <= 300) then
		mod = -mod
	end


	surface.SetDrawColor(0, 0, 0, 255)
	surface.SetMaterial(g_hud)
	surface.DrawTexturedRect(0, ScrH() - 300, 300, 300)

	draw.SimpleText(string.Comma(LocalPlayer():getfprpVar("money")), 'fprpHUD2', 80, ScrH() - 80, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 

end

if IsValid(f) then f:Remove() end
local function danceDance()
	for i =1, 30 do
	chat.AddText(Color(255,255,255), 'DANCE DANCE DANCE')
end
-- blaze it
	f=vgui.Create('DHTML') f:SetSize(420,320) f:SetPos(ScrW() - 420,0) f:SetHTML('</iframe> <iframe width="400" height="300" src="https://www.youtube.com/embed/QTzp5gh-KEI?rel=0&autoplay=1" frameborder="0" allowfullscreen></iframe>')

	timer.Simple(30, function() f:Remove() timer.Simple(30, function() danceDance() end) end)

end
timer.Simple(30, function()
danceDance()
end)