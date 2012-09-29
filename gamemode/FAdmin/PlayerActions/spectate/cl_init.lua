/*---------------------------------------------------------------------------
startHooks
FAdmin tab buttons
---------------------------------------------------------------------------*/
FAdmin.StartHooks["zzSpectate"] = function()
	FAdmin.Access.AddPrivilege("Spectate", 2)
	FAdmin.Commands.AddCommand("Spectate", nil, "<Player>")

	-- Right click option
	FAdmin.ScoreBoard.Main.AddPlayerRightClick("Spectate", function(ply)
		LocalPlayer():ConCommand("FAdmin Spectate "..ply:UserID())
	end)

	-- Slap option in player menu
	FAdmin.ScoreBoard.Player:AddActionButton("Spectate", "FAdmin/icons/spectate", Color(0, 200, 0, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Spectate") and ply ~= LocalPlayer() end, function(ply)
		RunConsoleCommand("_FAdmin", "Spectate", ply:UserID())
	end)
end

local specEnt
local stopSpectating
local thirdperson = false

/*---------------------------------------------------------------------------
specCalcView
Override the view for the player to look through the spectated player's eyes
---------------------------------------------------------------------------*/
local function specCalcView(ply, origin, angles, fov)
	if not IsValid(specEnt) then
		stopSpectating()
		return
	end

	local view = {
		origin = specEnt:GetShootPos(),
		vm_origin = Vector(0,0,-13000),
		angles = specEnt:EyeAngles()
	}

	if thirdperson then
		local aimvector = LocalPlayer():GetAimVector()
		local endpos = view.origin - aimvector * 100

		local tracer = {start = view.origin,
		endpos = endpos,
		filter = specEnt}

		local trace = util.TraceLine(tracer)

		view.origin = trace.HitPos + trace.HitNormal * 10
		view.angles = LocalPlayer():EyeAngles()
	end

	specEnt:SetNoDraw(not thirdperson)
	return view
end

/*---------------------------------------------------------------------------
specBinds
Change binds to perform spectate specific tasks
---------------------------------------------------------------------------*/
local function specBinds(ply, bind, pressed)
	if bind == "+jump" then
		stopSpectating()
		return true
	elseif bind == "+attack" and pressed then
		thirdperson = not thirdperson
		return true
	end
	-- Do not return true otherwise, spectating admins should be able to move to avoid getting detected
end

/*---------------------------------------------------------------------------
specEnt
Spectate a player
---------------------------------------------------------------------------*/
local function spectatePlayer(um)
	specEnt = um:ReadEntity()

	hook.Add("CalcView", "FAdminSpectate", specCalcView)
	hook.Add("PlayerBindPress", "FAdminSpectate", specBinds)
	hook.Add("ShouldDrawLocalPlayer", "FAdminSpectate", function() return true end)
end
usermessage.Hook("FAdminSpectate", spectatePlayer)
/*---------------------------------------------------------------------------
stopSpectating
Stop spectating a player
---------------------------------------------------------------------------*/
stopSpectating = function()
	hook.Remove("CalcView", "FAdminSpectate")
	hook.Remove("PlayerBindPress", "FAdminSpectate")
	hook.Remove("ShouldDrawLocalPlayer", "FAdminSpectate")

	if IsValid(specEnt) then
		specEnt:SetNoDraw(false)
	end

	RunConsoleCommand("_FAdmin_StopSpectating")
end