FAdmin.ScoreBoard.Player.Information = {}
FAdmin.ScoreBoard.Player.ActionButtons = {}

function FAdmin.ScoreBoard.Player.Show(ply)
    ply = ply or FAdmin.ScoreBoard.Player.Player
    FAdmin.ScoreBoard.Player.Player = ply

    if not IsValid(ply) or not IsValid(FAdmin.ScoreBoard.Player.Player) then FAdmin.ScoreBoard.ChangeView("Main") return end

    local ScreenHeight = ScrH()

    FAdmin.ScoreBoard.Player.Controls.AvatarBackground = vgui.Create("AvatarImage")
    FAdmin.ScoreBoard.Player.Controls.AvatarBackground:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 100)
    FAdmin.ScoreBoard.Player.Controls.AvatarBackground:SetSize(184, 184)
    FAdmin.ScoreBoard.Player.Controls.AvatarBackground:SetPlayer(ply, 184)
    FAdmin.ScoreBoard.Player.Controls.AvatarBackground:SetVisible(true)

    FAdmin.ScoreBoard.Player.InfoPanels = FAdmin.ScoreBoard.Player.InfoPanels or {}
    for k, v in pairs(FAdmin.ScoreBoard.Player.InfoPanels) do
        if IsValid(v) then
            v:Remove()
            FAdmin.ScoreBoard.Player.InfoPanels[k] = nil
        end
    end

    if IsValid(FAdmin.ScoreBoard.Player.Controls.InfoPanel1) then
        FAdmin.ScoreBoard.Player.Controls.InfoPanel1:Remove()
    end

    FAdmin.ScoreBoard.Player.Controls.InfoPanel1 = vgui.Create("DListLayout")
    FAdmin.ScoreBoard.Player.Controls.InfoPanel1:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 100 + 184 + 5 --[[ + Avatar size]])
    FAdmin.ScoreBoard.Player.Controls.InfoPanel1:SetSize(184, ScreenHeight * 0.1 + 2)
    FAdmin.ScoreBoard.Player.Controls.InfoPanel1:SetVisible(true)
    FAdmin.ScoreBoard.Player.Controls.InfoPanel1:Clear(true)

    FAdmin.ScoreBoard.Player.Controls.InfoPanel2 = FAdmin.ScoreBoard.Player.Controls.InfoPanel2 or vgui.Create("FAdminPanelList")
    FAdmin.ScoreBoard.Player.Controls.InfoPanel2:SetPos(FAdmin.ScoreBoard.X + 25 + 184 --[[+ Avatar]], FAdmin.ScoreBoard.Y + 100)
    FAdmin.ScoreBoard.Player.Controls.InfoPanel2:SetSize(FAdmin.ScoreBoard.Width - 184 - 30 - 10, 184 + 5 + ScreenHeight * 0.1 + 2)
    FAdmin.ScoreBoard.Player.Controls.InfoPanel2:SetVisible(true)
    FAdmin.ScoreBoard.Player.Controls.InfoPanel2:Clear(true)

    local function AddInfoPanel()
        local pan = FAdmin.ScoreBoard.Player.Controls.InfoPanel2:Add("DListLayout")
        pan:SetSize(1, FAdmin.ScoreBoard.Player.Controls.InfoPanel2:GetTall())

        table.insert(FAdmin.ScoreBoard.Player.InfoPanels, pan)
        return pan
    end

    local SelectedPanel = AddInfoPanel() -- Make first panel to put the first things in

    for k, v in pairs(FAdmin.ScoreBoard.Player.Information) do
        SelectedPanel:Dock(LEFT)
        local Value = v.func(FAdmin.ScoreBoard.Player.Player)
        --if not Value or Value == "" then return --[[ Value = "N/A" ]] end
        if Value and Value ~= "" then

            local Text = vgui.Create("DLabel")
            Text:Dock(LEFT)
            Text:SetFont("TabLarge")
            Text:SetText(v.name .. ": " .. Value)
            Text:SizeToContents()
            Text:SetColor(Color(200,200,200,200))
            Text:SetTooltip("Click to copy " .. v.name .. " to clipboard")
            Text:SetMouseInputEnabled(true)

            function Text:OnMousePressed(mcode)
                self:SetTooltip(v.name .. " copied to clipboard!")
                ChangeTooltip(self)
                SetClipboardText(Value)
                self:SetTooltip("Click to copy " .. v.name .. " to clipboard")
            end

            timer.Create("FAdmin_Scoreboard_text_update_" .. v.name, 1, 0, function()
                if not IsValid(ply) or not IsValid(FAdmin.ScoreBoard.Player.Player) or not IsValid(Text) then
                    timer.Remove("FAdmin_Scoreboard_text_update_" .. v.name)
                    if FAdmin.ScoreBoard.Visible and (not IsValid(ply) or not IsValid(FAdmin.ScoreBoard.Player.Player)) then FAdmin.ScoreBoard.ChangeView("Main") end
                    return
                end
                Value = v.func(FAdmin.ScoreBoard.Player.Player)
                if not Value or Value == "" then Value = "N/A" end
                Text:SetText(v.name .. ": " .. Value)
            end)

            if (#FAdmin.ScoreBoard.Player.Controls.InfoPanel1:GetChildren() * 17 + 17) <= FAdmin.ScoreBoard.Player.Controls.InfoPanel1:GetTall() and not v.NewPanel then
                FAdmin.ScoreBoard.Player.Controls.InfoPanel1:Add(Text)
            else
                if #SelectedPanel:GetChildren() * 17 + 17 >= SelectedPanel:GetTall() or v.NewPanel then
                    SelectedPanel = AddInfoPanel() -- Add new panel if the last one is full
                end
                SelectedPanel:Add(Text)
                if Text:GetWide() > SelectedPanel:GetWide() then
                    SelectedPanel:SetWide(Text:GetWide() + 40)
                end
            end
        end
    end

    local CatColor = team.GetColor(ply:Team())
    if GAMEMODE.Name == "Sandbox" then
        CatColor = Color(100, 150, 245, 255)
        if ply:Team() == TEAM_CONNECTING then
            CatColor = Color(200, 120, 50, 255)
        elseif ply:IsAdmin() then
            CatColor = Color(30, 200, 50, 255)
        end

        if ply:GetFriendStatus() == "friend" then
            CatColor = Color(236, 181, 113, 255)
        end
    end
    CatColor = hook.Run("FAdmin_PlayerRowColour", ply, CatColor) or CatColor

    FAdmin.ScoreBoard.Player.Controls.ButtonCat = FAdmin.ScoreBoard.Player.Controls.ButtonCat or vgui.Create("FAdminPlayerCatagory")
    FAdmin.ScoreBoard.Player.Controls.ButtonCat:SetLabel("  Player options!")
    FAdmin.ScoreBoard.Player.Controls.ButtonCat.CatagoryColor = CatColor
    FAdmin.ScoreBoard.Player.Controls.ButtonCat:SetSize(FAdmin.ScoreBoard.Width - 40, 100)
    FAdmin.ScoreBoard.Player.Controls.ButtonCat:SetPos(FAdmin.ScoreBoard.X + 20, FAdmin.ScoreBoard.Y + 100 + FAdmin.ScoreBoard.Player.Controls.InfoPanel2:GetTall() + 5)
    FAdmin.ScoreBoard.Player.Controls.ButtonCat:SetVisible(true)

    function FAdmin.ScoreBoard.Player.Controls.ButtonCat:Toggle()
    end

    FAdmin.ScoreBoard.Player.Controls.ButtonPanel = FAdmin.ScoreBoard.Player.Controls.ButtonPanel or vgui.Create("FAdminPanelList", FAdmin.ScoreBoard.Player.Controls.ButtonCat)
    FAdmin.ScoreBoard.Player.Controls.ButtonPanel:SetSpacing(5)
    FAdmin.ScoreBoard.Player.Controls.ButtonPanel:EnableHorizontal(true)
    FAdmin.ScoreBoard.Player.Controls.ButtonPanel:EnableVerticalScrollbar(true)
    FAdmin.ScoreBoard.Player.Controls.ButtonPanel:SizeToContents()
    FAdmin.ScoreBoard.Player.Controls.ButtonPanel:SetVisible(true)
    FAdmin.ScoreBoard.Player.Controls.ButtonPanel:SetSize(0, (ScreenHeight - FAdmin.ScoreBoard.Y - 40) - (FAdmin.ScoreBoard.Y + 100 + FAdmin.ScoreBoard.Player.Controls.InfoPanel2:GetTall() + 5))
    FAdmin.ScoreBoard.Player.Controls.ButtonPanel:Clear()
    FAdmin.ScoreBoard.Player.Controls.ButtonPanel:DockMargin(5, 5, 5, 5)

    for _, v in ipairs(FAdmin.ScoreBoard.Player.ActionButtons) do
        if v.Visible == true or (isfunction(v.Visible) and v.Visible(FAdmin.ScoreBoard.Player.Player) == true) then
            local ActionButton = vgui.Create("FAdminActionButton")
            local imageType = TypeID(v.Image)
            if imageType == TYPE_STRING then
                ActionButton:SetImage(v.Image or "icon16/exclamation")
            elseif imageType == TYPE_TABLE then
                ActionButton:SetImage(v.Image[1])
                if v.Image[2] then ActionButton:SetImage2(v.Image[2]) end
            elseif imageType == TYPE_FUNCTION then
                local img1, img2 = v.Image(ply)
                ActionButton:SetImage(img1)
                if img2 then ActionButton:SetImage2(img2) end
            else
                ActionButton:SetImage("icon16/exclamation")
            end
            local name = v.Name
            if isfunction(name) then name = name(FAdmin.ScoreBoard.Player.Player) end
            ActionButton:SetText(DarkRP.deLocalise(name))
            ActionButton:SetBorderColor(v.color)

            function ActionButton:DoClick()
                if not IsValid(FAdmin.ScoreBoard.Player.Player) then return end
                return v.Action(FAdmin.ScoreBoard.Player.Player, self)
            end
            FAdmin.ScoreBoard.Player.Controls.ButtonPanel:AddItem(ActionButton)
            if v.OnButtonCreated then
                v.OnButtonCreated(FAdmin.ScoreBoard.Player.Player, ActionButton)
            end
        end
    end
    FAdmin.ScoreBoard.Player.Controls.ButtonPanel:Dock(TOP)
end

function FAdmin.ScoreBoard.Player:AddInformation(name, func, ForceNewPanel) -- ForeNewPanel is to start a new column
    table.insert(FAdmin.ScoreBoard.Player.Information, {name = name, func = func, NewPanel = ForceNewPanel})
end

function FAdmin.ScoreBoard.Player:AddActionButton(Name, Image, color, Visible, Action, OnButtonCreated)
    table.insert(FAdmin.ScoreBoard.Player.ActionButtons, {Name = Name, Image = Image, color = color, Visible = Visible, Action = Action, OnButtonCreated = OnButtonCreated})
end

FAdmin.ScoreBoard.Player:AddInformation("Name", function(ply) return ply:Nick() end)
FAdmin.ScoreBoard.Player:AddInformation("Kills", function(ply) return ply:Frags() end)
FAdmin.ScoreBoard.Player:AddInformation("Deaths", function(ply) return ply:Deaths() end)
FAdmin.ScoreBoard.Player:AddInformation("Health", function(ply) return ply:Health() end)
FAdmin.ScoreBoard.Player:AddInformation("Ping", function(ply) return ply:Ping() end)
FAdmin.ScoreBoard.Player:AddInformation("SteamID", function(ply) return ply:SteamID() end, true)
