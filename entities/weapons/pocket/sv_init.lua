local meta = FindMetaTable("Player")

/*---------------------------------------------------------------------------
Stubs
---------------------------------------------------------------------------*/
fprp.stub{
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

fprp.stub{
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

fprp.stub{
	name = "removePocketItem",
	description = "Remove an item from the pocket of the player.",
	parameters = {
		{
			name = "item",
			description = "The entity to remove from pocket.",
			type = "string",
			optional = false
		}
	},
	returns = {
	},
	metatable = meta
}

fprp.hookStub{
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

fprp.hookStub{
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

fprp.hookStub{
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

/*---------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------*/
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

	return serialized
end

local function deserialize(ply, item)
	local ent = ents.Create(item.Class)
	duplicator.DoGeneric(ent, item)
	ent:Spawn()
	ent:Activate()

	duplicator.DoGenericPhysics(ent, ply, item)
	table.Merge(ent:GetTable(), item)

	local pos, mins = ent:GetPos(), ent:WorldSpaceAABB()
	local offset = pos.z - mins.z

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	ent:SetPos(tr.HitPos + Vector(0, 0, offset))

	local phys = ent:GetPhysicsObject()
	timer.Simple(0, function() if phys:IsValid() then phys:Wake() end end)

	return ent
end

local function dropAllPocketItems(ply)
	for k,v in pairs(ply.fprpPocket or {}) do
		ply:dropPocketItem(k)
	end
end

util.AddNetworkString("fprp_Pocket")
local function sendPocketItems(ply)
	net.Start("fprp_Pocket")
		net.WriteTable(ply:getPocketItems())
	net.Send(ply)
end

/*---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------*/
function meta:addPocketItem(ent)
	if not IsValid(ent) then fprp.error("Entity not valid", 2) end
	if ent.USED then return end

	-- This item cannot be used until it has been removed
	ent.USED = true

	local serialized = serialize(ent)

	hook.Call("onPocketItemAdded", nil, self, ent, serialized)

	ent:Remove()

	self.fprpPocket = self.fprpPocket or {}

	local id = table.insert(self.fprpPocket, serialized)
	sendPocketItems(self)
	return id
end

function meta:removePocketItem(item)
	if not self.fprpPocket or not self.fprpPocket[item] then fprp.error("Player does not contain " .. item .. " in their pocket.", 2) end

	hook.Call("onPocketItemRemoved", nil, self, item)

	self.fprpPocket[item] = nil
	sendPocketItems(self)
end

function meta:dropPocketItem(item)
	if not self.fprpPocket or not self.fprpPocket[item] then fprp.error("Player does not contain " .. item .. " in their pocket.", 2) end

	local id = self.fprpPocket[item]
	local ent = deserialize(self, id)

	-- reset USED status
	ent.USED = nil

	hook.Call("onPocketItemDropped", nil, self, ent, item, id)

	self:removePocketItem(item)

	return ent
end

-- serverside implementation
function meta:getPocketItems()
	self.fprpPocket = self.fprpPocket or {}

	local res = {}
	for k,v in pairs(self.fprpPocket) do
		res[k] = {
			model = v.Model,
			class = v.Class
		}
	end

	return res
end

/*---------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------*/
util.AddNetworkString("fprp_spawnPocket")
net.Receive("fprp_spawnPocket", function(len, ply)
	local item = net.ReadFloat()
	if not ply.fprpPocket or not ply.fprpPocket[item] then return end
	ply:dropPocketItem(item)
end)

/*---------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------*/

local function onAdded(ply, ent, serialized)
	if not ent:IsValid() or not ent.fprpItem or not ent.Getowning_ent or not IsValid(ent:Getowning_ent()) then return end

	local ply = ent:Getowning_ent()
	local cmdname = string.gsub(ent.fprpItem.ent, " ", "_")

	ply:addCustomEntity(ent.fprpItem)
end
hook.Add("onPocketItemAdded", "defaultImplementation", onAdded)

local function canPocket(ply, item)
	if not IsValid(item) then return false end
	local class = item:GetClass()

	if item.Removed then return false, fprp.getPhrase("cannot_pocket_x") end
	if not item:CPPICanPickup(ply) then return false, fprp.getPhrase("cannot_pocket_x") end
	if item.jailWall then return false, fprp.getPhrase("cannot_pocket_x") end
	if GAMEMODE.Config.PocketBlacklist[class] then return false, fprp.getPhrase("cannot_pocket_x") end
	if string.find(class, "func_") then return false, fprp.getPhrase("cannot_pocket_x") end
	if item:IsRagdoll() then return false, fprp.getPhrase("cannot_pocket_x") end

	local trace = ply:GetEyeTrace()
	if ply:EyePos():Distance(trace.HitPos) > 150 then return false end

	local phys = trace.Entity:GetPhysicsObject()
	if not phys:IsValid() then return false end

	local mass = trace.Entity.RPOriginalMass and trace.Entity.RPOriginalMass or phys:GetMass()
	if mass > 100 then return false, fprp.getPhrase("object_too_heavy") end

	local job = ply:Team()
	local max = RPExtraTeams[job].maxpocket or GAMEMODE.Config.pocketitems
	if table.Count(ply.fprpPocket or {}) >= max then return false, fprp.getPhrase("pocket_full") end

	return true
end
hook.Add("canPocket", "defaultRestrictions", canPocket)


-- Drop pocket items on death
hook.Add("PlayerDeath", "DropPocketItems", function(ply)
	if not GAMEMODE.Config.droppocketdeath or not ply.fprpPocket then return end
	dropAllPocketItems(ply)
end)

hook.Add("playerArrested", "DropPocketItems", function(ply)
	if not GAMEMODE.Config.droppocketarrest then return end
	dropAllPocketItems(ply)
end)
