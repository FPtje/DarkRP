-- Skin for DarkRP gui's
local skin = {}

skin.PrintName          = "DarkRP"
skin.Author             = "FPtje Falco"
skin.DermaVersion       = 1


-- Collapsible catagory header
skin.colCollapsibleCategory = Color(GetConVarNumber("salary11"), GetConVarNumber("salary12"), GetConVarNumber("salary13"), GetConVarNumber("salary14"))
skin.fontCategoryHeader = "TargetID"

-- tab
skin.colTab = Color(0, 0, 0, 50)
skin.colTabInactive = Color(skin.colTab.r + 70, skin.colTab.g + 70, skin.colTab.b + 70, skin.colTab.a)
skin.colPropertySheet = skin.colTab


function skin:PaintFrame(frame)
	local w, h = frame:GetSize()
	local color = Color(GetConVarNumber("background1"), GetConVarNumber("background2"), GetConVarNumber("background3"), GetConVarNumber("background4"))//self.bg_color
	draw.RoundedBox(8, 0, 0, w, h, color)
	
	surface.SetDrawColor(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
	surface.DrawLine(0, 20, w, 20)
end


function skin:PaintButton(button)
	local w, h = button:GetSize()
	local x, y = 0,0
	
	local bordersize = 8
	if w <= 32 or h <= 32 then bordersize = 4 end -- This is so small buttons don't look messed up
	
	if button.m_bBackground then
		local color1 = Color(GetConVarNumber("Healthbackground1"), GetConVarNumber("Healthbackground2"), GetConVarNumber("Healthbackground3"), GetConVarNumber("Healthbackground4"))
		local color2 = Color(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
		
		if button:GetDisabled() then
			color2 = Color(80, 80, 80, 255)
		elseif button.Depressed or button:GetSelected() then
			x, y = w*0.15, h*0.15
			w = w *0.7
			h = h * 0.7
		elseif button.Hovered then
			//color1 = Color(color1.r + 40, color1.g + 40, color1.b + 40, color1.a + 40)
			color2 = Color(color2.r + 40, color2.g + 40, color2.b + 40, color2.a + 40)
		end
		draw.RoundedBox(bordersize, x, y, w, h, color1)
		draw.RoundedBox(bordersize, x + 2, y + 2, w-4, h-4, color2)
		
	end
end

function skin:PaintOverButton( panel ) end


function skin:PaintVScrollBar(scrollbar)
	local color = Color(GetConVarNumber("Healthbackground1"), GetConVarNumber("Healthbackground2"), GetConVarNumber("Healthbackground3"), GetConVarNumber("Healthbackground4"))
	local w, h = scrollbar:GetSize()
	draw.RoundedBox(8, 0, 0, w, h, color)
end

function skin:PaintScrollBarGrip(scrollbar)
	local color = Color(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
	local w, h = scrollbar:GetSize()
	draw.RoundedBox(8, 0, 0, w, h, color)
end

function skin:PaintPanelList(panellist)
	if panellist.m_bBackground then
		local w, h = panellist:GetSize()
		local color = Color(GetConVarNumber("Healthbackground1"), GetConVarNumber("Healthbackground2"), GetConVarNumber("Healthbackground3"), GetConVarNumber("Healthbackground4"))
		draw.RoundedBox( 4, 0, 0, w, h, color)
	end
end

derma.DefineSkin("DarkRP", "The official skin for DarkRP", skin)