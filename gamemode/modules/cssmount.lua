if IsMounted("cstrike") and util.IsValidModel("models/props/cs_assault/money.mdl") then return end
local texts = {
	"Counter Strike Source is not mounted!",
	"Common symptoms: money and guns floating in the air",
	"You need to mount CSS",
	"DarkRP will not work without it",
	"Read these pages:",
	"http://wiki.garrysmod.com/page/Retrieving_content_to_be_mounted_on_a_Dedicated_Server",
	"http://wiki.garrysmod.com/page/Mounting_Content_on_a_DS"
}

hook.Add("PlayerInitialSpawn", "CSSCheck", function(ply)
	timer.Simple(5, function()
		if not IsValid(ply) then return end
		for _, text in pairs(texts) do
			GAMEMODE:TalkToPerson(ply, Color(255, 0, 0,255), text)
		end
	end)
end)