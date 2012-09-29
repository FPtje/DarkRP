ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spawned Money"
ENT.Author = "FPtje"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:DTVar("Int",0,"amount")
end

local ENTITY = FindMetaTable("Entity")
function ENTITY:IsMoneyBag()
	return self:GetClass() == "spawned_money"
end