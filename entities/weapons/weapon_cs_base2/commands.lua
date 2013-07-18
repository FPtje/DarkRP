local function DropWeapon(ply)
	local ent = ply:GetActiveWeapon()
	if not IsValid(ent) then
		DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
		return ""
	end

	local canDrop = hook.Call("CanDropWeapon", GAMEMODE, ply, ent)
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
		if IsValid(ply) and IsValid(ent) and ent:GetModel() then
			ply:DropDRPWeapon(ent)
		end
	end)
	return ""
end
DarkRP.defineChatCommand("drop", DropWeapon)
DarkRP.defineChatCommand("dropweapon", DropWeapon)
DarkRP.defineChatCommand("weapondrop", DropWeapon)
