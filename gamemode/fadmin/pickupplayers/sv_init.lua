CreateConVar("FAdmin_AdminsCanPickUpPlayers", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
CreateConVar("FAdmin_PlayersCanPickUpPlayers", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

hook.Add("PhysgunPickup", "FAdmin_PickUpPlayers", function(ply, ent)
	if not IsValid(ent) or not ent:IsPlayer() then return end
	if tobool(GetConVarNumber("FAdmin_PlayersCanPickUpPlayers")) or (tobool(GetConVarNumber("FAdmin_AdminsCanPickUpPlayers")) and FAdmin.Access.PlayerHasPrivilege(ply, "AdminsCanPickUpPlayers", ent)) and not tobool(ply:GetInfo("FPP_PrivateSettings_Players")) then
		ent:SetMoveType(MOVETYPE_NONE)
		ent:Freeze(true)
		return true
	end
end)

hook.Add("PhysgunDrop", "FAdmin_PickUpPlayers", function(ply, ent)
	if IsValid(ent) and ent:IsPlayer() then
		ent:SetMoveType(MOVETYPE_WALK)
		ent:Freeze(false)
	end
end)

local function ChangeAdmin(ply, cmd, args)
	if not ply:IsSuperAdmin() then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[1] then return end

	local Value = tonumber(args[1])
	if Value ~= 1 and Value ~= 0 then return end
	RunConsoleCommand("FAdmin_AdminsCanPickUpPlayers", Value)

	DB.SaveSetting("FAdmin_AdminsCanPickUpPlayers", Value)

	local OnOff = (tobool(Value) and "on") or "off"
	FAdmin.Messages.ActionMessage(ply, player.GetAll(), ply:Nick().." turned Admin>Player pickup "..OnOff, "Admin>Player pickup has been turned "..OnOff, "Turned Admin>Player pickup "..OnOff)
end

local function ChangeUser(ply, cmd, args)
	if not ply:IsSuperAdmin() then FAdmin.Messages.SendMessage(ply, 5, "No access!") return end
	if not args[1] then return end

	local Value = tonumber(args[1])
	if Value ~= 1 and Value ~= 0 then return end
	RunConsoleCommand("FAdmin_PlayersCanPickUpPlayers", Value)

	DB.SaveSetting("FAdmin_PlayersCanPickUpPlayers", Value)

	local OnOff = (tobool(Value) and "on") or "off"
	FAdmin.Messages.ActionMessage(ply, player.GetAll(), ply:Nick().." turned Player>Player pickup "..OnOff, "Player>Player pickup has been turned "..OnOff, "Turned Player>Player pickup "..OnOff)
end

FAdmin.StartHooks["PickUpPlayers"] = function()
	FAdmin.Access.AddPrivilege("PickUpPlayers", 2)
	FAdmin.Commands.AddCommand("AdminsCanPickUpPlayers", ChangeAdmin)
	FAdmin.Commands.AddCommand("PlayersCanPickUpPlayers", ChangeUser)
end
