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
SWEP.ViewModel = "models/weapons/c_snip_awp.mdl"
SWEP.WorldModel = "models/canofsoda/nikke/sniper.mdl"

SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false

SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Automatic = true  -- full auto enabled
SWEP.Primary.Ammo = "SMG1"

SWEP.Primary.Delay = 0.2      -- faster fire rate for auto
SWEP.Primary.Damage = 1000
SWEP.Primary.Recoil = 1

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    if SERVER then
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:GiveAmmo(1000, self.Primary.Ammo, true) -- 1000 reserve ammo added on spawn
        end
    end
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end

    self:EmitSound("Weapon_SMG1.Launch")  -- laser-like sound

    local bullet = {}
    bullet.Num = 1
    bullet.Src = self:GetOwner():GetShootPos()
    bullet.Dir = self:GetOwner():GetAimVector()
    bullet.Spread = Vector(0, 0, 0)  -- no spread, shoots straight
    bullet.Tracer = 1
    bullet.TracerName = "LaserTracer"  -- red laser trail
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
    -- Optional zoom or alternate fire code here later
end

-- Adjust how the gun is held in 3rd person (world model)
function SWEP:DrawWorldModel()
    local ply = self:GetOwner()
    if IsValid(ply) then
        local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
        if not bone then return end

        local pos, ang = ply:GetBonePosition(bone)

        -- Adjust these numbers to fine-tune the weapon's position
        pos = pos + ang:Forward() * 3 + ang:Right() * 1 + ang:Up() * 4
        ang:RotateAroundAxis(ang:Right(), 175)
        ang:RotateAroundAxis(ang:Up(), 185)

        self:SetRenderOrigin(pos)
        self:SetRenderAngles(ang)
    end

    self:DrawModel()
end
