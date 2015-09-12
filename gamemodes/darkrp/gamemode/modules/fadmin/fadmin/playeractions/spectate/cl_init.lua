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
    FAdmin.ScoreBoard.Player:AddActionButton("Spectate", "fadmin/icons/spectate", Color(0, 200, 0, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Spectate") and ply ~= LocalPlayer() end, function(ply)
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

    view = getCalcView()

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
        local key = string.lower(string.match(bind, "+([a-z A-Z 0-9]+)") or "")
        if not key or key == "use" or key == "showscores" or string.find(bind, "messagemode") then return end

        keysDown[key:upper()] = pressed

        return true
    end
    -- Do not return otherwise, spectating admins should be able to move to avoid getting detected
end

/*---------------------------------------------------------------------------
Scoreboardshow
Set to main view when roaming, open on a player when spectating
---------------------------------------------------------------------------*/
local function fadminmenushow()
    if isRoaming then
        FAdmin.ScoreBoard.ChangeView("Main")
    elseif IsValid(specEnt) and specEnt:IsPlayer() then
        FAdmin.ScoreBoard.ChangeView("Main")
        FAdmin.ScoreBoard.ChangeView("Player", specEnt)
    end
end


/*---------------------------------------------------------------------------
RenderScreenspaceEffects
Draws the lines from players' eyes to where they are looking
---------------------------------------------------------------------------*/
local LineMat = Material("cable/new_cable_lit")
local linesToDraw = {}
local function lookingLines()
    if not linesToDraw[0] then return end

    render.SetMaterial(LineMat)

    cam.Start3D(view.origin, view.angles)
        for i = 0, #linesToDraw, 3 do
            render.DrawBeam(linesToDraw[i], linesToDraw[i + 1], 4, 0.01, 10, linesToDraw[i + 2])
        end
    cam.End3D()
end

/*---------------------------------------------------------------------------
gunpos
Gets the position of a player's gun
---------------------------------------------------------------------------*/
local function gunpos(ply)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return ply:EyePos() end
    local att = wep:GetAttachment(1)
    if not att then return ply:EyePos() end
    return att.Pos
end

/*---------------------------------------------------------------------------
Spectate think
Free roaming position updates
---------------------------------------------------------------------------*/
local function specThink()
    local ply = LocalPlayer()

    -- Update linesToDraw
    local pls = player.GetAll()
    local lastPly = 0
    local skip = 0
    for i = 0, #pls - 1 do
        local p = pls[i + 1]
        if not isRoaming and p == specEnt and not thirdperson then skip = skip + 3 continue end

        local tr = p:GetEyeTrace()
        local sp = gunpos(p)

        local pos = i * 3 - skip

        linesToDraw[pos] = tr.HitPos
        linesToDraw[pos + 1] = sp
        linesToDraw[pos + 2] = team.GetColor(p:Team())
        lastPly = i
    end

    -- Remove entries from linesToDraw that don't match with a player anymore
    for i = #linesToDraw, lastPly * 3 + 3, -1 do linesToDraw[i] = nil end

    if not isRoaming or keysDown["USE"] then return end

    local roamSpeed = 1000
    local aimVec = ply:GetAimVector()
    local direction
    local frametime = RealFrameTime()

    if keysDown["FORWARD"] then
        direction = aimVec
    elseif keysDown["BACK"] then
        direction = -aimVec
    end

    if keysDown["MOVELEFT"] then
        local right = aimVec:Angle():Right()
        direction = direction and (direction - right):GetNormalized() or -right
    elseif keysDown["MOVERIGHT"] then
        local right = aimVec:Angle():Right()
        direction = direction and (direction + right):GetNormalized() or right
    end

    if keysDown["SPEED"] then
        roamSpeed = 2500
    elseif keysDown["WALK"] or keysDown["DUCK"] then
        roamSpeed = 300
    end

    if not direction then return end

    roamVelocity = direction * roamSpeed
    roamPos = roamPos + roamVelocity * frametime
end

/*---------------------------------------------------------------------------
Draw help on the screen
---------------------------------------------------------------------------*/
local uiForeground, uiBackground = Color(240, 240, 255, 255), Color(20, 20, 20, 120)
local red = Color(255, 0, 0, 255)
local function drawHelp()
    local scrHalfH = math.floor(ScrH() / 2)
    draw.WordBox(2, 10, scrHalfH, "Left click: (Un)select player to spectate", "UiBold", uiBackground, uiForeground)
    draw.WordBox(2, 10, scrHalfH + 20, isRoaming and "Right click: quickly move forwards" or "Right click: toggle thirdperson", "UiBold", uiBackground, uiForeground)
    draw.WordBox(2, 10, scrHalfH + 40, "Jump: Stop spectating", "UiBold", uiBackground, uiForeground)
    draw.WordBox(2, 10, scrHalfH + 60, "Reload: Stop spectating and teleport", "UiBold", uiBackground, uiForeground)
    draw.WordBox(2, 10, scrHalfH + 80, "Opening FAdmin's menu while spectating a player", "UiBold", uiBackground, uiForeground)
    draw.WordBox(2, 10, scrHalfH + 100, "\twill open their page!", "UiBold", uiBackground, uiForeground)


    local target = findNearestPlayer()
    local pls = player.GetAll()
    for i = 1, #pls do
        local ply = pls[i]
        if not isRoaming and ply == specEnt then continue end

        local pos = ply:GetShootPos():ToScreen()
        if not pos.visible then continue end

        local x, y = pos.x, pos.y

        draw.RoundedBox(2, x, y - 6, 12, 12, team.GetColor(ply:Team()))
        draw.WordBox(2, x, y - 66, ply:Nick(), "UiBold", uiBackground, uiForeground)
        draw.WordBox(2, x, y - 46, "Health: " .. ply:Health(), "UiBold", uiBackground, uiForeground)
        draw.WordBox(2, x, y - 26, ply:GetUserGroup(), "UiBold", uiBackground, uiForeground)

        if ply == target then
            draw.WordBox(2, x, y - 86, "Left click to spectate!", "UiBold", uiBackground, uiForeground)
        end
    end

    if not isRoaming then return end

    if not IsValid(target) then return end
    local mins, maxs = target:LocalToWorld(target:OBBMins()):ToScreen(), target:LocalToWorld(target:OBBMaxs()):ToScreen()
    draw.RoundedBox(12, mins.x, mins.y, maxs.x - mins.x, maxs.y - mins.y, red)
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
    hook.Add("FAdmin_ShowFAdminMenu", "FAdminSpectate", fadminmenushow)
    hook.Add("RenderScreenspaceEffects", "FAdminSpectate", lookingLines)

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
    hook.Remove("FAdmin_ShowFAdminMenu", "FAdminSpectate")
    hook.Remove("RenderScreenspaceEffects", "FAdminSpectate")

    timer.Remove("FAdminSpectatePosUpdate")

    if IsValid(specEnt) then
        specEnt:SetNoDraw(false)
    end

    RunConsoleCommand("_FAdmin_StopSpectating")
    isSpectating = false
end
