local MotdMessage =
[[

---------------------------------------------------------------------------
			fprp Message of the day!
---------------------------------------------------------------------------
]]

local endMOTD = "---------------------------------------------------------------------------\n"

local motd = [[
Welcome to fprp!
Commit shit on our github https://github.com/aStonedPenguin/fprp
]]

local function drawMOTD()
	MsgC(Color(255, 20, 20, 255), MotdMessage, Color(255, 255, 255, 255), motd, Color(255, 20, 20, 255), endMOTD);
end

concommand.Add("fprp_motd", drawMOTD);
