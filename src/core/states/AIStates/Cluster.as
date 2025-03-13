package core.states.AIStates {
	import core.projectile.Projectile;
	import core.projectile.ProjectileFactory;
	import core.scene.Game;
	import core.states.IState;
	import generics.Util;
	
	public class Cluster extends ProjectileBullet implements IState {
		protected var newProjectile:Projectile;
		private var clusterAngle:Number;
		
		public function Cluster(g:Game, p:Projectile) {
			super(g,p);
		}
		
		override public function enter() : void {
			clusterAngle = Util.degreesToRadians(p.clusterAngle);
			super.enter();
		}
		
		override public function execute() : void {
			var _local4:Number = NaN;
			var _local5:int = 0;
			var _local1:Projectile = null;
			var _local3:Number = NaN;
			var _local2:Number = 33;
			if(p.ttl - 1 < _local2 && p.clusterNrOfSplits > 0) {
				_local4 = clusterAngle;
				if(p.clusterNrOfProjectiles > 1) {
					_local4 = Math.floor(p.clusterNrOfProjectiles / 2) * clusterAngle;
					if(p.clusterNrOfProjectiles % 2 == 0) {
						_local4 -= clusterAngle / 2;
					}
				}
				_local5 = 0;
				while(_local5 < p.clusterNrOfProjectiles) {
					_local1 = ProjectileFactory.create(p.clusterProjectile,m,p.unit,p.weapon);
					if(_local1 == null) {
						return;
					}
					_local1.course.copy(p.course);
					_local1.course.rotation -= _local4;
					_local3 = p.course.speed.length;
					_local1.course.speed.x = Math.cos(_local1.course.rotation) * _local3;
					_local1.course.speed.y = Math.sin(_local1.course.rotation) * _local3;
					_local1.clusterNrOfSplits = p.clusterNrOfSplits - 1;
					m.projectileManager.activateProjectile(_local1);
					if(p.clusterNrOfProjectiles > 4) {
						_local1.ttl = 0.6 * p.ttlMax;
					} else {
						_local1.ttl = p.ttlMax;
					}
					_local1.numberOfHits = 1;
					_local4 -= clusterAngle;
					_local5++;
				}
			}
			super.execute();
		}
	}
}

