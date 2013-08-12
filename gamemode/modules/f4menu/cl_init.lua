local f4Frame

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function DarkRP.openF4Menu()
	if f4Frame then
		f4Frame:Show()
	else
		DarkRP.toggleF4Menu()
	end
end

function DarkRP.closeF4Menu()
	if f4Frame then
		f4Frame:Hide()
	end
end

function DarkRP.toggleF4Menu()
	if not ValidPanel(f4Frame) then
		f4Frame = vgui.Create("F4MenuFrame")
		f4Frame:generateTabs()
	elseif not f4Frame:IsVisible() then
		f4Frame:Show()
	else
		f4Frame:Hide()
	end
end

GM.ShowSpare2 = DarkRP.toggleF4Menu

function DarkRP.addF4MenuTab(name, panel)
	if not f4Frame then error("DarkRP.addF4MenuTab called at the wrong time. Please call in the F4MenuTabs hook.") end

	return f4Frame:createTab(name, panel)
end

function DarkRP.removeF4MenuTab(name)
	if not f4Frame then error("DarkRP.addF4MenuTab called at the wrong time. Please call in the F4MenuTabs hook.") end

	f4Frame:removeTab(name)
end

function DarkRP.switchTabOrder(tab1, tab2)
	if not f4Frame then error("DarkRP.addF4MenuTab called at the wrong time. Please call in the F4MenuTabs hook.") end

	f4Frame:switchTabOrder(tab1, tab2)
end


/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/
hook.Add("F4MenuTabs", "DefaultTabs", function()
	DarkRP.addF4MenuTab(DarkRP.getPhrase("jobs"), vgui.Create("F4MenuJobs"))
	DarkRP.addF4MenuTab(DarkRP.getPhrase("shipments"), vgui.Create("F4MenuShipments"))

	local guns = fn.Filter(fn.Curry(fn.GetValue, 2)("seperate"), CustomShipments)
	PrintTable(guns)
	if #guns > 0 then
		DarkRP.addF4MenuTab(DarkRP.getPhrase("F4guns"), vgui.Create("F4MenuGuns"))
	end
end)

/*---------------------------------------------------------------------------
Fonts
---------------------------------------------------------------------------*/
surface.CreateFont("Ubuntu Light", { -- font is not found otherwise
		size = 18,
		weight = 300,
		antialias = true,
		shadow = false,
		font = "Ubuntu Light"})

surface.CreateFont("F4MenuFont1", {
		size = 23,
		weight = 400,
		antialias = true,
		shadow = false,
		font = "Ubuntu Light"})

surface.CreateFont("F4MenuFont2", {
		size = 30,
		weight = 800,
		antialias = true,
		shadow = false,
		font = "Ubuntu Light"})
