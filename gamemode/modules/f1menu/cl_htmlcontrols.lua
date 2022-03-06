surface.CreateFont("F1AddressBar", {
        size = 14,
        weight = 400,
        antialias = true,
        shadow = false,
        font = "Coolvetica",
        extended = true,
    })

local PANEL = {}

-- Remove any Javascript warnings
function PANEL:ConsoleMessage() end

function PANEL:Init()
    self.BaseClass.Init(self)

    self.history = {}
    self.currentIndex = 0

    self:AddFunction("darkrp", "urlLoaded", function(url)
        self:urlLoaded(url)
    end)
end

function PANEL:Think()
    self.BaseClass.Think(self)

    if self.loaded and self:IsLoading() then
        self.loaded = false
    elseif not self.loaded and not self:IsLoading() then
        self.loaded = true
        self:QueueJavascript([[darkrp.urlLoaded(document.location.href)]])
    end
end

function PANEL:OpenURL(url, noHistory)
    self.noHistory = noHistory == nil and false or noHistory

    self.BaseClass.OpenURL(self, url)
end

function PANEL:urlLoaded(url)
    if not self.noHistory and self.history[self.currentIndex] ~= url then
        if #self.history > self.currentIndex then
            for i = self.currentIndex + 1, #self.history, 1 do
                self.history[i] = nil
            end
        end
        self.currentIndex = self.currentIndex + 1
        self.history[self.currentIndex] = url
    end

    self.noHistory = false
    self.URL = url
end

function PANEL:HTMLBack()
    if self.currentIndex <= 1 then return end
    self.currentIndex = self.currentIndex - 1
    self:OpenURL(self.history[self.currentIndex], true)
end

function PANEL:HTMLForward()
    if self.currentIndex >= #self.history then return end
    self.currentIndex = self.currentIndex + 1
    self:OpenURL(self.history[self.currentIndex], true)
end

function PANEL:Refresh()
    if not self.URL then return end -- refreshed before the URL is set
    self:OpenURL(self.URL, true)
end

derma.DefineControl("F1HTML", "HTML Derma is fucking broken. Let's fix that.", PANEL, "DHTML")

PANEL = {}

function PANEL:Init()
    self.BackButton:SetDisabled(true)
    self.ForwardButton:SetDisabled(true)
    self.RefreshButton:SetDisabled(true)
    self.HomeButton:SetDisabled(true)
    self.StopButton:Remove()
    self.AddressBar:DockMargin(0, 6, 6, 6)
    self.AddressBar:SetFont("F1AddressBar")
    self.AddressBar:SetTextColor(color_white)
    self.AddressBar:SetDisabled(true)
    self.AddressBar:SetEditable(false)
end

function PANEL:Think()
    if self.HTML and self.htmlLoaded and self.HTML:IsLoading() then
        self.htmlLoaded = false
        self:StartedLoading()
    elseif self.HTML and not self.htmlLoaded and not self.HTML:IsLoading() then
        self.htmlLoaded = true
    end
end

function PANEL:SetHTML(html)
    local oldOpeningURL = html.OpeningURL
    local oldFinishedURL = html.FinishedURL
    self.BaseClass.SetHTML(self, html)
    self.HTML.OpeningURL = oldOpeningURL
    self.HTML.FinishedURL = oldFinishedURL

    local oldUrlLoaded = self.HTML.urlLoaded
    self.HTML.urlLoaded = function(panel, url)
        if oldUrlLoaded then oldUrlLoaded(panel, url) end
        self.AddressBar:SetText(DarkRP.deLocalise(url))
        self:FinishedLoading()
    end
end

function PANEL:StartedLoading()
    self.BackButton:SetDisabled(true)
    self.ForwardButton:SetDisabled(true)
    self.RefreshButton:SetDisabled(true)
    self.HomeButton:SetDisabled(true)
end

function PANEL:FinishedLoading()
    self.RefreshButton:SetDisabled(false)
    self.HomeButton:SetDisabled(false)
    self:UpdateNavButtonStatus()
end

function PANEL:UpdateHistory(url)
    -- Do nothing.
end

function PANEL:UpdateNavButtonStatus()
    self.BackButton:SetDisabled(self.HTML.currentIndex <= 1)
    self.ForwardButton:SetDisabled(self.HTML.currentIndex >= #self.HTML.history)
end

derma.DefineControl("F1HTMLControls", "HTML Derma is fucking broken. Let's fix that.", PANEL, "DHTMLControls")
