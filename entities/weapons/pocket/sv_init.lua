local meta = FindMetaTable("Player")

DarkRP.stub{
	name = "dropPocketItem",
	description = "Make the player drop an item from the pocket",
	parameters = {
		{
			name = "ent",
			description = "The entity to drop",
			type = "Entity",
			optional = false
		}
	},
	returns = {
	},
	metatable = meta
}

-- Drop pocket items on death
-- dropPocketItem
-- add item to pocket
-- remove item from pocket
-- spawn item from pocket
-- canPocket hook
---- if not trace.Entity:CPPICanPickup(self.Owner) or trace.Entity.IsPocketed or trace.Entity.jailWall then
-- RPExtraTeams[t].maxpocket or GAMEMODE.Config.pocketitems
-- blacklist = {"fadmin_jail", "drug_lab", "money_printer", "meteor", "microwave", "door", "func_", "player", "beam", "worldspawn", "env_", "path_", "spawned_shipment", "prop_physics"}
