ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spawned Money"
ENT.Author = "FPtje"
ENT.Spawnable = false
ENT.IsSpawnedMoney = true

function ENT:SetupDataTables()
    self:NetworkVar("Int",0,"amount")
end

DarkRP.hookStub{
    name = "playerPickedUpMoney",
    description = "Called when a player picked up money.",
    parameters = {
        {
            name = "player",
            description = "The player who picked up the money.",
            type = "Player"
        },
        {
            name = "amount",
            description = "The amount of money picked up.",
            type = "number"
        }
    },
    returns = {
    },
    realm = "Server"
}
