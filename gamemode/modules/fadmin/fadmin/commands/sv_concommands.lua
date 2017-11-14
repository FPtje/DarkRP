local function concommand_executed(ply, cmd, args)
    if not args[1] then return end
    local name = string.lower(args[1])

    if not name or not FAdmin.Commands.List[name] then
        FAdmin.Messages.SendMessage(ply, 1, "Command does not exist!")
        return
    end

    local args2 = args
    table.remove(args2, 1)
    for k, v in pairs(args2) do
        if string.sub(v, -1) == "," and args2[k + 1] then
            args2[k] = args2[k] .. args2[k + 1]
            table.remove(args2, k + 1)
        end
    end
    table.ClearKeys(args2)
    local res = {FAdmin.Commands.List[name].callback(ply, name, args2)}
    hook.Call("FAdmin_OnCommandExecuted", nil, ply, name, args2, res)
end

local function AutoComplete(command, ...)
    local autocomplete = {}
    local args = string.Explode(" ", ...)
    table.remove(args, 1) --Remove the first space
    if args[1] == "" then
        for k in pairs(FAdmin.Commands.List) do
            table.insert(autocomplete, command .. " " .. k)
        end
    elseif not args[2] then
        for k in pairs(FAdmin.Commands.List) do
            if string.sub(k, 1, string.len(args[1])) == args[1] then
                table.insert(autocomplete, command .. " " .. k)
            end
        end
    end
    table.sort(autocomplete)
    return autocomplete
end
concommand.Add("_FAdmin", concommand_executed, AutoComplete)
concommand.Add("FAdmin", concommand_executed, AutoComplete)

-- DO NOT EDIT THIS, NO MATTER HOW MUCH YOU'VE EDITED FADMIN IT DOESN'T GIVE YOU ANY RIGHT TO CHANGE CREDITS AND/OR REMOVE THE AUTHOR
FAdmin.Commands.AddCommand("FAdminCredits", function(ply, cmd, args)
    if ply:SteamID() == "STEAM_0:0:8944068" and args[1] then
        local targets = FAdmin.FindPlayer(args[1])
        if not targets or (#targets == 1 and not IsValid(targets[1])) then
            FAdmin.Messages.SendMessage(ply, 1, "Player not found")
            return false
        end
        for _, target in pairs(targets) do
            if IsValid(target) then
                concommand_executed(target, "FAdmin", {"FAdminCredits"})
            end
        end

        FAdmin.Messages.SendMessage(ply, 4, "Credits sent!")
        return true
    end
    FAdmin.Messages.SendMessage(ply, 2, "FAdmin by (FPtje) Falco, STEAM_0:0:8944068")
    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == "STEAM_0:0:8944068" then
            FAdmin.Messages.SendMessage(ply, 4, "(FPtje) Falco is in the server at this moment")
            return true
        end
    end
    FAdmin.Messages.SendMessage(ply, 5, "(FPtje) Falco is NOT in the server at this moment")

    return true
end)
