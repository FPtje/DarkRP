/*---------------------------------------------------------------------------
/*---------------------------------------------------------------------------
Ammo types
---------------------------------------------------------------------------
Ammo boxes that can be purchased in the F4 menu.

Add your custom ammo types in this file. Here's the syntax:
DarkRP.createAmmoType("ammoType", {
    name = "Ammo name",
    model = "Model",
    price = 1234,
    amountGiven = 5678,
    customCheck = function(ply) return ply:IsAdmin() end
})

ammoType: The name of the ammo that Garry's mod recognizes
    If you open your SWEP's shared.lua, you can find the ammo name next to
    SWEP.Primary.Ammo = "AMMO NAME HERE"
    or
    SWEP.Secondary.Ammo = "AMMO NAME HERE"

name: The name you want to give to the ammo. This can be anything.

model: The model you want the ammo to have in the F4 menu

price: the price of your ammo in dollars

amountGiven: How much bullets of this ammo is given every time the player buys it

customCheck: (Optional! Advanced!) a Lua function that describes who can buy the ammo.
    Similar to the custom check function for jobs and shipments
    Parameters:
        ply: the player who is trying to buy the ammo

Examples are below!
---------------------------------------------------------------------------*/

-- Pistol ammo type. Used by p228, desert eagle and all other pistols
DarkRP.createAmmoType("pistol", {
    name = "Pistol ammo",
    model = "models/Items/BoxSRounds.mdl",
    price = 30,
    amountGiven = 24
})

-- Buckshot ammo, used by the shotguns
DarkRP.createAmmoType("buckshot", {
    name = "Shotgun ammo",
    model = "models/Items/BoxBuckshot.mdl",
    price = 50,
    amountGiven = 8
})

-- Rifle ammo, usually used by assault rifles
DarkRP.createAmmoType("smg1", {
    name = "Rifle ammo",
    model = "models/Items/BoxMRounds.mdl",
    price = 80,
    amountGiven = 30
})

DarkRP.createCategory{
    name = "Other",
    categorises = "ammo",
    startExpanded = true,
    color = Color(0, 107, 0, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 255,
}
