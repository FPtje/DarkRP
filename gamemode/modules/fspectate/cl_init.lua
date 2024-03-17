FSpectate = {}

local stopSpectating, startFreeRoam
local isSpectating = false
local specEnt
local thirdperson = true
local isRoaming = false
local roamPos -- the position when roaming free
local roamVelocity = Vector(0)
local thirdPersonDistance = 100

/*---------------------------------------------------------------------------
Retrieve the current spectated player
---------------------------------------------------------------------------*/
function FSpectate.getSpecEnt()
    if isSpectating and not isRoaming then
        return IsValid(specEnt) and specEnt or nil
    else
        return nil
    end
end

/*---------------------------------------------------------------------------
startHooks
FAdmin tab buttons
---------------------------------------------------------------------------*/
hook.Add("Initialize", "FSpectate", function()
    surface.CreateFont("UiBold", {
        size = 16,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Verdana"})

    if not FAdmin then return end
    FAdmin.StartHooks["zzSpectate"] = function()
        FAdmin.Commands.AddCommand("Spectate", nil, "<Player>")

        -- Right click option
        FAdmin.ScoreBoard.Main.AddPlayerRightClick("Spectate", function(ply)
            if not IsValid(ply) then return end
            RunConsoleCommand("FSpectate", ply:UserID())
        end)

        local canSpectate = false
        local function calcAccess()
            CAMI.PlayerHasAccess(LocalPlayer(), "FSpectate", function(b, _)
                canSpectate = b
            end)
        end

        -- Spectate option in player menu
        FAdmin.ScoreBoard.Player:AddActionButton("Spectate", "fadmin/icons/spectate", Color(0, 200, 0, 255), function(ply) calcAccess() return canSpectate and ply ~= LocalPlayer() end, function(ply)
            if not IsValid(ply) then return end
            RunConsoleCommand("FSpectate", ply:UserID())
        end)
    end
end)

/*---------------------------------------------------------------------------
Get the thirdperson position
---------------------------------------------------------------------------*/
local function getThirdPersonPos(ent)
    local aimvector = LocalPlayer():GetAimVector()
    local startPos = ent:IsPlayer() and ent:GetShootPos() or ent:LocalToWorld(ent:OBBCenter())
    local endpos = startPos - aimvector * thirdPersonDistance

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
local view = {}
local function getCalcView()
    if not isRoaming then
        if thirdperson then
            view.origin = getThirdPersonPos(specEnt)
            view.angles = LocalPlayer():EyeAngles()
        else
            view.origin = specEnt:IsPlayer() and specEnt:GetShootPos() or specEnt:LocalToWorld(specEnt:OBBCenter())
            view.angles = specEnt:IsPlayer() and specEnt:EyeAngles() or specEnt:GetAngles()
        end

        roamPos = view.origin
        view.drawviewer = false

        return view
    end

    view.origin = roamPos
    view.angles = LocalPlayer():EyeAngles()
    view.drawviewer = true

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
local function findNearestObject()
    local aimvec = LocalPlayer():GetAimVector()

    local fromPos = not isRoaming and IsValid(specEnt) and specEnt:EyePos() or roamPos

    local lookingAt = util.QuickTrace(fromPos, aimvec * 5000, LocalPlayer())
    local ent = lookingAt.Entity

    if IsValid(ent) then return ent end

    local foundPly, foundDot = nil, 0

    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or ply == LocalPlayer() then continue end

        local pos = ply:GetShootPos()
        local dot = (pos - fromPos):GetNormalized():Dot(aimvec)

        -- Discard players you're not looking at
        if dot < 0.97 then continue end
        -- not a better alternative
        if dot < foundDot then continue end

        local trace = util.QuickTrace(fromPos, pos - fromPos, ply)

        if trace.Hit then continue end

        foundPly, foundDot = ply, dot
    end

    return foundPly
end

/*---------------------------------------------------------------------------
Spectate the person you're looking at while you're roaming
---------------------------------------------------------------------------*/
local function spectateLookingAt()
    local obj = findNearestObject()

    if not IsValid(obj) then return end

    isRoaming = false
    specEnt = obj

    net.Start("FSpectateTarget")
        net.WriteEntity(obj)
    net.SendToServer()
end

/*---------------------------------------------------------------------------
specBinds
Change binds to perform spectate specific tasks
---------------------------------------------------------------------------*/
-- Manual keysDown table, so I can return true in plyBindPress and still detect key presses
local keysDown = {}
local function specBinds(ply, bind, pressed)
    local key = input.LookupBinding(bind)

    if bind == "+jump" then
        stopSpectating()
        return true
    elseif bind == "+reload" and pressed then
        local pos = getCalcView().origin - Vector(0, 0, 64)
        RunConsoleCommand("FTPToPos", string.format("%d, %d, %d", pos.x, pos.y, pos.z),
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
        local keybind = string.upper(string.match(bind, "+([a-z A-Z 0-9]+)") or "")
        if not keybind or keybind == "USE" or keybind == "SHOWSCORES" or string.find(bind, "messagemode") then return end

        keysDown[keybind] = pressed

        return true
    elseif not isRoaming and thirdperson and (key == "MWHEELDOWN" or key == "MWHEELUP") then
        thirdPersonDistance = thirdPersonDistance + 10 * (key == "MWHEELDOWN" and 1 or -1)
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
        if not IsValid(p) then continue end
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

    roamVelocity = (direction or Vector(0, 0, 0)) * roamSpeed

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

    if FAdmin then
        draw.WordBox(2, 10, scrHalfH + 80, "Opening FAdmin's menu while spectating a player", "UiBold", uiBackground, uiForeground)
        draw.WordBox(2, 10, scrHalfH + 100, "\twill open their page!", "UiBold", uiBackground, uiForeground)
    end


    local target = findNearestObject()
    local pls = player.GetAll()
    for i = 1, #pls do
        local ply = pls[i]
        if not IsValid(ply) then continue end
        if not isRoaming and ply == specEnt then continue end

        local pos = ply:GetShootPos():ToScreen()
        if not pos.visible then continue end

        local x, y = pos.x, pos.y

        draw.RoundedBox(2, x, y - 6, 12, 12, team.GetColor(ply:Team()))
        draw.WordBox(2, x, y - 66, ply:Nick(), "UiBold", uiBackground, uiForeground)
        draw.WordBox(2, x, y - 46, "Health: " .. ply:Health(), "UiBold", uiBackground, uiForeground)
        draw.WordBox(2, x, y - 26, ply:GetUserGroup(), "UiBold", uiBackground, uiForeground)
    end

    if not isRoaming then return end

    if not IsValid(target) then return end

    local center = target:LocalToWorld(target:OBBCenter())
    local eyeAng = EyeAngles()
    local rightUp = eyeAng:Right() * 16 + eyeAng:Up() * 36
    local topRight = (center + rightUp):ToScreen()
    local bottomLeft = (center - rightUp):ToScreen()

    draw.RoundedBox(12, bottomLeft.x, bottomLeft.y, math.max(20, topRight.x - bottomLeft.x), topRight.y - bottomLeft.y, red)
    draw.WordBox(2, bottomLeft.x, bottomLeft.y + 12, "Left click to spectate!", "UiBold", uiBackground, uiForeground)
end

/*---------------------------------------------------------------------------
Start roaming free, rather than spectating a given player
---------------------------------------------------------------------------*/
startFreeRoam = function()
    roamPos = isSpectating and roamPos or LocalPlayer():GetShootPos()

    if IsValid(specEnt) then
        if specEnt:IsPlayer() then
            roamPos = thirdperson and getThirdPersonPos(specEnt) or specEnt:GetShootPos()
        end
        specEnt:SetNoDraw(false)
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
    isRoaming = net.ReadBool()
    specEnt = net.ReadEntity()
    specEnt = IsValid(specEnt) and specEnt or nil

    if isRoaming then
        startFreeRoam()
    end

    isSpectating = true
    keysDown = {}

    hook.Add("CalcView", "FSpectate", specCalcView)
    hook.Add("PlayerBindPress", "FSpectate", specBinds)
    hook.Add("ShouldDrawLocalPlayer", "FSpectate", function() return isRoaming or thirdperson end)
    hook.Add("Think", "FSpectate", specThink)
    hook.Add("HUDPaint", "FSpectate", drawHelp)
    hook.Add("FAdmin_ShowFAdminMenu", "FSpectate", fadminmenushow)
    hook.Add("RenderScreenspaceEffects", "FSpectate", lookingLines)

    timer.Create("FSpectatePosUpdate", 0.5, 0, function()
        if not isRoaming then return end

        RunConsoleCommand("_FSpectatePosUpdate", roamPos.x, roamPos.y, roamPos.z)
    end)
end
net.Receive("FSpectate", startSpectate)

/*---------------------------------------------------------------------------
stopSpectating
Stop spectating a player
---------------------------------------------------------------------------*/
stopSpectating = function()
    hook.Remove("CalcView", "FSpectate")
    hook.Remove("PlayerBindPress", "FSpectate")
    hook.Remove("ShouldDrawLocalPlayer", "FSpectate")
    hook.Remove("Think", "FSpectate")
    hook.Remove("HUDPaint", "FSpectate")
    hook.Remove("FAdmin_ShowFAdminMenu", "FSpectate")
    hook.Remove("RenderScreenspaceEffects", "FSpectate")

    timer.Remove("FSpectatePosUpdate")

    if IsValid(specEnt) then
        specEnt:SetNoDraw(false)
    end

    RunConsoleCommand("FSpectate_StopSpectating")
    isSpectating = false
end
