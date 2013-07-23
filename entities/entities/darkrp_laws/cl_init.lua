
include("shared.lua")

-- These are the default laws, they're unchangeable in-game.
local Laws = {
	"1. Do not attack other citizens except in self-defence.",
	"2. Do not steal or break in to peoples homes.",
	"3. Money printers/drugs are illegal."
}

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
		draw.SimpleText("LAWS OF THE LAND", "TargetID", 279, 5, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)

		local col = Color(255, 255, 255, 255)
		for k,v in ipairs(Laws) do
			draw.SimpleText(v, "TargetID", 5, 35 + (k-1)*21, col)
		end

	cam.End3D2D()
end

local function AddLaw(um)
	local law = um:ReadString()
	law = GAMEMODE:TextWrap(law, "TargetID", 522)

	Laws[#Laws + 1] = (#Laws + 1).. ". " .. law
end
usermessage.Hook("DRP_AddLaw", AddLaw)

local function RemoveLaw(um)
	local i = um:ReadChar()

	while i < #Laws do
		Laws[i] = i .. string.sub(Laws[i+1], (fn.ReverseArgs(string.find(Laws[i+1], "%d%."))))
		i = i + 1
	end
	Laws[i] = nil
end
usermessage.Hook("DRP_RemoveLaw", RemoveLaw)