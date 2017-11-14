local function IncludeFolder(fol)
    fol = string.lower(fol)
    local _, folders = file.Find(fol .. "*", "LUA")

    for _, folder in SortedPairs(folders, true) do
        if folder ~= "." and folder ~= ".." then
            for _, File in SortedPairs(file.Find(fol .. folder .. "/sh_*.lua", "LUA"), true) do
                include(fol .. folder .. "/" .. File)
            end

            for _, File in SortedPairs(file.Find(fol .. folder .. "/cl_*.lua", "LUA"), true) do
                include(fol .. folder .. "/" .. File)
            end
        end
    end
end

IncludeFolder(GM.FolderName .. "/gamemode/modules/fadmin/fadmin/")
IncludeFolder(GM.FolderName .. "/gamemode/modules/fadmin/fadmin/playeractions/")

--[[---------------------------------------------------------------------------
FAdmin global settings
---------------------------------------------------------------------------]]
net.Receive("FAdmin_GlobalSetting", function(len)
    local setting, value = net.ReadString(), net.ReadType(net.ReadUInt(8))

    FAdmin.GlobalSetting = FAdmin.GlobalSetting or {}
    FAdmin.GlobalSetting[setting] = value
end)

net.Receive("FAdmin_PlayerSetting", function(len)
    local uid, setting, value = net.ReadUInt(16), net.ReadString(), net.ReadType(net.ReadUInt(8))

    FAdmin.PlayerSettings = FAdmin.PlayerSettings or {}
    FAdmin.PlayerSettings[uid] = FAdmin.PlayerSettings[uid] or {}
    FAdmin.PlayerSettings[uid][setting] = value
end)

timer.Create("FAdmin_CleanPlayerSettings", 300, 0, function()
    if not FAdmin.PlayerSettings then return end

    -- find highest userID
    local max = math.huge
    for _, v in ipairs(player.GetAll()) do
        if IsValid(v) and v:UserID() > max then max = v:UserID() end
    end

    -- Anything lower than the maximal UserID can be culled
    -- This prevents data from joining players from being removed
    -- New players always get a strictly higher UserID than any player before them
    for uid in pairs(FAdmin.PlayerSettings) do
        if IsValid(Player(uid)) or uid > max then continue end

        FAdmin.PlayerSettings[uid] = nil
    end
end)

local plyMeta = FindMetaTable("Player")

function plyMeta:FAdmin_GetGlobal(setting)
    local uid = self:UserID()
    return FAdmin.PlayerSettings and FAdmin.PlayerSettings[uid] and FAdmin.PlayerSettings[uid][setting] or nil
end

net.Receive("FAdmin_GlobalPlayerSettings", function(len)
    local globalCount = net.ReadUInt(8)

    FAdmin.GlobalSetting = FAdmin.GlobalSetting or {}

    for i = 1, globalCount do
        FAdmin.GlobalSetting[net.ReadString()] = net.ReadType(net.ReadUInt(8))
    end

    local plyCount = net.ReadUInt(8)
    FAdmin.PlayerSettings = FAdmin.PlayerSettings or {}

    for i = 1, plyCount do
        local uid = net.ReadUInt(16)
        local count = net.ReadUInt(8)

        FAdmin.PlayerSettings[uid] = FAdmin.PlayerSettings[uid] or {}

        for j = 1, count do
            FAdmin.PlayerSettings[uid][net.ReadString()] = net.ReadType(net.ReadUInt(8))
        end
    end
end)

