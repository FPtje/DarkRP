local f4Frame

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
	elseif not f4Frame:IsVisible() then
		f4Frame:Show()
	else
		f4Frame:Hide()
	end
end

GM.ShowSpare2 = DarkRP.toggleF4Menu
