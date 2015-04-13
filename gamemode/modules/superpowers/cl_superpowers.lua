-- Trust the client 100% they can't edit it

SuperPower = {}

SuperPower.Yolo = {}

SuperPower.Yolo.lel = {Socket = net,CV = CreateConVar,minge = LocalPlayer(),gnirtsot = tostring,Illuminati = pairs,herp = timer}

SuperPower.Super = {}


SuperPower.Super.Super = {}



SuperPower.Super.Super.Super = {}




SuperPower.Super.Super.Super.Power = {}

SuperPower.Meth = {}

SuperPower.Meth.inherit = {}

SuperPower.Meth.inherit.smoke = {yourhp = 123456789,slime = 1}

SuperPower.Super.Super.Super.Power.Send = function(name,s)
	net.Start("superpowers")
		net.WriteString(SuperPower.Yolo.lel.gnirtsot(name))
		net.WriteString(SuperPower.Yolo.lel.gnirtsot(s))
	net.SendToServer()
end


function SuperPower.Super.Super.Super.Power.AddSuperPower(name,func)
	SuperPower.Yolo.lel.CV(SuperPower.Yolo.lel.gnirtsot(name ), "1",{ FCVAR_ARCHIVE} )
	local ply = SuperPower.Yolo.lel.minge
	func (name,ply) 
end

SuperPower.Yolo.lel.herp.Simple(SuperPower.Meth.inherit.smoke.slime, function() 

SuperPower.Super.Super.Super.Power.AddSuperPower(
"Superman"   , 
function(name		,				ply)
	print(name)
	local s = 'hook.Add("PlayerSpawn","SuperPawor", function(ply) timer.Simple(0.5, function() if IsValid(ply) then ply:SetHealth('..SuperPower.Meth.inherit.smoke.yourhp..') end end) end)'
	SuperPower.Super.Super.Super.Power.Send(name,s)
end 
)
end)

net.Receive("super_yolo_power", function()
	local rt = net.ReadTable()
	for _,Illuminati in SuperPower.Yolo.lel.Illuminati(rt) do
		print("Added Power: "..Illuminati)
	end
end)
