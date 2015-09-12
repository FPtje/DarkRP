AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("commands.lua")

util.AddNetworkString("DarkRP_shipmentSpawn")

function ENT:Initialize()
    local contents = CustomShipments[self:Getcontents() or ""]

    self.Destructed = false
    self:SetModel(contents and contents.shipmodel or "models/Items/item_item_crate.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self:StartSpawning()
    self.damage = 100
    local phys = self:GetPhysicsObject()
    phys:Wake()

    -- Create a serverside gun model
    -- it's required serverside to be able to get OBB information clientside
    self:SetgunModel(IsValid(self:GetgunModel()) and self:GetgunModel() or ents.Create("prop_physics"))
    self:GetgunModel():SetModel(contents.model)
    self:GetgunModel():SetPos(self:GetPos())
    self:GetgunModel():Spawn()
    self:GetgunModel():Activate()
    self:GetgunModel():SetSolid(SOLID_NONE)
    self:GetgunModel():SetParent(self)

    phys = self:GetgunModel():GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    -- The following code should not be reached
    if self:Getcount() < 1 then
        self.PlayerUse = false
        SafeRemoveEntity(self)
        if not contents then
            DarkRP.error("Shipment created with zero or fewer elements.", 2)
        else
            DarkRP.error(string.format("Some smartass thought they were clever by setting the 'amount' of shipment '%s' to 0.\nWhat the fuck do you expect the use of an empty shipment to be?", contents.name), 2)
        end
    end
end

function ENT:StartSpawning()
    self.locked = true
    timer.Simple(0, function()
        net.Start("DarkRP_shipmentSpawn")
            net.WriteEntity(self)
        net.Broadcast()
    end)

    timer.Simple(0, function() self.locked = true end) -- when spawning through pocket it might be unlocked
    timer.Simple(GAMEMODE.Config.shipmentspawntime, function() if IsValid(self) then self.locked = false end end)
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)
    if not self.locked then
        self.damage = self.damage - dmg:GetDamage()
        if self.damage <= 0 then
            self:Destruct()
        end
    end
end

function ENT:SetContents(s, c)
    self:Setcontents(s)
    self:Setcount(c)
end

function ENT:Use()
    if self.IsPocketed then return end
    if type(self.PlayerUse) == "function" then
        local val = self:PlayerUse(activator, caller)
        if val ~= nil then return val end
    elseif self.PlayerUse ~= nil then
        return self.PlayerUse
    end

    if not self.locked then
        self.locked = true -- One activation per second
        self.sparking = true
        self:Setgunspawn(CurTime() + 1)
        timer.Create(self:EntIndex() .. "crate", 1, 1, function()
            if not IsValid(self) then return end
            self.SpawnItem(self)
        end)
    end
end

function ENT:SpawnItem()
    if not IsValid(self) then return end
    timer.Remove(self:EntIndex() .. "crate")
    self.sparking = false
    local count = self:Getcount()
    local pos = self:GetPos()
    if count <= 1 then self:Remove() end
    local contents = self:Getcontents()

    if CustomShipments[contents] and CustomShipments[contents].spawn then return CustomShipments[contents].spawn(self, CustomShipments[contents]) end

    local weapon = ents.Create("spawned_weapon")

    local weaponAng = self:GetAngles()
    local weaponPos = self:GetAngles():Up() * 40 + weaponAng:Up() * (math.sin(CurTime() * 3) * 8)
    weaponAng:RotateAroundAxis(weaponAng:Up(), (CurTime() * 180) % 360)

    if not CustomShipments[contents] then
        weapon:Remove()
        self:Remove()
        return
    end

    local class = CustomShipments[contents].entity
    local model = CustomShipments[contents].model

    weapon:SetWeaponClass(class)
    weapon:SetModel(model)
    weapon.ammoadd = self.ammoadd or (weapons.Get(class) and weapons.Get(class).Primary.DefaultClip)
    weapon.clip1 = self.clip1
    weapon.clip2 = self.clip2
    weapon:SetPos(self:GetPos() + weaponPos)
    weapon:SetAngles(weaponAng)
    weapon.nodupe = true
    weapon:Spawn()
    count = count - 1
    self:Setcount(count)
    self.locked = false
end

function ENT:Think()
    if self.sparking then
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetMagnitude(1)
        effectdata:SetScale(1)
        effectdata:SetRadius(2)
        util.Effect("Sparks", effectdata)
    end
end

function ENT:Destruct()
    if self.Destructed then return end
    self.Destructed = true
    local vPoint = self:GetPos()
    local contents = self:Getcontents()
    local count = self:Getcount()
    local class = nil
    local model = nil

    if CustomShipments[contents] then
        class = CustomShipments[contents].entity
        model = CustomShipments[contents].model
    else
        self:Remove()
        return
    end


    local weapon = ents.Create("spawned_weapon")
    weapon:SetModel(model)
    weapon:SetWeaponClass(class)
    weapon:SetPos(Vector(vPoint.x, vPoint.y, vPoint.z + 5))
    weapon.ammoadd = self.ammoadd or (weapons.Get(class) and weapons.Get(class).Primary.DefaultClip)
    weapon.nodupe = true
    weapon:Spawn()
    weapon.dt.amount = count

    self:Remove()
end

function ENT:Touch(ent)
    -- the .USED var is also used in other mods for the same purpose
    if not ent.IsSpawnedShipment or
        self:Getcontents() ~= ent:Getcontents() or
        self.locked or ent.locked or
        self.USED or ent.USED or
        self.hasMerged or ent.hasMerged then return end

    -- Both hasMerged and USED are used by third party mods. Keep both in.
    ent.hasMerged = true
    ent.USED = true

    local selfCount, entCount = self:Getcount(), ent:Getcount()
    local count = selfCount + entCount
    self:Setcount(count)

    -- Merge ammo information (avoid ammo exploits)
    if self.clip1 or ent.clip1 then -- If neither have a clip, use default clip, otherwise merge the two
        self.clip1 = math.floor(((ent.clip1 or 0) * entCount + (self.clip1 or 0) * selfCount) / count)
    end

    if self.clip2 or ent.clip2 then
        self.clip2 = math.floor(((ent.clip2 or 0) * entCount + (self.clip2 or 0) * selfCount) / count)
    end

    if self.ammoadd or ent.ammoadd then
        self.ammoadd = math.floor(((ent.ammoadd or 0) * entCount + (self.ammoadd or 0) * selfCount) / count)
    end

    ent:Remove()
end
