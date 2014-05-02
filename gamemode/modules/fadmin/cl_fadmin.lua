local function IncludeFolder(fol)
	fol = string.lower(fol)

	local files, folders = file.Find(fol.."*", "LUA")
	for _, folder in SortedPairs(folders, true) do
		if folder ~= "." and folder ~= ".." then
			for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA"), true) do
				include(fol.. folder .. "/" ..File)
			end

			for _, File in SortedPairs(file.Find(fol .. folder .."/cl_*.lua", "LUA"), true) do
				include(fol.. folder .. "/" ..File)
			end
		end
	end
end
IncludeFolder(GM.FolderName.."/gamemode/modules/fadmin/fadmin/")
IncludeFolder(GM.FolderName.."/gamemode/modules/fadmin/fadmin/playeractions/")

/*---------------------------------------------------------------------------
FAdmin global settings
---------------------------------------------------------------------------*/
local GetTypes = {Angle = "ReadAngle",
boolean = "ReadBool",
Entity = "ReadEntity",
number = "ReadFloat",
Player = "ReadEntity",
string = "ReadString",
Vector = "ReadVector"}
usermessage.Hook("FAdmin_GlobalSetting", function(um)
	FAdmin.GlobalSetting = FAdmin.GlobalSetting or {}
	local key, value = um:ReadString(), um:ReadString()
	FAdmin.GlobalSetting[key] = um[GetTypes[value]](um)
end)
usermessage.Hook("FAdmin_PlayerSetting", function(um)
	local ply = um:ReadEntity()
	if not ply:IsValid() then return end
	ply.GlobalSetting = ply.GlobalSetting or {}
	ply.GlobalSetting[um:ReadString()] = um[GetTypes[um:ReadString()]](um)
end)
