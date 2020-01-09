--[[---------------------------------------------------------------------------
Log a message to console
---------------------------------------------------------------------------]]
local function AdminLog()
    local colour = Color(net.ReadInt(16),net.ReadInt(16),net.ReadInt(16))
    local text = DarkRP.deLocalise(net.ReadString() .. "\n")

    MsgC(Color(255, 0, 0), "[" .. GAMEMODE.Name .. "] ", colour, text)

    hook.Call("DarkRPLogPrinted", nil, text, colour)
end
net.Receive('DRPLogMsg', AdminLog)

--[[---------------------------------------------------------------------------
Interface
---------------------------------------------------------------------------]]
DarkRP.hookStub{
    name = "DarkRPLogPrinted",
    description = "Called when a log has printed in console.",
    realm = "Client",
    parameters = {
        {
            name = "text",
            description = "The actual log.",
            type = "string"
        },
        {
            name = "colour",
            description = "The colour of the printed log.",
            type = "Color"
        }
    },
    returns = {}
}
