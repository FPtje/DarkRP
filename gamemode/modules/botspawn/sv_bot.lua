local firstSpawn = true
hook.Add("PlayerSpawn","SpawnBot",function(ply)
	if(!firstSpawn) then return end
	local ent = ents.Create("fuck_you")
	if(!IsValid(ent)) then return end
		ent:Spawn()
		ent:SetPos(ply:GetPos())
		ent:SetAngles(ply:GetAngles())
		ent:SetEnemy(ply)
	firstSpawn = false
end)