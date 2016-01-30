DarkRP.createFood = DarkRP.stub{
    name = "createFood",
    description = "Create food for DarkRP.",
    parameters = {
        {
            name = "name",
            description = "The name of the food.",
            type = "string",
            optional = false
        },
        {
            name = "tbl",
            description = "Table containing the information for the food.",
            type = "table",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}
AddFoodItem = DarkRP.createFood

DarkRP.removeFoodItem = DarkRP.stub{
    name = "removeFoodItem",
    description = "Remove a food item from DarkRP. NOTE: Must be called from BOTH server AND client to properly get it removed!",
    parameters = {
        {
            name = "i",
            description = "The index of the item.",
            type = "number",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.hookStub{
    name = "onFoodItemRemoved",
    description = "Called when a food item is removed.",
    parameters = {
        {
            name = "num",
            description = "The index of this item.",
            type = "number"
        },
        {
            name = "itemTable",
            description = "The table containing all the info about this item.",
            type = "table"
        }
    },
    returns = {
    }
}

DarkRP.PLAYER.isCook = DarkRP.stub{
    name = "isCook",
    description = "Whether this player is a cook. This function is only available if hungermod is enabled.",
    parameters = {
    },
    returns = {
        {
            name = "answer",
            description = "Whether this player is a cook.",
            type = "boolean"
        }
    },
    metatable = DarkRP.PLAYER
}

DarkRP.getFoodItems = DarkRP.stub{
    name = "getFoodItems",
    description = "Get all food items.",
    parameters = {

    },
    returns = {
        {
            name = "set",
            description = "Table with food items.",
            type = "table"
        }
    },
    metatable = DarkRP
}
