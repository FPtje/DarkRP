--[[
WHEN GETTING KICKED
]]
local KickText = ""
usermessage.Hook("FAdmin_kick_start", function()
    hook.Add("HUDPaint", "FAdmin_kick", function()
        draw.RoundedBox(0,0,0, ScrW(), ScrH(), Color(0,0,0,255))
        draw.DrawNonParsedText("You are getting kicked\nReason: " .. KickText .. "\nLeaving voluntarily is also an option.", "HUDNumber5", ScrW() / 2, ScrH() / 2, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
    end)
end)

usermessage.Hook("FAdmin_kick_cancel", function()
    hook.Remove("HUDPaint", "FAdmin_kick")
    FAdmin.Messages.AddMessage(4, "Kick was canceled by admin")
end)

usermessage.Hook("FAdmin_kick_update", function(um)
    KickText = um:ReadString()
end)

local BanText = "No reason"
local BanTimeText = "permanent"

usermessage.Hook("FAdmin_ban_start", function()
    hook.Add("HUDPaint", "FAdmin_ban", function()
        draw.RoundedBox(0,0,0, ScrW(), ScrH(), Color(0,0,0,255))
        draw.DrawNonParsedText("You are getting banned\nReason: " .. BanText .. "\nTime: " .. " " .. BanTimeText .. "\nLeaving voluntarily or rejoining will not prevent banning.", "HUDNumber5", ScrW() / 2, ScrH() / 2, Color(0, 0, 255, 255), TEXT_ALIGN_CENTER)
    end)
end)

usermessage.Hook("FAdmin_ban_cancel", function()
    hook.Remove("HUDPaint", "FAdmin_ban")
    FAdmin.Messages.AddMessage(4, "Ban was canceled by admin")
end)

usermessage.Hook("FAdmin_ban_update", function(um)
    BanTimeText = FAdmin.PlayerActions.ConvertBanTime(um:ReadLong())
    BanText = um:ReadString()
end)

--[[---------------------------------------------------------------------------
Show the window for banning
---------------------------------------------------------------------------]]
local function showBanWindow(SteamID, NICK, time, reason)
    local BanTime = time or 60
    NICK = NICK or ""
    reason = reason or "No reason"
    local M,H,D,W,Y = BanTime % 60,
        math.floor(BanTime / 60) % 24,
        math.floor(BanTime / 1440) % 7,
        math.floor(BanTime / 10080) % 53,
        math.floor(BanTime / 525948)

    RunConsoleCommand("_FAdmin", "ban", SteamID, "start")

    local Window = vgui.Create("DFrame")
    Window:SetTitle("Ban Details")
    Window:SetDraggable(false)
    Window:ShowCloseButton(false)
    Window:SetBackgroundBlur(true)
    Window:SetDrawOnTop(true)

    local InnerPanel = vgui.Create("DPanel", Window)
    InnerPanel:SetPaintBackground(false)

    local Text = vgui.Create("DLabel", InnerPanel)
        Text:SetText("Ban " .. NICK .. "")
        Text:SizeToContents()
        Text:SetContentAlignment(5)


    local TimePanel = vgui.Create("DPanel", Window)
    TimePanel:SetPaintBackground(false)

    local TextEntry = vgui.Create("DTextEntry", TimePanel)
        function TextEntry:OnTextChanged()
            RunConsoleCommand("_FAdmin", "ban", SteamID, "update", BanTime, self:GetValue())
        end
        TextEntry:SetText(DarkRP.deLocalise(reason))
        TextEntry.OnEnter = function() Window:Close() RunConsoleCommand("_FAdmin", "ban", SteamID, "execute", BanTime, TextEntry:GetValue()) end
        function TextEntry:OnFocusChanged(changed)
            self:RequestFocus()
            self:SelectAllText(true)
        end

    local Minutes = vgui.Create("DNumberWang", TimePanel)
    Minutes:SetMinMax(0, 59)
    Minutes:SetDecimals(0)
    Minutes:SetValue(M)

    local Hours = vgui.Create("DNumberWang", TimePanel)
    Hours:SetMinMax(0, 23)
    Hours:SetValue(H)
    Hours:SetDecimals(0)

    local Days = vgui.Create("DNumberWang", TimePanel)
    Days:SetMinMax(0, 6)
    Days:SetValue(D)
    Days:SetDecimals(0)

    local Weeks = vgui.Create("DNumberWang", TimePanel)
    Weeks:SetMinMax(0, 53)
    Weeks:SetValue(W)
    Weeks:SetDecimals(0)

    local Years = vgui.Create("DNumberWang", TimePanel)
    Years:SetMinMax(0, 3)
    Years:SetValue(Y)
    Years:SetDecimals(0)

    local MinLabel, HourLabel, DayLabel, WeekLabel, YearLabel = vgui.Create("DLabel", TimePanel), vgui.Create("DLabel", TimePanel),
    vgui.Create("DLabel", TimePanel), vgui.Create("DLabel", TimePanel), vgui.Create("DLabel", TimePanel)
    MinLabel:SetText("Minutes:")
    HourLabel:SetText("Hours:")
    DayLabel:SetText("Days:")
    WeekLabel:SetText("Weeks:")
    YearLabel:SetText("Years:")


    MinLabel:SetPos(370, 0)
    HourLabel:SetPos(280, 0)
    DayLabel:SetPos(190, 0)
    WeekLabel:SetPos(100, 0)
    YearLabel:SetPos(10, 0)

    local function update()
        BanTime = M + H * 60 + D * 1440 + W * 10080 + Y * 525948
        RunConsoleCommand("_FAdmin", "ban", SteamID, "update", BanTime, TextEntry:GetValue())
    end

    function Minutes:OnValueChanged(val) if val == M then return end M = val update() end
    function Hours:OnValueChanged(val) if val == H then return end H = val update() end
    function Days:OnValueChanged(val) if val == D then return end D = val update() end
    function Weeks:OnValueChanged(val) if val == W then return end W = val update() end
    function Years:OnValueChanged(val) if val == Y then return end Y = val update() end

    local ButtonPanel = vgui.Create("DPanel", Window)
    ButtonPanel:SetTall(25)
    ButtonPanel:SetPaintBackground(false)

    local Button = vgui.Create("DButton", ButtonPanel)
        Button:SetText("OK")
        Button:SizeToContents()
        Button:SetTall(20)
        Button:SetWide(Button:GetWide() + 20)
        Button:SetPos(5, 3)
        Button.DoClick = function()
            Window:Close()
            M, H, D, W, Y = Minutes:GetValue(), Hours:GetValue(), Days:GetValue(), Weeks:GetValue(), Years:GetValue()
            update()
            RunConsoleCommand("_FAdmin", "ban", SteamID, BanTime, (TextEntry and TextEntry:GetValue()) or "")
        end

    local ButtonCancel = vgui.Create("DButton", ButtonPanel)
        ButtonCancel:SetText("Cancel")
        ButtonCancel:SizeToContents()
        ButtonCancel:SetTall(20)
        ButtonCancel:SetWide(Button:GetWide() + 20)
        ButtonCancel:SetPos(5, 3)
        ButtonCancel.DoClick = function() Window:Close() RunConsoleCommand("_FAdmin", "ban", SteamID, "cancel") end
        ButtonCancel:MoveRightOf(Button, 5)

    ButtonPanel:SetWide(Button:GetWide() + 5 + ButtonCancel:GetWide() + 10)

    Window:SetSize(450, 111 + 75 + 20)
    Window:Center()

    InnerPanel:StretchToParent(5, 25, 5, 125)
    TimePanel:StretchToParent(5, 83, 5, 37)

    Minutes:SetPos(370, 20)
    Hours:SetPos(280, 20)
    Days:SetPos(190, 20)
    Weeks:SetPos(100, 20)
    Years:SetPos(10, 20)

    Text:StretchToParent(5, 5, 5, nil)

    TextEntry:StretchToParent(5, nil, 5, nil)
    TextEntry:AlignBottom(5)

    TextEntry:RequestFocus()

    ButtonPanel:CenterHorizontal()
    ButtonPanel:AlignBottom(7)

    Window:MakePopup()
    Window:DoModal()
end

--[[
ADD BUTTONS ETC. TO MENU
]]
FAdmin.StartHooks["CL_KickBan"] = function()
    FAdmin.Access.AddPrivilege("Kick", 2)
    FAdmin.Access.AddPrivilege("Ban", 2)
    FAdmin.Access.AddPrivilege("UnBan", 2)

    FAdmin.Commands.AddCommand("kick", nil, "<Player>", "[Reason]")
    FAdmin.Commands.AddCommand("ban", nil, "<Player>", "<Time (minutes)>", "[Reason]")
    FAdmin.Commands.AddCommand("unban", "<SteamID>")

    FAdmin.ScoreBoard.Main.AddPlayerRightClick("Quick Kick", function(ply, Panel)
        RunConsoleCommand("_FAdmin", "kick", ply:UserID(), "Quick kick")
        if IsValid(Panel) then Panel:Remove() end
    end)
    FAdmin.ScoreBoard.Main.AddPlayerRightClick("Ban", function(ply, Panel)
        showBanWindow(ply:SteamID(), ply:Nick())
        if IsValid(Panel) then Panel:Remove() end
    end)


    -- Kick button
    FAdmin.ScoreBoard.Player:AddActionButton("Kick", "fadmin/icons/kick", nil, function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Kick", ply) end, function(ply)
        if not IsValid(ply) then return end
        local UserID = ply:UserID()
        local NICK = ply:Nick()

        RunConsoleCommand("FAdmin", "kick", UserID, "start")
        local Window = vgui.Create("DFrame")
        Window:SetTitle("Reason for kicking")
        Window:SetDraggable(false)
        Window:ShowCloseButton(false)
        Window:SetBackgroundBlur(true)
        Window:SetDrawOnTop(true)

        local InnerPanel = vgui.Create("DPanel", Window)
        InnerPanel:SetPaintBackground(false)

        local Text = vgui.Create("DLabel", InnerPanel)
            Text:SetText(NICK .. " knows they are getting kicked\nTake all your time entering the reason, they can't do anything anymore")
            Text:SizeToContents()
            Text:SetContentAlignment(5)
            Text:SetTextColor(color_white)

        local TextEntry = vgui.Create("DTextEntry", InnerPanel)
            function TextEntry:OnTextChanged()
                RunConsoleCommand("_FAdmin", "kick", UserID, "update", self:GetValue())
            end
            TextEntry:SetText("Enter reason here")
            TextEntry.OnEnter = function() Window:Close() RunConsoleCommand("_FAdmin", "kick", UserID, "execute", TextEntry:GetValue()) end
            function TextEntry:OnFocusChanged(changed)
                self:RequestFocus()
                self:SelectAllText(true)
            end



        local ButtonPanel = vgui.Create("DPanel", Window)
        ButtonPanel:SetTall(30)
        ButtonPanel:SetPaintBackground(false)

        local Button = vgui.Create("DButton", ButtonPanel)
            Button:SetText("OK")
            Button:SizeToContents()
            Button:SetTall(20)
            Button:SetWide(Button:GetWide() + 20)
            Button:SetPos(5, 5)
            Button.DoClick = function() Window:Close() RunConsoleCommand("_FAdmin", "kick", UserID, "execute", TextEntry:GetValue()) end

        local ButtonCancel = vgui.Create("DButton", ButtonPanel)
            ButtonCancel:SetText("Cancel")
            ButtonCancel:SizeToContents()
            ButtonCancel:SetTall(20)
            ButtonCancel:SetWide(Button:GetWide() + 20)
            ButtonCancel:SetPos(5, 5)

        ButtonCancel.DoClick = function()
            Window:Close()
            RunConsoleCommand("FAdmin", "kick", UserID, "cancel")
        end

        ButtonCancel:MoveRightOf(Button, 5)
        ButtonPanel:SetWide(Button:GetWide() + 5 + ButtonCancel:GetWide() + 10)
        local w, h = Text:GetSize()
        w = math.max(w, 400)
        Window:SetSize(w + 50, h + 25 + 75 + 10)
        Window:Center()
        InnerPanel:StretchToParent(5, 25, 5, 45)
        Text:StretchToParent(5, 5, 5, 35)
        TextEntry:StretchToParent(5, nil, 5, nil)
        TextEntry:AlignBottom(5)
        TextEntry:RequestFocus()
        ButtonPanel:CenterHorizontal()
        ButtonPanel:AlignBottom(8)

        Window:MakePopup()
        Window:DoModal()
    end)

    -- Ban button
    FAdmin.ScoreBoard.Player:AddActionButton("Ban", "fadmin/icons/ban", nil, function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Ban", ply) end, function(ply)
        local SteamID = ply:SteamID()
        local NICK = ply:Nick()

        if ply:IsBot() then SteamID = "BOT" end
        showBanWindow(SteamID, NICK)
    end)

    FAdmin.ScoreBoard.Server:AddPlayerAction("Unban", function() return "fadmin/icons/ban", "fadmin/icons/disable" end, Color(0, 155, 0, 255), true, function(button)
        local selectedLine

        local Frame = vgui.Create("DFrame")
        Frame:SetSize(740, 600)
        Frame:SetTitle("Unban Details")
        Frame:SetDraggable(true)
        Frame:ShowCloseButton(true)
        Frame:SetBackgroundBlur(true)
        Frame:SetDrawOnTop(true)

        local BanList = vgui.Create("DListView", Frame)
        BanList:StretchToParent(5, 55, 5, 5)
        BanList:AddColumn("SteamID")
        BanList:AddColumn("Name")
        BanList:AddColumn("Time")
        BanList:AddColumn("Reason")
        BanList:AddColumn("Banned by")
        BanList:AddColumn("Banned by SteamID")

        local unban = vgui.Create("DButton", Frame)
        unban:SetText("Unban")
        unban:SetPos(695, 25)
        unban:SetSize(40, 25)

        function unban:DoClick()
            if IsValid(selectedLine) then
                RunConsoleCommand("_FAdmin", "Unban", string.upper(selectedLine:GetValue(1)))
                BanList:RemoveLine(selectedLine:GetID())
            end
        end

        local edit = vgui.Create("DButton", Frame)
        edit:SetText("Edit")
        edit:SetPos(650, 25)
        edit:SetSize(40, 25)
        function edit:DoClick()
            if not selectedLine then return end
            showBanWindow(selectedLine:GetValue(1), selectedLine.name, selectedLine.time > os.time() and (selectedLine.time - os.time()) / 60 or 0, selectedLine.reason)
            Frame:Close()
        end

    local function RetrieveBans(len)
        local banCount = net.ReadUInt(32)

        for i = 1, banCount do
            local steamid = net.ReadString()
            local time = net.ReadUInt(32)
            local name = net.ReadString()
            local reason = net.ReadString()
            local adminname = net.ReadString()
            local adminsteam = net.ReadString()


            local Line = BanList:AddLine(
                    steamid,
                    name or "N/A",
                    (tonumber(time or "") and FAdmin.PlayerActions.ConvertBanTime((tonumber(time) - os.time()) / 60)) or "N/A",
                    reason or "",
                    adminname or "",
                    adminsteam or "")
                Line.name = name
                Line.time = time
                Line.reason = reason

                function Line:OnSelect()
                    selectedLine = self
                end
            end
        end
        net.Receive("FAdmin_retrievebans", RetrieveBans)
        RunConsoleCommand("_FAdmin", "RequestBans")

        Frame:Center()
        Frame:MakePopup()
        Frame:DoModal()
    end)
end
