local function AutoComplete(command, args)
    local autocomplete = {}
    args = string.Explode(" ", args)
    table.remove(args, 1) --Remove the first space
    if args[1] == "" then
        for k in pairs(FAdmin.Commands.List) do
            table.insert(autocomplete, command .. " " .. k)
        end
    elseif not args[2] or args[3] then
        for k, v in pairs(FAdmin.Commands.List) do
            if string.sub(k, 1, string.len(args[1])) == args[1] then
                local ExtraArgs = table.concat(v.ExtraArgs, "    ")
                table.insert(autocomplete, command .. " " .. k .. "        " .. ExtraArgs)
            end
        end
    elseif not args[3] and FAdmin.Commands.List[string.lower(args[1])] and FAdmin.Commands.List[string.lower(args[1])].ExtraArgs[1] == "<Player>" then
        for _, v in ipairs(player.GetAll()) do
            if args[2] == "" or table.HasValue(FAdmin.FindPlayer(args[2]) or {}, v) then
                table.insert(autocomplete, command .. " " .. args[1] .. " " .. v:Nick())
            end
        end
    end
    table.sort(autocomplete)
    return autocomplete
end
concommand.Add("FAdmin", function(ply, cmd, args)
    RunConsoleCommand("_" .. cmd, unpack(args))
end, AutoComplete)
