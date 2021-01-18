local Anims = {}

-- Load animations after the languages for translation purposes
hook.Add("loadCustomDarkRPItems", "loadAnimations", function()
    Anims[ACT_GMOD_GESTURE_BOW] = DarkRP.getPhrase("bow")
    Anims[ACT_GMOD_TAUNT_MUSCLE] = DarkRP.getPhrase("sexy_dance")
    Anims[ACT_GMOD_GESTURE_BECON] = DarkRP.getPhrase("follow_me")
    Anims[ACT_GMOD_TAUNT_LAUGH] = DarkRP.getPhrase("laugh")
    Anims[ACT_GMOD_TAUNT_PERSISTENCE] = DarkRP.getPhrase("lion_pose")
    Anims[ACT_GMOD_GESTURE_DISAGREE] = DarkRP.getPhrase("nonverbal_no")
    Anims[ACT_GMOD_GESTURE_AGREE] = DarkRP.getPhrase("thumbs_up")
    Anims[ACT_GMOD_GESTURE_WAVE] = DarkRP.getPhrase("wave")
    Anims[ACT_GMOD_TAUNT_DANCE] = DarkRP.getPhrase("dance")
end)

function DarkRP.addPlayerGesture(anim, text)
    if not anim then DarkRP.error("Argument #1 of DarkRP.addPlayerGesture (animation/gesture) does not exist.", 2) end
    if not text then DarkRP.error("Argument #2 of DarkRP.addPlayerGesture (text) does not exist.", 2) end

    Anims[anim] = text
end

function DarkRP.removePlayerGesture(anim)
    if not anim then DarkRP.error("Argument #1 of DarkRP.removePlayerGesture (animation/gesture) does not exist.", 2) end

    Anims[anim] = nil
end

local function physGunCheck(ply)
    local hookName = "darkrp_anim_physgun_" .. ply:EntIndex()
    hook.Add("Think", hookName, function()
        if IsValid(ply) and
           ply:Alive() and
           ply:GetActiveWeapon():IsValid() and
           ply:GetActiveWeapon():GetClass() == "weapon_physgun" and
           ply:KeyDown(IN_ATTACK) and
           (ply:GetAllowWeaponsInVehicle() or not ply:InVehicle()) then
            local ent = ply:GetEyeTrace().Entity
            if IsValid(ent) and ent:IsPlayer() and not ply.SaidHi then
                ply.SaidHi = true
                ply:DoAnimationEvent(ACT_SIGNAL_GROUP)
            end
        else
            if IsValid(ply) then
                ply.SaidHi = nil
            end
            hook.Remove("Think", hookName)
        end
    end)
end

hook.Add("KeyPress", "darkrp_animations", function(ply, key)
    if key == IN_ATTACK then
        local weapon = ply:GetActiveWeapon()

        if weapon:IsValid() then
            local class = weapon:GetClass()

            -- Saying hi/hello to a player
            if class == "weapon_physgun" then
                physGunCheck(ply)

            -- Hobo throwing poop!
            elseif class == "weapon_bugbait" then
                local Team = ply:Team()
                if RPExtraTeams[Team] and RPExtraTeams[Team].hobo then
                    ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_THROW)
                end
            end
        end
    end
end)

if SERVER then
    local function CustomAnim(ply, cmd, args)
        if ply:EntIndex() == 0 then return end
        local Gesture = tonumber(args[1] or 0)
        if not Anims[Gesture] then return end

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

local function KeysAnims(um)
    local ply = um:ReadEntity()
    local act = um:ReadString()

    if not IsValid(ply) then return end
    ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, act == "usekeys" and ACT_GMOD_GESTURE_ITEM_PLACE or ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
end
usermessage.Hook("anim_keys", KeysAnims)

local function CustomAnimation(um)
    local ply = um:ReadEntity()
    local act = um:ReadShort()

    if not IsValid(ply) then return end
    ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, act, true)
end
usermessage.Hook("_DarkRP_CustomAnim", CustomAnimation)

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
    AnimFrame:SetPos(ScrW() / 2 + ScrW() * 0.1, ScrH() / 2 - (Height / 2))
    AnimFrame:SetTitle(DarkRP.getPhrase("custom_animation"))
    AnimFrame.btnMaxim:SetVisible(false)
    AnimFrame.btnMinim:SetVisible(false)
    AnimFrame:SetVisible(true)
    AnimFrame:MakePopup()
    AnimFrame:ParentToHUD()

    function AnimFrame:Close()
        Panel:Remove()
        AnimFrame:Remove()
        AnimFrame = nil
    end

    local i = 0
    for k, v in SortedPairs(Anims) do
        i = i + 1
        local button = vgui.Create("DButton", AnimFrame)
        button:SetPos(10, (i - 1) * 55 + 30)
        button:SetSize(110, 50)
        button:SetText(v)

        button.DoClick = function()
            RunConsoleCommand("_DarkRP_DoAnimation", k)
        end
    end
    AnimFrame:SetSkin(GAMEMODE.Config.DarkRPSkin)
end
concommand.Add("_DarkRP_AnimationMenu", AnimationMenu)
