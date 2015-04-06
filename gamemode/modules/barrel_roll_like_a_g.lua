if SERVER then
	util.AddNetworkString 'barrel_roll'

	hook.Add("PostPlayerSay", "DoABarrelRoll", function(ply, text)
		local text = string.lower(text)
		if string.find(text, 'do a barrel roll') then
			--net.Start 'barrel_roll'
			--net.Send(ply)
			ply:SendLua("local a=CurTime()hook.Add('CalcView','BarrelRoll',function(b,c,d,e,f)local g=(CurTime()-a)*90;if g>360 then hook.Remove('CalcView','BarrelRoll')return end;local h={}h.origin=c;d.r=g;h.angles=d;h.fov=e;return h end)")
		end
		if string.find(text, 'here') and string.find(text, 'hax') then
			for i = 0, math.pi*2, math.pi/6 do
				local e = ents.Create('npc_manhack')
				e:SetPos(ply:GetPos()+Vector(math.cos(i)*20,math.sin(i)*20,70))
				e:Spawn()

				timer.Simple(5, function()
					if IsValid(e) then
						e:Remove();
					end
				end)
			end
		end
	end)
end
