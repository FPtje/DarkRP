/*---------------------------------------------------------------------------
HUD ConVars
---------------------------------------------------------------------------*/
local ConVars = {}
local HUDWidth
local HUDHeight

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
	n = tonumber(n)
	if (!n) then
		return 0
	end
	if n >= 1e14 then return tostring(n) end
    n = tostring(n)
    sep = sep or ","
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
	Health = math.min(100, (Health == LocalPlayer():Health() and Health) or Lerp(0.1, Health, LocalPlayer():Health()))

	local DrawHealth = math.Min(Health / GetConVarNumber("startinghealth"), 1)
	local Border = math.Min(6, math.pow(2, math.Round(3*DrawHealth)))
	draw.RoundedBox(Border, RelativeX + 4, RelativeY - 30, HUDWidth - 8, 20, ConVars.Healthbackground)
	draw.RoundedBox(Border, RelativeX + 5, RelativeY - 29, (HUDWidth - 9) * DrawHealth, 18, ConVars.Healthforeground)

	draw.DrawText(math.Max(0, math.Round(LocalPlayer():Health())), "TargetID", RelativeX + 4 + (HUDWidth - 8)/2, RelativeY - 32, ConVars.HealthText, 1)
end

local function DrawInfo()
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	local Salary = 	LANGUAGE.salary .. CUR .. (LocalPlayer().DarkRPVars.salary or 0)

	local JobWallet =
	LANGUAGE.job .. (LocalPlayer().DarkRPVars.job or "") .. "\n"..
	LANGUAGE.wallet .. CUR .. (formatNumber(LocalPlayer().DarkRPVars.money) or 0)

	local wep = LocalPlayer( ):GetActiveWeapon( );

	if ValidEntity( wep ) and GetConVarNumber("weaponhud") == 1 then
        local name = wep:GetPrintName();
		draw.DrawText("Weapon: "..name, "UiBold", RelativeX + 5, RelativeY - HUDHeight - 18, Color(255, 255, 255, 255), 0)
	end

	draw.DrawText(Salary, "TargetID", RelativeX + 5, RelativeY - HUDHeight + 6, ConVars.salary1, 0)
	draw.DrawText(Salary, "TargetID", RelativeX + 4, RelativeY - HUDHeight + 5, ConVars.salary2, 0)

	surface.SetFont("TargetID")
	local w, h = surface.GetTextSize(Salary)

	draw.DrawText(JobWallet, "TargetID", RelativeX + 5, RelativeY - HUDHeight + h + 6, ConVars.Job1, 0)
	draw.DrawText(JobWallet, "TargetID", RelativeX + 4, RelativeY - HUDHeight + h + 5, ConVars.Job2, 0)
end

local Page = surface.GetTextureID("gui/silkicons/page")
local function GunLicense()
	if LocalPlayer().DarkRPVars.HasGunlicense then
		local QuadTable = {}

		QuadTable.texture 	= Page
		QuadTable.color		= Color( 255, 255, 255, 100 )

		QuadTable.x = RelativeX + HUDWidth + 31
		QuadTable.y = ScrH() - 32
		QuadTable.w = 32
		QuadTable.h = 32
		draw.TexturedQuad(QuadTable)
	end
end

local function JobHelp()
	local Helps = {"Cop", "Mayor", "Admin", "Boss"}

	for k,v in pairs(Helps) do
		if LocalPlayer().DarkRPVars["help"..v] then
			draw.RoundedBox(10, 10, 10, 590, 194, Color(0, 0, 0, 255))
			draw.RoundedBox(10, 12, 12, 586, 190, Color(51, 58, 51, 200))
			draw.RoundedBox(10, 12, 12, 586, 20, Color(0, 0, 70, 200))
			draw.DrawText(v.." Help", "ScoreboardText", 30, 12, Color(255,0,0,255),0)
			draw.DrawText(string.format(LANGUAGE[v:lower().."help"], GetConVarNumber("jailtimer")), "ScoreboardText", 30, 35, Color(255,255,255,255),0)
		end
	end
end

local function Agenda()
	local DrawAgenda, AgendaManager = DarkRPAgendas[LocalPlayer():Team()], LocalPlayer():Team()
	if not DrawAgenda then
		for k,v in pairs(DarkRPAgendas) do
			if table.HasValue(v.Listeners, LocalPlayer():Team()) then
				DrawAgenda, AgendaManager = DarkRPAgendas[k], k
				break
			end
		end
	end
	if DrawAgenda then
		draw.RoundedBox(10, 10, 10, 460, 110, Color(0, 0, 0, 155))
		draw.RoundedBox(10, 12, 12, 456, 106, Color(51, 58, 51,100))
		draw.RoundedBox(10, 12, 12, 456, 20, Color(0, 0, 70, 100))

		draw.DrawText(DrawAgenda.Title, "ScoreboardText", 30, 12, Color(255,0,0,255),0)

		local AgendaText = ""
		for k,v in pairs(team.GetPlayers(AgendaManager)) do
			AgendaText = AgendaText .. (v.DarkRPVars.agenda or "")
		end
		draw.DrawText(string.gsub(string.gsub(AgendaText, "//", "\n"), "\\n", "\n"), "ScoreboardText", 30, 35, Color(255,255,255,255),0)
	end
end

local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
	if LocalPlayer().DRPIsTalking then
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
		draw.DrawText(LANGUAGE.lockdown_started, "ScoreboardSubtitle", chbxX, chboxY + chatBoxSize, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_LEFT)
	end
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)
	local StartArrested = CurTime()
	local ArrestedUntil = msg:ReadFloat()

	Arrested = function()
		if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer().DarkRPVars.Arrested then
		draw.DrawText(string.format(LANGUAGE.youre_arrested, math.ceil(ArrestedUntil - (CurTime() - StartArrested))), "ScoreboardText", ScrW()/2, ScrH() - ScrH()/12, Color(255,255,255,255), 1)
		elseif not LocalPlayer().DarkRPVars.Arrested then
			Arrested = function() end
		end
	end
end)

local AdminTell = function() end

usermessage.Hook("AdminTell", function(msg)
	local Message = msg:ReadString()

	AdminTell = function()
		draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, 255))
		draw.DrawText(LANGUAGE.listen_up, "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, 255), 1)
		draw.DrawText(Message, "ChatFont", ScrW() / 2 + 10, 65, Color(200, 30, 30, 255), 1)
	end

	timer.Simple(10, function()
		AdminTell = function() end
	end)
end)

/*---------------------------------------------------------------------------
Drawing the HUD elements such as Health etc.
---------------------------------------------------------------------------*/
local function DrawHUD()
	Scrw, Scrh = ScrW(), ScrH()
	RelativeX, RelativeY = 0, Scrh

	--Background
	draw.RoundedBox(6, 0, Scrh - HUDHeight, HUDWidth, HUDHeight, ConVars.background)

	DrawHealth()
	DrawInfo()
	GunLicense()
	Agenda()
	JobHelp()
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

	if GetConVarNumber("nametag") == 1 then
		draw.DrawText(ply:Nick(), "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "TargetID", pos.x, pos.y, team.GetColor(ply:Team()), 1)
		draw.DrawText(LANGUAGE.health ..ply:Health(), "TargetID", pos.x + 1, pos.y + 21, Color(0, 0, 0, 255), 1)
		draw.DrawText(LANGUAGE.health..ply:Health(), "TargetID", pos.x, pos.y + 20, Color(255,255,255,200), 1)
	end

	if GetConVarNumber("jobtag") == 1 then
		draw.DrawText(ply.DarkRPVars.job or "", "TargetID", pos.x + 1, pos.y + 41, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply.DarkRPVars.job or "", "TargetID", pos.x, pos.y + 40, Color(255, 255, 255, 200), 1)
	end

	if ply.DarkRPVars.HasGunlicense then
		surface.SetTexture(surface.GetTextureID("gui/silkicons/page"))
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(pos.x-16, pos.y + 60, 32, 32)
	end
end

local function DrawWantedInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()
	if not pos:RPIsInSight({LocalPlayer(), ply}) then return end

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	if GetConVarNumber("nametag") == 1 then
		draw.DrawText(ply:Nick(), "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "TargetID", pos.x, pos.y, team.GetColor(ply:Team()), 1)
	end

	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "TargetID", pos.x, pos.y - 40, Color(255, 255, 255, 200), 1)
	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "TargetID", pos.x + 1, pos.y - 41, Color(255, 0, 0, 255), 1)
end

/*---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------*/
local function DrawEntityDisplay()
	local shootPos = LocalPlayer():GetShootPos()
	local aimVec = LocalPlayer():GetAimVector()

	for k, ply in pairs(player.GetAll()) do
		if not ply:Alive() then continue end
		local hisPos = ply:GetShootPos()

		ply.DarkRPVars = ply.DarkRPVars or {}
		if ply.DarkRPVars.wanted then DrawWantedInfo(ply) end

		if GetConVarNumber("globalshow") == 1 and ply ~= LocalPlayer() then
			DrawPlayerInfo(ply)
		-- Draw when you're (almost) looking at him
		elseif not tobool(GetConVarNumber("globalshow")) and hisPos:Distance(shootPos) < 400 then
			local pos = (hisPos - shootPos):GetNormalized()
			if pos:Dot(aimVec) > 0.95 then
				local trace = util.QuickTrace(shootPos, pos * 400, LocalPlayer())
				if trace.Hit and trace.Entity ~= ply then return end
				DrawPlayerInfo(ply)
			end
		end
	end

	local tr = LocalPlayer():GetEyeTrace()

	if tr.Entity:IsOwnable() and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 200 then
		tr.Entity:DrawOwnableInfo()
	end
end

/*---------------------------------------------------------------------------
Zombie display
---------------------------------------------------------------------------*/
local function DrawZombieInfo()
	if not LocalPlayer().DarkRPVars.zombieToggle then return end
	for x=1, LocalPlayer().DarkRPVars.numPoints, 1 do
		local zPoint = LocalPlayer().DarkRPVars["zPoints".. x]
		if zPoint then
			zPoint = zPoint:ToScreen()
			draw.DrawText("Zombie Spawn (" .. x .. ")", "TargetID", zPoint.x, zPoint.y - 20, Color(255, 255, 255, 200), 1)
			draw.DrawText("Zombie Spawn (" .. x .. ")", "TargetID", zPoint.x + 1, zPoint.y - 21, Color(255, 0, 0, 255), 1)
		end
	end
end

/*---------------------------------------------------------------------------
Actual HUDPaint hook
---------------------------------------------------------------------------*/
function GM:HUDPaint()
	DrawHUD()
	DrawZombieInfo()
	DrawEntityDisplay()

	self.BaseClass:HUDPaint()
end