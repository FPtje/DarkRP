AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

--[[
Public attributes
]]
ENT.manager = NULL
ENT.surfProps = {}
ENT.startPoint = NULL
ENT.Finishers = {}

--[[
Methods
]]
function ENT:Initialize()
	if table.Count(self.manager:getParticipants()) == 0 then self.manager:Remove() return end
	self.surfProps = {}
	self.Finishers = {}

	for k,v in pairs(self.manager:getParticipants()) do
		local surfProp = ents.Create("ent_surfprop")
		surfProp:setSurfer(v)
		surfProp:setLastCheckpoint(self.startPoint)
		surfProp.raceGame = self
		surfProp:Spawn()
		table.insert(self.surfProps, surfProp)

		self.startPoint:setHasPassed(v, true)
	end

	self:positionSurfers()
	self:CountDown()
end

function ENT:setManager(ctrl_racemanager)
	self.manager = ctrl_racemanager
end

function ENT:setStart(ent_start)
	self.startPoint = ent_start
end

function ENT:HasFinished(ply)
	return table.HasValue(self.Finishers, ply)
end

function ENT:positionSurfers()
	local movement = 100
	local startPos = self.startPoint:GetPos()
	local startAngles = self.startPoint:GetAngles()
	startPos = startPos + startAngles:Right() * 100
	startPos = startPos + startAngles:Up() * 20
	startPos = startPos - startAngles:Forward() * 90

	for k,v in pairs(self.surfProps) do
		local position = startPos
		position = position - startAngles:Right() * (((k-1) % 3) * movement)
		position = position - startAngles:Forward() * (math.floor((k-1) / 9) * movement * 1.5)
		position = position + startAngles:Up() * Vector(0,0,math.floor((k-1) / 3) % 3 * movement)

		v:SpawnPlayer(position, startAngles)
	end
end

function ENT:CountDown()
	for k,v in pairs(self.manager:getParticipants()) do
		v:Freeze(true)
		v:ChatPrint("Race starting in") -- Simple chat print, I can't be bothered to make some notification class
	end

	local count = 5
	timer.Create("CountDown", 1, 6, function()
		for k,v in pairs(self.manager:getParticipants()) do
			if count == 0 then
				v:Freeze(false)
				v:ChatPrint("GO!")
				v:GetNWEntity("SurfProp").StartingTime = CurTime()
				continue
			end
			v:ChatPrint(count)
		end

		if count == 0 then
			timer.Simple(300, function()
				if ValidEntity(self) then
					self:CalculateWinner()-- Some people will never make it to the finish... :)
				end
			end)
		end
		count = count - 1
	end)
end

function ENT:Finish(ply)
	for k,v in pairs(self.surfProps) do
		if not ValidEntity(v.Owner) then
			SafeRemoveEntity(v)
			table.remove(self.surfProps)
		end
	end

	ply:GetNWEntity("SurfProp").EndingTime = CurTime()
	if not table.HasValue(self.Finishers, ply) then
		table.insert(self.Finishers, ply)
		if table.Count(self.Finishers) == table.Count(self.surfProps) then
			self:CalculateWinner()
		end
	end
end

function ENT:CalculateWinner()
	if ValidEntity(self.Finishers[1]) then
		for k,v in pairs(self.manager:getParticipants()) do
			v:ChatPrint("The race has finished! ".. self.Finishers[1]:Nick() .." has won! Congratulations!")
		end
		self:Winner(self.Finishers[1]) -- the one who finished first is the winner :)
	else
		for k,v in pairs(self.manager:getParticipants()) do
			v:ChatPrint("The race has finished! Nobody won...")
		end
	end
	self.manager:Remove()
end

function ENT:Winner(ply) -- You are winner!
	ply:AddMoney(1000)
	ply:Give("ls_sniper")
end

function ENT:OnRemove()
	for k,v in pairs(self.surfProps) do
		SafeRemoveEntity(v)
	end
end