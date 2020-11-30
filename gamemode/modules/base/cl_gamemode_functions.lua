local GUIToggled = false
local mouseX, mouseY = ScrW() / 2, ScrH() / 2
function GM:ShowSpare1()
    local jobTable = LocalPlayer():getJobTable()

    -- We need to check for the existance of jobTable here, because in very rare edge cases, the player's team isn't set, when the getJobTable-function is called here.
    if jobTable and jobTable.ShowSpare1 then
        return jobTable.ShowSpare1(LocalPlayer())
    end

    GUIToggled = not GUIToggled

    if GUIToggled then
        gui.SetMousePos(mouseX, mouseY)
    else
        mouseX, mouseY = gui.MousePos()
    end
    gui.EnableScreenClicker(GUIToggled)
end

function GM:ShowSpare2()
    local jobTable = LocalPlayer():getJobTable()

    -- We need to check for the existance of jobTable here, because in very rare edge cases, the player's team isn't set, when the getJobTable-function is called here.
    if jobTable and jobTable.ShowSpare2 then
        return jobTable.ShowSpare2(LocalPlayer())
    end

    DarkRP.toggleF4Menu()
end

function GM:PlayerStartVoice(ply)
    if ply == LocalPlayer() then
        ply.DRPIsTalking = true
        return -- Not the original rectangle for yourself! ugh!
    end
    self.Sandbox.PlayerStartVoice(self, ply)
end

function GM:PlayerEndVoice(ply)
    if ply == LocalPlayer() then
        ply.DRPIsTalking = false
        return
    end

    self.Sandbox.PlayerEndVoice(self, ply)
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
    self.Sandbox.PlayerBindPress(self, ply, bind, pressed)

    local bnd = string.match(string.lower(bind), "gm_[a-z]+[12]?")
    if bnd and FKeyBinds[bnd] then
        hook.Call(FKeyBinds[bnd], GAMEMODE)
    end

    if not self.Config.deadvoice and not ply:Alive() and string.find(string.lower(bind), "voicerecord") then return true end
end

function GM:InitPostEntity()
    hook.Call("teamChanged", GAMEMODE, GAMEMODE.DefaultTeam, GAMEMODE.DefaultTeam)
end

function GM:teamChanged(before, after)
end

local function OnChangedTeam(um)
    local oldTeam, newTeam = um:ReadShort(), um:ReadShort()
    hook.Call("teamChanged", GAMEMODE, oldTeam, newTeam) -- backwards compatibility
    hook.Call("OnPlayerChangedTeam", GAMEMODE, LocalPlayer(), oldTeam, newTeam)
end
usermessage.Hook("OnChangedTeam", OnChangedTeam)

timer.Simple(0, function() GAMEMODE.ShowTeam = DarkRP.openKeysMenu end)
