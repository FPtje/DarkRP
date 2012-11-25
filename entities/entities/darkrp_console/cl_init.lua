include("shared.lua")

function ENT:Initialize()
end

function ENT:Draw()
	self:DrawModel()

	if IsValid(self.dt.reporter) and self.dt.reporter.Name and IsValid(self.dt.reported) and self.dt.reported.Name and self:GetNWString("reason") != nil then
		local reporter = self.dt.reporter:Name()
		local reported = self.dt.reported:Name()
		local reason = self:GetNWString("reason")
		local distance = math.Round(self.dt.reporter:GetPos():Distance(self:GetPos()) / 25.4) .. "m" -- In metres sir!

		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Right(), -103)
		ang:RotateAroundAxis(ang:Up(), 90)

		cam.Start3D2D(self:GetPos() + self:GetAngles():Forward() * 16, ang, 0.1)
			draw.RoundedBox(2, -128, -32, 256, 200, Color(0,0,0,255))
			draw.DrawText("CP Console\nReporter: " .. reporter .. "\nReported: " .. reported .. "\nReason: " .. reason .. "\nDistance from console: " .. distance .. "\nPress E to memorise data", "TargetID",
			0, 0, Color(0, 0, 255, 255), TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end

	if self.dt.alarm then
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.Pos = self:GetPos()
			dlight.r = 255
			dlight.g = 0
			dlight.b = 0
			dlight.Brightness = 10
			dlight.Size = 256
			dlight.Decay = 256 * 5
			dlight.DieTime = CurTime() + 1
		end
	end
end

function ENT:Think()
end

local function Memory(um)
	local ent = um:ReadEntity()
	local Memory = um:ReadBool()
	local MemoryTime = um:ReadShort()

	local Reporter, Reported = ent.dt and ent.dt.reporter, ent.dt and ent.dt.reported

	hook.Add("HUDPaint", "darkRP_memory", function()
		if IsValid(Reporter) and IsValid(Reported) then
			local VicPos = ((Reporter.GetShootPos and Reporter:GetShootPos()) or Reporter:GetPos()) + Vector(0,0,10)
			local VillainPos = ((Reported.GetShootPos and Reported:GetShootPos()) or Reported:GetPos()) + Vector(0,0,10)

			local VicX, VicY = VicPos:ToScreen()
			VicX, VicY = VicX.x, VicX.y
			local VillainX, VillainY = VillainPos:ToScreen()
			VillainX, VillainY = VillainX.x, VillainX.y

			draw.SimpleText("Reported person "..math.Round(VillainPos:Distance(LocalPlayer():GetPos()) / 25.4) .. "m", "Trebuchet24", VillainX, VillainY, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
			if Reporter ~= Reported then
				draw.SimpleText("Caller "..math.Round(VicPos:Distance(LocalPlayer():GetPos()) / 25.4) .. "m", "Trebuchet24", VicX, VicY, Color(0, 255, 0, 255), TEXT_ALIGN_CENTER)
			end
		end
	end)

	timer.Simple(MemoryTime, function() hook.Remove("HUDPaint", "darkRP_memory") end)
end
usermessage.Hook("darkrp_memory", Memory)

