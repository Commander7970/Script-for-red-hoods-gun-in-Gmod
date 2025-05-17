AddCSLuaFile()

SWEP.PrintName = "Red Hood Sniper"
SWEP.Author = "Custom Weapon"
SWEP.Instructions = "A wolf has to die at the bottom of the well."

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"
SWEP.Category = "Red Hood"

SWEP.HoldType = "ar2"

function SWEP:Reload()
    if self:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 then
        self:DefaultReload(ACT_VM_RELOAD)
        self:SetNextPrimaryFire(CurTime() + 2)
    end
end

SWEP.UseHands = true
SWEP.ViewModel = "models/canofsoda/nikke/sniper.mdl" -- Your sniper model
SWEP.WorldModel = "models/canofsoda/nikke/sniper.mdl"

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = 18
SWEP.Primary.DefaultClip = -1  -- Prevent GMod from setting weird default clip
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

function SWEP:GetViewModelPosition(pos, ang)
    -- Move the gun slightly forward and right, adjust the angle a bit so it looks natural
    pos = pos + ang:Forward() * 10   -- Move 5 units forward
    pos = pos + ang:Right() * 15     -- Move 2 units to the right
    pos = pos + ang:Up() * -18      -- Move 2 units down (negative up)

    ang:RotateAroundAxis(ang:Right(), -5)   -- Tilt gun slightly down
    ang:RotateAroundAxis(ang:Up(), 10)      -- Rotate gun a bit to the right

    return pos, ang
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

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()
    if IsValid(ply) then
        local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
        if not bone then return end

        local pos, ang = ply:GetBonePosition(bone)

        pos = pos + ang:Forward() * 3 + ang:Right() * 1 + ang:Up() * 4
        ang:RotateAroundAxis(ang:Right(), 175)
        ang:RotateAroundAxis(ang:Up(), 185)

        self:SetRenderOrigin(pos)
        self:SetRenderAngles(ang)
    end

    self:DrawModel()
end

-- Add these at the top with your other variables:
SWEP.ADS = false
SWEP.ADSFOV = 45       -- how much FOV zoom when aiming down sights
SWEP.NormalFOV = 90    -- your normal viewmodel FOV
SWEP.ADSPos = Vector(-2, 0, 1)   -- tweak this vector to move gun closer to center when aiming
SWEP.ADSAng = Angle(0, 0, 0)     -- tweak this for gun angle when aiming

function SWEP:SecondaryAttack()
    if self.ADS then
        self:ExitADS()
    else
        self:EnterADS()
    end
    self:SetNextSecondaryFire(CurTime() + 0.3) -- debounce right click
end

function SWEP:EnterADS()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    self.ADS = true
    owner:SetFOV(self.ADSFOV, 0.2)  -- zoom in over 0.2 seconds
end

function SWEP:ExitADS()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    self.ADS = false
    owner:SetFOV(self.NormalFOV, 0.2)  -- zoom back out over 0.2 seconds
end

function SWEP:GetViewModelPosition(pos, ang)
    if self.ADS then
        pos = pos + self.ADSPos
        ang = ang + self.ADSAng
    else
        -- Your original position adjustments here, for example:
        pos = pos + ang:Forward() * 10
        pos = pos + ang:Right() * 13
        pos = pos + ang:Up() * -16

        ang:RotateAroundAxis(ang:Right(), -10)
        ang:RotateAroundAxis(ang:Up(), 15)
    end

    return pos, ang
end
