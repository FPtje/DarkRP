local HELP_CATEGORY_ADMINTOGGLE = 5
local HELP_CATEGORY_ADMINCMD = 6

GM.ValueCmds = {}
function GM:AddValueCommand(cmd, cfgvar, default)
	self.ValueCmds[cmd] = {var = cfgvar, default = default}
	CreateConVar(cfgvar, default, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
	if SERVER then
		concommand.Add(cmd, function(p, c, a) GAMEMODE:ccValueCommand(p, c, a) end)
	end
end

GM.ToggleCmds = {}
function GM:AddToggleCommand(cmd, cfgvar, default, superadmin)
	self.ToggleCmds[cmd] = {var = cfgvar, superadmin = superadmin, default = default}
	CreateConVar(cfgvar, default, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
	if SERVER then
		concommand.Add(cmd, function(p, c, a) GAMEMODE:ccToggleCommand(p, c, a) end)
	end
end
CreateConVar("DarkRP_LockDown", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}) -- Don't save this one!

concommand.Add("rp_commands", function()
	for k, v in SortedPairs(GAMEMODE.ToggleCmds) do
		print(k)
	end
	for k,v in SortedPairs(GAMEMODE.ValueCmds) do
		print(k)
	end
end)

if SERVER then
	concommand.Add("rp_ResetAllSettings", function(ply, cmd, args)
		if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
			GAMEMODE:Notify(ply, 1, 5, string.format(LANGUAGE.need_sadmin, "rp_resetallsettings"))
			return
		end
		DB.Query("DELETE FROM darkrp_cvar;")
		GAMEMODE:Notify(ply, 0, 4, LANGUAGE.reset_settings)
		local count = 0
		for k,v in pairs(GAMEMODE.ToggleCmds) do
			count = count + 1
			timer.Simple(count * 0.1, function() RunConsoleCommand(v.var, v.default) end)
		end

		for k,v in pairs(GAMEMODE.ValueCmds) do
			count = count + 1
			timer.Simple(count * 0.1, function() RunConsoleCommand(v.var, v.default) end)
		end
	end)
end

-----------------------------------------------------------
-- TOGGLE COMMANDS --
-----------------------------------------------------------
-- Usage of GM:AddToggleCommand
-- (Command name,  Cfg variable name, Default value, Superadmin only)
local DefaultWeapons = {"weapon_physcannon", "weapon_physgun","weapon_crowbar","weapon_stunstick","weapon_pistol","weapon_357","weapon_smg1","weapon_shotgun","weapon_crossbow","weapon_ar2","weapon_bugbait", "weapon_rpg", "gmod_camera", "gmod_tool"}
local Allowedweps = {"weapon_physcannon", "weapon_physgun", "weapon_bugbait", "gmod_tool", "gmod_camera"}
for k,v in pairs(DefaultWeapons) do
	local allowed = 0
	if table.HasValue(Allowedweps, v) then allowed = 1 end
	GM:AddToggleCommand("rp_licenseweapon_"..v, "licenseweapon_"..v, allowed, true)
end
Allowedweps = {"lockpick", "door_ram", "med_kit", "arrest_stick", "unarrest_stick", "keys", "laserpointer", "remotecontroller", "weaponchecker"}
timer.Simple(1, function()
	for k,v in pairs(weapons.GetList()) do
		local allowed = 0
		if table.HasValue(Allowedweps, v.ClassName) then allowed = 1 end
		GAMEMODE:AddToggleCommand("rp_licenseweapon_"..string.lower(v.ClassName), "licenseweapon_"..string.lower(v.ClassName), allowed, true)
	end
end)


GM:AddToggleCommand("rp_3dvoice", "3dvoice", 1)
GM:AddToggleCommand("rp_adminnpcs", "adminnpcs", 1)
GM:AddToggleCommand("rp_adminsents", "adminsents", 1)
GM:AddToggleCommand("rp_AdminsSpawnWithCopWeapons", "AdminsCopWeapons", 1, true)
GM:AddValueCommand("rp_adminweapons", "adminweapons", 1)
GM:AddToggleCommand("rp_adminvehicles", "adminvehicles", 1)
GM:AddToggleCommand("rp_advertisements", "advertisements", 1)
GM:AddToggleCommand("rp_allowrpnames", "allowrpnames", 1)
GM:AddToggleCommand("rp_allowswitchjob", "allowjobswitch", 1)
GM:AddToggleCommand("rp_allowvehiclenocollide", "allowvnocollide", 0)
GM:AddToggleCommand("rp_allowvehicleowning", "allowvehicleowning", 1)
GM:AddToggleCommand("rp_alltalk", "alltalk", 1)
GM:AddToggleCommand("rp_autovehiclelock", "autovehiclelock", 0)
GM:AddToggleCommand("rp_babygod", "babygod", 5)
GM:AddToggleCommand("rp_chiefjailpos", "chiefjailpos", 1)
GM:AddToggleCommand("rp_citpropertytax", "cit_propertytax", 0)
GM:AddToggleCommand("rp_copscanunfreeze", "copscanunfreeze", 1)
GM:AddToggleCommand("rp_copscanunweld", "copscanunweld", 0)
GM:AddToggleCommand("rp_cpcanarrestcp", "cpcanarrestcp", 1)
GM:AddToggleCommand("rp_customjobs", "customjobs", 1)
GM:AddToggleCommand("rp_customspawns", "customspawns", 1)
GM:AddToggleCommand("rp_deathblack", "deathblack", 0)
GM:AddToggleCommand("rp_deathpov", "deathpov", 1)
GM:AddToggleCommand("rp_decalcleaner", "decalcleaner", 0)
GM:AddToggleCommand("rp_dm_autokick", "dmautokick", 1)
GM:AddToggleCommand("rp_doorwarrants", "doorwarrants", 1)
GM:AddToggleCommand("rp_dropmoneyondeath", "dropmoneyondeath", 0)
GM:AddToggleCommand("rp_droppocketonarrest", "droppocketarrest", 0)
GM:AddToggleCommand("rp_droppocketondeath", "droppocketdeath", 1)
GM:AddToggleCommand("rp_dropweaponondeath", "dropweapondeath", 0)
GM:AddToggleCommand("rp_earthquakes", "earthquakes", 0)
GM:AddToggleCommand("rp_enablebuyhealth", "enablebuyhealth", 1)
GM:AddToggleCommand("rp_enablebuypistol", "enablebuypistol", 1)
GM:AddToggleCommand("rp_enablemayorsetsalary", "enablemayorsetsalary", 1)
GM:AddToggleCommand("rp_enableshipments", "enableshipments", 1)
GM:AddToggleCommand("rp_enforcemodels", "enforceplayermodel", 1)
GM:AddToggleCommand("rp_globaltags", "globalshow", 0)
GM:AddToggleCommand("rp_hobownership", "hobownership", 1)
GM:AddToggleCommand("rp_ironshoot", "ironshoot", 1)
GM:AddToggleCommand("rp_letters", "letters", 1)
GM:AddToggleCommand("rp_license", "license", 0)
GM:AddToggleCommand("rp_logging", "logging", 1, true)
GM:AddToggleCommand("rp_lottery", "lottery", 1)
GM:AddToggleCommand("rp_needwantedforarrest", "needwantedforarrest", 0)
GM:AddToggleCommand("rp_noguns", "noguns", 0)
GM:AddToggleCommand("rp_norespawn", "norespawn", 1)
GM:AddToggleCommand("rp_npcarrest", "npcarrest", 1)
GM:AddToggleCommand("rp_ooc", "ooc", 1)
GM:AddToggleCommand("rp_pocket", "pocket", 1)
GM:AddToggleCommand("rp_propertytax", "propertytax", 0)
GM:AddToggleCommand("rp_proplympics", "proplympics", 1)
GM:AddToggleCommand("rp_proppaying", "proppaying", 0)
GM:AddToggleCommand("rp_propspawning", "propspawning", 1)
GM:AddToggleCommand("rp_removeclassitems",  "removeclassitems", 1)
GM:AddToggleCommand("rp_respawninjail", "respawninjail", 1)
GM:AddToggleCommand("rp_restrictallteams", "restrictallteams", 0)
GM:AddToggleCommand("rp_restrictbuypistol", "restrictbuypistol", 0)
GM:AddToggleCommand("rp_restrictdrop", "restrictdrop", 0)
GM:AddToggleCommand("rp_showcrosshairs", "xhair", 1)
GM:AddToggleCommand("rp_showdeaths", "deathnotice", 1)
GM:AddToggleCommand("rp_showjob", "jobtag", 1)
GM:AddToggleCommand("rp_showname", "nametag", 1)
GM:AddToggleCommand("rp_strictsuicide", "strictsuicide", 0)
GM:AddToggleCommand("rp_tax", "wallettax", 0)
GM:AddToggleCommand("rp_telefromjail", "telefromjail", 1)
GM:AddToggleCommand("rp_teletojail", "teletojail", 1)
GM:AddToggleCommand("rp_toolgun", "toolgun", 1)
GM:AddToggleCommand("rp_unlockdoorsonstart", "unlockdoorsonstart", 0)
GM:AddToggleCommand("rp_voiceradius", "voiceradius", 0)
GM:AddToggleCommand("rp_voiceradius_dynamic", "dynamicvoice", 1)
GM:AddToggleCommand("rp_wantedsuicide", "wantedsuicide", 0)
GM:AddToggleCommand("rp_allowsprays", "allowsprays", 1)

-----------------------------------------------------------
-- VALUE COMMANDS --
-----------------------------------------------------------

GM:AddValueCommand("rp_arrestspeed", "aspd", 120)
GM:AddValueCommand("rp_babygodtime", "babygodtime", 5)
GM:AddValueCommand("rp_deathfee", "deathfee", 30)
GM:AddValueCommand("rp_decaltimer", "decaltimer", 120)
GM:AddValueCommand("rp_demotetime", "demotetime", 120)
GM:AddValueCommand("rp_dm_gracetime", "dmgracetime", 30)
GM:AddValueCommand("rp_dm_maxkills", "dmmaxkills", 3)
GM:AddValueCommand("rp_doorcost", "doorcost", 30)
GM:AddValueCommand("rp_EntityRemoveDelay", "entremovedelay", 0)
GM:AddValueCommand("rp_healthcost", "healthcost", 60)
GM:AddValueCommand("rp_jailtimer", "jailtimer", 120)
GM:AddValueCommand("rp_maxcopsalary", "maxcopsalary", 100)
GM:AddValueCommand("rp_maxdoors", "maxdoors", 20)
GM:AddValueCommand("rp_maxdrugs", "maxdrugs", 2)
GM:AddValueCommand("rp_maxfoods", "maxfoods", 2)
GM:AddValueCommand("rp_maxlawboards", "maxlawboards", 2)
GM:AddValueCommand("rp_maxletters", "maxletters", 10)
GM:AddValueCommand("rp_maxmayorsetsalary", "maxmayorsetsalary", 120)
GM:AddValueCommand("rp_maxnormalsalary", "maxnormalsalary", 90)
GM:AddValueCommand("rp_maxvehicles", "maxvehicles", 5)
GM:AddValueCommand("rp_microwavefoodcost", "microwavefoodcost", 30)
GM:AddValueCommand("rp_normalsalary", "normalsalary", 45)
GM:AddValueCommand("rp_npckillpay", "npckillpay", 10)
GM:AddValueCommand("rp_paydelay", "paydelay", 160)
GM:AddValueCommand("rp_pocketitems", "pocketitems", 10)
GM:AddValueCommand("rp_pricecap", "pricecap", 500)
GM:AddValueCommand("rp_pricemin", "pricemin", 50)
GM:AddValueCommand("rp_printamount", "mprintamount", 250)
GM:AddValueCommand("rp_propcost", "propcost", 10)
GM:AddValueCommand("rp_quakechance_1_in", "quakechance", 4000)
GM:AddValueCommand("rp_respawntime", "respawntime", 3)
GM:AddValueCommand("rp_runspeed", "rspd", 240)
GM:AddValueCommand("rp_searchtime", "searchtime", 30)
GM:AddValueCommand("rp_ShipmentSpawnTime", "ShipmentSpamTime", 3)
GM:AddValueCommand("rp_shipmenttime", "shipmentspawntime", 10)
GM:AddValueCommand("rp_startinghealth", "startinghealth", 100)
GM:AddValueCommand("rp_startingmoney", "startingmoney", 500)
GM:AddValueCommand("rp_taxmax", "wallettaxmax", 5)
GM:AddValueCommand("rp_taxmin", "wallettaxmin", 1)
GM:AddValueCommand("rp_taxtime", "wallettaxtime", 600)
GM:AddValueCommand("rp_vehiclecost", "vehiclecost", 40)
GM:AddValueCommand("rp_walkspeed", "wspd", 160)
GM:AddValueCommand("rp_wantedtime", "wantedtime", 120)
GM:AddValueCommand("rp_minlotterycost", "minlotterycommitcost", 30)
GM:AddValueCommand("rp_maxlotterycost", "maxlotterycommitcost", 250)

function GM:AddEntityCommands(name, command, max, price)
	local cmdname = string.gsub(command, " ", "_")

	GM:AddToggleCommand("rp_disable"..cmdname, "disable"..cmdname, 0)
	GM:AddValueCommand("rp_"..cmdname.."_price", cmdname.."_price", price or 30)

	if CLIENT then
		GM:AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_disable"..cmdname.." - disable that people can buy the "..name..".")
		GM:AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_"..cmdname.."_price <Number> - Sets the price of ".. name .. ".")
	end
end

function GM:AddTeamCommands(CTeam, max)
	local k = 0
	for num,v in pairs(RPExtraTeams) do
		if v.command == CTeam.command then
			k = num
		end
	end
	self:AddToggleCommand("rp_allow"..CTeam.command, "allow"..CTeam.command, 1, true)

	if CLIENT then
		self:AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_"..CTeam.command.. " [Nick|SteamID|UserID] - Make a player become a "..CTeam.name..".")
		self:AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allow"..CTeam.command.." - Enable/disable "..CTeam.name)
		return
	end

	if CTeam.Vote then
		AddChatCommand("/vote"..CTeam.command, function(ply)
			if GetConVarNumber("allow"..CTeam.command) and GetConVarNumber("allow"..CTeam.command) ~= 1 then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, CTeam.name, ""))
				return ""
			end
			if type(CTeam.NeedToChangeFrom) == "number" and ply:Team() ~= CTeam.NeedToChangeFrom then
				GAMEMODE:Notify(ply, 1,4, string.format(LANGUAGE.need_to_be_before, team.GetName(CTeam.NeedToChangeFrom), CTeam.name))
				return ""
			elseif type(CTeam.NeedToChangeFrom) == "table" and not table.HasValue(CTeam.NeedToChangeFrom, ply:Team()) then
				local teamnames = ""
				for a,b in pairs(CTeam.NeedToChangeFrom) do teamnames = teamnames.." or "..team.GetName(b) end
				GAMEMODE:Notify(ply, 1,4, string.format(LANGUAGE.need_to_be_before, string.sub(teamnames, 5), CTeam.name))
				return ""
			end
			if #player.GetAll() == 1 then
				GAMEMODE:Notify(ply, 0, 4, LANGUAGE.vote_alone)
				ply:ChangeTeam(k)
				return ""
			end
			if not ply:ChangeAllowed(k) then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.unable, "/vote"..CTeam.command, "banned/demoted"))
				return ""
			end
			if CurTime() - ply:GetTable().LastVoteCop < 80 then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.have_to_wait, math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)), CTeam.command))
				return ""
			end
			if ply:Team() == k then
				GAMEMODE:Notify(ply, 1, 4,  string.format(LANGUAGE.unable, CTeam.command, ""))
				return ""
			end
			local max = CTeam.max
			if max ~= 0 and ((max % 1 == 0 and team.NumPlayers(k) >= max) or (max % 1 ~= 0 and (team.NumPlayers(k) + 1) / #player.GetAll() > max)) then
				GAMEMODE:Notify(ply, 1, 4,  string.format(LANGUAGE.team_limit_reached,CTeam.name))
				return ""
			end
			GAMEMODE.vote:Create(string.format(LANGUAGE.wants_to_be, ply:Nick(), CTeam.name), ply:EntIndex() .. "votecop", ply, 20, function(choice, ply)
				if choice == 1 then
					ply:ChangeTeam(k)
				else
					GAMEMODE:NotifyAll(1, 4, string.format(LANGUAGE.has_not_been_made_team, ply:Nick(), CTeam.name))
				end
			end)
			ply:GetTable().LastVoteCop = CurTime()
			return ""
		end)
		AddChatCommand("/"..CTeam.command, function(ply)
			if GetConVarNumber("allow"..CTeam.command) ~= 1 then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, CTeam.name, ""))
				return ""
			end

			if ply:HasPriv("rp_"..CTeam.command) then
				ply:ChangeTeam(k, true)
				return ""
			end

			local a = CTeam.admin
			if a > 0 and not ply:IsAdmin()
			or a > 1 and not ply:IsSuperAdmin()
			then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, CTeam.name))
				return ""
			end

			if a == 0 and not ply:IsAdmin()
			or a == 1 and not ply:IsSuperAdmin()
			or a == 2
			then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_to_make_vote, CTeam.name))
				return ""
			end

			ply:ChangeTeam(k, true)
			return ""
		end)
	else
		AddChatCommand("/"..CTeam.command, function(ply)
			if GetConVarNumber("allow"..CTeam.command) ~= 1 then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.disabled, CTeam.name, ""))
				return ""
			end
			if CTeam.admin == 1 and not ply:IsAdmin() then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_admin, "/"..CTeam.command))
				return ""
			end
			if CTeam.admin > 1 and not ply:IsSuperAdmin() then
				GAMEMODE:Notify(ply, 1, 4, string.format(LANGUAGE.need_sadmin, "/"..CTeam.command))
				return ""
			end
			ply:ChangeTeam(k)
			return ""
		end)
	end

	concommand.Add("rp_"..CTeam.command, function(ply, cmd, args)
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			ply:PrintMessage(2, string.format(LANGUAGE.need_admin, cmd))
			return
        end

		if CTeam.admin > 1 and not ply:IsSuperAdmin() then
			ply:PrintMessage(2, string.format(LANGUAGE.need_sadmin, cmd))
			return
		end

		if CTeam.Vote then
			if CTeam.admin >= 1 and ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
				ply:PrintMessage(2, string.format(LANGUAGE.need_admin, cmd))
				return
			elseif CTeam.admin > 1 and ply:IsSuperAdmin() and ply:EntIndex() ~= 0 then
				ply:PrintMessage(2, string.format(LANGUAGE.need_to_make_vote, CTeam.name))
				return
			end
		end

		if not args[1] then return end
		local target = GAMEMODE:FindPlayer(args[1])

        if (target) then
			target:ChangeTeam(k, true)
			if (ply:EntIndex() ~= 0) then
				nick = ply:Nick()
			else
				nick = "Console"
			end
			target:PrintMessage(2, nick .. " has made you a " .. CTeam.name .. "!")
        else
			if (ply:EntIndex() == 0) then
				print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
			else
				ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
			end
			return
        end
	end)
end