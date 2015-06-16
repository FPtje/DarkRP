TOOL.Category           = "Falco Prop Protection"
TOOL.Name               = "Share props"
TOOL.Command            = nil
TOOL.ConfigName         = ""

function TOOL:RightClick(trace)
	if not IsValid(trace.Entity) or CLIENT then return true end

	local ply = self:GetOwner()

	trace.Entity.SharePhysgun1 = nil
	trace.Entity.ShareGravgun1 = nil
	trace.Entity.SharePlayerUse1 = nil
	trace.Entity.ShareEntityDamage1 = nil
	trace.Entity.ShareToolgun1 = nil

	trace.Entity.AllowedPlayers = nil
	return true
end

function TOOL:LeftClick(trace)
	if not IsValid(trace.Entity) or CLIENT then return true end

	local ply = self:GetOwner()

	local Physgun = trace.Entity.SharePhysgun1 or false
	local GravGun = trace.Entity.ShareGravgun1 or false
	local PlayerUse = trace.Entity.SharePlayerUse1 or false
	local Damage = trace.Entity.ShareEntityDamage1 or false
	local Toolgun = trace.Entity.ShareToolgun1 or false

	-- Test size with netmessages
	net.Start("FPP_ShareSettings")
		net.WriteEntity(trace.Entity)
		net.WriteBool(Physgun)
		net.WriteBool(GravGun)
		net.WriteBool(PlayerUse)
		net.WriteBool(Damage)
		net.WriteBool(Toolgun)
		if trace.Entity.AllowedPlayers then
			net.WriteUInt(#trace.Entity.AllowedPlayers, 32)
			for k,v in pairs(trace.Entity.AllowedPlayers) do
				net.WriteEntity(v)
			end
		end
	net.Send(ply)
	return true
end

if CLIENT then
	language.Add( "Tool.shareprops.name", "Share tool" )
	language.Add( "Tool.shareprops.desc", "Change sharing settings per prop" )
	language.Add( "Tool.shareprops.0", "Left click: shares a prop. Right click unshares a prop")
end