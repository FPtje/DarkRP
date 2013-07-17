local PLAYER_CLASS = {}

PLAYER_CLASS.DisplayName = "DarkRP Player Class"

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

player_manager.RegisterClass("player_DarkRP", PLAYER_CLASS, "player_default")