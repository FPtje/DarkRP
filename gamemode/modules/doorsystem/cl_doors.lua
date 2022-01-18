local meta = FindMetaTable("Entity")
local black = color_black
local white = Color(255, 255, 255, 200)
local red = Color(128, 30, 30, 255)
local changeDoorAccess = false

local function updatePrivs()
    CAMI.PlayerHasAccess(LocalPlayer(), "DarkRP_ChangeDoorSettings", function(b, _)
        changeDoorAccess = b
    end)
end
-- Timer due to lack of "on privilege changed" hook
hook.Add("InitPostEntity", "Load door privileges", function()
    updatePrivs()
    timer.Create("Door changeDoorAccess checker", 1, 0, updatePrivs)
end)

function meta:drawOwnableInfo()
    local ply = LocalPlayer()
    if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end

    -- Look, if you want to change the way door ownership is drawn, don't edit this file, use the hook instead!
    local doorDrawing = hook.Call("HUDDrawDoorData", nil, self)
    if doorDrawing == true then return end

    local blocked = self:getKeysNonOwnable()
    local doorTeams = self:getKeysDoorTeams()
    local doorGroup = self:getKeysDoorGroup()
    local playerOwned = self:isKeysOwned() or table.GetFirstValue(self:getKeysCoOwners() or {}) ~= nil
    local owned = playerOwned or doorGroup or doorTeams

    local doorInfo = {}

    local title = self:getKeysTitle()
    if title then table.insert(doorInfo, title) end

    if owned then
        table.insert(doorInfo, DarkRP.getPhrase("keys_owned_by"))
    end

    if playerOwned then
        if self:isKeysOwned() then table.insert(doorInfo, self:getDoorOwner():Nick()) end
        for k in pairs(self:getKeysCoOwners() or {}) do
            local ent = Player(k)
            if not IsValid(ent) or not ent:IsPlayer() then continue end
            table.insert(doorInfo, ent:Nick())
        end

        local allowedCoOwn = self:getKeysAllowedToOwn()
        if allowedCoOwn and not fn.Null(allowedCoOwn) then
            table.insert(doorInfo, DarkRP.getPhrase("keys_other_allowed"))

            for k in pairs(allowedCoOwn) do
                local ent = Player(k)
                if not IsValid(ent) or not ent:IsPlayer() then continue end
                table.insert(doorInfo, ent:Nick())
            end
        end
    elseif doorGroup then
        table.insert(doorInfo, doorGroup)
    elseif doorTeams then
        for k, v in pairs(doorTeams) do
            if not v or not RPExtraTeams[k] then continue end

            table.insert(doorInfo, RPExtraTeams[k].name)
        end
    elseif blocked and changeDoorAccess then
        table.insert(doorInfo, DarkRP.getPhrase("keys_allow_ownership"))
    elseif not blocked then
        table.insert(doorInfo, DarkRP.getPhrase("keys_unowned"))
        if changeDoorAccess then
            table.insert(doorInfo, DarkRP.getPhrase("keys_disallow_ownership"))
        end
    end

    if self:IsVehicle() then
        local driver = self:GetDriver()
        if driver:IsPlayer() then
            table.insert(doorInfo, DarkRP.getPhrase("driver", driver:Nick()))
        end
    end

    local x, y = ScrW() / 2, ScrH() / 2
    local text = table.concat(doorInfo, "\n")
    draw.DrawNonParsedText(text, "Roboto20", x , y + 1 , black, 1)
    draw.DrawNonParsedText(text, "Roboto20", x, y, (blocked or owned) and white or red, 1)
end


--[[---------------------------------------------------------------------------
Door data
---------------------------------------------------------------------------]]
DarkRP.doorData = DarkRP.doorData or {}

--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function meta:getDoorData()
    local doorData = DarkRP.doorData[self:EntIndex()] or {}

    self.DoorData = doorData -- Backwards compatibility

    return doorData
end

--[[---------------------------------------------------------------------------
Networking
---------------------------------------------------------------------------]]

--[[---------------------------------------------------------------------------
Retrieve all the data for all doors
---------------------------------------------------------------------------]]
local function retrieveAllDoorData(len)
    local count = net.ReadUInt(16)

    for i = 1, count do
        local ix = net.ReadUInt(16)
        local varCount = net.ReadUInt(8)

        DarkRP.doorData[ix] = DarkRP.doorData[ix] or {}

        for vc = 1, varCount do
            local name, value = DarkRP.readNetDoorVar()
            DarkRP.doorData[ix][name] = value
        end
    end
end
net.Receive("DarkRP_AllDoorData", retrieveAllDoorData)

--[[---------------------------------------------------------------------------
Update changed variables
---------------------------------------------------------------------------]]
local function updateDoorData()
    local door = net.ReadUInt(32)

    DarkRP.doorData[door] = DarkRP.doorData[door] or {}

    local var, value = DarkRP.readNetDoorVar()

    DarkRP.doorData[door][var] = value
end
net.Receive("DarkRP_UpdateDoorData", updateDoorData)

--[[---------------------------------------------------------------------------
Set a value of a single doorvar to nil
---------------------------------------------------------------------------]]
local function removeDoorVar()
    local door = net.ReadUInt(16)
    local id = net.ReadUInt(8)

    local name = id == 0 and net.ReadString() or DarkRP.getDoorVars()[id].name

    if not DarkRP.doorData[door] then return end
    DarkRP.doorData[door][name] = nil
end
net.Receive("DarkRP_RemoveDoorVar", removeDoorVar)

--[[---------------------------------------------------------------------------
Remove doordata of removed entity
---------------------------------------------------------------------------]]
local function removeDoorData()
    local door = net.ReadUInt(32)
    DarkRP.doorData[door] = nil
end
net.Receive("DarkRP_RemoveDoorData", removeDoorData)
