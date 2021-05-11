include("shared.lua")

local color_red = Color(140, 0, 0, 100)
local color_white = Color(255, 255, 255)

function ENT:Draw()
    local ret = hook.Call("onDrawSpawnedWeapon", nil, self)
    if ret ~= nil then return end
    self:DrawModel()

    local amount = self:Getamount()
    if amount == 1 then return end

    local Pos = self:GetPos()
    local Ang = self:GetAngles()
    local text = DarkRP.getPhrase("amount") .. amount

    surface.SetFont("HUDNumber5")
    local TextWidth = surface.GetTextSize(text)

    Ang:RotateAroundAxis(Ang:Forward(), 90)

    cam.Start3D2D(Pos + Ang:Up(), Ang, 0.11)
        draw.WordBox(2, 0, -40, text, "HUDNumber5", color_red, color_white)
    cam.End3D2D()

    Ang:RotateAroundAxis(Ang:Right(), 180)

    cam.Start3D2D(Pos + Ang:Up() * 3, Ang, 0.11)
        draw.WordBox(2, -TextWidth, -40, text, "HUDNumber5", color_red, color_white)
    cam.End3D2D()
end

--[[---------------------------------------------------------------------------
Create a shipment from a spawned_weapon
---------------------------------------------------------------------------]]
properties.Add("createShipment",
    {
        MenuLabel   =   DarkRP.getPhrase("createshipment"),
        Order       =   2003,
        MenuIcon    =   "icon16/add.png",

        Filter      =   function(self, ent, ply)
                            if not IsValid(ent) then return false end
                            return ent.IsSpawnedWeapon
                        end,

        Action      =   function(self, ent)
                            if not IsValid(ent) then return end
                            RunConsoleCommand("darkrp", "makeshipment", ent:EntIndex())
                        end
    }
)

--[[---------------------------------------------------------------------------
Interface
---------------------------------------------------------------------------]]
DarkRP.hookStub{
    name = "onDrawSpawnedWeapon",
    description = "Draw spawned weapons.",
    realm = "Client",
    parameters = {
        {
            name = "weapon",
            description = "The weapon to perform drawing operations on.",
            type = "Player"
        }
    },
    returns = {
        {
            name = "value",
            description = "Return a value to completely override drawing",
            type = "any"
        }
    }
}
