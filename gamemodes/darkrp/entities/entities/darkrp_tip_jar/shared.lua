ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Tip Jar"
ENT.Author = "FPtje"
ENT.Spawnable = false
ENT.IsTipjar = true

function ENT:initVars()
    self.model = "models/props_lab/jar01a.mdl"
    self.damage = 100
    self.callOnRemoveId = "tipjar_activedonation_" .. self:EntIndex() .. "_"

    self.activeDonations = {}
    self.madeDonations = {}

    self.PlayerUse = true
end

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
end

function ENT:UpdateActiveDonation(ply, amount)
    local old = self.activeDonations[ply]
    self.activeDonations[ply] = amount

    self:PruneActiveDonations()

    ply:CallOnRemove(self.callOnRemoveId .. ply:UserID(), function()
        if not IsValid(self) then return end

        self:ExitActiveDonation(ply)
    end)

    hook.Call("tipjarUpdateActiveDonation", DarkRP.hooks, self, ply, amount, old)
end

function ENT:ExitActiveDonation(ply)
    local old = self.activeDonations[ply]

    self.activeDonations[ply] = nil

    self:PruneActiveDonations()
    hook.Call("tipjarExitActiveDonation", DarkRP.hooks, self, ply, old)

    self:RemoveCallOnRemove(self.callOnRemoveId .. ply:UserID())
end

function ENT:ClearActiveDonations()
    table.Empty(self.activeDonations)
    hook.Call("tipjarClearActiveDonation", DarkRP.hooks, self)
end

function ENT:PruneActiveDonations()
    for ply, _ in pairs(self.activeDonations) do
        if not IsValid(ply) then self.activeDonations[ply] = nil end
    end
end

function ENT:AddDonation(name, amount)
    local lastDonation = self.madeDonations[#self.madeDonations]

    if lastDonation and lastDonation.name == name then
        lastDonation.amount = lastDonation.amount + amount
    else
        table.insert(self.madeDonations, {
            name = name,
            amount = amount,
        })
   end

   -- Enforce maximum of 100 donations
   while #self.madeDonations > 100 do
       table.remove(self.madeDonations, 1)
   end
end

function ENT:ClearDonations()
    table.Empty(self.madeDonations)
end
