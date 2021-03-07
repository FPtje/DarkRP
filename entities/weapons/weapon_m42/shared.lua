AddCSLuaFile()

if CLIENT then
    SWEP.Author = "DarkRP Developers"
    SWEP.Contact = ""
    SWEP.Purpose = ""
    SWEP.Instructions = ""
    SWEP.Instructions = "Hold use and right-click to change firemodes or left-click to attach silencer."
    SWEP.Slot = 2
    SWEP.SlotPos = 0
    SWEP.IconLetter = "w"

    killicon.AddFont("weapon_m42", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base = "weapon_cs_base2"

SWEP.PrintName = "M4"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "DarkRP (Weapon)"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.HoldType = "ar2"
SWEP.LoweredHoldType = "passive"
SWEP.DarkRPViewModelBoneManipulations = {
    ["ValveBiped.Bip01_Spine4"]     = { scale = Vector(1, 1, 1),       pos = Vector(2, 0, 0),           angle = Angle(0, 0, 0)      },
    ["ValveBiped.Bip01_L_Hand"]     = { scale = Vector(0.7, 0.7, 0.5), pos = Vector(-0.6, -0.6, 0),     angle = Angle(17, -21, 0)   },
    ["ValveBiped.Bip01_L_Finger0"]  = { scale = Vector(1, 1, 1.5),     pos = Vector(0, 0, 0),           angle = Angle(0, -2, 0)     },
    ["ValveBiped.Bip01_L_Finger1"]  = { scale = Vector(1, 1, 1.5),     pos = Vector(-0.3, -0.8, 0),     angle = Angle(0, -10, 0)    },
    ["ValveBiped.Bip01_L_Finger11"] = { scale = Vector(1, 1, 1),       pos = Vector(0, 0, 0),           angle = Angle(0, -15, 0)    },
    ["ValveBiped.Bip01_L_Finger12"] = { scale = Vector(1, 1, 1),       pos = Vector(0, 0, 0),           angle = Angle(0, -14, 0)    },
    ["ValveBiped.Bip01_L_Finger2"]  = { scale = Vector(1, 1, 1.5),     pos = Vector(-0.6, -1, -0),      angle = Angle(0, 7, 0)      },
    ["ValveBiped.Bip01_L_Finger21"] = { scale = Vector(1, 1, 1),       pos = Vector(0, 0, 0),           angle = Angle(0, -15, 0)    },
    ["ValveBiped.Bip01_L_Finger22"] = { scale = Vector(0.8, 0.8, 1),   pos = Vector(0, -0.3, 0),        angle = Angle(0, -36, 0)    },
    ["ValveBiped.Bip01_L_Finger3"]  = { scale = Vector(1, 1, 1.5),     pos = Vector(-0.36, -1.2, -0.2), angle = Angle(-6, -2, 0)    },
    ["ValveBiped.Bip01_L_Finger31"] = { scale = Vector(1, 1, 1),       pos = Vector(0, -0.1, 0),        angle = Angle(0, -4, 0)     },
    ["ValveBiped.Bip01_L_Finger32"] = { scale = Vector(1, 1, 1),       pos = Vector(0, -0.2, 0),        angle = Angle(0, -12, 0)    },
    ["ValveBiped.Bip01_L_Finger4"]  = { scale = Vector(1, 1, 1.5),     pos = Vector(-0.3, -1.2, 0.3),   angle = Angle(12, -6.2, -4) },
    ["ValveBiped.Bip01_L_Finger41"] = { scale = Vector(1, 1, 1),       pos = Vector(0, 0, 0),           angle = Angle(0, 38, 0)     },
    ["ValveBiped.Bip01_L_Finger42"] = { scale = Vector(1, 1, 1),       pos = Vector(0, 0, 0),           angle = Angle(0, 30, 0)     }
}

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Sound = Sound("Weapon_M4A1.Single")
SWEP.Primary.Recoil = 1.25
SWEP.Primary.Unrecoil = 8
SWEP.Primary.Damage = 15
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone   = 0.03
SWEP.Primary.ClipSize = 30
SWEP.Primary.Delay = 0.07
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- Start of Firemode configuration
SWEP.IronSightsPos = Vector(-8.09, -4.5, 0.56)
SWEP.IronSightsAng = Vector(2.75, -3.97, -3.8)
SWEP.IronSightsPosAfterShootingAdjustment = Vector(0.5, 0, 0)
SWEP.IronSightsAngAfterShootingAdjustment = Vector(0, 1.65, 0)

SWEP.MultiMode = true
