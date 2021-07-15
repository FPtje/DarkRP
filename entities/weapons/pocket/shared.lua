AddCSLuaFile()

if SERVER then
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
SWEP.IsDarkRPPocket = true

SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"
SWEP.WorldModel = ""

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
    self:SetHoldType("normal")
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

    local Owner = self:GetOwner()
    Owner:DrawViewModel(true)
    Owner:DrawWorldModel(true)

    return true
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.2)

    if not SERVER then return end

    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    local ent = Owner:GetEyeTrace().Entity
    local canPickup, message = hook.Call("canPocket", GAMEMODE, Owner, ent)

    if not canPickup then
        if message then DarkRP.notify(Owner, 1, 4, message) end
        return
    end

    Owner:addPocketItem(ent)
end

function SWEP:SecondaryAttack()
    if not SERVER then return end

    local Owner = self:GetOwner()

    if not IsValid(Owner) then return end

    local maxK = 0

    for k in pairs(Owner:getPocketItems()) do
        if k < maxK then continue end
        maxK = k
    end

    if maxK == 0 then
        DarkRP.notify(Owner, 1, 4, DarkRP.getPhrase("pocket_no_items"))
        return
    end

    if SERVER then
        local canPickup, message = hook.Call("canDropPocketItem", nil, Owner, maxK, Owner.darkRPPocket[maxK])
        if canPickup == false then
            if message then DarkRP.notify(Owner, 1, 4, message) end
            return
        end
    end

    Owner:dropPocketItem(maxK)
end

function SWEP:Reload()
    if CLIENT then
      DarkRP.openPocketMenu()
    end

    if SERVER and game.SinglePlayer() then
        net.Start("DarkRP_PocketMenu")
        net.Send(self:GetOwner())
    end
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
