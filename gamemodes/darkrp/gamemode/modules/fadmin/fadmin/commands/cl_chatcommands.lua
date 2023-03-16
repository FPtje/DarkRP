local Options = {}
local targets
local colorBackground = Color(0, 0, 0, 200)
local colorHighlight = Color(255, 125, 0, 200)
hook.Add("ChatTextChanged", "FAdmin_Chat_autocomplete", function(text)
    if not FAdmin.GlobalSetting.FAdmin then return end
    Options = {}
    local prefix = GetGlobalString("FAdmin_commandprefix")
    prefix = prefix ~= '' and prefix or '/'

    if string.sub(text, 1, 1) ~= prefix then targets = nil return end

    local TExplode = string.Explode(" ", string.sub(text, 2))
    if not TExplode[1] then return end
    local Command = string.lower(TExplode[1])
    local Args = table.Copy(TExplode)
    Args[1] = nil
    Args = table.ClearKeys(Args)


    local optionsCount = 0
    for k, v in pairs(FAdmin.Commands.List) do
        if string.find(string.lower(k), Command, 1, true) ~= 1 then continue end

        Options[prefix .. k] = table.Copy(v.ExtraArgs)

        optionsCount = optionsCount + 1
    end

    local ChatBoxPosX, ChatBoxPosY = chat.GetChatBoxPos()
    local ChatBoxWidth = chat.GetChatBoxSize() -- Don't need height
    local DidMakeShorter = false
    table.sort(Options)
    local i = 1
    for k in pairs(Options) do
        local Pos = ChatBoxPosY + i * 24
        if Pos + 24 > ScrH() then
            Options[k] = nil
            DidMakeShorter = true
            optionsCount = optionsCount - 1
        end
        i = i + 1
    end

    -- Player arguments
    local firstVal = table.GetFirstValue(Options)
    if optionsCount == 1 and firstVal[#Args] and string.match(firstVal[#Args], ".Player.") then
        local players = {}

        for _, v in pairs(FAdmin.FindPlayer(Args[#Args]) or {}) do
            if not IsValid(v) then continue end
            table.insert(players, v:Nick())
        end

        targets = table.concat(players, ", ")
    end

    local xPos = ChatBoxPosX + ChatBoxWidth + 2
    hook.Add("HUDPaint", "FAdmin_Chat_autocomplete", function()
        local j = 0
        for option, args in pairs(Options) do
            draw.WordBox(4, xPos, ChatBoxPosY + j * 24, option, "UiBold", colorBackground, color_white)

            for k, arg in pairs(args) do
                draw.WordBox(4, xPos + k * 130, ChatBoxPosY + j * 24, arg, "UiBold", colorBackground, color_white)
            end

            j = j + 1
        end

        if targets then
            draw.WordBox(4, xPos, ChatBoxPosY + j * 24, "Targets: " .. targets, "UiBold", colorHighlight, color_white)
        end

        if DidMakeShorter then
            draw.WordBox(4, xPos, ChatBoxPosY + j * 24, "...", "UiBold", colorBackground, color_white)
        end
    end)
end)

hook.Add("FinishChat", "FAdmin_Chat_autocomplete", function() hook.Remove("HUDPaint", "FAdmin_Chat_autocomplete") end)

local plyIndex = 1

hook.Add("OnChatTab", "FAdmin_Chat_autocomplete", function(text)
    if not FAdmin.GlobalSetting.FAdmin then return end

    for command in pairs(Options) do
        if string.find(text, " ") == nil then
            return string.sub(command, 1, string.find(command, " "))
        elseif string.find(text, " ") then
            plyIndex = plyIndex + 1

            if plyIndex > player.GetCount() then
                plyIndex = 1
            end

            return string.sub(command, 1, string.find(command, " ")) .. " " .. string.sub(player.GetAll()[plyIndex]:Nick(), 1, string.find(player.GetAll()[plyIndex]:Nick(), " "))
        end
    end
end)

FAdmin.StartHooks["Chatcommands"] = function()
    FAdmin.ScoreBoard.Server:AddServerSetting("Set FAdmin's chat command prefix", "fadmin/icons/message", Color(0, 0, 155, 255), function(ply) return FAdmin.Access.PlayerHasPrivilege(ply, "ServerSetting") end, function()
        local prefix = GetGlobalString("FAdmin_commandprefix")
        prefix = prefix ~= '' and prefix or '/'
        Derma_StringRequest("Set chat command prefix", "Make sure it's only one character!", prefix, fp{RunConsoleCommand, "_Fadmin", "CommandPrefix"})
    end)
end
