DarkRP.createAmmoType("pistol", {
    name = "Pistol ammo",
    model = "models/Items/BoxSRounds.mdl",
    price = 30,
    amountGiven = 24
})

DarkRP.createAmmoType("buckshot", {
    name = "Shotgun ammo",
    model = "models/Items/BoxBuckshot.mdl",
    price = 50,
    amountGiven = 8
})

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
