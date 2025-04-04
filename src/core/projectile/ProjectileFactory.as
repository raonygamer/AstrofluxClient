package core.projectile {
import core.particle.EmitterFactory;
import core.scene.Game;
import core.ship.EnemyShip;
import core.ship.PlayerShip;
import core.states.AIStates.AIStateFactory;
import core.turret.Turret;
import core.unit.Unit;
import core.weapon.Weapon;

import data.DataLocator;
import data.IDataManager;

import flash.geom.Point;

import movement.Heading;

import sound.ISound;
import sound.SoundLocator;

import textures.TextureLocator;

public class ProjectileFactory {
    public static function create(key:String, g:Game, u:Unit, w:Weapon, course:Heading = null):Projectile {
        var _loc6_:Point = null;
        var _loc7_:Number = NaN;
        var _loc10_:Number = NaN;
        var _loc8_:Number = NaN;
        var _loc13_:ISound = null;
        if (u == null) {
            return null;
        }
        if (w == null) {
            return null;
        }
        if (g.me.ship == null && w.ttl < 2000) {
            return null;
        }
        if (u.movieClip != g.camera.focusTarget) {
            if (isNaN(u.pos.x)) {
                return null;
            }
            if (course != null) {
                _loc6_ = g.camera.getCameraCenter().subtract(course.pos);
            } else {
                _loc6_ = g.camera.getCameraCenter().subtract(u.pos);
            }
            _loc7_ = _loc6_.x * _loc6_.x + _loc6_.y * _loc6_.y;
            _loc10_ = 450;
            if (w.global && _loc7_ > 10 * 60 * 60 * 1000) {
                return null;
            }
            _loc8_ = 0;
            if (w.type == "instant") {
                _loc8_ = w.range;
            } else {
                _loc8_ = (Math.abs(w.speed) + _loc10_) * 0.001 * w.ttl + 500;
            }
            if (_loc7_ > _loc8_ * _loc8_) {
                return null;
            }
        }
        var _loc14_:IDataManager = DataLocator.getService();
        var _loc12_:Object = _loc14_.loadKey("Projectiles", key);
        var _loc11_:Projectile = g.projectileManager.getProjectile();
        if (w.maxProjectiles > 0) {
            w.projectiles.push(_loc11_);
            if (w.projectiles.length > w.maxProjectiles) {
                w.projectiles[0].destroy(false);
            }
        }
        _loc11_.name = _loc12_.name;
        _loc11_.useShipSystem = w.useShipSystem;
        _loc11_.unit = u;
        if (u is EnemyShip || u is Turret) {
            _loc11_.isEnemy = true;
        } else if (u is PlayerShip) {
            _loc11_.ps = u as PlayerShip;
        }
        _loc11_.weapon = w;
        if (w.dmg.type == 6) {
            _loc11_.isHeal = true;
        } else {
            _loc11_.isHeal = false;
        }
        _loc11_.debuffType = w.debuffType;
        _loc11_.collisionRadius = _loc12_.collisionRadius;
        _loc11_.ttl = w.ttl;
        _loc11_.ttlMax = w.ttl;
        _loc11_.numberOfHits = w.numberOfHits;
        _loc11_.speedMax = w.speed;
        _loc11_.rotationSpeedMax = w.rotationSpeed;
        _loc11_.acceleration = w.acceleration;
        _loc11_.dmgRadius = w.dmgRadius;
        _loc11_.course.speed.x = u.speed.x;
        _loc11_.course.speed.y = u.speed.y;
        _loc11_.alive = true;
        _loc11_.randomAngle = w.randomAngle;
        _loc11_.wave = _loc12_.wave;
        w.waveDirection = w.waveDirection == 1 ? -1 : 1;
        _loc11_.waveDirection = w.waveDirection;
        _loc11_.waveAmplitude = _loc12_.waveAmplitude;
        _loc11_.waveFrequency = _loc12_.waveFrequency;
        _loc11_.boomerangReturnTime = _loc12_.boomerangReturnTime;
        _loc11_.boomerangReturning = false;
        _loc11_.clusterProjectile = _loc12_.clusterProjectile;
        _loc11_.clusterNrOfProjectiles = _loc12_.clusterNrOfProjectiles;
        _loc11_.clusterNrOfSplits = _loc12_.clusterNrOfSplits;
        _loc11_.clusterAngle = _loc12_.clusterAngle;
        _loc11_.aiDelayedAcceleration = _loc12_.aiDelayedAcceleration;
        _loc11_.aiDelayedAccelerationTime = _loc12_.aiDelayedAccelerationTime;
        _loc11_.switchTexturesByObj(_loc12_);
        _loc11_.blendMode = _loc12_.blendMode;
        if (_loc12_.hasOwnProperty("aiAlwaysExplode")) {
            _loc11_.aiAlwaysExplode = _loc12_.aiAlwaysExplode;
        }
        if (_loc12_.ribbonTrail) {
            _loc11_.ribbonTrail = g.ribbonTrailPool.getRibbonTrail();
            _loc11_.hasRibbonTrail = true;
            _loc11_.ribbonTrail.color = _loc12_.ribbonColor;
            _loc11_.ribbonTrail.movingRatio = _loc12_.ribbonSpeed;
            _loc11_.ribbonTrail.alphaRatio = _loc12_.ribbonAlpha;
            _loc11_.ribbonThickness = _loc12_.ribbonThickness;
            _loc11_.ribbonTrail.blendMode = "add";
            _loc11_.ribbonTrail.texture = TextureLocator.getService().getTextureMainByTextureName(_loc12_.ribbonTexture || "ribbon_trail");
            _loc11_.ribbonTrail.followTrailSegmentsLine(_loc11_.followingRibbonSegmentLine);
            _loc11_.ribbonTrail.isPlaying = false;
            _loc11_.ribbonTrail.visible = false;
            _loc11_.useRibbonOffset = _loc12_.useRibbonOffset;
        }
        var _loc9_:Boolean = w.reloadTime < 60 && Math.random() < 0.4;
        if (_loc12_.thrustEffect != null && !_loc9_) {
            _loc11_.thrustEmitters = EmitterFactory.create(_loc12_.thrustEffect, g, u.pos.x, u.pos.y, _loc11_, true);
        }
        _loc11_.forcedRotation = _loc12_.forcedRotation;
        if (_loc11_.forcedRotation) {
            _loc11_.forcedRotationAngle = Math.random() * 2 * 3.141592653589793 - 3.141592653589793;
            _loc11_.forcedRotationSpeed = _loc12_.forcedRotationSpeed;
        }
        _loc11_.explosionSound = _loc12_.explosionSound;
        if (_loc12_.explosionSound != null) {
            _loc13_ = SoundLocator.getService();
            _loc13_.preCacheSound(_loc12_.explosionSound);
        }
        _loc11_.explosionEffect = _loc12_.explosionEffect;
        _loc11_.stateMachine.changeState(AIStateFactory.createProjectileAI(_loc12_, g, _loc11_));
        return _loc11_;
    }

    public function ProjectileFactory() {
        super();
    }
}
}

