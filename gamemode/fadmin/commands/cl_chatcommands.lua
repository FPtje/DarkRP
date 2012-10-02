local prefix = "/"

local Options = {}
hook.Add("ChatTextChanged", "FAdmin_Chat_autocomplete", function(text)
	if not FAdmin.GlobalSetting.FAdmin then return end
	if string.sub(text, 1, 1) == prefix then
		Options = {}
		
		local TExplode = string.Explode(" ", string.sub(text, 2))
		if not TExplode[1] then return end
		local Command = string.lower(TExplode[1])
		local Args = table.Copy(TExplode)
		Args[1] = nil
		Args = table.ClearKeys(Args)
		
		--if #Args == 0 then
			for k,v in pairs(FAdmin.Commands.List) do
				if string.find(string.lower(k), Command, 1, true) == 1 then
					local ExtraArgs = ""
					if table.Count(v.ExtraArgs) > 0 then
						ExtraArgs = "        " .. table.concat(v.ExtraArgs, "    ")
					end
					table.insert(Options, "/"..k.. ExtraArgs)
				end
			end
		--end
		
		local ChatBoxPosX, ChatBoxPosY = chat.GetChatBoxPos()
		local DidMakeShorter = false
		table.sort(Options)
		for k,v in SortedPairs(Options) do
			local Pos = ChatBoxPosY + 260 + (k)*20
			if Pos > ScrH() then
				Options[k] = nil
				DidMakeShorter = true
			end
		end
		if DidMakeShorter then Options[#Options] = "..." end
		
		hook.Add("HUDPaint", "FAdmin_Chat_autocomplete", function()
			for k,v in SortedPairs(Options) do
				draw.WordBox(4, ChatBoxPosX + 20, ChatBoxPosY + 260 + (k-1)*20, v, "UiBold", Color(0,0,0,200), Color(255,255,255,255))
			end
		end)
	end
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