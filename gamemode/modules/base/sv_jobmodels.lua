util.AddNetworkString("DarkRP_preferredjobmodels")
util.AddNetworkString("DarkRP_preferredjobmodel")

local preferredJobModels = {}
local plyMeta = FindMetaTable("Player")

local received = {}
net.Receive("DarkRP_preferredjobmodels", function(len, ply)
    preferredJobModels[ply] = {}

    for i in pairs(RPExtraTeams) do
        if net.ReadBit() == 0 then continue end

        preferredJobModels[ply][i] = net.ReadString()
    end

    if not received[ply] and preferredJobModels[ply][ply:Team()] then
        gamemode.Call("PlayerSetModel", ply)
    end

    received[ply] = true
end)

net.Receive("DarkRP_preferredjobmodel", function(len, ply)
    local teamNr = net.ReadUInt(8)
    local model = net.ReadString()

    if not RPExtraTeams[teamNr] then return end

    preferredJobModels[ply] = preferredJobModels[ply] or {}
    preferredJobModels[ply][teamNr] = model
end)

function plyMeta:getPreferredModel(TeamNr)
    preferredJobModels[self] = preferredJobModels[self] or {}

    return preferredJobModels[self][TeamNr]
end
