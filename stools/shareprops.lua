TOOL.Category           = "Falco Prop Protection"
TOOL.Name                       = "#share props"
TOOL.Command            = nil
TOOL.ConfigName         = ""

function TOOL:RightClick(trace)
	if not ValidEntity(trace.Entity) or CLIENT then return true end
	
	local ply = self:GetOwner()
	
	trace.Entity.SharePhysgun = nil
	trace.Entity.ShareGravgun = nil
	trace.Entity.SharePlayerUse = nil
	trace.Entity.ShareDamage = nil
	trace.Entity.ShareToolgun = nil
	
	trace.Entity.AllowedPlayers = nil
	return true
end

function TOOL:LeftClick(trace)
	if not ValidEntity(trace.Entity) or CLIENT then return true end
	
	local ply = self:GetOwner()
	
	local Physgun = trace.Entity.SharePhysgun or false
	local GravGun = trace.Entity.ShareGravgun or false
	local PlayerUse = trace.Entity.SharePlayerUse or false
	local Damage = trace.Entity.ShareDamage or false
	local Toolgun = trace.Entity.ShareToolgun or false
	
	-- This big usermessage will be too big if you select 63 players, since that will not happen I can't be arsed to solve it
	umsg.Start("FPP_ShareSettings", ply)
		umsg.Entity(trace.Entity)
		umsg.Bool(Physgun)
		umsg.Bool(GravGun)
		umsg.Bool(PlayerUse)
		umsg.Bool(Damage)
		umsg.Bool(Toolgun)
		if trace.Entity.AllowedPlayers then
			umsg.Long(#trace.Entity.AllowedPlayers)
			for k,v in pairs(trace.Entity.AllowedPlayers) do
				umsg.Entity(v)
			end
		end
	umsg.End()
	return true
end

if CLIENT then
	language.Add( "Tool_shareprops_name", "Share tool" )
	language.Add( "Tool_shareprops_desc", "Change sharing settings per prop" )
	language.Add( "Tool_shareprops_0", "Left click: shares a prop. Right click unshares a prop")
end