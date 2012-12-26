if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "Admin keypad checker"
SWEP.Author = "FPtje"
SWEP.Instructions = "Left click on a keypad or fading door to check it, right click to clear"
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = 0

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.HoldType = "normal"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.IconLetter = ""

if not SERVER then return end

/*
	Gets which entities are controlled by which keyboard keys
*/
local function getTargets(keypad, keyPass, keyDenied, delayPass, delayDenied)
	local targets = {}

	for k,v in pairs(numpad.OnDownItems or {}) do
		if v.key == keyPass and v.ply == keypad.Owner then
			table.insert(targets, {type = "Entering the right password", name = v.name, ent = v.ent, original = keypad})
		end
		if v.key == keyDenied and v.ply == keypad.Owner then
			table.insert(targets, {type = "Entering a wrong password", name = v.name, ent = v.ent, original = keypad})
		end
	end

	for k,v in pairs(numpad.OnUpItems or {}) do
		if v.key == keyPass and v.ply == keypad.Owner then
			table.insert(targets, {type = "after having entered the right password", name = v.name, delay = math.Round(delayPass, 2), ent = v.ent, original = keypad})
		end
		if v.key == keyDenied and v.ply == keypad.Owner then
			table.insert(targets, {type = "after having entered wrong password", name = v.name, delay = math.Round(delayDenied, 2), ent = v.ent, original = keypad})
		end
	end

	return targets
end

/*---------------------------------------------------------------------------
Get the entities that are affected by the keypad
---------------------------------------------------------------------------*/
local function get_sent_keypad_Info(keypad)
	local keyPass = keypad:GetNWInt("keypad_keygroup1")
	local keyDenied = keypad:GetNWInt("keypad_keygroup2")
	local delayPass = keypad:GetNWInt("keypad_length1")
	local delayDenied = keypad:GetNWInt("keypad_length2")

	return getTargets(keypad, keyPass, keyDenied, delayPass, delayDenied)
end

/*---------------------------------------------------------------------------
Overload for a different keypad addon
---------------------------------------------------------------------------*/
local function get_keypad_Info(keypad)
	local keyPass = tonumber(keypad.KeypadData.KeyGranted) or 0
	local keyDenied = tonumber(keypad.KeypadData.KeyDenied) or 0
	local delayPass = tonumber(keypad.KeypadData.LengthGranted) or 0
	local delayDenied = tonumber(keypad.KeypadData.LengthDenied) or 0

	return getTargets(keypad, keyPass, keyDenied, delayPass, delayDenied)
end


/*---------------------------------------------------------------------------
Get the keypads that trigger this entity
---------------------------------------------------------------------------*/
local function getEntityKeypad(ent)
	local targets = {}
	local doorKeys = {} -- The numpad keys that activate this entity

	for k,v in pairs(numpad.OnDownItems or {}) do
		if v.ent == ent then
			table.insert(doorKeys, v.key)
		end
	end

	for k,v in pairs(numpad.OnUpItems or {}) do
		if v.ent == ent then
			table.insert(doorKeys, v.key)
		end
	end

	for k,v in pairs(ents.FindByClass("sent_keypad")) do
		if v.Owner == ent.Owner and table.HasValue(doorKeys, v:GetNWInt("keypad_keygroup1")) then
			table.insert(targets, {type = "Right password entered", ent = v, original = ent})
		end
		if v.Owner == ent.Owner and  table.HasValue(doorKeys, v:GetNWInt("keypad_keygroup2")) then
			table.insert(targets, {type = "Wrong password entered", ent = v, original = ent})
		end
	end

	for k,v in pairs(ents.FindByClass("keypad")) do
		if v.Owner == ent.Owner and table.HasValue(doorKeys, tonumber(v.KeypadData.KeyGranted) or 0) then
			table.insert(targets, {type = "Right password entered", ent = v, original = ent})
		end
		if v.Owner == ent.Owner and  table.HasValue(doorKeys, tonumber(v.KeypadData.KeyDenied) or 0) then
			table.insert(targets, {type = "Wrong password entered", ent = v, original = ent})
		end
	end

	return targets
end

/*---------------------------------------------------------------------------
Send the info to the client
---------------------------------------------------------------------------*/
function SWEP:PrimaryAttack()
	local trace = self.Owner:GetEyeTrace()
	local ent, class = trace.Entity, trace.Entity:GetClass()
	local data

	if class == "sent_keypad" then
		data = get_sent_keypad_Info(ent)
		GAMEMODE:Notify(self.Owner, 1, 4, "This keypad controls "..#data / 2 .. " entities")
	elseif class == "keypad" then
		data = get_keypad_Info(ent)
		GAMEMODE:Notify(self.Owner, 1, 4, "This keypad controls "..#data / 2 .. " entities")
	else
		data = getEntityKeypad(ent)
		GAMEMODE:Notify(self.Owner, 1, 4, "This entity is controlled by "..#data .. " keypads")
	end

	net.Start("DarkRP_keypadData")
		net.WriteTable(data)
	net.Send(self.Owner)
end

function SWEP:SecondaryAttack()
end