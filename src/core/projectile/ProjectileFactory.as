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
		public function ProjectileFactory() {
			super();
		}
		
		public static function create(key:String, g:Game, u:Unit, w:Weapon, course:Heading = null) : Projectile {
			var _local7:Point = null;
			var _local12:Number = NaN;
			var _local9:Number = NaN;
			var _local13:Number = NaN;
			var _local6:ISound = null;
			if(u == null) {
				return null;
			}
			if(w == null) {
				return null;
			}
			if(g.me.ship == null && w.ttl < 2000) {
				return null;
			}
			if(u.movieClip != g.camera.focusTarget) {
				if(isNaN(u.pos.x)) {
					return null;
				}
				if(course != null) {
					_local7 = g.camera.getCameraCenter().subtract(course.pos);
				} else {
					_local7 = g.camera.getCameraCenter().subtract(u.pos);
				}
				_local12 = _local7.x * _local7.x + _local7.y * _local7.y;
				_local9 = 450;
				if(w.global && _local12 > 10 * 60 * 60 * 1000) {
					return null;
				}
				_local13 = 0;
				if(w.type == "instant") {
					_local13 = w.range;
				} else {
					_local13 = (Math.abs(w.speed) + _local9) * 0.001 * w.ttl + 500;
				}
				if(_local12 > _local13 * _local13) {
					return null;
				}
			}
			var _local14:IDataManager = DataLocator.getService();
			var _local11:Object = _local14.loadKey("Projectiles",key);
			var _local10:Projectile = g.projectileManager.getProjectile();
			if(w.maxProjectiles > 0) {
				w.projectiles.push(_local10);
				if(w.projectiles.length > w.maxProjectiles) {
					w.projectiles[0].destroy(false);
				}
			}
			_local10.name = _local11.name;
			_local10.useShipSystem = w.useShipSystem;
			_local10.unit = u;
			if(u is EnemyShip || u is Turret) {
				_local10.isEnemy = true;
			} else if(u is PlayerShip) {
				_local10.ps = u as PlayerShip;
			}
			_local10.weapon = w;
			if(w.dmg.type == 6) {
				_local10.isHeal = true;
			} else {
				_local10.isHeal = false;
			}
			_local10.debuffType = w.debuffType;
			_local10.collisionRadius = _local11.collisionRadius;
			_local10.ttl = w.ttl;
			_local10.ttlMax = w.ttl;
			_local10.numberOfHits = w.numberOfHits;
			_local10.speedMax = w.speed;
			_local10.rotationSpeedMax = w.rotationSpeed;
			_local10.acceleration = w.acceleration;
			_local10.dmgRadius = w.dmgRadius;
			_local10.course.speed.x = u.speed.x;
			_local10.course.speed.y = u.speed.y;
			_local10.alive = true;
			_local10.randomAngle = w.randomAngle;
			_local10.wave = _local11.wave;
			w.waveDirection = w.waveDirection == 1 ? -1 : 1;
			_local10.waveDirection = w.waveDirection;
			_local10.waveAmplitude = _local11.waveAmplitude;
			_local10.waveFrequency = _local11.waveFrequency;
			_local10.boomerangReturnTime = _local11.boomerangReturnTime;
			_local10.boomerangReturning = false;
			_local10.clusterProjectile = _local11.clusterProjectile;
			_local10.clusterNrOfProjectiles = _local11.clusterNrOfProjectiles;
			_local10.clusterNrOfSplits = _local11.clusterNrOfSplits;
			_local10.clusterAngle = _local11.clusterAngle;
			_local10.aiDelayedAcceleration = _local11.aiDelayedAcceleration;
			_local10.aiDelayedAccelerationTime = _local11.aiDelayedAccelerationTime;
			_local10.switchTexturesByObj(_local11);
			_local10.blendMode = _local11.blendMode;
			if(_local11.hasOwnProperty("aiAlwaysExplode")) {
				_local10.aiAlwaysExplode = _local11.aiAlwaysExplode;
			}
			if(_local11.ribbonTrail) {
				_local10.ribbonTrail = g.ribbonTrailPool.getRibbonTrail();
				_local10.hasRibbonTrail = true;
				_local10.ribbonTrail.color = _local11.ribbonColor;
				_local10.ribbonTrail.movingRatio = _local11.ribbonSpeed;
				_local10.ribbonTrail.alphaRatio = _local11.ribbonAlpha;
				_local10.ribbonThickness = _local11.ribbonThickness;
				_local10.ribbonTrail.blendMode = "add";
				_local10.ribbonTrail.texture = TextureLocator.getService().getTextureMainByTextureName(_local11.ribbonTexture || "ribbon_trail");
				_local10.ribbonTrail.followTrailSegmentsLine(_local10.followingRibbonSegmentLine);
				_local10.ribbonTrail.isPlaying = false;
				_local10.ribbonTrail.visible = false;
				_local10.useRibbonOffset = _local11.useRibbonOffset;
			}
			var _local8:Boolean = w.reloadTime < 60 && Math.random() < 0.4;
			if(_local11.thrustEffect != null && !_local8) {
				_local10.thrustEmitters = EmitterFactory.create(_local11.thrustEffect,g,u.pos.x,u.pos.y,_local10,true);
			}
			_local10.forcedRotation = _local11.forcedRotation;
			if(_local10.forcedRotation) {
				_local10.forcedRotationAngle = Math.random() * 2 * 3.141592653589793 - 3.141592653589793;
				_local10.forcedRotationSpeed = _local11.forcedRotationSpeed;
			}
			_local10.explosionSound = _local11.explosionSound;
			if(_local11.explosionSound != null) {
				_local6 = SoundLocator.getService();
				_local6.preCacheSound(_local11.explosionSound);
			}
			_local10.explosionEffect = _local11.explosionEffect;
			_local10.stateMachine.changeState(AIStateFactory.createProjectileAI(_local11,g,_local10));
			return _local10;
		}
	}
}

