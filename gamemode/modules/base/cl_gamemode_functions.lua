local GUIToggled = false
local mouseX, mouseY = ScrW() / 2, ScrH() / 2
function GM:ShowSpare1()
	GUIToggled = not GUIToggled

	if GUIToggled then
		gui.SetMousePos(mouseX, mouseY)
	else
		mouseX, mouseY = gui.MousePos()
	end
	gui.EnableScreenClicker(GUIToggled)
end

function GM:PlayerStartVoice(ply)
	if ply == LocalPlayer() then
		ply.DRPIsTalking = true
		return -- Not the original rectangle for yourself! ugh!
	end
	self.BaseClass:PlayerStartVoice(ply)
end

function GM:PlayerEndVoice(ply)
	if ply == LocalPlayer() then
		ply.DRPIsTalking = false
		return
	end

	self.BaseClass:PlayerEndVoice(ply)
end

function GM:OnPlayerChat()
end

local FKeyBinds = {
	["gm_showhelp"] = "ShowHelp",
	["gm_showteam"] = "ShowTeam",
	["gm_showspare1"] = "ShowSpare1",
	["gm_showspare2"] = "ShowSpare2"
}

function GM:PlayerBindPress(ply, bind, pressed)
	self.BaseClass:PlayerBindPress(ply, bind, pressed)

	local bnd = string.match(string.lower(bind), "gm_[a-z]+[12]?")
	if bnd and FKeyBinds[bnd] then
		hook.Call(FKeyBinds[bnd], GAMEMODE)
	end
end

function GM:InitPostEntity()
	hook.Call("teamChanged", GAMEMODE, GAMEMODE.DefaultTeam, GAMEMODE.DefaultTeam)
end

function GM:teamChanged(before, after)
end

local function OnChangedTeam()
	local oldTeam, newTeam = net.ReadUInt(16), net.ReadUInt(16)
	hook.Call("teamChanged", GAMEMODE, oldTeam, newTeam) -- backwards compatibility
	hook.Call("OnPlayerChangedTeam", GAMEMODE, LocalPlayer(), oldTeam, newTeam)
end
net.Receive("OnChangedTeam", OnChangedTeam)

timer.Simple(0, function() GAMEMODE.ShowTeam = DarkRP.openKeysMenu end)
