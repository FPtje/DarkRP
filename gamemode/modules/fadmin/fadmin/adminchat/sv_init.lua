util.AddNetworkString("FAdmin_ReceiveAdminMessage")
local function ToAdmins(ply, cmd, args)
    if not args[1] then return false end

    local text = table.concat(args, " ")
    local send = {}

    if IsValid(ply) then table.insert(send, ply) end
    for _, v in ipairs(player.GetAll()) do
        if FAdmin.Access.PlayerHasPrivilege(v, "AdminChat") or v:IsAdmin() then
            table.insert(send, v)
        end
    end

    net.Start("FAdmin_ReceiveAdminMessage")
        net.WriteEntity(ply)
        net.WriteString(text)
    net.Send(send)

    return true, text
end

FAdmin.StartHooks["Chatting"] = function()
    FAdmin.Commands.AddCommand("adminhelp", ToAdmins)
    FAdmin.Commands.AddCommand("//", ToAdmins)

    FAdmin.Access.AddPrivilege("AdminChat", 2)
end
