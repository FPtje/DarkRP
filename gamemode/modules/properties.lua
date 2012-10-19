--[[
	Name:		Properties
	Author:		Banana Lord
	Purpose:	Provide an extremely basic property system to demonstrate the new hooks in DarkRP
]]--

if( CLIENT ) then return; end

local properties = { }
properties.Enabled = false; -- change to true if you want to use properties
properties.VIP_Discount = 75; -- 0-100 number determining the % of discount a VIP player gets off door purchases (ie. a value of 75 would give them 75% off doors, so a $100 door would cost $25)
properties.BoughtMessage = "You are now the proud owner of this door for only $%i!"; -- place %i anywhere in the message to display the cost of the door
properties.SoldMessage = "You have parted with your door for $%i"; -- place %i anywhere in the message to display the refunded money

---
-- Calculate the cost of a door (returns integer)
-- @param objPl The player buying the door
-- @param objEnt The door the player is buying
hook.Add("GetDoorCost", "properties_GetDoorCost", function( objPl, objEnt )
	if( properties.Enabled ) then
		local iCost = GAMEMODE.Config.doorcost
		local iDiscount = math.Clamp( properties.VIP_Discount, 0, 100 );
		if( ( ulx || getmetatable(Player(0)).IsVIP ) && iDiscount > 0 ) then
			if( ulx && objPl:CheckGroup("vip") || objPl:IsVIP( ) ) then
				iCost = math.ceil( iCost * ( properties.VIP_Discount / 100 ) );
			end
		end
		return iCost;
	end
end );

---
-- Determine if a player is allowed to purchase a door
-- @param objPl The player buying the door
-- @param objEnt The door the player is buying
hook.Add("PlayerBuyDoor", "properties_AllowPurchase", function( objPl, objEnt )
	if( properties.Enabled ) then
		return IsValid( objPl ), "You aren't a valid player (wtf)", true;
	end
end );

---
-- Callback after the door is purchased
-- @param objPl The player who bought the door
-- @param objEnt The door the player bought
-- @param iCost The amount of money the door cost
hook.Add("PlayerBoughtDoor", "properties_BoughtDoor", function( objPl, objEnt, iCost )
	if( properties.Enabled ) then
		GAMEMODE:Notify( objPl, 0, 4, string.format( properties.BoughtMessage, iCost ) );
	end
end );

---
-- Determine if the default sell message should be shown (return true to disable)
-- @param objPl The player selling the door
-- @param objEnt The door the player is selling
hook.Add("HideSellDoorMessage", "properties_SellDoor", function( objPl, objEnt )
	if( properties.Enabled ) then
		return true;
	end
end );

---
-- Callback after the door is sold
-- @param objPl The player who sold the door
-- @param objEnt The door the player sold
-- @param iCost The amount of money refunded to the player
hook.Add("PlayerSoldDoor", "properties_SoldDoor", function( objPl, objEnt, iCost )
	if( properties.Enabled && iCost > 0 ) then
		GAMEMODE:Notify( objPl, 0, 4, string.format( properties.SoldMessage, iCost ) );
	end
end );