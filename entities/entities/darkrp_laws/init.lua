AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- These are the default laws, they're unchangeable in-game.
local Laws = {
	"Do not attack other citizens except in self-defence.",
	"Do not steal or break in to peoples homes.",
	"Money printers/drugs are illegal."
}

local FixedLaws = table.Copy(Laws)

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/Billboard.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
		phys:EnableMotion(false)
	end
end

local function AddLaw(ply, args)
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then
		GAMEMODE:Notify(ply, 1, 4, "You must be the mayor to set laws!")
		return ""
	end

	if string.len(args) < 3 then
		GAMEMODE:Notify(ply, 1, 4, "Law too short.")
		return ""
	end

	if #Laws >= 12 then
		GAMEMODE:Notify(ply, 1, 4, "The laws are full.")
		return ""
	end

	table.insert(Laws, args)

	umsg.Start("DRP_AddLaw")
		umsg.String(args)
	umsg.End()

	GAMEMODE:Notify(ply, 0, 2, "Law added.")

	return ""
end
AddChatCommand("/addlaw", AddLaw)

local function RemoveLaw(ply, args)
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then
		GAMEMODE:Notify(ply, 1, 4, "You must be the mayor to remove laws!")
		return ""
	end

	if not tonumber(args) then
		GAMEMODE:Notify(ply, 1, 4, "Invalid arguments.")
		return ""
	end

	if not Laws[ tonumber(args) ] then
		GAMEMODE:Notify(ply, 1, 4, "Invalid law.")
		return ""
	end

	if FixedLaws[ tonumber(args) ] then
		GAMEMODE:Notify(ply, 1, 4, "You are not allowed to change the default laws.")
		return ""
	end

	table.remove(Laws, tonumber(args))

	umsg.Start("DRP_RemoveLaw")
		umsg.Char(tonumber(args))
	umsg.End()

	GAMEMODE:Notify(ply, 0, 2, "Law removed.")

	return ""
end
AddChatCommand("/removelaw", RemoveLaw)

local numlaws = 0
local function PlaceLaws(ply, args)
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then
		GAMEMODE:Notify(ply, 1, 4, "You must be the mayor to place a list of laws.")
		return ""
	end

	if numlaws >= GAMEMODE.Config.maxlawboards then
		GAMEMODE:Notify(ply, 1, 4, "You have reached the max number of laws you can place!")
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	local ent = ents.Create("darkrp_laws")
	ent:SetPos(tr.HitPos + Vector(0, 0, 100))

	local ang = ply:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 180)
	ent:SetAngles(ang)

	ent:CPPISetOwner(ply)
	ent.SID = ply.SID

	ent:Spawn()
	ent:Activate()

	if IsValid(ent) then
		numlaws = numlaws + 1
	end

	ply.lawboards = ply.lawboards or {}
	table.insert(ply.lawboards, ent)

	return ""
end
AddChatCommand("/placelaws", PlaceLaws)

function ENT:OnRemove()
	numlaws = numlaws - 1
end

hook.Add("PlayerInitialSpawn", "SendLaws", function(ply)
	for i, law in pairs(Laws) do
		if FixedLaws[i] then continue end

		umsg.Start("DRP_AddLaw", ply)
			umsg.String(law)
		umsg.End()
	end
end)