--[[---------------------------------------------------------------------------
functions
---------------------------------------------------------------------------]]
local meta = FindMetaTable("Player")
function meta:addMoney(amount)
    if not amount then return false end
    local total = self:getDarkRPVar("money") + math.floor(amount)
    total = hook.Call("playerWalletChanged", GAMEMODE, self, amount, self:getDarkRPVar("money")) or total

    self:setDarkRPVar("money", total)

    if self.DarkRPUnInitialized then return end
    DarkRP.storeMoney(self, total)
end

function DarkRP.payPlayer(ply1, ply2, amount)
    if not IsValid(ply1) or not IsValid(ply2) then return end
    ply1:addMoney(-amount)
    ply2:addMoney(amount)
end

function meta:payDay()
    if not IsValid(self) then return end
    if not self:isArrested() then
        DarkRP.retrieveSalary(self, function(amount)
            amount = math.floor(amount or GAMEMODE.Config.normalsalary)
            local suppress, message, hookAmount = hook.Call("playerGetSalary", GAMEMODE, self, amount)
            amount = hookAmount or amount

            if amount == 0 or not amount then
                if not suppress then DarkRP.notify(self, 4, 4, message or DarkRP.getPhrase("payday_unemployed")) end
            else
                self:addMoney(amount)
                if not suppress then DarkRP.notify(self, 4, 4, message or DarkRP.getPhrase("payday_message", DarkRP.formatMoney(amount))) end
            end
        end)
    else
        DarkRP.notify(self, 4, 4, DarkRP.getPhrase("payday_missed"))
    end
end

function DarkRP.createMoneyBag(pos, amount)
    local moneybag = ents.Create(GAMEMODE.Config.MoneyClass)
    moneybag:SetPos(pos)
    moneybag:Setamount(math.Min(amount, 2147483647))
    moneybag:Spawn()
    moneybag:Activate()
    if GAMEMODE.Config.moneyRemoveTime and  GAMEMODE.Config.moneyRemoveTime ~= 0 then
        timer.Create("RemoveEnt" .. moneybag:EntIndex(), GAMEMODE.Config.moneyRemoveTime, 1, fn.Partial(SafeRemoveEntity, moneybag))
    end
    return moneybag
end

--[[---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------]]
local function GiveMoney(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end

    if not tonumber(args) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end
    local trace = ply:GetEyeTrace()

    if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():DistToSqr(ply:GetPos()) >= 22500 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("must_be_looking_at", "player"))
        return ""
    end

    local amount = math.floor(tonumber(args))

    if amount < 1 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ">=1"))
        return ""
    end

    if not ply:canAfford(amount) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

        return ""
    end

    local RP = RecipientFilter()
    RP:AddAllPlayers()

    umsg.Start("anim_giveitem", RP)
        umsg.Entity(ply)
    umsg.End()
    ply.anim_GivingItem = true

    timer.Simple(1.2, function()
        if not IsValid(ply) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/give", ""))
            return ""
        end

        if not ply:canAfford(amount) then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))
            return ""
        end

        local trace2 = ply:GetEyeTrace()
        if not IsValid(trace2.Entity) or not trace2.Entity:IsPlayer() or trace2.Entity:GetPos():DistToSqr(ply:GetPos()) >= 22500 then return end

        DarkRP.payPlayer(ply, trace2.Entity, amount)

        hook.Call("playerGaveMoney", nil, ply, trace2.Entity, amount)

        DarkRP.notify(trace2.Entity, 0, 4, DarkRP.getPhrase("has_given", ply:Nick(), DarkRP.formatMoney(amount)))
        DarkRP.notify(ply, 0, 4, DarkRP.getPhrase("you_gave", trace2.Entity:Nick(), DarkRP.formatMoney(amount)))
        DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") has given " .. DarkRP.formatMoney(amount) .. " to " .. trace2.Entity:Nick() .. " (" .. trace2.Entity:SteamID() .. ")")
    end)

    return ""
end
DarkRP.defineChatCommand("give", GiveMoney, 0.2)

local function DropMoney(ply, args)
    if args == "" then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end

    if not tonumber(args) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
        return ""
    end
    local amount = math.floor(tonumber(args))

    if amount < 1 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ">0"))
        return ""
    end

    if amount >= 2147483647 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "<2,147,483,647"))
        return ""
    end

    if not ply:canAfford(amount) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

        return ""
    end

    ply:addMoney(-amount)
    local RP = RecipientFilter()
    RP:AddAllPlayers()

    umsg.Start("anim_dropitem", RP)
        umsg.Entity(ply)
    umsg.End()
    ply.anim_DroppingItem = true

    timer.Simple(1, function()
        if not IsValid(ply) then return end

        local trace = {}
        trace.start = ply:EyePos()
        trace.endpos = trace.start + ply:GetAimVector() * 85
        trace.filter = ply

        local tr = util.TraceLine(trace)
        local moneybag = DarkRP.createMoneyBag(tr.HitPos, amount)
        hook.Call("playerDroppedMoney", nil, ply, amount, moneybag)
        DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") has dropped " .. DarkRP.formatMoney(amount))
    end)

    return ""
end
DarkRP.defineChatCommand("dropmoney", DropMoney, 0.3)
DarkRP.defineChatCommand("moneydrop", DropMoney, 0.3)

local function CreateCheque(ply, args)
    local recipient = DarkRP.findPlayer(args[1])
    local amount = tonumber(args[2]) or 0

    if not recipient then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "recipient (1)"))
        return ""
    end

    if amount <= 1 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", "amount (2)"))
        return ""
    end

    if not ply:canAfford(amount) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_afford", ""))

        return ""
    end

    if IsValid(ply) and IsValid(recipient) then
        ply:addMoney(-amount)
    end

    umsg.Start("anim_dropitem", RecipientFilter():AddAllPlayers())
        umsg.Entity(ply)
    umsg.End()
    ply.anim_DroppingItem = true

    timer.Simple(1, function()
        if IsValid(ply) and IsValid(recipient) then
            local trace = {}
            trace.start = ply:EyePos()
            trace.endpos = trace.start + ply:GetAimVector() * 85
            trace.filter = ply

            local tr = util.TraceLine(trace)
            local Cheque = ents.Create("darkrp_cheque")
            Cheque:SetPos(tr.HitPos)
            Cheque:Setowning_ent(ply)
            Cheque:Setrecipient(recipient)

            local min_amount = math.Min(amount, 2147483647)
            Cheque:Setamount(min_amount)
            Cheque:Spawn()
            hook.Call("playerDroppedCheque", nil, ply, recipient, min_amount, Cheque)
        else
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", "/cheque", ""))
        end
    end)
    return ""
end
DarkRP.defineChatCommand("cheque", CreateCheque, 0.3)
DarkRP.defineChatCommand("check", CreateCheque, 0.3) -- for those of you who can't spell

local function ccSetMoney(ply, args)
    if not tonumber(args[2]) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return
    end

    local target = DarkRP.findPlayer(args[1])

    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args[1])))
        return
    end

    local amount = math.floor(tonumber(args[2]))
    amount = hook.Call("playerWalletChanged", GAMEMODE, target, amount - target:getDarkRPVar("money"), target:getDarkRPVar("money")) or amount

    DarkRP.storeMoney(target, amount)
    target:setDarkRPVar("money", amount)

    DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("you_set_x_money", target:Nick(), DarkRP.formatMoney(amount), ""))

    DarkRP.notify(target, 0, 4, DarkRP.getPhrase("x_set_your_money", ply:EntIndex() == 0 and "Console" or ply:Nick(), DarkRP.formatMoney(amount), ""))

    if ply:EntIndex() == 0 then
        DarkRP.log("Console set " .. target:SteamName() .. "'s money to " .. DarkRP.formatMoney(amount), Color(30, 30, 30))
    else
        DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") set " .. target:SteamName() .. "'s money to " ..  DarkRP.formatMoney(amount), Color(30, 30, 30))
    end
end
DarkRP.definePrivilegedChatCommand("setmoney", "DarkRP_SetMoney", ccSetMoney)

local function ccAddMoney(ply, args)
    if not tonumber(args[2]) then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
        return
    end

    local target = DarkRP.findPlayer(args[1])

    if not target then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", tostring(args[1])))
        return
    end

    local amount = math.floor(tonumber(args[2]))

    if target then
        target:addMoney(amount)

        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("you_gave", target:Nick(), DarkRP.formatMoney(amount)))

        DarkRP.notify(target, 0, 4, DarkRP.getPhrase("x_set_your_money", ply:EntIndex() == 0 and "Console" or ply:Nick(), DarkRP.formatMoney(target:getDarkRPVar("money")), ""))
        if ply:EntIndex() == 0 then
            DarkRP.log("Console added " .. DarkRP.formatMoney(amount) .. " to " .. target:SteamName() .. "'s wallet", Color(30, 30, 30))
        else
            DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") added " .. DarkRP.formatMoney(amount) .. " to " .. target:SteamName() .. "'s wallet", Color(30, 30, 30))
        end
    else
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("could_not_find", args[1]))
    end
end
DarkRP.definePrivilegedChatCommand("addmoney", "DarkRP_SetMoney", ccAddMoney)

DarkRP.hookStub{
    name = "playerGaveMoney",
    description = "Called when a player gives another player money.",
    parameters = {
        {
            name = "player",
            description = "The player that gives the money.",
            type = "Player"
        },
        {
            name = "otherPlayer",
            description = "The player that receives the money.",
            type = "Player"
        },
        {
            name = "amount",
            description = "The amount of money.",
            type = "number"
        }
    },
    returns = {
    },
    realm = "Server"
}

DarkRP.hookStub{
    name = "playerDroppedMoney",
    description = "Called when a player drops some money.",
    parameters = {
        {
            name = "player",
            description = "The player who dropped the money.",
            type = "Player"
        },
        {
            name = "amount",
            description = "The amount of money dropped.",
            type = "number"
        },
        {
            name = "entity",
            description = "The entity of the money that was dropped.",
            type = "Entity"
        }
    },
    returns = {
    },
    realm = "Server"
}

DarkRP.hookStub{
    name = "playerDroppedCheque",
    description = "Called when a player drops a cheque.",
    parameters = {
        {
            name = "player",
            description = "The player who dropped the cheque.",
            type = "Player"
        },
        {
            name = "player",
            description = "The player the cheque was written to.",
            type = "Player"
        },
        {
            name = "amount",
            description = "The amount of money the cheque has.",
            type = "number"
        },
        {
            name = "entity",
            description = "The entity of the cheque that was dropped.",
            type = "Entity"
        }
    },
    returns = {
    },
    realm = "Server"
}
