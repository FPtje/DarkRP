local meta = FindMetaTable("Player")
function meta:dropDRPWeapon(weapon)
	if GAMEMODE.Config.RestrictDrop then
		local found = false
		for k,v in pairs(CustomShipments) do
			if v.entity == weapon:GetClass() then
				found = true
				break
			end
		end

		if not found then return end
	end

	local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())
	self:DropWeapon(weapon) -- Drop it so the model isn't the viewmodel

	local ent = ents.Create("spawned_weapon")
	local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()

	ent.ShareGravgun = true
	ent:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
	ent:SetModel(model)
	ent:SetSkin(weapon:GetSkin())
	ent.weaponclass = weapon:GetClass()
	ent.nodupe = true
	ent.clip1 = weapon:Clip1()
	ent.clip2 = weapon:Clip2()
	ent.ammoadd = ammo

	self:RemoveAmmo(ammo, weapon:GetPrimaryAmmoType())

	ent:Spawn()

	weapon:Remove()
end

local function DropWeapon(ply)
	local ent = ply:GetActiveWeapon()
	if not IsValid(ent) or not ent:GetModel() or ent:GetModel() == "" then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
		return ""
	end

	local canDrop = hook.Call("canDropWeapon", GAMEMODE, ply, ent)
	if not canDrop then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
		return ""
	end

	local RP = RecipientFilter()
	RP:AddAllPlayers()

	umsg.Start("anim_dropitem", RP)
		umsg.Entity(ply)
	umsg.End()
	ply.anim_DroppingItem = true

	timer.Simple(1, function()
		if IsValid(ply) and IsValid(ent) and ent:GetModel() and ent:GetModel() ~= "" then
			ply:dropDRPWeapon(ent)
		end
	end)
	return ""
end
DarkRP.defineChatCommand("drop", DropWeapon)
DarkRP.defineChatCommand("dropweapon", DropWeapon)
DarkRP.defineChatCommand("weapondrop", DropWeapon)

DarkRP.stub{
	name = "dropDRPWeapon",
	description = "Drop the weapon with animations.",
	parameters = {
		{
			name = "weapon",
			description = "The weapon to drop",
			type = "Entity",
			optional = false
		}
	},
	returns = {
	},
	metatable = meta
}
