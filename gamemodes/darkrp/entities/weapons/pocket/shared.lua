if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_menu.lua")
	include("sv_init.lua")
end

if CLIENT then
	include("cl_menu.lua")
end

SWEP.PrintName = "Pocket"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to pick up\nRight click to drop\nReload to open the menu"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"
SWEP.WorldModel	= ""

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:Deploy()
	return true
end

function SWEP:DrawWorldModel() end

function SWEP:PreDrawViewModel(vm)
	return true
end

function SWEP:Holster()
	if not SERVER then return true end

	self.Owner:DrawViewModel(true)
	self.Owner:DrawWorldModel(true)

	return true
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)

	if not SERVER then return end

	local ent = self.Owner:GetEyeTrace().Entity
	local canPickup, message = hook.Call("canPocket", nil, self.Owner, ent)

	if not canPickup then
		if message then DarkRP.notify(self.Owner, 1, 4, message) end
		return
	end

	self.Owner:addPocketItem(ent)
end

function SWEP:SecondaryAttack()
	if not SERVER then return end

	local item = #self.Owner:getPocketItems()
	if item <= 0 then
		DarkRP.notify(self.Owner, 1, 4, DarkRP.getPhrase("pocket_no_items"))
		return
	end

	self.Owner:dropPocketItem(item)
end

function SWEP:Reload()
	if not CLIENT then return end

	DarkRP.openPocketMenu()
end

local meta = FindMetaTable("Player")
DarkRP.stub{
	name = "getPocketItems",
	description = "Get a player's pocket items.",
	parameters = {
	},
	returns = {
		{
			name = "items",
			description = "A table containing crucial information about the items in the pocket.",
			type = "table"
		}
	},
	metatable = meta,
	realm = "Shared"
}
