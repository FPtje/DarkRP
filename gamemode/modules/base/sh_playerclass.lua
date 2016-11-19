local PLAYER_CLASS = {}
PLAYER_CLASS.DisplayName = "DarkRP Base Player Class"
PLAYER_CLASS.WalkSpeed = -1
PLAYER_CLASS.RunSpeed = -1
PLAYER_CLASS.DuckSpeed = 0.3
PLAYER_CLASS.UnDuckSpeed = 0.3
PLAYER_CLASS.TeammateNoCollide = false
PLAYER_CLASS.StartHealth = -1

function PLAYER_CLASS:Loadout()
end

function PLAYER_CLASS:SetModel()
end

function PLAYER_CLASS:ShouldDrawLocal()
end

function PLAYER_CLASS:CreateMove(cmd)
end

function PLAYER_CLASS:CalcView(view)
end

function PLAYER_CLASS:GetHandsModel()
end

function PLAYER_CLASS:StartMove(mv, cmd)
end

function PLAYER_CLASS:FinishMove(mv)
end

player_manager.RegisterClass("player_darkrp", PLAYER_CLASS, "player_sandbox")
