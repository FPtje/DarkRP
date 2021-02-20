util.AddNetworkString("FAdmin_retrievebans")
util.AddNetworkString("FADMIN_SendGroups")
util.AddNetworkString("FAdmin_GlobalSetting")
util.AddNetworkString("FAdmin_PlayerSetting")
util.AddNetworkString("FAdmin_GlobalPlayerSettings")

local SortedPairs, ipairs, pairs = SortedPairs, ipairs, pairs
-- recursively adds everything in a directory to be downloaded by client
local function AddDir(dir)
    local files, folders = file.Find(dir .. "/*", "GAME")

    for _, fdir in ipairs(folders) do
        -- don't spam people with useless .svn folders
        if fdir ~= ".svn" then
            AddDir(dir .. "/" .. fdir)
        end
    end

    for _, v in ipairs(files) do
        resource.AddFile(dir .. "/" .. v)
    end
end

AddDir("materials/fadmin")

local function AddCSLuaFolder(fol)
    fol = string.lower(fol)
    local _, folders = file.Find(fol .. "*", "LUA")

    for _, folder in SortedPairs(folders, true) do
        if folder ~= "." and folder ~= ".." then
            for _, File in SortedPairs(file.Find(fol .. folder .. "/sh_*.lua", "LUA")) do
                AddCSLuaFile(fol .. folder .. "/" .. File)
                include(fol .. folder .. "/" .. File)
            end

            for _, File in SortedPairs(file.Find(fol .. folder .. "/sv_*.lua", "LUA"), true) do
                include(fol .. folder .. "/" .. File)
            end

            for _, File in SortedPairs(file.Find(fol .. folder .. "/cl_*.lua", "LUA"), true) do
                AddCSLuaFile(fol .. folder .. "/" .. File)
            end
        end
    end
end

AddCSLuaFolder(GM.FolderName .. "/gamemode/modules/fadmin/fadmin/")
AddCSLuaFolder(GM.FolderName .. "/gamemode/modules/fadmin/fadmin/playeractions/")

--[[---------------------------------------------------------------------------
FAdmin global settings
---------------------------------------------------------------------------]]
function FAdmin.SetGlobalSetting(setting, value)
    if FAdmin.GlobalSetting[setting] == value then return end -- If the value didn't change, we don't need to resend it.
    FAdmin.GlobalSetting[setting] = value
    net.Start("FAdmin_GlobalSetting")
        net.WriteString(setting)
        net.WriteType(value)
    net.Broadcast()
end


local plyMeta = FindMetaTable("Player")
function plyMeta:FAdmin_SetGlobal(setting, value)
    self.GlobalSetting = self.GlobalSetting or {}
    if self.GlobalSetting[setting] == value then return end -- If the value didn't change, we don't need to resend it.
    self.GlobalSetting[setting] = value

    net.Start("FAdmin_PlayerSetting")
        net.WriteUInt(self:UserID(), 16)
        net.WriteString(setting)
        net.WriteType(value)
    net.Broadcast()
end

function plyMeta:FAdmin_GetGlobal(setting)
    return self.GlobalSetting and self.GlobalSetting[setting] or nil
end

hook.Add("PlayerInitialSpawn", "FAdmin_GlobalSettings", function(ply)
    -- Not optimal in efficiency, but with the amount of global settings
    -- it's not worth spending a lot of time on.
    net.Start("FAdmin_GlobalPlayerSettings")
        net.WriteUInt(table.Count(FAdmin.GlobalSetting), 8) -- assume max 255 settings

        for k, v in pairs(FAdmin.GlobalSetting) do
            net.WriteString(k)
            net.WriteType(v)
        end

        local tPlayers = player.GetAll()
        net.WriteUInt(#tPlayers, 8)
        for _, target in ipairs(tPlayers) do
            local targetSettings = target.GlobalSetting or {}

            net.WriteUInt(target:UserID(), 16)
            net.WriteUInt(table.Count(targetSettings), 8)

            for k, v in pairs(targetSettings) do
                net.WriteString(k)
                net.WriteType(v)
            end
        end
    net.Send(ply)
end)
FAdmin.SetGlobalSetting("FAdmin", true)
