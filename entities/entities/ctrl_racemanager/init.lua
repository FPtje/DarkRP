AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

--[[
public attributes
]]
ENT.Player = NULL
ENT.PlayerHasTool = false
ENT.CheckPoints = {}
ENT.CurrentCheckPoint = 1
ENT.Participants = {}

--[[
Methods
]]
function ENT:Initialize()
	self.dt.stage = 1 -- setup stage

	self.participants = {}
	self.CheckPoints = {}
	if not ValidEntity(self.Player) then self:Remove() end
	--self.Player:SendLua("Entity(".. self:EntIndex().."):Start()")
	self.PlayerHasTool = self.Player:HasWeapon("gmod_tool")
	self.Player:Give("gmod_tool")
	self.Player:SendLua([[RunConsoleCommand("gmod_tool", "checkpoint_setter")]])
	self.Player:GetWeapon("gmod_tool"):SetNWEntity("Game", self)
	self.Player:GetWeapon("gmod_tool"):SetNWString("nextEntity", "start")

	hook.Add("PlayerDisconnected", "ProplympicsDisconnect" .. self:EntIndex(),
			function(ply) self:OnPlayerDisconnected(ply) end)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetPlayer(ply)
	self.Player = ply
end

function ENT:addCheckpoint(pos, angle)
	self.Player:GetWeapon("gmod_tool"):SetNWString("nextEntity", "checkpoint")
	local checkpoint
	if self.CurrentCheckPoint == 1 then -- First checkpoint, starting point
		checkpoint = ents.Create("ent_start")
	else
		checkpoint = ents.Create("ent_checkpoint")
		checkpoint:setPreviousCheckpoint(self.CheckPoints[self.CurrentCheckPoint - 1])
		self.CheckPoints[self.CurrentCheckPoint - 1]:setNextCheckpoint(checkpoint)
	end

	checkpoint:SetPos(pos)
	checkpoint:SetAngles(angle)
	checkpoint.dt.manager = self

	checkpoint:Spawn()
	checkpoint:Activate()

	self.CheckPoints[self.CurrentCheckPoint] = checkpoint
	self.CurrentCheckPoint = self.CurrentCheckPoint + 1

	return checkpoint
end

function ENT:createFinish(pos, angle)
	if self.CurrentCheckPoint == 1 then return end
	local finish = ents.Create("ent_finish")

	finish:setPreviousCheckpoint(self.CheckPoints[self.CurrentCheckPoint - 1])
	self.CheckPoints[self.CurrentCheckPoint - 1]:setNextCheckpoint(finish)

	finish:SetPos(pos)
	finish:SetAngles(angle)
	finish.dt.manager = self

	finish:Spawn()

	self.CheckPoints[self.CurrentCheckPoint] = finish
	self.CurrentCheckPoint = self.CurrentCheckPoint + 1

	if not self.PlayerHasTool then
		self.Player:StripWeapon("gmod_tool")
	end
	self.Player:ConCommand("gmod_toolmode weld") -- make sure he's not holding the secret tool anymore

	-- Start the idle, waiting for players mode
	self.dt.stage = 2
	for k,v in pairs(player.GetAll()) do -- notify everyone of race
		v:ChatPrint("Get ready for a prop surf race! Apply for free at the starting point of the race! The winner gets $1000 and a sniper!")
	end
end

function ENT:addParticipant(ply)
	if not table.HasValue(self.participants, ply) then
		table.insert(self.participants, ply)
		umsg.Start("raceParticipate", ply)
			umsg.Entity(self)
			umsg.Bool(true)
		umsg.End()
	else
		for k,v in pairs(self.participants) do
			if v == ply then
				self.participants[k] = nil
				umsg.Start("raceParticipate", ply)
					umsg.Entity(self)
					umsg.Bool(false)
				umsg.End()
				break
			end
		end
	end
end

function ENT:getParticipants()
	return table.Copy(self.participants) -- Data hiding, sort of... I wish we had private members.
end

function ENT:startRace()
	if table.Count(self.participants) <= 1 then
		self.Player:ChatPrint("Not enough participants!") -- Just so the mayor doesn't get easy money and guns
		self:Remove()
		return
	end
	self.dt.stage = 3
	self.raceGame = ents.Create("ctrl_racegame")
	self.raceGame:setManager(self)
	self.raceGame:setStart(self.CheckPoints[1])
	self.raceGame:Spawn()
end

function ENT:OnRemove()
	for k,v in pairs(self.CheckPoints) do
		SafeRemoveEntity(v)
	end
	SafeRemoveEntity(self.raceGame)

	hook.Remove("PlayerDisconnected", "ProplympicsDisconnect" .. self:EntIndex())
end

function ENT:OnPlayerDisconnected(ply)
	if ply == self.Player then
		SafeRemoveEntity(self)
	else
		for k,v in pairs(self.participants) do
			if v == ply then
				table.remove(self.participants, k)
				break
			end
		end
	end
end
