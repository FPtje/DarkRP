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


/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/
hook.Add("F4MenuTabs", "DefaultTabs", function()
end)
