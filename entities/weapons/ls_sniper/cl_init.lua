include("shared.lua")
local deltas = {-44, -34, -24, -14, 44, 34, 24, 14}
function SWEP:DrawHUD()
    if self:GetScopeLevel() < 2 then return end

    --Width hairs
    draw.RoundedBox(1, ScrW() / 2 - 54, ScrH() / 2, 50, 1, color_black)
    draw.RoundedBox(1, ScrW() / 2 + 4, ScrH() / 2, 50, 1, color_black)

    draw.RoundedBox(1, ScrW() / 2, ScrH() / 2 - 54, 1, 50, color_black)
    draw.RoundedBox(1, ScrW() / 2, ScrH() / 2 + 4, 1, 50, color_black)

    for _,v in pairs(deltas) do
        draw.RoundedBox(1, ScrW() / 2 + v, ScrH() / 2 - 5, 1, 11, color_black)
        draw.RoundedBox(1, ScrW() / 2 - 5, ScrH() / 2 + v, 11, 1, color_black)
    end
end
