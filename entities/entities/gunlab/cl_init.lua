include("shared.lua");

function ENT:Draw()
	self:DrawModel();

	local Pos = self:GetPos();
	local Ang = self:GetAngles();

	local owner = self:Getowning_ent();
	owner = (IsValid(owner) and owner:Nick()) or fprp.getPhrase("unknown");

	surface.SetFont("HUDNumber5");
	local text = fprp.getPhrase("gun_lab");
	local text2 = fprp.getPhrase("priceTag", fprp.formatshekel(self:Getprice()), "");
	local TextWidth = surface.GetTextSize(text);
	local TextWidth2 = surface.GetTextSize(text2);

	Ang:RotateAroundAxis(Ang:Forward(), 90);
	local TextAng = Ang

	TextAng:RotateAroundAxis(TextAng:Right(), CurTime() * -180);

	cam.Start3D2D(Pos + Ang:Right() * -30, TextAng, 0.2);
		draw.WordBox(2, -TextWidth*0.5 + 5, -30, text, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255));
		draw.WordBox(2, -TextWidth2*0.5 + 5, 18, text2, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255));
	cam.End3D2D();
end