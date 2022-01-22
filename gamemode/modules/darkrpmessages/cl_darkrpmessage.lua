local MotdMessage =
[[


---------------------------------------------------------------------------
            DarkRP Message of the day!
---------------------------------------------------------------------------
]]

local endMOTD = "---------------------------------------------------------------------------\n"

local function drawMOTD(text)
    MsgC(Color(255, 20, 20, 255), MotdMessage, color_white, text, Color(255, 20, 20, 255), endMOTD)
end

local function receiveMOTD(html, len, headers, code)
    if not headers or headers.Status and string.sub(headers.Status, 1, 3) ~= "200" then return end
    drawMOTD(html)
end

local function showMOTD()
    http.Fetch("https://raw.githubusercontent.com/FPtje/DarkRPMotd/master/motd.txt", receiveMOTD, fn.Id)
end
timer.Simple(5, showMOTD)

concommand.Add("DarkRP_motd", showMOTD)
