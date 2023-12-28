local QuestionVGUI = {}
local PanelNum = 0
local VoteVGUI = {}
local function MsgDoVote(msg)
    local _, chatY = chat.GetChatBoxPos()

    local question = msg:ReadString()
    local voteid = msg:ReadShort()
    local timeleft = msg:ReadFloat()
    if timeleft == 0 then
        timeleft = 100
    end
    local OldTime = CurTime()
    if not IsValid(LocalPlayer()) then return end -- Sent right before player initialisation

    LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
    local panel = vgui.Create("DFrame")
    panel:SetPos(3 + PanelNum, chatY - 145)
    panel:SetTitle(DarkRP.getPhrase("vote"))
    panel:SetSize(140, 140)
    panel:SetSizable(false)
    panel.btnClose:SetVisible(false)
    panel.btnMaxim:SetVisible(false)
    panel.btnMinim:SetVisible(false)
    panel:SetDraggable(false)
    function panel:Close()
        PanelNum = PanelNum - 140
        VoteVGUI[voteid .. "vote"] = nil

        local num = 0
        for _, v in SortedPairs(VoteVGUI) do
            v:SetPos(num, ScrH() / 2 - 50)
            num = num + 140
        end

        for _, v in SortedPairs(QuestionVGUI) do
            v:SetPos(num, ScrH() / 2 - 50)
            num = num + 300
        end
        self:Remove()
    end

    function panel:Think()
        self:SetTitle(DarkRP.getPhrase("time", math.Clamp(math.ceil(timeleft - (CurTime() - OldTime)), 0, 9999)))
        if timeleft - (CurTime() - OldTime) <= 0 then
            panel:Close()
        end
    end

    panel:SetKeyboardInputEnabled(false)
    panel:SetMouseInputEnabled(true)
    panel:SetVisible(true)

    local label = vgui.Create("DLabel")
    label:SetParent(panel)
    label:SetPos(5, 25)
    label:SetText(DarkRP.textWrap(DarkRP.deLocalise(question), "DermaDefault", 130))
    label:SizeToContents()
    label:SetVisible(true)

    local nextHeight = label:GetTall() > 78 and label:GetTall() - 78 or 0 -- Make panel taller for divider and buttons
    panel:SetTall(panel:GetTall() + nextHeight)

    local divider = vgui.Create("Divider")
    divider:SetParent(panel)
    divider:SetPos(2, panel:GetTall() - 30)
    divider:SetSize(180, 2)
    divider:SetVisible(true)

    local ybutton = vgui.Create("Button")
    ybutton:SetParent(panel)
    ybutton:SetPos(25, panel:GetTall() - 25)
    ybutton:SetSize(40, 20)
    ybutton:SetText(DarkRP.getPhrase("yes"))
    ybutton:SetVisible(true)
    ybutton.DoClick = function()
        LocalPlayer():ConCommand("vote " .. voteid .. " yea\n")
        panel:Close()
    end

    local nbutton = vgui.Create("Button")
    nbutton:SetParent(panel)
    nbutton:SetPos(70, panel:GetTall() - 25)
    nbutton:SetSize(40, 20)
    nbutton:SetText(DarkRP.getPhrase("no"))
    nbutton:SetVisible(true)
    nbutton.DoClick = function()
        LocalPlayer():ConCommand("vote " .. voteid .. " nay\n")
        panel:Close()
    end

    PanelNum = PanelNum + 140
    VoteVGUI[voteid .. "vote"] = panel
    panel:SetSkin(GAMEMODE.Config.DarkRPSkin)
end
usermessage.Hook("DoVote", MsgDoVote)

local function KillVoteVGUI(msg)
    local id = msg:ReadShort()

    if VoteVGUI[id .. "vote"] and VoteVGUI[id .. "vote"]:IsValid() then
        VoteVGUI[id .. "vote"]:Close()
    end
end
usermessage.Hook("KillVoteVGUI", KillVoteVGUI)

local function MsgDoQuestion(msg)
    if not IsValid(LocalPlayer()) then return end

    local question = msg:ReadString()
    local quesid = msg:ReadString()
    local timeleft = msg:ReadFloat()
    if timeleft == 0 then
        timeleft = 100
    end
    local OldTime = CurTime()
    LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
    local panel = vgui.Create("DFrame")
    panel:SetPos(3 + PanelNum, ScrH() / 2 - 50) -- Times 140 because if the question is the second screen, the first screen is always a vote screen.
    panel:SetSize(300, 140)
    panel:SetSizable(false)
    panel.btnClose:SetVisible(false)
    panel.btnMaxim:SetVisible(false)
    panel.btnMinim:SetVisible(false)
    panel:SetKeyboardInputEnabled(false)
    panel:SetMouseInputEnabled(true)
    panel:SetVisible(true)

    function panel:Close()
        PanelNum = PanelNum - 300
        QuestionVGUI[quesid .. "ques"] = nil
        local num = 0
        for _, v in SortedPairs(VoteVGUI) do
            v:SetPos(num, ScrH() / 2 - 50)
            num = num + 140
        end

        for _, v in SortedPairs(QuestionVGUI) do
            v:SetPos(num, ScrH() / 2 - 50)
            num = num + 300
        end

        self:Remove()
    end

    function panel:Think()
        self:SetTitle(DarkRP.getPhrase("time", math.Clamp(math.ceil(timeleft - (CurTime() - OldTime)), 0, 9999)))
        if timeleft - (CurTime() - OldTime) <= 0 then
            panel:Close()
        end
    end

    local label = vgui.Create("DLabel")
    label:SetParent(panel)
    label:SetPos(5, 30)
    label:SetSize(380, 40)
    label:SetText(DarkRP.deLocalise(question))
    label:SetVisible(true)

    local divider = vgui.Create("Divider")
    divider:SetParent(panel)
    divider:SetPos(2, 80)
    divider:SetSize(380, 2)
    divider:SetVisible(true)

    local ybutton = vgui.Create("DButton")
    ybutton:SetParent(panel)
    ybutton:SetPos(105, 100)
    ybutton:SetSize(40, 20)
    ybutton:SetText(DarkRP.getPhrase("yes"))
    ybutton:SetVisible(true)
    ybutton.DoClick = function()
        LocalPlayer():ConCommand("ans " .. quesid .. " 1\n")
        panel:Close()
    end

    local nbutton = vgui.Create("DButton")
    nbutton:SetParent(panel)
    nbutton:SetPos(155, 100)
    nbutton:SetSize(40, 20)
    nbutton:SetText(DarkRP.getPhrase("no"))
    nbutton:SetVisible(true)
    nbutton.DoClick = function()
        LocalPlayer():ConCommand("ans " .. quesid .. " 2\n")
        panel:Close()
    end

    PanelNum = PanelNum + 300
    QuestionVGUI[quesid .. "ques"] = panel

    panel:SetSkin(GAMEMODE.Config.DarkRPSkin)
end
usermessage.Hook("DoQuestion", MsgDoQuestion)

local function KillQuestionVGUI(msg)
    local id = msg:ReadString()

    if QuestionVGUI[id .. "ques"] and QuestionVGUI[id .. "ques"]:IsValid() then
        QuestionVGUI[id .. "ques"]:Close()
    end
end
usermessage.Hook("KillQuestionVGUI", KillQuestionVGUI)

local function DoVoteAnswerQuestion(ply, cmd, args)
    if not args[1] then return end

    local vote = 0
    if tonumber(args[1]) == 1 or string.lower(args[1]) == "yes" or string.lower(args[1]) == "true" then vote = 1 end

    for k, v in pairs(VoteVGUI) do
        if IsValid(v) then
            local ID = string.sub(k, 1, -5)
            VoteVGUI[k]:Close()
            RunConsoleCommand("vote", ID, vote)
            return
        end
    end

    for k, v in pairs(QuestionVGUI) do
        if IsValid(v) then
            local ID = string.sub(k, 1, -5)
            QuestionVGUI[k]:Close()
            RunConsoleCommand("ans", ID, vote)
            return
        end
    end
end
concommand.Add("rp_vote", DoVoteAnswerQuestion)
