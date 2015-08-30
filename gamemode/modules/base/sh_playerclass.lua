local PLAYER_CLASS = {}

-- Value of -1 = set to config value, if a corresponding setting exists
PLAYER_CLASS.DisplayName = "DarkRP Base Player Class"
PLAYER_CLASS.WalkSpeed = -1
PLAYER_CLASS.RunSpeed = -1
PLAYER_CLASS.DuckSpeed = 0.3
PLAYER_CLASS.UnDuckSpeed = 0.3
PLAYER_CLASS.TeammateNoCollide = false
PLAYER_CLASS.StartHealth = -1

function PLAYER_CLASS:Loadout()
    -- Let gamemode decide
end

function PLAYER_CLASS:SetModel()
    -- Let gamemode decide
end

function PLAYER_CLASS:ShouldDrawLocal()
    -- Let gamemode decide
end

function PLAYER_CLASS:CreateMove(cmd)
    -- Let gamemode decide
end

function PLAYER_CLASS:CalcView(view)
    -- Let gamemode decide
end

function PLAYER_CLASS:GetHandsModel()
    -- Let gamemode decide
end

function PLAYER_CLASS:StartMove(mv, cmd)
    -- Let gamemode decide
end

function PLAYER_CLASS:FinishMove(mv)
    -- Let gamemode decide
end

player_manager.RegisterClass("player_darkrp", PLAYER_CLASS, "player_sandbox")
