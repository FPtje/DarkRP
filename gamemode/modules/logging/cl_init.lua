/*---------------------------------------------------------------------------
Log a message to console
---------------------------------------------------------------------------*/
local function AdminLog()
	local colour = Color(net.ReadUInt(16), net.ReadUInt(16), net.ReadUInt(16))
	local text = net.ReadString() .. "\n"
	MsgC(Color(255,0,0), "[" .. GAMEMODE.Name .. "] ", colour, DarkRP.deLocalise(text))
end
net.Receive("DRPLogMsg", AdminLog)
