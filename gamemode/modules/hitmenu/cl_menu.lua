local PANEL
local minHitDistanceSqr = GM.Config.minHitDistance * GM.Config.minHitDistance

--[[---------------------------------------------------------------------------
Hitman menu
---------------------------------------------------------------------------]]
PANEL = {}

AccessorFunc(PANEL, "hitman", "Hitman")
AccessorFunc(PANEL, "target", "Target")
AccessorFunc(PANEL, "selected", "Selected")

function PANEL:Init()
    self.BaseClass.Init(self)

    self.btnClose = vgui.Create("DButton", self)
    self.btnClose:SetText("")
    self.btnClose.DoClick = function() self:Remove() end
    self.btnClose.Paint = function(panel, w, h) derma.SkinHook("Paint", "WindowCloseButton", panel, w, h) end

    self.icon = vgui.Create("SpawnIcon", self)
    self.icon:SetDisabled(true)
    self.icon.PaintOver = function(icon) icon:SetTooltip() end
    self.icon:SetTooltip()

    self.title = vgui.Create("DLabel", self)
    self.title:SetText(DarkRP.getPhrase("hitman"))

    self.name = vgui.Create("DLabel", self)
    self.price = vgui.Create("DLabel", self)

    self.playerList = vgui.Create("DScrollPanel", self)

    self.btnRequest = vgui.Create("HitmanMenuButton", self)
    self.btnRequest:SetText(DarkRP.getPhrase("hitmenu_request"))
    self.btnRequest.DoClick = function()
        if IsValid(self:GetTarget()) then
            RunConsoleCommand("darkrp", "requesthit", self:GetTarget():SteamID(), self:GetHitman():UserID())
            self:Remove()
        end
    end

    self.btnCancel = vgui.Create("HitmanMenuButton", self)
    self.btnCancel:SetText(DarkRP.getPhrase("cancel"))
    self.btnCancel.DoClick = function() self:Remove() end

    self:SetSkin(GAMEMODE.Config.DarkRPSkin)

    self:InvalidateLayout()
end

function PANEL:Think()
    if not IsValid(self:GetHitman()) or self:GetHitman():GetPos():DistToSqr(LocalPlayer():GetPos()) > minHitDistanceSqr then
        self:Remove()
        return
    end

    -- update the price (so the hitman can't scam)
    self.price:SetText(DarkRP.getPhrase("priceTag", DarkRP.formatMoney(self:GetHitman():getHitPrice()), ""))
    self.price:SizeToContents()
end

function PANEL:PerformLayout()
    local w, h = self:GetSize()

    self:SetSize(500, 700)
    self:Center()

    self.btnClose:SetSize(24, 24)
    self.btnClose:SetPos(w - 24 - 5, 5)

    self.icon:SetSize(128, 128)
    self.icon:SetModel(self:GetHitman():GetModel())
    self.icon:SetPos(20, 20)

    self.title:SetFont("ScoreboardHeader")
    self.title:SetPos(20 + 128 + 20, 20)
    self.title:SizeToContents(true)

    self.name:SizeToContents(true)
    self.name:SetText(DarkRP.getPhrase("name", self:GetHitman():Nick()))
    self.name:SetPos(20 + 128 + 20, 20 + self.title:GetTall())

    self.price:SetFont("HUDNumber5")
    self.price:SetColor(Color(255, 0, 0, 255))
    self.price:SetText(DarkRP.getPhrase("priceTag", DarkRP.formatMoney(self:GetHitman():getHitPrice()), ""))
    self.price:SetPos(20 + 128 + 20, 20 + self.title:GetTall() + 20)
    self.price:SizeToContents(true)

    self.playerList:SetPos(20, 20 + self.icon:GetTall() + 20)
    self.playerList:SetWide(self:GetWide() - 40)

    self.btnRequest:SetPos(20, h - self.btnRequest:GetTall() - 20)
    self.btnRequest:SetButtonColor(Color(0, 120, 30, 255))

    self.btnCancel:SetPos(w - self.btnCancel:GetWide() - 20, h - self.btnCancel:GetTall() - 20)
    self.btnCancel:SetButtonColor(Color(140, 0, 0, 255))

    self.playerList:StretchBottomTo(self.btnRequest, 20)

    self.BaseClass.PerformLayout(self)
end

function PANEL:Paint()
    local w, h = self:GetSize()

    surface.SetDrawColor(Color(0, 0, 0, 200))
    surface.DrawRect(0, 0, w, h)
end

function PANEL:AddPlayerRows()
    local players = table.Copy(player.GetAll())

    table.sort(players, function(a, b)
        local aTeam, bTeam, aNick, bNick = team.GetName(a:Team()), team.GetName(b:Team()), string.lower(a:Nick()), string.lower(b:Nick())
        return aTeam == bTeam and aNick < bNick or aTeam < bTeam
    end)

    for _, v in ipairs(players) do
        local canRequest = hook.Call("canRequestHit", DarkRP.hooks, self:GetHitman(), LocalPlayer(), v, self:GetHitman():getHitPrice())
        if not canRequest then continue end

        local line = vgui.Create("HitmanMenuPlayerRow")
        line:SetPlayer(v)
        self.playerList:AddItem(line)
        line:SetWide(self.playerList:GetWide() - 100)
        line:Dock(TOP)

        line.DoClick = function()
            self:SetTarget(line:GetPlayer())

            if IsValid(self:GetSelected()) then
                self:GetSelected():SetSelected(false)
            end

            line:SetSelected(true)
            self:SetSelected(line)
        end
    end
end

vgui.Register("HitmanMenu", PANEL, "DPanel")

--[[---------------------------------------------------------------------------
Hitmenu button
---------------------------------------------------------------------------]]
PANEL = {}

AccessorFunc(PANEL, "btnColor", "ButtonColor")

function PANEL:PerformLayout()
    self:SetSize(self:GetParent():GetWide() / 2 - 30, 100)
    self:SetFont("HUDNumber5")
    self:SetTextColor(color_white)

    self.BaseClass.PerformLayout(self)
end

function PANEL:Paint()
    local w, h = self:GetSize()
    local col = self:GetButtonColor() or Color(0, 120, 30, 255)
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("HitmanMenuButton", PANEL, "DButton")

--[[---------------------------------------------------------------------------
Player row
---------------------------------------------------------------------------]]
PANEL = {}

AccessorFunc(PANEL, "player", "Player")
AccessorFunc(PANEL, "selected", "Selected", FORCE_BOOL)

function PANEL:Init()
    self.lblName = vgui.Create("DLabel", self)
    self.lblName:SetMouseInputEnabled(false)
    self.lblName:SetColor(Color(255,255,255,200))

    self.lblTeam = vgui.Create("DLabel", self)
    self.lblTeam:SetMouseInputEnabled(false)
    self.lblTeam:SetColor(Color(255,255,255,200))

    self:SetText("")

    self:SetCursor("hand")
end

function PANEL:PerformLayout()
    local ply = self:GetPlayer()
    if not IsValid(ply) then self:Remove() return end

    self.lblName:SetFont("UiBold")
    self.lblName:SetText(DarkRP.deLocalise(ply:Nick()))
    self.lblName:SizeToContents()
    self.lblName:SetPos(10, 1)

    self.lblTeam:SetFont("UiBold")
    self.lblTeam:SetText((ply.DarkRPVars and DarkRP.deLocalise(ply:getDarkRPVar("job") or "")) or team.GetName(ply:Team()))
    self.lblTeam:SizeToContents()
    self.lblTeam:SetPos(self:GetWide() / 2, 1)
end

function PANEL:Paint()
    if not IsValid(self:GetPlayer()) then self:Remove() return end

    local color = team.GetColor(self:GetPlayer():Team())
    color.a = self:GetSelected() and 70 or 255

    surface.SetDrawColor(color)
    surface.DrawRect(0, 0, self:GetWide(), 20)
end

vgui.Register("HitmanMenuPlayerRow", PANEL, "Button")

--[[---------------------------------------------------------------------------
Open the hit menu
---------------------------------------------------------------------------]]
function DarkRP.openHitMenu(hitman)
    local frame = vgui.Create("HitmanMenu")
    frame:SetHitman(hitman)
    frame:AddPlayerRows()
    frame:SetVisible(true)
    frame:MakePopup()
    frame:ParentToHUD()
end
