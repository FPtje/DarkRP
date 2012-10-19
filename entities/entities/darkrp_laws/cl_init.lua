
include("shared.lua")

-- These are the default laws, they're unchangeable in-game.
local Laws = {
	"Do not attack other citizens except in self-defence.",
	"Do not steal or break in to peoples homes.",
	"Money printers/drugs are illegal."
}

function ENT:Draw()
	
	self:DrawModel()
	
	local DrawPos = self:LocalToWorld( Vector( 1, -111, 58 ) )
	
	local DrawAngles = self:GetAngles()
	DrawAngles:RotateAroundAxis( self:GetAngles():Forward(), 90 )
	DrawAngles:RotateAroundAxis( self:GetAngles():Up(), 90 )

	cam.Start3D2D( DrawPos, DrawAngles, 0.4 )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, 0, 558, 290 )
		
		draw.RoundedBox( 4, 0, 0, 558, 30, Color( 0, 0, 70, 200 ) )
		draw.DrawText("LAWS OF THE LAND", "TargetID", 279, 5, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER )
		
		local y = 35
		for i, law in pairs( Laws ) do
		
			draw.DrawText( i .. ": " .. law, "TargetID", 5, y, Color( 255, 255, 255, 255 ) )
			
			y = y + 20
			
		end
	
	cam.End3D2D()

end

local function AddLaw( um )

	table.insert( Laws, um:ReadString() )

end
usermessage.Hook("DRP_AddLaw", AddLaw )

local function RemoveLaw( um )

	table.remove( Laws, um:ReadChar() )
	
end
usermessage.Hook("DRP_RemoveLaw", RemoveLaw )