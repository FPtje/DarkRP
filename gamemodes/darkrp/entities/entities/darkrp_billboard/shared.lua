ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "DarkRP billboard"
ENT.Instructions = "Shows advertisements."
ENT.Author = "FPtje"

ENT.Spawnable = false
ENT.Editable = true
ENT.IsDarkRPBillboard = true

cleanup.Register("advert_billboards")

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "TopText", {
        KeyName = "toptext",
        Edit = {
            type = "Generic",
            title = "Top text",
            category = "Text",
            order = 0
        }
    })

    self:NetworkVar("String", 1, "BottomText", {
        KeyName = "bottomtext",
        Edit = {
            type = "Generic",
            title = "Bottom text",
            category = "Text",
            order = 1
        }
    })

    self:NetworkVar("Vector", 0, "BackgroundColor", {
        KeyName = "backgroundcolor",
        Edit = {
            type = "VectorColor",
            title = "Background color",
            category = "Color",
            order = 0
        }
    })

    self:NetworkVar("Vector", 1, "BarColor", {
        KeyName = "barcolor",
        Edit = {
            type = "VectorColor",
            title = "Top bar color",
            category = "Color",
            order = 1
        }
    })
end

DarkRP.declareChatCommand{
    command = "advert",
    description = "Create a billboard holding an advertisement.",
    delay = 1.5
}

DarkRP.hookStub{
    name = "canAdvert",
    description = "Whether someone can place an advertisement billboard.",
    parameters = {
        {
            name = "player",
            description = "The player trying to advertise.",
            type = "Player"
        },
        {
            name = "arguments",
            description = "The advertisement itself.",
            type = "table"
        }
    },
    returns = {
        {
            name = "canAdvert",
            description = "A yes or no as to whether the player can place the billboard.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message that is shown when they can't place the billboard.",
            type = "string"
        }
    },
    realm = "Server"
}

DarkRP.hookStub{
    name = "playerAdverted",
    description = "Called when a player placed an advertisement billboard.",
    parameters = {
        {
            name = "player",
            description = "The player.",
            type = "Player"
        },
        {
            name = "arguments",
            description = "The advertisement itself.",
            type = "string"
        },
        {
            name = "entity",
            description = "The placed advertisement billboard.",
            type = "Entity"
        }
    },
    returns = {},
    realm = "Server"
}
