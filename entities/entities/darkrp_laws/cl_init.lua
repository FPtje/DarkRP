include("shared.lua")

local Laws = {}
local drawLaws = ""

function ENT:Draw()
	self:DrawModel()

	local DrawPos = self:LocalToWorld(Vector(1, -111, 58))

	local DrawAngles = self:GetAngles()
	DrawAngles:RotateAroundAxis(self:GetAngles():Forward(), 90)
	DrawAngles:RotateAroundAxis(self:GetAngles():Up(), 90)

	cam.Start3D2D(DrawPos, DrawAngles, 0.4)

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, 558, 290)

		draw.RoundedBox(4, 0, 0, 558, 30, Color(0, 0, 70, 200))
		draw.DrawText(DarkRP.getPhrase("laws_of_the_land"), "TargetID", 279, 5, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)

		draw.DrawText(drawLaws, "TargetID", 5, 35, Color(255, 255, 255, 255))

	cam.End3D2D()
end

local function AddLaw(inLaw)
	local law = GAMEMODE:TextWrap(inLaw, "TargetID", 522)

	Laws[#Laws + 1] = (#Laws + 1).. ". " .. law
	drawLaws = table.concat(Laws, "\n")
end

local function AddLawUM(um)
	AddLaw(um:ReadString())
end
usermessage.Hook("DRP_AddLaw", AddLawUM)

local function RemoveLaw(um)
	local i = um:ReadShort()


	while i < #Laws do
		Laws[i] = i .. string.sub(Laws[i+1], (fn.ReverseArgs(string.find(Laws[i+1], "%."))))
		i = i + 1
	end
	Laws[i] = nil

	drawLaws = table.concat(Laws, "\n")
end
usermessage.Hook("DRP_RemoveLaw", RemoveLaw)

timer.Simple(0, function()
	fn.Foldl(function(val,v) AddLaw(v) end, nil, GAMEMODE.Config.DefaultLaws)
end)
