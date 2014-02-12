if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Weapon Checker"
	SWEP.Slot = 1
	SWEP.SlotPos = 9
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "DarkRP Developers"
SWEP.Instructions = "Left click to weapon check\nRight click to confiscate weapons\nReload to give back the weapons"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

if CLIENT then
	usermessage.Hook("weaponcheck_time", function(um)
		local wep = um:ReadEntity()
		local time = um:ReadLong()

		wep.IsWeaponChecking = true
		wep.StartCheck = CurTime()
		wep.WeaponCheckTime = time
		wep.EndCheck = CurTime() + time

		wep.Dots = wep.Dots or ""
		timer.Create("WeaponCheckDots", 0.5, 0, function()
			if not wep:IsValid() then timer.Destroy("WeaponCheckDots") return end
			local len = string.len(wep.Dots)
			local dots = {[0]=".", [1]="..", [2]="...", [3]=""}
			wep.Dots = dots[len]
		end)
	end)
end

function SWEP:Deploy()
	return true
end

function SWEP:DrawWorldModel() end

function SWEP:PreDrawViewModel(vm)
	return true
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() or self.IsWeaponChecking then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)

	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():Distance(self.Owner:GetPos()) > 100 then
		return
	end

	if SERVER then
		self.Owner:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
		timer.Simple(0.3, function() self.Owner:EmitSound("npc/combine_soldier/gear5.wav", 50, 100) end)
		return
	end

	local result = {}
	for k,v in pairs(trace.Entity:GetWeapons()) do
		if not v:IsValid() then continue end
		local class = v:GetClass()

		if GAMEMODE.Config.weaponCheckerHideDefault and (table.HasValue(GAMEMODE.Config.DefaultWeapons, class) or
			((trace.Entity:hasDarkRPPrivilege("rp_tool") or trace.Entity:IsAdmin()) and table.HasValue(GAMEMODE.Config.AdminWeapons, class)) or
			trace.Entity:getJobTable() and trace.Entity:getJobTable().weapons and table.HasValue(trace.Entity:getJobTable().weapons, class)) then
			continue
		end

		if (GAMEMODE.Config.weaponCheckerHideNoLicense and GAMEMODE.NoLicense[class]) or GAMEMODE.Config.noStripWeapons[class] then continue end

		table.insert(result, v:GetPrintName() and language.GetPhrase(v:GetPrintName()) or v:GetClass())
	end
	result = table.concat(result, ", ")

	if result == "" then
		self.Owner:ChatPrint(DarkRP.getPhrase("no_illegal_weapons", trace.Entity:Nick()))
	else
		self.Owner:ChatPrint(DarkRP.getPhrase("persons_weapons", trace.Entity:Nick()))
		if string.len(result) >= 126 then
			local amount = math.ceil(string.len(result) / 126)
			for i = 1, amount, 1 do
				self.Owner:ChatPrint(string.sub(result, (i-1) * 126, i * 126 - 1))
			end
		else
			self.Owner:ChatPrint(result)
		end
	end
end

function SWEP:SecondaryAttack()
	if CLIENT or self.IsWeaponChecking then return end
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.2)

	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():Distance(self.Owner:GetPos()) > 100 then
		return
	end

	if SERVER then
		self.IsWeaponChecking = true
		self.StartCheck = CurTime()
		self.WeaponCheckTime = math.Rand(5, 10)
		umsg.Start("weaponcheck_time", self.Owner)
			umsg.Entity(self)
			umsg.Long(self.WeaponCheckTime)
		umsg.End()
		self.EndCheck = CurTime() + self.WeaponCheckTime

		timer.Create("WeaponCheckSounds", 0.5, self.WeaponCheckTime * 2, function()
			if not IsValid(self) then return end
			self:EmitSound("npc/combine_soldier/gear5.wav", 100, 100)
		end)
	end
end

SWEP.OnceReload = true
function SWEP:Reload()
	if CLIENT or not self.Weapon.OnceReload then return end
	self.Weapon.OnceReload = false
	timer.Simple(1, function() self.Weapon.OnceReload = true end)
	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() or trace.Entity:GetPos():Distance(self.Owner:GetPos()) > 100 then
		return
	end

	if not trace.Entity:GetTable().ConfiscatedWeapons then
		DarkRP.notify(self.Owner, 1, 4, DarkRP.getPhrase("no_weapons_confiscated", trace.Entity:Nick()))
		return
	else
		for k,v in pairs(trace.Entity.ConfiscatedWeapons) do
			local wep = trace.Entity:Give(v[1])
			trace.Entity:RemoveAllAmmo()
			trace.Entity:SetAmmo(v[2], v[3], false)
			trace.Entity:SetAmmo(v[4], v[5], false)

			wep:SetClip1(v[6])
			wep:SetClip2(v[7])

		end
		DarkRP.notify(self.Owner, 2, 4, DarkRP.getPhrase("returned_persons_weapons", trace.Entity:Nick()))
		trace.Entity:GetTable().ConfiscatedWeapons = nil
	end
end

function SWEP:Holster()
	self.IsWeaponChecking = false
	if SERVER then timer.Destroy("WeaponCheckSounds") end
	if CLIENT then timer.Destroy("WeaponCheckDots") end
	return true
end

function SWEP:Succeed()
	if not IsValid(self.Owner) then return end
	self.IsWeaponChecking = false

	if CLIENT then return end
	local result = {}
	local stripped = {}
	local trace = self.Owner:GetEyeTrace()
	if not IsValid(trace.Entity) or not trace.Entity:IsPlayer() then return end
	for k,v in pairs(trace.Entity:GetWeapons()) do
		if not v:IsValid() then continue end
		local class = v:GetClass()

		if GAMEMODE.Config.weaponCheckerHideDefault and (table.HasValue(GAMEMODE.Config.DefaultWeapons, class) or
			((trace.Entity:hasDarkRPPrivilege("rp_tool") or trace.Entity:IsAdmin()) and table.HasValue(GAMEMODE.Config.AdminWeapons, class)) or
			trace.Entity:getJobTable() and trace.Entity:getJobTable().weapons and table.HasValue(trace.Entity:getJobTable().weapons, class)) then
			continue
		end

		if (GAMEMODE.Config.weaponCheckerHideNoLicense and GAMEMODE.NoLicense[class]) or GAMEMODE.Config.noStripWeapons[class] then continue end

		trace.Entity:StripWeapon(class)
		table.insert(result, class)
		table.insert(stripped, {class, trace.Entity:GetAmmoCount(v:GetPrimaryAmmoType()),
		v:GetPrimaryAmmoType(), trace.Entity:GetAmmoCount(v:GetSecondaryAmmoType()), v:GetSecondaryAmmoType(),
		v:Clip1(), v:Clip2()})
	end
	result = table.concat(result, ", ")

	if not trace.Entity:GetTable().ConfiscatedWeapons then
		trace.Entity:GetTable().ConfiscatedWeapons = stripped
	else
		for k,v in pairs(stripped) do
			local found = false
			for a,b in pairs(trace.Entity:GetTable().ConfiscatedWeapons) do
				if b[1] == v[1] then
					found = true
					break
				end
			end

			if not found then
				table.insert(trace.Entity:GetTable().ConfiscatedWeapons, v)
			end
		end
	end

	if result == "" then
		self.Owner:ChatPrint(DarkRP.getPhrase("no_illegal_weapons", trace.Entity:Nick()))
		self.Owner:EmitSound("npc/combine_soldier/gear5.wav", 50, 100)
		timer.Simple(0.3, function() self.Owner:EmitSound("npc/combine_soldier/gear5.wav", 50, 100) end)
	else
		self.Owner:EmitSound("ambient/energy/zap1.wav", 50, 100)
		self.Owner:ChatPrint(DarkRP.getPhrase("confiscated_these_weapons"))
		if string.len(result) >= 126 then
			local amount = math.ceil(string.len(result) / 126)
			for i = 1, amount, 1 do
				self.Owner:ChatPrint(string.sub(result, (i-1) * 126, i * 126 - 1))
			end
		else
			self.Owner:ChatPrint(result)
		end
	end
end

function SWEP:Fail()
	self.IsWeaponChecking = false
	self:SetWeaponHoldType("normal")
	if SERVER then timer.Destroy("WeaponCheckSounds") end
	if CLIENT then timer.Destroy("WeaponCheckDots") end
end

function SWEP:Think()
	if self.IsWeaponChecking and self.EndCheck then
		local trace = self.Owner:GetEyeTrace()
		if not IsValid(trace.Entity) then
			self:Fail()
		end
		if trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 or not trace.Entity:IsPlayer() then
			self:Fail()
		end
		if self.EndCheck <= CurTime() then
			self:Succeed()
		end
	end
end

function SWEP:DrawHUD()
	if self.IsWeaponChecking and self.EndCheck then
		self.Dots = self.Dots or ""
		local w = ScrW()
		local h = ScrH()
		local x,y,width,height = w/2-w/10, h/2, w/5, h/15
		draw.RoundedBox(8, x, y, width, height, Color(10,10,10,120))

		local time = self.EndCheck - self.StartCheck
		local curtime = CurTime() - self.StartCheck
		local status = math.Clamp(curtime/time, 0, 1)
		local BarWidth = status * (width - 16)
		local cornerRadius = math.Min(8, BarWidth/3*2 - BarWidth/3*2%2)
		draw.RoundedBox(cornerRadius, x+8, y+8, BarWidth, height-16, Color(0, 0+(status*255), 255-(status*255), 255))

		draw.DrawNonParsedSimpleText(DarkRP.getPhrase("checking_weapons")..self.Dots, "Trebuchet24", w/2, y + height/2, Color(255,255,255,255), 1, 1)
	end
end
