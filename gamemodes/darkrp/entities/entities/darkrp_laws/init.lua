AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local Laws = {}
local FixedLaws = {}

timer.Simple(0, function()
	Laws = table.Copy(GAMEMODE.Config.DefaultLaws)
	FixedLaws = table.Copy(Laws)
end)

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
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", GAMEMODE.Config.chatCommandPrefix .. "addlaw"))
		return ""
	end

	if not args or args == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return ""
	end

	if string.len(args) < 3 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("law_too_short"))
		return ""
	end

	if #Laws >= 12 then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("laws_full"))
		return ""
	end

	local num = table.insert(Laws, args)

	umsg.Start("DRP_AddLaw")
		umsg.String(args)
	umsg.End()

	hook.Run("addLaw", num, args)

	DarkRP.notify(ply, 0, 2, DarkRP.getPhrase("law_added"))

	return ""
end
DarkRP.defineChatCommand("addlaw", AddLaw)

local function RemoveLaw(ply, args)
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", GAMEMODE.Config.chatCommandPrefix .. "removelaw"))
		return ""
	end

	local i = tonumber(args)

	if not i or not Laws[i] then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
		return ""
	end

	if FixedLaws[i] then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("default_law_change_denied"))
		return ""
	end

	local law = Laws[i]

	table.remove(Laws, i)

	umsg.Start("DRP_RemoveLaw")
		umsg.Short(i)
	umsg.End()

	hook.Run("removeLaw", i, law)

	DarkRP.notify(ply, 0, 2, DarkRP.getPhrase("law_removed"))

	return ""
end
DarkRP.defineChatCommand("removelaw", RemoveLaw)

local numlaws = 0
local function PlaceLaws(ply, args)
	if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("incorrect_job", GAMEMODE.Config.chatCommandPrefix .. "placelaws"))
		return ""
	end

	if numlaws >= GAMEMODE.Config.maxlawboards then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("limit", GAMEMODE.Config.chatCommandPrefix .. "placelaws"))
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
DarkRP.defineChatCommand("placelaws", PlaceLaws)

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

function DarkRP.getLaws()
	return Laws
end
