local function MessageGui(ply)
    if not FAdmin.Messages or not FAdmin.Messages.MsgTypes then return end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Send message")
    frame:SetSize(350, 170)
    frame:Center()
    frame:SetVisible(true)
    frame:MakePopup()

    local MsgType = 2

    local i = 0
    local TypeButtons = {}
    local MsgTypeNames = {ERROR = 1, NOTIFY = 2, QUESTION = 3, GOOD = 4, BAD = 5}
    for k, v in pairs(FAdmin.Messages.MsgTypes) do


        local MsgTypeButton = vgui.Create("DCheckBox", frame)
        MsgTypeButton:SetPos(20 + i * 64, 46)
        if k == "NOTIFY" then MsgTypeButton:SetValue(true) end

        function MsgTypeButton:DoClick()
            for _, B in pairs(TypeButtons) do B:SetValue(false) end

            self:SetValue(true)
            MsgType = MsgTypeNames[k]
        end

        local Icon = vgui.Create("DImageButton", frame)
        Icon:SetImage(v.TEXTURE)
        Icon:SetPos(20 + i * 64 + 16, 30)
        Icon:SetSize(32, 32)
        function Icon:DoClick()
            for _, B in pairs(TypeButtons) do B:SetValue(false) end
            MsgTypeButton:SetValue(true)
            MsgType = MsgTypeNames[k]
        end

        table.insert(TypeButtons, MsgTypeButton)
        i = i + 1
    end

    local OK = vgui.Create("DButton", frame)
    local TextBox = vgui.Create("DTextEntry", frame)
    TextBox:SetPos(20, 100)
    TextBox:StretchToParent(20, nil, 20, nil)
    TextBox:RequestFocus()
    function TextBox:Think() -- Most people are holding tab when they open this window. Get focus back!
        TextBox.InTab = TextBox.InTab or input.IsKeyDown(KEY_TAB)
        if TextBox.InTab and not input.IsKeyDown(KEY_TAB) then self:RequestFocus() end
    end
    function TextBox:OnEnter()
        OK:DoClick()
    end

    OK:SetSize(100, 20)
    OK:SetText("OK")
    OK:AlignRight(20)
    OK:AlignBottom(20)
    function OK:DoClick()
        frame:Close()
        if not IsValid(ply) then return end
        RunConsoleCommand("_FAdmin", "Message", ply:SteamID(), MsgType, TextBox:GetValue())
    end
end

FAdmin.StartHooks["zzSendMessage"] = function()
    FAdmin.Access.AddPrivilege("Message", 1)
    FAdmin.Commands.AddCommand("Message", nil, "<Player>", "[type]", "<text>")

    FAdmin.ScoreBoard.Player:AddActionButton("Send message", "fadmin/icons/message", Color(0, 200, 0, 255),
        function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "Message") and not ply:IsBot() end, function(ply, button)
            MessageGui(ply)
        end
    )
end
