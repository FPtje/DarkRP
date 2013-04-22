include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	if self.dt.amount == 1 then return end

	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	local text = "Amount: " .. self.dt.amount

	surface.SetFont("HUDNumber5")
	local TextWidth = surface.GetTextSize(text)

	Ang:RotateAroundAxis(Ang:Forward(), 90)

	cam.Start3D2D(Pos + Ang:Up(), Ang, 0.11)
		draw.WordBox(2, 0, -40, text, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()

	Ang:RotateAroundAxis(Ang:Right(), 180)

	cam.Start3D2D(Pos + Ang:Up() * 3, Ang, 0.11)
		draw.WordBox(2, -TextWidth, -40, text, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
end

/*---------------------------------------------------------------------------
Create a shipment from a spawned_weapon
---------------------------------------------------------------------------*/
properties.Add("createShipment",
{
	MenuLabel	=	"Create a shipment",
	Order		=	2002,
	MenuIcon	=	"icon16/add.png",

	Filter		=	function(self, ent, ply)
						if not IsValid(ent) then return false end
						return ent:GetClass() == "spawned_weapon"
					end,

	Action		=	function(self, ent)
						if not IsValid(ent) then return end
						RunConsoleCommand("darkrp", "/makeshipment", ent:EntIndex())
					end
})