AddCSLuaFile()

SWEP.PrintName = "Red Hood Sniper"
SWEP.Author = "Custom Weapon"
SWEP.Instructions = "A wolf has to die at the bottom of the well."

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"
SWEP.Category = "Red Hood"

SWEP.HoldType = "ar2"

SWEP.UseHands = false  -- Disable default hands since we're forcing worldmodel

SWEP.ViewModel = "models/canofsoda/nikke/sniper.mdl"  -- worldmodel path as viewmodel
SWEP.WorldModel = "models/canofsoda/nikke/sniper.mdl"

SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = 18
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"

SWEP.Primary.Delay = 0.25
SWEP.Primary.Damage = 1000
SWEP.Primary.Recoil = 1

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)

    if SERVER then
        timer.Simple(0, function()
            if not IsValid(self) then return end
            local owner = self:GetOwner()
            if IsValid(owner) and owner:IsPlayer() then
                owner:GiveAmmo(1000, self.Primary.Ammo, true)
            end
        end)
    end
end

function SWEP:Equip(owner)
    if SERVER and IsValid(owner) and owner:IsPlayer() then
        owner:GiveAmmo(1000, self.Primary.Ammo, true)
    end
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

    local bullet = {}
    bullet.Num = 1
    bullet.Src = self:GetOwner():GetShootPos()
    bullet.Dir = self:GetOwner():GetAimVector()
    bullet.Spread = Vector(0, 0, 0)
    bullet.Tracer = 1
    bullet.TracerName = "LaserTracer"
    bullet.Force = 10
    bullet.Damage = self.Primary.Damage

    bullet.Callback = function(attacker, tr, dmginfo)
        local effectdata = EffectData()
        effectdata:SetOrigin(tr.HitPos)
        util.Effect("Explosion", effectdata)

        util.BlastDamage(attacker, attacker, tr.HitPos, 150, self.Primary.Damage)
    end

    self:GetOwner():FireBullets(bullet)
    self:TakePrimaryAmmo(1)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
    -- Optional zoom or alt fire
end

-- Override to draw worldmodel in first person attached to view
function SWEP:ViewModelDrawn()
    if CLIENT then
        local vm = self.Owner:GetViewModel()
        if IsValid(vm) then
            vm:SetNoDraw(true) -- Hide default viewmodel to avoid double drawing
        end

        -- Draw the world model attached to the player's view origin
        self:SetRenderOrigin(self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 10 + self.Owner:EyeAngles():Right() * 4 + self.Owner:EyeAngles():Up() * -4)
        self:SetRenderAngles(self.Owner:EyeAngles())
        self:DrawModel()
    end
end

-- Disable the normal DrawWorldModel so we don't double draw in third person
function SWEP:DrawWorldModel()
    -- Optional: keep drawing the worldmodel in third person or not
    if not self.Owner or not IsValid(self.Owner) or self.Owner ~= LocalPlayer() then
        self:DrawModel()
    end
end
