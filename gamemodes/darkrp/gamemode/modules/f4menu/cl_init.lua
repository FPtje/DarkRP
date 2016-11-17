local f4Frame

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function DarkRP.openF4Menu()
    if IsValid(f4Frame) then
        f4Frame:Show()
        f4Frame:InvalidateLayout()
    else
        f4Frame = vgui.Create("F4MenuFrame")
        f4Frame:generateTabs()
    end
end

function DarkRP.closeF4Menu()
    if f4Frame then
        f4Frame:Hide()
    end
end

function DarkRP.toggleF4Menu()
    if not IsValid(f4Frame) or not f4Frame:IsVisible() then
        DarkRP.openF4Menu()
    else
        DarkRP.closeF4Menu()
    end
end

function DarkRP.getF4MenuPanel()
    return f4Frame
end

function DarkRP.addF4MenuTab(name, panel)
    if not f4Frame then DarkRP.error("DarkRP.addF4MenuTab called at the wrong time. Please call in the F4MenuTabs hook.", 2) end

    return f4Frame:createTab(name, panel)
end

function DarkRP.removeF4MenuTab(name)
    if not f4Frame then DarkRP.error("DarkRP.addF4MenuTab called at the wrong time. Please call in the F4MenuTabs hook.", 2) end

    f4Frame:removeTab(name)
end

function DarkRP.switchTabOrder(tab1, tab2)
    if not f4Frame then DarkRP.error("DarkRP.addF4MenuTab called at the wrong time. Please call in the F4MenuTabs hook.", 2) end

    f4Frame:switchTabOrder(tab1, tab2)
end


--[[---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]
function DarkRP.hooks.F4MenuTabs()
    DarkRP.addF4MenuTab(DarkRP.getPhrase("jobs"), vgui.Create("F4MenuJobs"))
    DarkRP.addF4MenuTab(DarkRP.getPhrase("F4entities"), vgui.Create("F4MenuEntities"))

    local shipments = fn.Filter(fn.Compose{fn.Not, fn.Curry(fn.GetValue, 2)("noship")}, CustomShipments)
    if table.Count(shipments) > 0 then
        DarkRP.addF4MenuTab(DarkRP.getPhrase("shipments"), vgui.Create("F4MenuShipments"))
    end

    local guns = fn.Filter(fn.Curry(fn.GetValue, 2)("separate"), CustomShipments)
    if table.Count(guns) > 0 then
        DarkRP.addF4MenuTab(DarkRP.getPhrase("F4guns"), vgui.Create("F4MenuGuns"))
    end

    if table.Count(GAMEMODE.AmmoTypes) > 0 then
        DarkRP.addF4MenuTab(DarkRP.getPhrase("F4ammo"), vgui.Create("F4MenuAmmo"))
    end

    if table.Count(CustomVehicles) > 0 then
        DarkRP.addF4MenuTab(DarkRP.getPhrase("F4vehicles"), vgui.Create("F4MenuVehicles"))
    end
end

hook.Add("DarkRPVarChanged", "RefreshF4Menu", function(ply, varname)
    if ply ~= LocalPlayer() or varname ~= "money" or not IsValid(f4Frame) or not f4Frame:IsVisible() then return end

    f4Frame:InvalidateLayout()
end)

--[[---------------------------------------------------------------------------
Fonts
---------------------------------------------------------------------------]]
surface.CreateFont("Roboto Light", { -- font is not found otherwise
        size = 19,
        weight = 300,
        antialias = true,
        shadow = false,
        font = "Roboto Light"})

surface.CreateFont("F4MenuFont01", {
        size = 23,
        weight = 400,
        antialias = true,
        shadow = false,
        font = "Roboto Light"})

surface.CreateFont("F4MenuFont02", {
        size = 30,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Roboto Light"})
