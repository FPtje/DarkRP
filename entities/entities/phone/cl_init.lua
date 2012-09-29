
include('shared.lua')

/*---------------------------------------------------------
   Name: DrawTranslucent
   Desc: Draw translucent
---------------------------------------------------------*/
function ENT:DrawTranslucent()
	self:DrawEntityOutline( 1.2 + math.sin( CurTime() * 60 ) * 0.05 )
	self:Draw()
end

function ENT:Draw()
	if not self.dt.IsBeingHeld and LocalPlayer():GetPos():Distance(self:GetPos()) < 200 then
		self:DrawEntityOutline( 1.2 + math.sin( CurTime() * 60 ) * 0.1 )
		AddWorldTip( self:EntIndex(), "YOU ARE BEING CALLED!\nUSE ME TO PICK UP THE PHONE!", 0.5, self:GetPos(), self  )
	end
	self:DrawModel()
end