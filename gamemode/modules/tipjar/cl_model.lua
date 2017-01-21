--[[-------------------------------------------------------------------------
The model describes the data that the drives the UI.
Loosely based on the Elm architecture.
---------------------------------------------------------------------------]]

local model = {
    -- The tip jar entity
    tipjar = nil,

    -- Whether the LocalPlayer is the owner of this tipjar
    isOwner = false,

    -- Whether the frame is visible
    frameVisible = false,

    -- The Derma frame object
    frame = nil,

    -- The amount the player is putting in the tip jar
    amount = 0,

    -- The last amount of money the player actually put in the tip jar
    lastTipAmount = 0,

    -- Action: when an active donation changes. The active donations
    -- themselves are fetched from the tipjar, which keeps track of the proper
    -- state for it.
    activeDonationUpdate = nil,

    -- Action: when someone donated. The list of donators is kept track of by
    -- the tipjar.
    donatedUpdate = nil,
}

local updaters = {}

DarkRP.tipJarUIModel = {}

--[[-------------------------------------------------------------------------
Update the model.
Automatically calls the registered update hook functions
---------------------------------------------------------------------------]]
function DarkRP.tipJarUIModel.updateModel(path, value, ...)
    path = istable(path) and path or {path}

    local updTbl = updaters
    local mdlTbl = model
    local key = path[#path]

    for i = 1, #path - 1 do
        mdlTbl = mdlTbl[path[i]]
        updTbl = updTbl and updTbl[path[i]]
    end

    local oldValue = mdlTbl[key]
    mdlTbl[key] = value

    for _, updFunc in ipairs(updTbl and updTbl[key] or {}) do
        updFunc(value, oldValue, ...)

        -- the updFunc changed this value, break off
        if mdlTbl[key] ~= value then break end
    end
end

--[[-------------------------------------------------------------------------
Retrieve a value of the model
---------------------------------------------------------------------------]]
function DarkRP.tipJarUIModel.getModelValue(path)
    path = istable(path) and path or {path}

    local mdlTbl = model
    local key = path[#path]

    for i = 1, #path - 1 do
        mdlTbl = mdlTbl[path[i]]
    end

    return mdlTbl[key]
end

--[[-------------------------------------------------------------------------
Registers a hook that gets triggered when a certain part of the model is
updated
---------------------------------------------------------------------------]]
function DarkRP.tipJarUIModel.onModelUpdate(path, func)
    path = istable(path) and path or {path}

    local updTbl = updaters
    local mdlTbl = model
    local key = path[#path]

    for i = 1, #path - 1 do
        mdlTbl = mdlTbl[path[i]]
        updTbl[path[i]] = updTbl[path[i]] or {}
        updTbl = updTbl[path[i]]
    end

    updTbl[key] = updTbl[key] or {}

    table.insert(updTbl[key], func)

    -- Call update with the initial value
    if mdlTbl[key] ~= nil then
        func(mdlTbl[key], mdlTbl[key])
    end
end

--[[-------------------------------------------------------------------------
Default listeners
---------------------------------------------------------------------------]]
local updateModel, _getModelValue, onModelUpdate =
    DarkRP.tipJarUIModel.updateModel,
    DarkRP.tipJarUIModel.getModelValue,
    DarkRP.tipJarUIModel.onModelUpdate

onModelUpdate("amount", function(new, _)
    local localply = LocalPlayer()
    if not IsValid(localply) then return end

    local ownMoney = localply:getDarkRPVar("money") or 0

    if new < 0 or new % 1 ~= 0 or new > ownMoney then
        local amount = math.abs(math.floor(new))
        amount = math.min(amount, ownMoney)
        updateModel("amount", amount)
    end
end)
