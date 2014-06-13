local stopSpectating, startFreeRoam
local isSpectating = false
local specEnt
local thirdperson = true
local isRoaming = false
local roamPos -- the position when roaming free
local roamVelocity = Vector(0)

/*---------------------------------------------------------------------------
startHooks
FAdmin tab buttons
---------------------------------------------------------------------------*/
FAdmin.StartHooks["zzSpectate"] = function()
	FAdmin.Access.AddPrivilege("Spectate", 2)
	FAdmin.Commands.AddCommand("Spectate", nil, "<Player>")

	-- Right click option
	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Spectate", function(ply)
		if not IsValid(ply) then return end
		RunConsoleCommand("_FAdmin", "Spectate", ply:UserID())
	end)

	-- Spectate option in player menu
	FAdmin.ScoreBoard.Player:AddActionButton("Spectate", "FAdmin/icons/spectate", Color(0, 200, 0, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Spectate") and ply ~= LocalPlayer() end, function(ply)
		if not IsValid(ply) then return end
		RunConsoleCommand("_FAdmin", "Spectate", ply:UserID())
	end)
end

/*---------------------------------------------------------------------------
Get the thirdperson position
---------------------------------------------------------------------------*/
local function getThirdPersonPos(ply)
	local aimvector = LocalPlayer():GetAimVector()
	local startPos = ply:GetShootPos()
	local endpos = startPos - aimvector * 100

	local tracer = {
		start = startPos,
		endpos = endpos,
		filter = specEnt
	}

	local trace = util.TraceLine(tracer)

	return trace.HitPos + trace.HitNormal * 10
end

/*---------------------------------------------------------------------------
Get the CalcView table
---------------------------------------------------------------------------*/
local view = {
	vm_origin = Vector(0, 0, -13000)
}
local function getCalcView()
	if not isRoaming then
		if thirdperson then
			view.origin = getThirdPersonPos(specEnt)
			view.angles = LocalPlayer():EyeAngles()
		else
			view.origin = specEnt:GetShootPos()
			view.angles = specEnt:EyeAngles()
		end

		roamPos = view.origin

		return view
	end

	view.origin = roamPos
	view.angles = LocalPlayer():EyeAngles()

	return view
end

/*---------------------------------------------------------------------------
specCalcView
Override the view for the player to look through the spectated player's eyes
---------------------------------------------------------------------------*/
local function specCalcView(ply, origin, angles, fov)
	if not IsValid(specEnt) and not isRoaming then
		startFreeRoam()
		return
	end

	local view = getCalcView()

	if IsValid(specEnt) then
		specEnt:SetNoDraw(not thirdperson)
	end

	return view
end

/*---------------------------------------------------------------------------
Find the right player to spectate
---------------------------------------------------------------------------*/
local function findNearestPlayer()
	local aimvec = LocalPlayer():GetAimVector()

	local foundPly, foundDot = nil, 0

	for _, ply in pairs(player.GetAll()) do
		if ply == LocalPlayer() then continue end

		local pos = ply:GetShootPos()
		local dot = (pos - roamPos):GetNormalized():Dot(aimvec)
		local distance = pos:Distance(roamPos)

		-- Discard players you're not looking at
		if dot < 0.97 then continue end
		-- not a better alternative
		if dot < foundDot then continue end

		local trace = util.QuickTrace(roamPos, pos - roamPos, ply)

		if trace.Hit then continue end

		foundPly, foundDot = ply, dot
	end

	return foundPly
end

/*---------------------------------------------------------------------------
Spectate the person you're looking at while you're roaming
---------------------------------------------------------------------------*/
local function spectateLookingAt()
	local foundPly = findNearestPlayer()

	if not IsValid(foundPly) then return end

	RunConsoleCommand("FAdmin", "Spectate", foundPly:SteamID())
end

/*---------------------------------------------------------------------------
specBinds
Change binds to perform spectate specific tasks
---------------------------------------------------------------------------*/
-- Manual keysDown table, so I can return true in plyBindPress and still detect key presses
local keysDown = {}
local function specBinds(ply, bind, pressed)
	if bind == "+jump" then
		stopSpectating()
		return true
	elseif bind == "+reload" and pressed then
		local pos = getCalcView().origin - Vector(0, 0, 64)
		RunConsoleCommand("FAdmin", "TPToPos", string.format("%d, %d, %d", pos.x, pos.y, pos.z),
			string.format("%d, %d, %d", roamVelocity.x, roamVelocity.y, roamVelocity.z))
		stopSpectating()
	elseif bind == "+attack" and pressed then
		if not isRoaming then
			startFreeRoam()
		else
			spectateLookingAt()
		end
		return true
	elseif bind == "+attack2" and pressed then
		if isRoaming then
			roamPos = roamPos + LocalPlayer():GetAimVector() * 500
			return true
		end
		thirdperson = not thirdperson

		return true
	elseif isRoaming and not LocalPlayer():KeyDown(IN_USE) then
		local key = string.match(bind, "+([a-z A-Z 0-9]+)")
		if not key or key == "use" then return end

		keysDown[key:upper()] = pressed

		return true
	end
	-- Do not return otherwise, spectating admins should be able to move to avoid getting detected
end

/*---------------------------------------------------------------------------
Spectate think
Free roaming position updates
---------------------------------------------------------------------------*/
local function specThink()
	local ply = LocalPlayer()

	if not isRoaming or keysDown["USE"] then return end

	local roamSpeed = 1000
	local aimVec = ply:GetAimVector()
	local direction = Vector(0)
	local frametime = RealFrameTime()

	if keysDown["FORWARD"] then
		direction = aimVec
	elseif keysDown["BACK"] then
		direction = -aimVec
	end

	if keysDown["MOVELEFT"] then
		direction = direction - aimVec:Angle():Right()
	elseif keysDown["MOVERIGHT"] then
		direction = direction + aimVec:Angle():Right()
	end

	if ply:KeyDown(IN_SPEED) then
		roamSpeed = 1700
	elseif keysDown["WALK"] then
		roamSpeed = 400
	end

	direction:Normalize()

	roamVelocity = direction * roamSpeed
	roamPos = roamPos + roamVelocity * frametime
end

/*---------------------------------------------------------------------------
Draw help on the screen
---------------------------------------------------------------------------*/
local uiForeground, uiBackground = Color(240, 240, 255, 255), Color(0, 0, 60, 120)
local red = Color(255, 0, 0, 255)
local function drawHelp()
	draw.WordBox(2, 10, ScrH() / 2, "Left click: (Un)select player to spectate", "UiBold", uiBackground, uiForeground)

	if isRoaming then
		draw.WordBox(2, 10, ScrH() / 2 + 20, "Right click: quickly move forwards", "UiBold", uiBackground, uiForeground)
	else
		draw.WordBox(2, 10, ScrH() / 2 + 20, "Right click: toggle thirdperson", "UiBold", uiBackground, uiForeground)
	end
	draw.WordBox(2, 10, ScrH() / 2 + 40, "Jump: Stop spectating", "UiBold", uiBackground, uiForeground)
	draw.WordBox(2, 10, ScrH() / 2 + 60, "Reload: Stop spectating and teleport", "UiBold", uiBackground, uiForeground)

	if not isRoaming then return end

	local ply = findNearestPlayer()
	if not IsValid(ply) then return end

	local mins, maxs = ply:LocalToWorld(ply:OBBMins()):ToScreen(), ply:LocalToWorld(ply:OBBMaxs()):ToScreen()
	draw.WordBox(2, math.min(mins.x, maxs.x), maxs.y - 46, ply:Nick(), "UiBold", uiBackground, uiForeground)
	draw.WordBox(2, math.min(mins.x, maxs.x), maxs.y - 26, "Left click to spectate!", "UiBold", uiBackground, uiForeground)
	draw.RoundedBox(8, mins.x, mins.y, maxs.x - mins.x, maxs.y - mins.y, Color(255, 0, 0, 255))
end

/*---------------------------------------------------------------------------
Start roaming free, rather than spectating a given player
---------------------------------------------------------------------------*/
startFreeRoam = function()
	if IsValid(specEnt) then
		roamPos = thirdperson and getThirdPersonPos(specEnt) or specEnt:GetShootPos()
		specEnt:SetNoDraw(false)
	else
		roamPos = isSpectating and roamPos or LocalPlayer():GetShootPos()
	end

	specEnt = nil
	isRoaming = true
	keysDown = {}
end

/*---------------------------------------------------------------------------
specEnt
Spectate a player
---------------------------------------------------------------------------*/
local function startSpectate(um)
	isRoaming = um:ReadBool()
	specEnt = um:ReadEntity()

	if isRoaming then
		startFreeRoam()
	end

	isSpectating = true
	keysDown = {}

	hook.Add("CalcView", "FAdminSpectate", specCalcView)
	hook.Add("PlayerBindPress", "FAdminSpectate", specBinds)
	hook.Add("ShouldDrawLocalPlayer", "FAdminSpectate", function() return isRoaming or thirdperson end)
	hook.Add("Think", "FAdminSpectate", specThink)
	hook.Add("HUDPaint", "FAdminSpectate", drawHelp)

	timer.Create("FAdminSpectatePosUpdate", 0.5, 0, function()
		if not isRoaming then return end

		RunConsoleCommand("_FAdmin_SpectatePosUpdate", roamPos.x, roamPos.y, roamPos.z)
	end)
end
usermessage.Hook("FAdminSpectate", startSpectate)

/*---------------------------------------------------------------------------
stopSpectating
Stop spectating a player
---------------------------------------------------------------------------*/
stopSpectating = function()
	hook.Remove("CalcView", "FAdminSpectate")
	hook.Remove("PlayerBindPress", "FAdminSpectate")
	hook.Remove("ShouldDrawLocalPlayer", "FAdminSpectate")
	hook.Remove("Think", "FAdminSpectate")
	hook.Remove("HUDPaint", "FAdminSpectate")

	timer.Destroy("FAdminSpectatePosUpdate")

	if IsValid(specEnt) then
		specEnt:SetNoDraw(false)
	end

	RunConsoleCommand("_FAdmin_StopSpectating")
	isSpectating = false
end
