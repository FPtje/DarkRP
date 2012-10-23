FPP = FPP or {}

surface.CreateFont("TabLarge", {
	size = 17,
	weight = 700,
	antialias = true,
	shadow = false,
	font = "Trebuchet MS"})

local TouchAlpha = 0
local CantTouchOwner = ""
local cantouch = false

-- Can/can not touch sir!
local function CanTouch(um)
	if TouchAlpha > 0 then return end
	CantTouchOwner = um:ReadString()
	cantouch = um:ReadBool()

	TouchAlpha = 255
	timer.Simple(1, function()
		TouchAlpha = 0
	end)
end
usermessage.Hook("FPP_CanTouch", CanTouch)

--Show the owner!
local CanTouchLookingAt, Why, LookingatEntity
FPP.CanTouchEntities = {}
local function RetrieveOwner(um)
	LookingatEntity, CanTouchLookingAt, Why = um:ReadEntity(), um:ReadBool(), um:ReadString()
	FPP.CanTouchEntities[LookingatEntity] = CanTouchLookingAt
end
usermessage.Hook("FPP_Owner", RetrieveOwner)

hook.Add("CanTool", "FPP_CL_CanTool", function(ply, trace, tool) -- Prevent client from SEEING his toolgun shoot while it doesn't shoot serverside.
	if IsValid(trace.Entity) and FPP.CanTouchEntities[trace.Entity] == false then
		return false
	end

	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().GetToolObject and ply:GetActiveWeapon():GetToolObject() and
	(string.find(ply:GetActiveWeapon():GetToolObject():GetClientInfo( "model" ) or "", "*") or
	string.find(ply:GetActiveWeapon():GetToolObject():GetClientInfo( "material" ) or "", "*") or
	string.find(ply:GetActiveWeapon():GetToolObject():GetClientInfo( "model" ) or "", "\\")
	/*or string.find(ply:GetActiveWeapon():GetToolObject():GetClientInfo( "tool" ), "/")*/) then
		return false
	end
end)

hook.Add("PhysgunPickup", "FPP_CL_PhysgunPickup", function(ply, ent)
	return false
end)--This looks weird, but whenever a client touches an ent he can't touch, without the code it'll look like he picked it up. WITH the code it really looks like he can't
-- besides, when the client CAN pick up a prop, it also looks like he can.


local HUDNote_c = 0
local HUDNote_i = 1
local HUDNotes = {}

--Notify ripped off the Sandbox notify, changed to my likings
function FPP.AddNotify( str, type )
	local tab = {}
	tab.text 	= str
	tab.recv 	= SysTime()
	tab.velx	= 0
	tab.vely	= -5
	surface.SetFont( "TabLarge" )
	local w, h = surface.GetTextSize( str )

	tab.x		= ScrW() / 2 + w*0.5 + (ScrW()/20)
	tab.y		= ScrH()
	tab.a		= 255

	if type then
		tab.type = true
	else
		tab.type = false
	end

	table.insert( HUDNotes, tab )

	HUDNote_c = HUDNote_c + 1
	HUDNote_i = HUDNote_i + 1

	LocalPlayer():EmitSound("npc/turret_floor/click1.wav", 10, 100)
end

usermessage.Hook("FPP_Notify", function(u) FPP.AddNotify(u:ReadString(), u:ReadBool()) end)

local function DrawNotice( self, k, v, i )

	local H = ScrH() / 1024
	local x = v.x - 75 * H
	local y = v.y - 20 * H - 2

	surface.SetFont( "TabLarge" )
	local w, h = surface.GetTextSize( v.text )

	w = w
	h = h + 10

	local col = Color(100, 30, 30, v.a*0.4)
	if v.type then	col = Color(30, 100, 30, v.a*0.4) end
	draw.RoundedBox( 4, x - w - h + 16, y - 8, w + h, h, col )

	// Draw Icon

	surface.SetDrawColor( 255, 255, 255, v.a )

	draw.SimpleText(v.text, "TabLarge", x+1, y+1, Color(0,0,0,v.a*0.8), TEXT_ALIGN_RIGHT)
	draw.SimpleText(v.text, "TabLarge", x-1, y-1, Color(0,0,0,v.a*0.5), TEXT_ALIGN_RIGHT)
	draw.SimpleText(v.text, "TabLarge", x+1, y-1, Color(0,0,0,v.a*0.6), TEXT_ALIGN_RIGHT)
	draw.SimpleText(v.text, "TabLarge", x-1, y+1, Color(0,0,0,v.a*0.6), TEXT_ALIGN_RIGHT)
	draw.SimpleText(v.text, "TabLarge", x, y, Color(255,255,255,v.a), TEXT_ALIGN_RIGHT)

	local ideal_y = ScrH() - (HUDNote_c - i) * h
	local ideal_x = ScrW() / 2 + w*0.5 + (ScrW()/20)

	local timeleft = 6 - (SysTime() - v.recv)

	// Cartoon style about to go thing
	if ( timeleft < 0.8  ) then
		ideal_x = ScrW() / 2 + w*0.5 + 200
	end

	// Gone!
	if ( timeleft < 0.5  ) then

		ideal_y = ScrH() + 50

	end

	local spd = RealFrameTime() * 15

	v.y = v.y + v.vely * spd
	v.x = v.x + v.velx * spd

	local dist = ideal_y - v.y
	v.vely = v.vely + dist * spd * 1
	if (math.abs(dist) < 2 and math.abs(v.vely) < 0.1) then v.vely = 0 end
	local dist = ideal_x - v.x
	v.velx = v.velx + dist * spd * 1
	if math.abs(dist) < 2 and math.abs(v.velx) < 0.1 then v.velx = 0 end

	// Friction.. kind of FPS independant.
	v.velx = v.velx * (0.95 - RealFrameTime() * 8 )
	v.vely = v.vely * (0.95 - RealFrameTime() * 8 )
end

local comingAroundAgain = 0
local function HUDPaint()

	--Show the owner:
	local LAEnt = LocalPlayer():GetEyeTraceNoCursor().Entity
	if CanTouchLookingAt ~= nil and IsValid(LAEnt) and (LAEnt == LookingatEntity or (LookingatEntity == NULL and LAEnt:EntIndex() ~= 0)) then--LookingatEntity is null when you look at a prop you just spawned(haven't spawned on client yet)

		surface.SetFont("Default")
		local w,h = surface.GetTextSize(Why)
		local col = Color(255,0,0,255)
		if CanTouchLookingAt then col = Color(0,255,0,255) end
		if comingAroundAgain < w then
			comingAroundAgain = math.Min(comingAroundAgain + (RealFrameTime()*600), w)
		end

		draw.RoundedBox(4, comingAroundAgain - w, ScrH()/2 - h - 2, w + 10, 20, Color(0, 0, 0, 110))
		draw.DrawText(Why, "Default", 5 - w + comingAroundAgain, ScrH()/2 - h, col, 0)
		surface.SetDrawColor(255,255,255,255)
	elseif CanTouchLookingAt ~= nil then
		if comingAroundAgain > 0 then
			comingAroundAgain = math.Max(comingAroundAgain - (RealFrameTime()*600), 0)
			surface.SetFont("Default")
			local w,h = surface.GetTextSize(Why)
			local col = CanTouchLookingAt and Color(0,255,0,255) or Color(255,0,0,255)

			draw.RoundedBox(4, comingAroundAgain - w, ScrH()/2 - h - 2, w + 10, 20, Color(0, 0, 0, 110))
			draw.DrawText(Why, "Default", 5 - w + comingAroundAgain, ScrH()/2 - h, col, 0)
			surface.SetDrawColor(255,255,255,255)
		else
			comingAroundAgain = 0
			CanTouchLookingAt, Why, LookingatEntity = nil, nil, nil
		end
	end
	-- Messsage when you can't touch something
	if TouchAlpha > 0 and CantTouchOwner and CantTouchOwner ~= "" then
		surface.SetDrawColor(255,255,255,TouchAlpha)

		surface.SetFont("Default")
		local w,h = surface.GetTextSize(CantTouchOwner)
		local col = cantouch and Color(0,255,0,255) or Color(255,0,0,255)

		draw.WordBox(4, ScrW()/2 - 0.51*w, ScrH()/2 + h, CantTouchOwner, "Default", Color(0, 0, 0, 110), col)
	end

	if not HUDNotes then return end
	local i = 0
	for k, v in pairs( HUDNotes ) do
		if v ~= 0 then
			i = i + 1
			DrawNotice( self, k, v, i)
		end
	end

	for k, v in pairs(HUDNotes) do
		if v ~= 0 and v.recv + 6 < SysTime() then
			HUDNotes[ k ] = 0
			HUDNote_c = HUDNote_c - 1
			if (HUDNote_c == 0) then HUDNotes = {} end
		end
	end
end
hook.Add("HUDPaint", "FPP_HUDPaint", HUDPaint)