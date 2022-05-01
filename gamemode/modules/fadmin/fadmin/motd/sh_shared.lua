local MOTDPage = CreateConVar("_FAdmin_MOTDPage", "default", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE})

if CLIENT then -- I can't be bothered to make a cl_init when there's a shared file with just one line in it.
    FAdmin.StartHooks["MOTD"] = function()
        FAdmin.ScoreBoard.Server:AddServerAction("Place MOTD", "fadmin/icons/motd", Color(155, 0, 0, 255), function(ply) return ply:IsSuperAdmin() end, function()
            RunConsoleCommand("_FAdmin", "CreateMOTD")
        end)

        FAdmin.ScoreBoard.Server:AddServerSetting("Set MOTD page", "fadmin/icons/motd", Color(0, 0, 155, 255), function(ply) return ply:IsSuperAdmin() end, function()
            local Window = vgui.Create("DFrame")
            Window:SetTitle("Set MOTD page")
            Window:SetDraggable(false)
            Window:ShowCloseButton(false)
            Window:SetBackgroundBlur(true)
            Window:SetDrawOnTop(true)

            local InnerPanel = vgui.Create("DPanel", Window)
            InnerPanel:SetPaintBackground(false) -- clear background

            local Text = vgui.Create("DLabel", InnerPanel)
            Text:SetText("Set the MOTD page. Click default to reset the MOTD to default.")
            Text:SizeToContents()
            Text:SetContentAlignment(5)
            Text:SetTextColor(color_white)

            local TextEntry = vgui.Create("DTextEntry", InnerPanel)
            TextEntry:SetText(MOTDPage:GetString())
            TextEntry.OnEnter = function() Window:Close() RunConsoleCommand("_FAdmin", "motdpage", TextEntry:GetValue()) end
            function TextEntry:OnFocusChanged(changed)
                self:RequestFocus()
                self:SelectAllText(true)
            end

            local ButtonPanel = vgui.Create("DPanel", Window)
            ButtonPanel:SetPaintBackground(false) -- clear background
            ButtonPanel:SetTall(30)

            local Button = vgui.Create("DButton", ButtonPanel)
            Button:SetText("OK")
            Button:SizeToContents()
            Button:SetTall(20)
            Button:SetWide(Button:GetWide() + 20)
            Button:SetPos(5, 5)

            Button.DoClick = function()
                Window:Close()
                RunConsoleCommand("_FAdmin", "motdpage", TextEntry:GetValue())
            end

            local ButtonDefault = vgui.Create("DButton", ButtonPanel)
                ButtonDefault:SetText("Default")
                ButtonDefault:SizeToContents()
                ButtonDefault:SetTall(20)
                ButtonDefault:SetWide(Button:GetWide() + 20)
                ButtonDefault:SetPos(5, 5)
                ButtonDefault.DoClick = function() Window:Close() RunConsoleCommand("_FAdmin", "motdpage", "default") end
                ButtonDefault:MoveRightOf(Button, 5)

            local ButtonCancel = vgui.Create("DButton", ButtonPanel)
                ButtonCancel:SetText("Cancel")
                ButtonCancel:SizeToContents()
                ButtonCancel:SetTall(20)
                ButtonCancel:SetWide(Button:GetWide() + 20)
                ButtonCancel:SetPos(5, 5)
                ButtonCancel.DoClick = function() Window:Close() end
                ButtonCancel:MoveRightOf(ButtonDefault, 5)

            ButtonPanel:SetWide(Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 + ButtonDefault:GetWide() + 5)

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
    end
end
