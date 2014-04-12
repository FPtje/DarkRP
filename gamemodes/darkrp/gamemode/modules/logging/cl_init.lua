/*---------------------------------------------------------------------------
Log a message to console
---------------------------------------------------------------------------*/
local function AdminLog(um)
	local colour = Color(um:ReadShort(), um:ReadShort(), um:ReadShort())
	local text = um:ReadString() .. "\n"
	MsgC(Color(255,0,0), "[DarkRP] ")
	MsgC(colour, DarkRP.deLocalise(text))
end
usermessage.Hook("DRPLogMsg", AdminLog)
