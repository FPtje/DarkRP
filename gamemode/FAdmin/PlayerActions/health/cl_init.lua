FAdmin.StartHooks["Health"] = function()
	FAdmin.Access.AddPrivilege("SetHealth", 2)
	FAdmin.Commands.AddCommand("hp", nil, "<Player>", "<health>")
	FAdmin.Commands.AddCommand("SetHealth", nil, "[Player]", "<health>")

	FAdmin.ScoreBoard.Player:AddActionButton("Set health", "gui/silkicons/heart", Color(255, 130, 0, 255),
	function(ply) return FAdmin.Access.PlayerHasPrivilege(LocalPlayer(), "SetHealth", ply) end,
	function(ply, button)
		--Do nothing when the button has been clicked
	end,
	function(ply, button) -- Create the Wang when the mouse is pressed
		button.OnMousePressed = function()
			local Wang = vgui.Create("DNumberWang")
			Wang:SetDecimals(0)
			Wang:SetMinMax(0, 10000)
			Wang:SetValue(ply:Health())
			Wang:SetPos(gui.MouseX() - 55, gui.MouseY() - 5)
			Wang:StartWang()
			//RegisterDermaMenuForClose(Wang)


			function Wang:OnMouseReleased()
				if self.Dragging then
					RunConsoleCommand("_fadmin", "SetHealth", ply:UserID(), math.floor(self:GetFloatValue()))
					self:EndWang()
					self:Remove()
				end
			end
		end
	end)
end