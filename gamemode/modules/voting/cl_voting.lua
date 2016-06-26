local tbl = {}
local tbl2 = {}
local next_keydown

local surface = surface
local draw = draw

usermessage.Hook("DoVote", function(msg)
	local question = msg:ReadString()
	local voteid = msg:ReadShort()
	local timeleft = msg:ReadFloat()
	
	local last = CurTime()
		
	LocalPlayer():EmitSound('Town.d1_town_02_elevbell1',100,100)
		
	local menu = vgui.Create("DPanel")
	menu:SetSize(380,54-15)
	menu:SetPos(-380,10+#tbl*(60-15))
	menu:MoveTo(10,10+#tbl*(60-15),0.2)
	menu.Close = function()
		if !menu.cls then
			menu.cls = true
			timer.Simple(0.2,function()
				menu:Remove()
			end)
			if #tbl>1 then
				local i=0
				local id = 0
				for v,k in pairs(tbl) do
					if k!=menu then
						i=i+1
						k:MoveTo(10,i*(60-15)-50+15,0.2)
					else
						menu:MoveTo(-380,v*(60-15)-50+15,0.2)
						id=v
					end
				end
				table.remove(tbl,id)
				tbl[1].fff = true
			else
				menu:MoveTo(-380,10,0.2)
				table.remove(tbl,1)
			end
		end
	end
	menu.Paint = function(self,w,h)
		local time = timeleft-CurTime()+last
		if time<=0 then menu:Close() end
		surface.SetDrawColor(30,30,30,220)
		surface.DrawRect(0,0,w,h)
		
		surface.SetDrawColor(0,0,0)
		surface.DrawOutlinedRect(0,0,w,h)
		
		surface.SetDrawColor(127,160,255)
		surface.DrawRect(0,0,w,5)
		
		surface.SetDrawColor(50,255,0)
		surface.DrawRect(0,0,time/timeleft*w,5)
		
	end
	menu.Think = function()
		if menu.fff then
			local f7 = input.IsKeyDown(KEY_F7)
			local f8 = input.IsKeyDown(KEY_F8)
			if f7 and !next_keydown then
				LocalPlayer():ConCommand("vote " .. voteid .. " yea\n")	
				menu:Close()
				next_keydown=true
			elseif f8 and !next_keydown  then
				LocalPlayer():ConCommand("vote " .. voteid .. " nay\n")
				menu:Close()
				next_keydown=true
			end
			if !f7 and !f8 then
				next_keydown=false	
			end
		end
	end
	
	local label = vgui.Create("DLabel",menu)
	label:SetPos(5, 25-15)
	label:SetText(question)
	label:SizeToContents()
	
	local no = vgui.Create("DButton",menu)
	no:SetSize(42,20)
	no:SetPos(333,25-15)
	no:SetText("")
	no.Paint = function(self,w,h)
		surface.SetDrawColor(255,30,30)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText(menu.fff and "No(F8)" or "Нет","DermaDefault",w/2,h/2,Color(0,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		
		surface.SetDrawColor(0,0,0)
		surface.DrawOutlinedRect(0,0,w,h)
	end
	no.DoClick = function()
		LocalPlayer():ConCommand("vote " .. voteid .. " nay\n")
		menu:Close()
	end
	
	local yes = vgui.Create("DButton",menu)
	yes:SetSize(42,20)
	yes:SetPos(286,25-15)
	yes:SetText("")
	yes.Paint = function(self,w,h)
		surface.SetDrawColor(30,255,30)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText(menu.fff and "Yes(F7)" or "Да","DermaDefault",w/2,h/2,Color(0,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		
		surface.SetDrawColor(0,0,0)
		surface.DrawOutlinedRect(0,0,w,h)
	end
	yes.DoClick = function()
		LocalPlayer():ConCommand("vote " .. voteid .. " yea\n")
		menu:Close()
	end
	
	if #tbl==0 then menu.fff=true end
	table.insert(tbl,menu)
	tbl2[voteid]=menu
	
end)

usermessage.Hook("KillVoteVGUI",function(msg)
	local id = msg:ReadShort()
	if IsValid(tbl2[id]) then
		tbl2[id]:Close()
	end
end)


local qtbl = {}
local qtbl2 = {}

usermessage.Hook("DoQuestion", function(msg)
	local question = msg:ReadString()
	local quesid = msg:ReadString()
	local timeleft = msg:ReadFloat()
	
	LocalPlayer():EmitSound('Town.d1_town_02_elevbell1',100,100)
	
	local last = CurTime()
		
	local menu = vgui.Create("DPanel")
	menu:SetSize(380,70-15)
	menu:SetPos(ScrW()+380,10+#qtbl*(80-15))
	menu:MoveTo(ScrW()-390,10+#qtbl*(80-15),0.2)
	menu.Close = function()
		if !menu.cls then
			menu.cls = true
			timer.Simple(0.2,function()
				menu:Remove()
			end)
			if #qtbl>1 then
				local i=0
				local id = 0
				for v,k in pairs(qtbl) do
					if k!=menu then
						i=i+1
						k:MoveTo(ScrW()-390,i*(80-15)-70+15,0.2)
					else
						menu:MoveTo(ScrW()+380,v*(80-15)-70+15,0.2)
						id=v
					end
				end
				table.remove(qtbl,id)
			else
				menu:MoveTo(ScrW()+380,10,0.2)
				table.remove(qtbl,1)
			end
		end
	end
	menu.Paint = function(self,w,h)
		local time = timeleft-CurTime()+last
		if time<=0 then menu:Close() end
		surface.SetDrawColor(30,30,30,220)
		surface.DrawRect(0,0,w,h)
		
		surface.SetDrawColor(0,0,0)
		surface.DrawOutlinedRect(0,0,w,h)
		
		surface.SetDrawColor(127,160,255)
		surface.DrawRect(0,0,w,5)
		
		surface.SetDrawColor(50,255,0)
		surface.DrawRect(0,0,time/timeleft*w,5)
		
	end
	
	local label = vgui.Create("DLabel",menu)
	label:SetPos(5, 24-15)
	label:SetText(question)
	label:SizeToContents()
	
	local no = vgui.Create("DButton",menu)
	no:SetSize(42,20)
	no:SetPos(328,40-15)
	no:SetText("")
	no.Paint = function(self,w,h)
		surface.SetDrawColor(255,30,30)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText("No","DermaDefault",w/2,h/2,Color(0,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		
		surface.SetDrawColor(0,0,0)
		surface.DrawOutlinedRect(0,0,w,h)
	end
	no.DoClick = function()
		LocalPlayer():ConCommand("ans " .. quesid .. " 2\n")
		menu:Close()
	end
	
	local yes = vgui.Create("DButton",menu)
	yes:SetSize(42,20)
	yes:SetPos(281,40-15)
	yes:SetText("")
	yes.Paint = function(self,w,h)
		surface.SetDrawColor(30,255,30)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText("Yes","DermaDefault",w/2,h/2,Color(0,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		
		surface.SetDrawColor(0,0,0)
		surface.DrawOutlinedRect(0,0,w,h)
	end
	yes.DoClick = function()
		LocalPlayer():ConCommand("ans " .. quesid .. " 1\n")
		menu:Close()
	end
	
	table.insert(qtbl,menu)
	qtbl2[quesid]=menu
	
end)

usermessage.Hook("KillQuestionVGUI",function(msg)
	local id = msg:ReadShort()
	if IsValid(qtbl2[id]) then
		qtbl2[id]:Close()
	end
end)
