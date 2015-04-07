local function MakeZombieSoundsAsHobo(ply)
	if ply:EntIndex() == 0 then return end
	local ran = math.random(1,3);
	if ran == 1 then
		ply:EmitSound("npc/zombie/zombie_voice_idle"..tostring(math.random(1,14))..".wav", 100,100);
	elseif ran == 2 then
		ply:EmitSound("npc/zombie/zombie_pain"..tostring(math.random(1,6))..".wav", 100,100);
	elseif ran == 3 then
		ply:EmitSound("npc/zombie/zombie_alert"..tostring(math.random(1,3))..".wav", 100,100);
	end
end
concommand.Add("_hobo_emitsound", MakeZombieSoundsAsHobo);
