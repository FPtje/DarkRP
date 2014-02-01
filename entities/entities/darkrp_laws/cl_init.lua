include("shared.lua")

local Laws = {}

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

		draw.DrawNonParsedSimpleText(DarkRP.getPhrase("laws_of_the_land"), "TargetID", 279, 5, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)

		local col = Color(255, 255, 255, 255)
		local lastHeight = 0
		for _,v in ipairs(Laws) do
			draw.DrawNonParsedText(v, "TargetID", 5, 35 + lastHeight, col)
			lastHeight = lastHeight + ((fn.ReverseArgs(string.gsub(v, "\n", "")))+1)*21
		end

	cam.End3D2D()
end

local function AddLaw(inLaw)
	local law = DarkRP.textWrap(inLaw, "TargetID", 522)

	Laws[#Laws + 1] = (#Laws + 1).. ". " .. law
end

local function AddLawUM(um)
	local law = um:ReadString()
	timer.Simple(0, fn.Curry(AddLaw, 2)(law))
	hook.Run("addLaw", #Laws + 1, law)
end
usermessage.Hook("DRP_AddLaw", AddLawUM)

local function RemoveLaw(um)
	local i = um:ReadShort()

	hook.Run("removeLaw", i, string.sub(Laws[i], 4))

	while i < #Laws do
		Laws[i] = i .. string.sub(Laws[i+1], (fn.ReverseArgs(string.find(Laws[i+1], "%d%."))))
		i = i + 1
	end
	Laws[i] = nil
end
usermessage.Hook("DRP_RemoveLaw", RemoveLaw)

function DarkRP.getLaws()
	return Laws
end

timer.Simple(0, function()
	fn.Foldl(function(val,v) AddLaw(v) end, nil, GAMEMODE.Config.DefaultLaws)
end)
