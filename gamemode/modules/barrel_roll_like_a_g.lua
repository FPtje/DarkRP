if SERVER then
	util.AddNetworkString 'barrel_roll'

	hook.Add("PostPlayerSay", "DoABarrelRoll", function(ply, text)
		local text = string.lower(text)
		if string.find(text, 'do a barrel roll') then
			--net.Start 'barrel_roll'
			--net.Send(ply)
			ply:SendLua("local a=CurTime()hook.Add('CalcView','BarrelRoll',function(b,c,d,e,f)local g=(CurTime()-a)*90;if g>360 then hook.Remove('CalcView','BarrelRoll')return end;local h={}h.origin=c;d.r=g;h.angles=d;h.fov=e;return h end)")
		end
	end)
end
