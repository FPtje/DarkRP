include("shared.lua")

function SWEP:DrawHUD()
	if LocalPlayer():GetFOV() < 90 then
		--Width hairs
		draw.RoundedBox(1, ScrW() / 2 - 54, ScrH() / 2, 50, 1, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 + 4, ScrH() / 2, 50, 1, Color(0,0,0,255))

		draw.RoundedBox(1, ScrW() / 2, ScrH() / 2 - 54, 1, 50, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2, ScrH() / 2 + 4, 1, 50, Color(0,0,0,255))

		draw.RoundedBox(1, ScrW() / 2 - 44, ScrH() / 2 - 5, 1, 11, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 - 34, ScrH() / 2 - 5, 1, 11, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 - 24, ScrH() / 2 - 5, 1, 11, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 - 14, ScrH() / 2 - 5, 1, 11, Color(0,0,0,255))

		draw.RoundedBox(1, ScrW() / 2 + 44, ScrH() / 2 - 5, 1, 11, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 + 34, ScrH() / 2 - 5, 1, 11, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 + 24, ScrH() / 2 - 5, 1, 11, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 + 14, ScrH() / 2 - 5, 1, 11, Color(0,0,0,255))

		draw.RoundedBox(1, ScrW() / 2 - 5, ScrH() / 2 - 44, 11, 1, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 - 5, ScrH() / 2 - 34, 11, 1, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 - 5, ScrH() / 2 - 24, 11, 1, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 - 5, ScrH() / 2 - 14, 11, 1, Color(0,0,0,255))

		draw.RoundedBox(1, ScrW() / 2 - 5, ScrH() / 2 + 44, 11, 1, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 - 5, ScrH() / 2 + 34, 11, 1, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 - 5, ScrH() / 2 + 24, 11, 1, Color(0,0,0,255))
		draw.RoundedBox(1, ScrW() / 2 - 5, ScrH() / 2 + 14, 11, 1, Color(0,0,0,255))
	end
end