local PLAYER_CLASS = {}

PLAYER_CLASS.DisplayName = "DarkRP Player Class"
PLAYER_CLASS.TeammateNoCollide = false

function PLAYER_CLASS:GetHandsModel()
	local jobTable = self.Player:getJobTable()
	if not jobTable then return end

	local model = istable(jobTable.model) and jobTable.model[1] or jobTable.model
	if not model then return end
	
	local name = player_manager.TranslateToPlayerModelName(model)

	return player_manager.TranslatePlayerHands(name)
end

function PLAYER_CLASS:Spawn()
	local col = self.Player:GetInfo( "cl_playercolor" )
	self.Player:SetPlayerColor( Vector( col ) )

	local col = self.Player:GetInfo( "cl_weaponcolor" )
	self.Player:SetWeaponColor( Vector( col ) )
end

player_manager.RegisterClass("player_DarkRP", PLAYER_CLASS, "player_default")
