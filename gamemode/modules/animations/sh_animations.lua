local Anims = {}

-- Load animations after the languages for translation purposes
hook.Add("loadCustomfprpItems", "loadAnimations", function()
	Anims[ACT_GMOD_GESTURE_BOW] = fprp.getPhrase("bow")
	Anims[ACT_GMOD_TAUNT_MUSCLE] = fprp.getPhrase("dance")
	Anims[ACT_GMOD_GESTURE_BECON] = fprp.getPhrase("follow_me")
	Anims[ACT_GMOD_TAUNT_LAUGH] = fprp.getPhrase("laugh")
	Anims[ACT_GMOD_TAUNT_PERSISTENCE] = fprp.getPhrase("lion_pose")
	Anims[ACT_GMOD_GESTURE_DISAGREE] = fprp.getPhrase("nonverbal_no")
	Anims[ACT_GMOD_GESTURE_AGREE] = fprp.getPhrase("thumbs_up")
	Anims[ACT_GMOD_GESTURE_WAVE] = fprp.getPhrase("wave")
end)

function fprp.addPlayerGesture(anim, text)
	if not anim then fprp.error("Argument #1 of fprp.addPlayerGesture (animation/gesture) does not exist.", 2) end
	if not text then fprp.error("Argument #2 of fprp.addPlayerGesture (text) does not exist.", 2) end

	Anims[anim] = text
end

function fprp.removePlayerGesture(anim)
	if not anim then fprp.error("Argument #1 of fprp.removePlayerGesture (animation/gesture) does not exist.", 2) end

	Anims[anim] = nil
end

hook.Add("CalcMainActivity", "fprp_animations", function(ply, velocity) -- Using hook.Add and not GM:CalcMainActivity to prevent animation problems
	-- Dropping weapons/shekel!
	if ply.anim_DroppingItem then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_DROP, true)
		ply.anim_DroppingItem = nil
	end

	-- Giving items!
	if ply.anim_GivingItem then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_GIVE, true)
		ply.anim_GivingItem = nil
	end

	if CLIENT and ply.SaidHi then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_SIGNAL_GROUP, true)
		ply.SaidHi = nil
	end

	if CLIENT and ply.ThrewPoop then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_THROW, true)
		ply.ThrewPoop = nil
	end

	if CLIENT and ply.knocking then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
		ply.knocking = nil
	end

	if CLIENT and ply.usekeys then
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
		ply.usekeys = nil
	end

	if not SERVER then return end

	-- Hobo throwing poop!
	local Weapon = ply:GetActiveWeapon()
	if RPExtraTeams[ply:Team()] and RPExtraTeams[ply:Team()].hobo and not ply.ThrewPoop and IsValid(Weapon) and Weapon:GetClass() == "weapon_bugbait" and ply:KeyDown(IN_ATTACK) then
		ply.ThrewPoop = true
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_THROW, true)


		local RP = RecipientFilter()
		RP:AddAllPlayers()

		umsg.Start("anim_throwpoop", RP)
			umsg.Entity(ply)
		umsg.End()
	elseif ply.ThrewPoop and not ply:KeyDown(IN_ATTACK) then
		ply.ThrewPoop = nil
	end

	-- Saying hi/hello to a player
	if not ply.SaidHi and IsValid(Weapon) and Weapon:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK) then
		local ent = ply:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsPlayer() then
			ply.SaidHi = true
			ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_SIGNAL_GROUP, true)

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
		if ply:EntIndex() == 0 then return end
		local Gesture = tonumber(args[1] or 0)
		if not Anims[Gesture] then return end

		local RP = RecipientFilter()
		RP:AddAllPlayers()

		umsg.Start("_fprp_CustomAnim", RP)
		umsg.Entity(ply)
		umsg.Short(Gesture)
		umsg.End()
	end
	concommand.Add("_fprp_DoAnimation", CustomAnim)
	return
end

local function DropItem(um)
	local ply = um:ReadEntity()
	if not IsValid(ply) then return end

	ply.anim_DroppingItem = true
end
usermessage.Hook("anim_dropitem", DropItem)

local function GiveItem(um)
	local ply = um:ReadEntity()
	if not IsValid(ply) then return end

	ply.anim_GivingItem = true
end
usermessage.Hook("anim_giveitem", GiveItem)

local function ThrowPoop(um)
	local ply = um:ReadEntity()
	if not IsValid(ply) then return end

	ply.ThrewPoop = true
end
usermessage.Hook("anim_throwpoop", ThrowPoop)

local function PhysgunHi(um)
	local ply = um:ReadEntity()
	if not IsValid(ply) then return end

	ply.SaidHi = true
end
usermessage.Hook("anim_sayhi", PhysgunHi)

local function KeysAnims(um)
	local ply = um:ReadEntity()
	if not IsValid(ply) then return end
	local Type = um:ReadString()
	ply[Type] = true
end
usermessage.Hook("anim_keys", KeysAnims)


local function CustomAnimation(um)
	local ply = um:ReadEntity()
	local act = um:ReadShort()

	if not IsValid(ply) then return end
	ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, act, true)
end
usermessage.Hook("_fprp_CustomAnim", CustomAnimation)

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
	local Height = table.Count(Anims) * 55 + 32
	AnimFrame:SetSize(130, Height)
	AnimFrame:SetPos(ScrW()/2 + ScrW() * 0.1, ScrH()/2 - (Height/2))
	AnimFrame:SetTitle(fprp.getPhrase("custom_animation"))
	AnimFrame:SetVisible(true)
	AnimFrame:MakePopup()

	function AnimFrame:Close()
		Panel:Remove()
		AnimFrame:Remove()
		AnimFrame = nil
	end

	local i = 0
	for k,v in SortedPairs(Anims) do
		i = i + 1
		local button = vgui.Create("DButton", AnimFrame)
		button:SetPos(10, (i-1)*55 + 30)
		button:SetSize(110, 50)
		button:SetText(v)

		button.DoClick = function()
			RunConsoleCommand("_fprp_DoAnimation", k)
		end
	end
	AnimFrame:SetSkin(GAMEMODE.Config.fprpSkin)
end
concommand.Add("_fprp_AnimationMenu", AnimationMenu)
