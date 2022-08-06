local meta = FindMetaTable("Player")

--[[---------------------------------------------------------------------------
Stubs
---------------------------------------------------------------------------]]
DarkRP.stub{
    name = "dropPocketItem",
    description = "Make the player drop an item from the pocket.",
    parameters = {
        {
            name = "ent",
            description = "The entity to drop.",
            type = "Entity",
            optional = false
        }
    },
    returns = {
    },
    metatable = meta
}

DarkRP.stub{
    name = "addPocketItem",
    description = "Add an item to the pocket of the player.",
    parameters = {
        {
            name = "ent",
            description = "The entity to add.",
            type = "Entity",
            optional = false
        }
    },
    returns = {
    },
    metatable = meta
}

DarkRP.stub{
    name = "removePocketItem",
    description = "Remove an item from the pocket of the player.",
    parameters = {
        {
            name = "item",
            description = "The index of the entity to remove from pocket.",
            type = "number",
            optional = false
        }
    },
    returns = {
    },
    metatable = meta
}

DarkRP.hookStub{
    name = "canPocket",
    description = "Whether a player can pocket a certain item.",
    parameters = {
        {
            name = "ply",
            description = "The player.",
            type = "Player"
        },
        {
            name = "item",
            description = "The item to be pocketed.",
            type = "Entity"
        }
    },
    returns = {
        {
            name = "answer",
            description = "Whether the entity can be pocketed.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message to send to the player when the answer is false.",
            type = "string"
        }
    }
}

DarkRP.hookStub{
    name = "onPocketItemAdded",
    description = "Called when an entity is added to the pocket.",
    parameters = {
        {
            name = "ply",
            description = "The pocket holder.",
            type = "Player"
        },
        {
            name = "ent",
            description = "The entity.",
            type = "Entity"
        },
        {
            name = "serialized",
            description = "The serialized version of the pocketed entity.",
            type = "table"
        }
    },
    returns = {
    }
}

DarkRP.hookStub{
    name = "canDropPocketItem",
    description = "Whether someone is allowed to drop something from their pocket.",
    parameters = {
        {
            name = "ply",
            description = "The pocket holder.",
            type = "Player"
        },
        {
            name = "item",
            description = "The pocket item's index in the pocket.",
            type = "table"
        },
        {
            name = "serialized",
            description = "The pocket item.",
            type = "table"
        }
    },
    returns = {
        {
            name = "answer",
            description = "Whether the item can be dropped.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message to send to the player when the answer is false.",
            type = "string"
        }
    }
}

DarkRP.hookStub{
    name = "onPocketItemRemoved",
    description = "Called when an item is removed from the pocket.",
    parameters = {
        {
            name = "ply",
            description = "The pocket holder.",
            type = "Player"
        },
        {
            name = "item",
            description = "The index of the pocket item.",
            type = "number"
        }
    },
    returns = {
    }
}

--[[---------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------]]
-- workaround: GetNetworkVars doesn't give entities because the /duplicator/ doesn't want to save entities
local function getDTVars(ent)
    if not ent.GetNetworkVars then return nil end
    local name, value = debug.getupvalue(ent.GetNetworkVars, 1)
    if name ~= "datatable" then
        ErrorNoHalt("Warning: Datatable cannot be stored properly in pocket. Tell a developer!")
    end

    local res = {}

    for k,v in pairs(value) do
        res[k] = v.GetFunc(ent, v.index)
    end

    return res
end

local function serialize(ent)
    local serialized = duplicator.CopyEntTable(ent)
    serialized.DT = getDTVars(ent)

    -- this function is also called in duplicator.CopyEntTable, but some
    -- entities change the DT vars of a copied entity (e.g. Lexic's moneypot)
    -- That is undone with the getDTVars function call.
    -- Re-call OnEntityCopyTableFinish assuming its implementation is pure.
    if ent.OnEntityCopyTableFinish then
        ent:OnEntityCopyTableFinish(serialized)
    end

    return serialized
end

local function deserialize(ply, item)
    local ent = ents.Create(item.Class)
    duplicator.DoGeneric(ent, item)
    ent:Spawn()
    ent:Activate()

    duplicator.DoGenericPhysics(ent, ply, item)
    table.Merge(ent:GetTable(), item)

    if ent:IsWeapon() and ent.Weapon ~= nil and not ent.Weapon:IsValid() then ent.Weapon = ent end
    if ent.Entity ~= nil and not ent.Entity:IsValid() then ent.Entity = ent end

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply

    local tr = util.TraceLine(trace)

    ent:SetPos(tr.HitPos)

    DarkRP.placeEntity(ent, tr, ply)

    local phys = ent:GetPhysicsObject()
    timer.Simple(0, function() if phys:IsValid() then phys:Wake() end end)

    if ent.OnDuplicated then
        ent:OnDuplicated(item)
    end

    if ent.PostEntityPaste then
        ent:PostEntityPaste(ply, ent, {ent})
    end

    return ent
end

local function dropAllPocketItems(ply)
    for k in pairs(ply.darkRPPocket or {}) do
        ply:dropPocketItem(k)
    end
end

util.AddNetworkString("DarkRP_Pocket")
local function sendPocketItems(ply)
    net.Start("DarkRP_Pocket")
        net.WriteTable(ply:getPocketItems())
    net.Send(ply)
end

util.AddNetworkString("DarkRP_PocketMenu")

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function meta:addPocketItem(ent)
    if not IsValid(ent) then DarkRP.error("Entity not valid", 2) end
    if ent.USED then return end

    -- This item cannot be used until it has been removed
    ent.USED = true

    local serialized = serialize(ent)

    hook.Call("onPocketItemAdded", nil, self, ent, serialized)

    ent.IsPocketing = true
    ent:Remove()

    self.darkRPPocket = self.darkRPPocket or {}

    local id = table.insert(self.darkRPPocket, serialized)
    sendPocketItems(self)
    return id
end

function meta:removePocketItem(item)
    if not self.darkRPPocket or not self.darkRPPocket[item] then DarkRP.error("Player does not contain " .. item .. " in their pocket.", 2) end

    hook.Call("onPocketItemRemoved", nil, self, item)

    self.darkRPPocket[item] = nil
    sendPocketItems(self)
end

function meta:dropPocketItem(item)
    if not self.darkRPPocket or not self.darkRPPocket[item] then DarkRP.error("Player does not contain " .. item .. " in their pocket.", 2) end

    local id = self.darkRPPocket[item]
    local ent = deserialize(self, id)

    -- reset USED status
    ent.USED = nil

    hook.Call("onPocketItemDropped", nil, self, ent, item, id)

    self:removePocketItem(item)

    return ent
end

-- serverside implementation
function meta:getPocketItems()
    self.darkRPPocket = self.darkRPPocket or {}

    local res = {}
    for k, v in pairs(self.darkRPPocket) do
        res[k] = {
            model = v.Model,
            class = v.Class
        }
    end

    return res
end

--[[---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------]]
util.AddNetworkString("DarkRP_spawnPocket")
net.Receive("DarkRP_spawnPocket", function(len, ply)
    local item = net.ReadFloat()
    if not ply.darkRPPocket or not ply.darkRPPocket[item] then return end
    local canPickup, message = hook.Call("canDropPocketItem", nil, ply, item, ply.darkRPPocket[item])
    if canPickup == false then
        if message then DarkRP.notify(ply, 1, 4, message) end
        sendPocketItems(ply)
        return
    end
    ply:dropPocketItem(item)
end)

--[[---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]
function GAMEMODE:canPocket(ply, item)
    if not IsValid(item) then return false end
    local class = item:GetClass()

    if item.Removed then return false, DarkRP.getPhrase("cannot_pocket_x") end
    if not item:CPPICanPickup(ply) then return false, DarkRP.getPhrase("cannot_pocket_x") end
    if item.jailWall then return false, DarkRP.getPhrase("cannot_pocket_x") end
    if GAMEMODE.Config.PocketBlacklist[class] then return false, DarkRP.getPhrase("cannot_pocket_x") end
    if string.find(class, "func_") then return false, DarkRP.getPhrase("cannot_pocket_x") end
    if item:IsRagdoll() then return false, DarkRP.getPhrase("cannot_pocket_x") end
    if item:IsNPC() then return false, DarkRP.getPhrase("cannot_pocket_x") end
    if not duplicator.IsAllowed(class) then return false, DarkRP.getPhrase("cannot_pocket_x") end
    -- Entities being held by the gravgun have different properties than
    -- entities not being held. One such property is mass, which is set to 1.
    -- The simple solution is to disallow pocketing entities that are being
    -- held.
    if item.DarkRPBeingGravGunHeldBy ~= nil then return false, DarkRP.getPhrase("cannot_pocket_gravgunned") end

    local trace = ply:GetEyeTrace()
    if ply:EyePos():DistToSqr(trace.HitPos) > 22500 then return false end

    local ent = trace.Entity
    local phys = ent:GetPhysicsObject()
    if not phys:IsValid() then return false end

    local mass = ent.RPOriginalMass and ent.RPOriginalMass or phys:GetMass()
    if mass > 100 then return false, DarkRP.getPhrase("object_too_heavy") end

    local job = ply:Team()
    local max = RPExtraTeams[job].maxpocket or GAMEMODE.Config.pocketitems
    if table.Count(ply.darkRPPocket or {}) >= max then return false, DarkRP.getPhrase("pocket_full") end

    return true
end


-- Drop pocket items on death
hook.Add("PlayerDeath", "DropPocketItems", function(ply)
    if not GAMEMODE.Config.droppocketdeath or not ply.darkRPPocket then return end
    dropAllPocketItems(ply)
end)

hook.Add("playerArrested", "DropPocketItems", function(ply)
    if not GAMEMODE.Config.droppocketarrest then return end
    dropAllPocketItems(ply)
end)
