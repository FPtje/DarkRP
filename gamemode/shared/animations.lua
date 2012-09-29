hook.Add("CalcMainActivity", "darkrp_animations", function(ply, velocity) -- Using hook.Add and not GM:CalcMainActivity to prevent animation problems
	-- Dropping weapons/money!
	if ply.anim_DroppingItem then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_DROP)
		ply.anim_DroppingItem = nil
	end

	-- Giving items!
	if ply.anim_GivingItem then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_GIVE)
		ply.anim_GivingItem = nil
	end

	if CLIENT and ply.SaidHi then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_SIGNAL_GROUP)
		ply.SaidHi = nil
	end

	if CLIENT and ply.ThrewPoop then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_THROW)
		ply.ThrewPoop = nil
	end

	if CLIENT and ply.knocking then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST)
		ply.knocking = nil
	end

	if CLIENT and ply.usekeys then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_PLACE)
		ply.usekeys = nil
	end

	if not SERVER then return end

	-- Hobo throwing poop!
	local Weapon = ply:GetActiveWeapon()
	if ply:Team() == TEAM_HOBO and not ply.ThrewPoop and ValidEntity(Weapon) and Weapon:GetClass() == "weapon_bugbait" and ply:KeyDown(IN_ATTACK) then
		ply.ThrewPoop = true
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_ITEM_THROW)


		local RP = RecipientFilter()
		RP:AddAllPlayers()

		umsg.Start("anim_throwpoop", RP)
			umsg.Entity(ply)
		umsg.End()
	elseif ply.ThrewPoop and not ply:KeyDown(IN_ATTACK) then
		ply.ThrewPoop = nil
	end

	-- Saying hi/hello to a player
	if not ply.SaidHi and ValidEntity(Weapon) and Weapon:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK) then
		local ent = ply:GetEyeTrace().Entity
		if ValidEntity(ent) and ent:IsPlayer() then
			ply.SaidHi = true
			ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_SIGNAL_GROUP)

			local RP = RecipientFilter()
			RP:AddAllPlayers()

			umsg.Start("anim_sayhi", RP)
				umsg.Entity(ply)
			umsg.End()
		end
	elseif ply.SaidHi and not ply:KeyDown(IN_ATTACK) then
		ply.SaidHi = nil
	end
end)

if SERVER then
	local function CustomAnim(ply, cmd, args)
		local Gesture = tonumber(args[1] or 0)
		if Gesture < 1782 or Gesture > 1900 then return end
		local RP = RecipientFilter()
		RP:AddAllPlayers()

		umsg.Start("_DarkRP_CustomAnim", RP)
		umsg.Entity(ply)
		umsg.Short(Gesture)
		umsg.End()
	end
	concommand.Add("_DarkRP_DoAnimation", CustomAnim)
	return
end

local function DropItem(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end

	ply.anim_DroppingItem = true
end
usermessage.Hook("anim_dropitem", DropItem)

local function GiveItem(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end

	ply.anim_GivingItem = true
end
usermessage.Hook("anim_giveitem", GiveItem)

local function ThrowPoop(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end

	ply.ThrewPoop = true
end
usermessage.Hook("anim_throwpoop", ThrowPoop)

local function PhysgunHi(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end

	ply.SaidHi = true
end
usermessage.Hook("anim_sayhi", PhysgunHi)

local function KeysAnims(um)
	local ply = um:ReadEntity()
	if not ValidEntity(ply) then return end
	local Type = um:ReadString()
	ply[Type] = true
end
usermessage.Hook("anim_keys", KeysAnims)


local function CustomAnimation(um)
	local ply = um:ReadEntity()
	local act = um:ReadShort()
	ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, act)
end
usermessage.Hook("_DarkRP_CustomAnim", CustomAnimation)

local Anims = {}
Anims["Thumbs up"] = ACT_GMOD_GESTURE_AGREE
Anims["Non-verbal no"] = ACT_GMOD_GESTURE_DISAGREE
Anims["Salute"] = ACT_GMOD_GESTURE_SALUTE
Anims["Bow"] = ACT_GMOD_GESTURE_BOW
Anims["Wave"] = ACT_GMOD_GESTURE_WAVE
Anims["Follow me!"] = ACT_GMOD_GESTURE_BECON

local AnimFrame
local function AnimationMenu()
	if AnimFrame then return end

	local Panel = vgui.Create("Panel")
	Panel:SetPos(0,0)
	Panel:SetSize(ScrW(), ScrH())
	function Panel:OnMousePressed()
		AnimFrame:Close()
	end

	AnimFrame = AnimFrame or vgui.Create("DFrame", Panel)
	local Height = table.Count(Anims) * 110
	AnimFrame:SetSize(200, Height)
	AnimFrame:SetPos(ScrW()/2 + ScrW() * 0.1, ScrH()/2 - (Height/2))
	AnimFrame:SetTitle("Custom animation!")
	AnimFrame:SetVisible(true)
	AnimFrame:MakePopup()

	function AnimFrame:Close()
		Panel:Remove()
		AnimFrame:Remove()
		AnimFrame = nil
	end

	local i = 0
	for k,v in pairs(Anims) do
		i = i + 1
		local button = vgui.Create("DButton", AnimFrame)
		button:SetPos(10, (i-1)*105 + 30)
		button:SetSize(180, 100)
		button:SetText(k)

		button.DoClick = function()
			RunConsoleCommand("_DarkRP_DoAnimation", v)
		end
	end
	AnimFrame:SetSkin("DarkRP")
end
concommand.Add("_DarkRP_AnimationMenu", AnimationMenu)