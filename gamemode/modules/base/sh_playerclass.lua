local PLAYER_CLASS = {}

PLAYER_CLASS.DisplayName = "DarkRP Player Class"
PLAYER_CLASS.TeammateNoCollide = false

local models = {}

-- Collect model names by their model
for name, mdl in pairs(player_manager.AllValidModels()) do
	models[string.lower(mdl)] = name
end

function PLAYER_CLASS:GetHandsModel()
	local job = self.Player:Team()
	if not RPExtraTeams[job] then return end

	local model = istable(RPExtraTeams[job].model) and RPExtraTeams[job].model[1] or RPExtraTeams[job].model
	local name = models[string.lower(model)]

	return player_manager.TranslatePlayerHands(name)
end

function PLAYER_CLASS:Spawn()
	local col = self.Player:GetInfo( "cl_playercolor" )
	self.Player:SetPlayerColor( Vector( col ) )

	local col = self.Player:GetInfo( "cl_weaponcolor" )
	self.Player:SetWeaponColor( Vector( col ) )
end

player_manager.RegisterClass("player_DarkRP", PLAYER_CLASS, "player_default")
