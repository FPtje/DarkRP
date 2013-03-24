local prefix = "/"

local Options = {}
local targets
hook.Add("ChatTextChanged", "FAdmin_Chat_autocomplete", function(text)
	if not FAdmin.GlobalSetting.FAdmin then return end
	if string.sub(text, 1, 1) ~= prefix then targets = nil return end
	Options = {}

	local TExplode = string.Explode(" ", string.sub(text, 2))
	if not TExplode[1] then return end
	local Command = string.lower(TExplode[1])
	local Args = table.Copy(TExplode)
	Args[1] = nil
	Args = table.ClearKeys(Args)


	local optionsCount = 0
	for k,v in pairs(FAdmin.Commands.List) do
		if string.find(string.lower(k), Command, 1, true) ~= 1 then continue end

		Options["/" .. k] = table.Copy(v.ExtraArgs)

		optionsCount = optionsCount + 1
	end

	local ChatBoxPosX, ChatBoxPosY = chat.GetChatBoxPos()
	local DidMakeShorter = false
	table.sort(Options)
	local i = 1
	for k,v in pairs(Options) do
		local Pos = ChatBoxPosY + i*24
		if Pos + 24 > ScrH() then
			Options[k] = nil
			DidMakeShorter = true
			optionsCount = optionsCount - 1
		end
		i = i + 1
	end

	-- Player arguments
	local firstVal = table.GetFirstValue(Options)
	if optionsCount == 1 and firstVal[#Args] and string.match(firstVal[#Args], ".Player.") then
		local players = {}

		for k,v in pairs(FAdmin.FindPlayer(Args[#Args]) or {}) do
			if not IsValid(v) then continue end
			table.insert(players, v:Nick())
		end

		targets = table.concat(players, ", ")
	end

	local xPos = (ChatBoxPosX == 12 and 412) or (ChatBoxPosX == 22 and 745) or (ChatBoxPosX == 21 and 741) or 526
	hook.Add("HUDPaint", "FAdmin_Chat_autocomplete", function()
		local i = 0
		for option, args in pairs(Options) do
			draw.WordBox(4, xPos, ChatBoxPosY + i*24, option, "UiBold", Color(0,0,0,200), Color(255,255,255,255))
			for k, arg in pairs(args) do
				draw.WordBox(4, xPos + k * 130, ChatBoxPosY + i*24, arg, "UiBold", Color(0,0,0,200), Color(255,255,255,255))
			end
			i = i + 1
		end

		if targets then
			draw.WordBox(4, xPos, ChatBoxPosY + i*24, "Targets: " .. targets, "UiBold", Color(255,125,0,200), Color(255,255,255,255))
		end
		if DidMakeShorter then
			draw.WordBox(4, xPos, ChatBoxPosY + i*24, "...", "UiBold", Color(0,0,0,200), Color(255,255,255,255))
		end
	end)
end)

hook.Add("FinishChat", "FAdmin_Chat_autocomplete", function() hook.Remove("HUDPaint", "FAdmin_Chat_autocomplete") end)

local i = 1
hook.Add("OnChatTab", "FAdmin_Chat_autocomplete", function(text)
	if not FAdmin.GlobalSetting.FAdmin then return end
	if #Options > 0 and not string.find(text, " ") then
		return string.sub(Options[1], 1, string.find(Options[1], " "))
	elseif #Options > 0 and string.find(text, " ") then
		i = i + 1
		if i > #player.GetAll() then i = 1 end

		return string.sub(Options[1], 1, string.find(Options[1], " "))..string.sub(player.GetAll()[i]:Nick(), 1, string.find(player.GetAll()[i]:Nick(), " "))
	end
end)