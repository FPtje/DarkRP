include("shared.lua")

-- I love the garry's mod wiki!
-- Credits to whoever made this function!
local function WorldToScreen(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos
    vWorldPos:Rotate(Angle(0,-aRot.y,0))
    vWorldPos:Rotate(Angle(-aRot.p,0,0))
    vWorldPos:Rotate(Angle(0,0,-aRot.r))
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale
end

function ENT:LoadPage()
	local Page = GetConVarString("_FAdmin_MOTDPage")
	if string.lower(string.sub(Page, -4)) == ".txt" and string.lower(string.sub(Page, 1, 5)) == "data/" then -- If it's a text file somewhere in data...
		Page = string.sub(Page, 6)
		self.HTML:SetHTML(file.Read(Page, "DATA") or "")
	else
		self.HTML:OpenURL(Page)
	end
end

function ENT:Initialize()
	self.Disabled = true
	self.LastDrawn = CurTime()
	self.HTML = self.HTMLControl or vgui.Create("HTML")
	self.HTML:SetPaintedManually(true)
	self.HTML:SetPos(-512, -256)
	self.HTML:SetSize(ScrW() / 2, ScrH() / 2)
	self:LoadPage()

	self.HTML:SetVisible(true)
end

function ENT:Think()
	if not self.HTML or self.Disabled or self.HTMLCloseButton then
		self.HTMLMat = nil
	else
		self.HTMLMat = self.HTML:GetHTMLMaterial()
	end
	self:NextThink(CurTime() + 0.1)
end


local gripTexture = surface.GetTextureID("sprites/grip")
local ArrowTexture = surface.GetTextureID("gui/arrow")
function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	if pos:Distance(LocalPlayer():GetShootPos()) > 300 then return end

	if CurTime() - self.LastDrawn > 0.5 then
		self.Disabled = true --Disable it again when you stop looking at it
	end

	self.LastDrawn = CurTime()
	local IsAdmin = LocalPlayer():IsAdmin()
	local HasPhysgun = (IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun")

	surface.SetFont("TargetID")
	local TextPosX = surface.GetTextSize("Physgun/use the button to see the MOTD!")*(-0.5)

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), -90)
	ang:RotateAroundAxis(ang:Up(), 90)


	local posX, posY = WorldToScreen(LocalPlayer():GetEyeTrace().HitPos, self:GetPos() + ang:Up()*3, 0.25, ang)
	render.SuppressEngineLighting(true)
	cam.Start3D2D(self:GetPos() + ang:Up()*3, ang, 0.25)

		if self.Disabled then
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(-512, 256, 1024, -512)
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos( TextPosX, 0 )
			surface.DrawText("Physgun/use the button to see the MOTD!")

			draw.WordBox(4, -16, 24, "Click!", "default", Color(100, 100, 100, 255), Color(255, 255, 255, 255))

			surface.SetDrawColor(255, 255, 255, 255)
			if IsAdmin and HasPhysgun then
				surface.SetTexture(gripTexture)
				surface.DrawTexturedRect(-10, 240, 16, 16)
			end
			if (HasPhysgun and LocalPlayer():KeyDown(IN_ATTACK)) or LocalPlayer():KeyDown(IN_USE) then

				posX, posY = math.Clamp(posX, -506, 506), math.Clamp(posY, -250, 250)
				surface.SetTexture(ArrowTexture)
				surface.DrawTexturedRectRotated(posX + 5, posY + 5, 16, 16, 45)

				-- Clicking button
				if posX > -16 and posX < 16 and posY > 24 and posY < 48 then
					self:LoadPage()
					self.Disabled = false
					self.CanClickAgain = CurTime() + 1
				end
			end
		elseif not self.HTMLMat then
			self.HTML:SetPaintedManually(false)

			timer.Simple(0, function() -- Fix HTML material
				self.HTML:SetPaintedManually(true)
			end)
		else
			surface.SetMaterial(self.HTMLMat)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(-512, -256, 1520, 780)
		end

	cam.End3D2D()
	render.SuppressEngineLighting(false)
	if self.HTMLCloseButton then return end

	--Drawing the actual HTML panel:

	if ((HasPhysgun and LocalPlayer():KeyDown(IN_ATTACK)) or LocalPlayer():KeyDown(IN_USE))
		and posX > -500 and posX < 500 and posY < 250 and posY > -250 then
		if not self.Disabled and self.HTML and self.HTML:IsValid() and self.CanClickAgain and CurTime() > self.CanClickAgain then
			self.CanClickAgain = CurTime() + 1
			self.HTML:SetPaintedManually(false)
			self.HTML:SetPos(0, 100)
			self.HTML:SetSize(ScrW(), ScrH() - 100)
			gui.EnableScreenClicker(true)
			//gui.SetMousePos(posX/1024*ScrW(), posY/512*(ScrH() - 100) + 100)
			self.HTMLCloseButton = self.HTMLCloseButton or vgui.Create("DButton")
			self.HTMLCloseButton:SetPos(ScrW() - 100, 0)
			self.HTMLCloseButton:SetSize(100, 100)
			self.HTMLCloseButton:SetText("X")
			self.HTMLCloseButton:SetVisible(true)
			self.HTML:SetVisible(true)
			self.HTML:RequestFocus()
			self.HTML:SetKeyBoardInputEnabled(true)
			self.HTML:MakePopup()

			function self.HTMLCloseButton.DoClick() -- Revert to drawing on the prop
				self.HTML:SetPos(-512, -256)
				self.HTML:SetSize(1024, 512)
				self.HTML:SetPaintedManually(true)
				self.HTML:SetKeyBoardInputEnabled(false)
				self.HTML:SetVisible(false)
				gui.EnableScreenClicker(false)
				self.HTMLCloseButton:Remove()
				self.HTMLCloseButton = nil
			end
		end
	end
end