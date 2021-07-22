util.AddNetworkString("DarkRP_TipJarUI")
util.AddNetworkString("DarkRP_TipJarDonate")
util.AddNetworkString("DarkRP_TipJarUpdate")
util.AddNetworkString("DarkRP_TipJarExit")
util.AddNetworkString("DarkRP_TipJarDonatedList")


net.Receive("DarkRP_TipJarDonate", function(_, ply)
    local tipjar = net.ReadEntity()
    local amount = net.ReadUInt(32)

    if not IsValid(tipjar) then return end
    if not tipjar.IsTipjar then return end

    local owner = tipjar:Getowning_ent()
    if not IsValid(owner) then return end
    if owner == ply then return end

    ply.DarkRPLastTip = ply.DarkRPLastTip or -1

    if ply.DarkRPLastTip > CurTime() - 0.1 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("wait_with_that"))
        return
    end

    if not ply:canAfford(amount) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", amount))
        return
    end

    if tipjar:GetPos():DistToSqr(ply:GetPos()) > 100 * 100 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("distance_too_big"))
        return
    end

    DarkRP.payPlayer(ply, owner, amount)

    tipjar:AddDonation(ply:Nick(), amount)

    tipjar:EmitSound("ambient/alarms/warningbell1.wav")

    local strAmount = DarkRP.formatMoney(amount)

    DarkRP.notify(ply,   3, 4, DarkRP.getPhrase("you_donated", strAmount,  owner:Nick()))
    DarkRP.notify(owner, 3, 4, DarkRP.getPhrase("has_donated", ply:Nick(), strAmount))

    net.Start("DarkRP_TipJarDonate")
        net.WriteEntity(tipjar)
        net.WriteEntity(ply)
        net.WriteUInt(amount, 32)
    net.Broadcast()

    ply.DarkRPLastTip = CurTime()
end)

net.Receive("DarkRP_TipJarUpdate", function(_, ply)
    local tipjar = net.ReadEntity()
    local amount = net.ReadUInt(32)

    if not IsValid(tipjar) then return end
    if not tipjar.IsTipjar then return end

    -- Larger margin of distance, to prevent false positives
    if tipjar:GetPos():DistToSqr(ply:GetPos()) > 150 * 150 then
        return
    end

    tipjar:UpdateActiveDonation(ply, amount)
end)

-- Send a tipjar's donation data to a single player
local function sendJarData(tipjar, ply)
    if not table.IsEmpty(tipjar.activeDonations) then
        net.Start("DarkRP_TipJarUpdate")
            net.WriteEntity(tipjar)

            for p, amnt in pairs(tipjar.activeDonations) do
                net.WriteEntity(p)
                net.WriteUInt(amnt, 32)
            end
        net.Send(ply)
    end

    if not table.IsEmpty(tipjar.madeDonations) then
        net.Start("DarkRP_TipJarDonatedList")
            net.WriteEntity(tipjar)
            net.WriteUInt(#tipjar.madeDonations, 8)

            for _, donation in ipairs(tipjar.madeDonations) do
                net.WriteString(donation.name)
                net.WriteUInt(donation.amount, 32)
            end
        net.Send(ply)
    end
end

function DarkRP.hooks:tipjarUpdateActiveDonation(tipjar, ply, amount, old)
    -- Player is new to this jar, send all data
    if not old then
        sendJarData(tipjar, ply)
    end

    -- Tell the rest of the player's active donation
    local updateTargets = RecipientFilter()

    for p, _ in pairs(tipjar.activeDonations) do
        updateTargets:AddPlayer(p)
    end

    updateTargets:RemovePlayer(ply)

    net.Start("DarkRP_TipJarUpdate")
        net.WriteEntity(tipjar)
        net.WriteEntity(ply)
        net.WriteUInt(amount, 32)
    net.Send(updateTargets)
end

net.Receive("DarkRP_TipJarExit", function(_, ply)
    local tipjar = net.ReadEntity()

    if not IsValid(tipjar) then return end
    if not tipjar.IsTipjar then return end

    tipjar:ExitActiveDonation(ply)
end)

function DarkRP.hooks:tipjarExitActiveDonation(tipjar, ply, old)
    local updateTargets = RecipientFilter()

    for p, _ in pairs(tipjar.activeDonations) do
        updateTargets:AddPlayer(p)
    end

    net.Start("DarkRP_TipJarExit")
        net.WriteEntity(tipjar)
        net.WriteEntity(ply)
    net.Send(updateTargets)
end
