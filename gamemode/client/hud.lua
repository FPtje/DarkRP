/*---------------------------------------------------------------------------
HUD ConVars
---------------------------------------------------------------------------*/
local ConVars = {}
local HUDWidth
local HUDHeight

local Color = Color
local cvars = cvars
local draw = draw
local GetConVar = GetConVar
local Lerp = Lerp
local localplayer
local pairs = pairs
local SortedPairs = SortedPairs
local string = string
local surface = surface
local table = table
local tostring = tostring

CreateClientConVar("weaponhud", 0, true, false)

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

local function formatNumber(n)
	if not n then return "" end
	if n >= 1e14 then return tostring(n) end
    n = tostring(n)
    local sep = sep or ","
    local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
    end
    return n
end


local Scrw, Scrh, RelativeX, RelativeY
/*---------------------------------------------------------------------------
HUD Seperate Elements
---------------------------------------------------------------------------*/
local Health = 0
local function DrawHealth()
	Health = math.min(100, (Health == localplayer:Health() and Health) or Lerp(0.1, Health, localplayer:Health()))

	local DrawHealth = math.Min(Health / GAMEMODE.Config.startinghealth, 1)
	local Border = math.Min(6, math.pow(2, math.Round(3*DrawHealth)))
	draw.RoundedBox(Border, RelativeX + 4, RelativeY - 30, HUDWidth - 8, 20, ConVars.Healthbackground)
	draw.RoundedBox(Border, RelativeX + 5, RelativeY - 29, (HUDWidth - 9) * DrawHealth, 18, ConVars.Healthforeground)

	draw.DrawText(math.Max(0, math.Round(localplayer:Health())), "DarkRPHUD2", RelativeX + 4 + (HUDWidth - 8)/2, RelativeY - 32, ConVars.HealthText, 1)

	-- Armor
	local armor = localplayer:Armor()
	if armor ~= 0 then
		draw.RoundedBox(2, RelativeX + 4, RelativeY - 15, (HUDWidth - 8) * armor / 100, 5, Color(0, 0, 255, 255))
	end
end

local function DrawInfo()
	local Salary = DarkRP.getPhrase("salary", GAMEMODE.Config.currency, (localplayer:getDarkRPVar("salary") or 0))

	local JobWallet = {
		DarkRP.getPhrase("job", localplayer:getDarkRPVar("job") or ""), "\n",
		DarkRP.getPhrase("wallet", GAMEMODE.Config.currency, formatNumber(localplayer:getDarkRPVar("money") or 0))
	}
	JobWallet = table.concat(JobWallet)

	local wep = localplayer:GetActiveWeapon()

	if IsValid(wep) and GAMEMODE.Config.weaponhud then
        local name = wep:GetPrintName();
		draw.DrawText("Weapon: "..name, "UiBold", RelativeX + 5, RelativeY - HUDHeight - 18, Color(255, 255, 255, 255), 0)
	end

	draw.DrawText(Salary, "DarkRPHUD2", RelativeX + 5, RelativeY - HUDHeight + 6, ConVars.salary1, 0)
	draw.DrawText(Salary, "DarkRPHUD2", RelativeX + 4, RelativeY - HUDHeight + 5, ConVars.salary2, 0)

	surface.SetFont("DarkRPHUD2")
	local w, h = surface.GetTextSize(Salary)

	draw.DrawText(JobWallet, "DarkRPHUD2", RelativeX + 5, RelativeY - HUDHeight + h + 6, ConVars.Job1, 0)
	draw.DrawText(JobWallet, "DarkRPHUD2", RelativeX + 4, RelativeY - HUDHeight + h + 5, ConVars.Job2, 0)
end

local Page = Material("icon16/page_white_text.png")
local function GunLicense()
	if localplayer:getDarkRPVar("HasGunlicense") then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(RelativeX + HUDWidth, ScrH() - 34, 32, 32)
	end
end

local function Agenda()
	local DrawAgenda, AgendaManager = DarkRPAgendas[localplayer:Team()], localplayer:Team()
	if not DrawAgenda then
		for k,v in pairs(DarkRPAgendas) do
			if table.HasValue(v.Listeners or {}, localplayer:Team()) then
				DrawAgenda, AgendaManager = DarkRPAgendas[k], k
				break
			end
		end
	end
	if DrawAgenda then
		draw.RoundedBox(10, 10, 10, 460, 110, Color(0, 0, 0, 155))
		draw.RoundedBox(10, 12, 12, 456, 106, Color(51, 58, 51,100))
		draw.RoundedBox(10, 12, 12, 456, 20, Color(0, 0, 70, 100))

		draw.DrawText(DrawAgenda.Title, "DarkRPHUD1", 30, 12, Color(255,0,0,255),0)

		local AgendaText = {}
		for k,v in pairs(team.GetPlayers(AgendaManager)) do
			if not v.DarkRPVars then continue end
			table.insert(AgendaText, v:getDarkRPVar("agenda"))
		end

		local text = table.concat(AgendaText, "\n")
		text = text:gsub("//", "\n"):gsub("\\n", "\n")
		text = GAMEMODE:TextWrap(text, "DarkRPHUD1", 440)
		draw.DrawText(text, "DarkRPHUD1", 30, 35, Color(255,255,255,255),0)
	end
end

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
		surface.DrawTexturedRectRotated(ScrW() - 100, chboxY, Rotating*96, 96, backwards)
	end
end

local function LockDown()
	local chbxX, chboxY = chat.GetChatBoxPos()
	if util.tobool(GetConVarNumber("DarkRP_LockDown")) then
		local cin = (math.sin(CurTime()) + 1) / 2
		local chatBoxSize = math.floor(ScrH() / 4)
		draw.DrawText(DarkRP.getPhrase("lockdown_started"), "ScoreboardSubtitle", chbxX, chboxY + chatBoxSize, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_LEFT)
	end
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)
	local StartArrested = CurTime()
	local ArrestedUntil = msg:ReadFloat()

	Arrested = function()
		if CurTime() - StartArrested <= ArrestedUntil and localplayer:getDarkRPVar("Arrested") then
		draw.DrawText(DarkRP.getPhrase("youre_arrested", math.ceil(ArrestedUntil - (CurTime() - StartArrested))), "DarkRPHUD1", ScrW()/2, ScrH() - ScrH()/12, Color(255,255,255,255), 1)
		elseif not localplayer:getDarkRPVar("Arrested") then
			Arrested = function() end
		end
	end
end)

local AdminTell = function() end

usermessage.Hook("AdminTell", function(msg)
	local Message = msg:ReadString()

	AdminTell = function()
		draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, 200))
		draw.DrawText(DarkRP.getPhrase("listen_up"), "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, 255), 1)
		draw.DrawText(Message, "ChatFont", ScrW() / 2 + 10, 80, Color(200, 30, 30, 255), 1)
	end

	timer.Simple(10, function()
		AdminTell = function() end
	end)
end)

/*---------------------------------------------------------------------------
Drawing the HUD elements such as Health etc.
---------------------------------------------------------------------------*/
local function DrawHUD()
	localplayer = localplayer and IsValid(localplayer) and localplayer or LocalPlayer()
	if not IsValid(localplayer) then return end

	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_HUD")
	if shouldDraw == false then return end

	Scrw, Scrh = ScrW(), ScrH()
	RelativeX, RelativeY = 0, Scrh

	--Background
	draw.RoundedBox(6, 0, Scrh - HUDHeight, HUDWidth, HUDHeight, ConVars.background)

	DrawHealth()
	DrawInfo()
	GunLicense()
	Agenda()
	DrawVoiceChat()
	LockDown()

	Arrested()
	AdminTell()
end

/*---------------------------------------------------------------------------
Entity HUDPaint things
---------------------------------------------------------------------------*/
local function DrawPlayerInfo(ply)
	local pos = ply:EyePos()

	pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
	pos = pos:ToScreen()
	pos.y = pos.y - 50 -- Move the text up a few pixels to compensate for the height of the text

	if GAMEMODE.Config.showname and not ply:getDarkRPVar("wanted") then
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x, pos.y, team.GetColor(ply:Team()), 1)
		draw.DrawText(DarkRP.getPhrase("health", ply:Health()), "DarkRPHUD2", pos.x + 1, pos.y + 21, Color(0, 0, 0, 255), 1)
		draw.DrawText(DarkRP.getPhrase("health", ply:Health()), "DarkRPHUD2", pos.x, pos.y + 20, Color(255,255,255,200), 1)
	end

	if GAMEMODE.Config.showjob then
		local teamname = team.GetName(ply:Team())
		draw.DrawText(ply:getDarkRPVar("job") or teamname, "DarkRPHUD2", pos.x + 1, pos.y + 41, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:getDarkRPVar("job") or teamname, "DarkRPHUD2", pos.x, pos.y + 40, Color(255, 255, 255, 200), 1)
	end

	if ply:getDarkRPVar("HasGunlicense") then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(pos.x-16, pos.y + 60, 32, 32)
	end
end

local function DrawWantedInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()
	if not pos:RPIsInSight({localplayer, ply}) then return end

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	if GAMEMODE.Config.showname then
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x, pos.y, team.GetColor(ply:Team()), 1)
	end

	local wantedText = DarkRP.getPhrase("wanted", tostring(ply:getDarkRPVar("wantedReason")))

	draw.DrawText(wantedText, "DarkRPHUD2", pos.x, pos.y - 40, Color(255, 255, 255, 200), 1)
	draw.DrawText(wantedText, "DarkRPHUD2", pos.x + 1, pos.y - 41, Color(255, 0, 0, 255), 1)
end

/*---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------*/
local function DrawEntityDisplay()
	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_EntityDisplay")
	if shouldDraw == false then return end

	local shootPos = localplayer:GetShootPos()
	local aimVec = localplayer:GetAimVector()

	for k, ply in pairs(player.GetAll()) do
		if not ply:Alive() then continue end
		local hisPos = ply:GetShootPos()
		if ply:getDarkRPVar("wanted") then DrawWantedInfo(ply) end

		if GAMEMODE.Config.globalshow and ply ~= localplayer then
			DrawPlayerInfo(ply)
		-- Draw when you're (almost) looking at him
		elseif not GAMEMODE.Config.globalshow and hisPos:Distance(shootPos) < 400 then
			local pos = hisPos - shootPos
			local unitPos = pos:GetNormalized()
			if unitPos:Dot(aimVec) > 0.95 then
				local trace = util.QuickTrace(shootPos, pos, localplayer)
				if trace.Hit and trace.Entity ~= ply then return end
				DrawPlayerInfo(ply)
			end
		end
	end

	local tr = localplayer:GetEyeTrace()

	if IsValid(tr.Entity) and tr.Entity:IsOwnable() and tr.Entity:GetPos():Distance(localplayer:GetPos()) < 200 then
		tr.Entity:DrawOwnableInfo()
	end
end

/*---------------------------------------------------------------------------
Actual HUDPaint hook
---------------------------------------------------------------------------*/
function GM:HUDPaint()
	DrawHUD()
	DrawEntityDisplay()

	self.BaseClass:HUDPaint()
end
