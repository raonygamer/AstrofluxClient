package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.projectile.ProjectileFactory;
	import core.scene.Game;
	import core.states.IState;
	import generics.Util;
	
	public class Cluster extends ProjectileBullet implements IState
	{
		protected var newProjectile:Projectile;
		
		private var clusterAngle:Number;
		
		public function Cluster(g:Game, p:Projectile)
		{
			super(g,p);
		}
		
		override public function enter() : void
		{
			clusterAngle = Util.degreesToRadians(p.clusterAngle);
			super.enter();
		}
		
		override public function execute() : void
		{
			var _loc3_:Number = NaN;
			var _loc4_:int = 0;
			var _loc2_:Projectile = null;
			var _loc5_:Number = NaN;
			var _loc1_:Number = 33;
			if(p.ttl - 1 < _loc1_ && p.clusterNrOfSplits > 0)
			{
				_loc3_ = clusterAngle;
				if(p.clusterNrOfProjectiles > 1)
				{
					_loc3_ = Math.floor(p.clusterNrOfProjectiles / 2) * clusterAngle;
					if(p.clusterNrOfProjectiles % 2 == 0)
					{
						_loc3_ -= clusterAngle / 2;
					}
				}
				_loc4_ = 0;
				while(_loc4_ < p.clusterNrOfProjectiles)
				{
					_loc2_ = ProjectileFactory.create(p.clusterProjectile,m,p.unit,p.weapon);
					if(_loc2_ == null)
					{
						return;
					}
					_loc2_.course.copy(p.course);
					_loc2_.course.rotation -= _loc3_;
					_loc5_ = p.course.speed.length;
					_loc2_.course.speed.x = Math.cos(_loc2_.course.rotation) * _loc5_;
					_loc2_.course.speed.y = Math.sin(_loc2_.course.rotation) * _loc5_;
					_loc2_.clusterNrOfSplits = p.clusterNrOfSplits - 1;
					m.projectileManager.activateProjectile(_loc2_);
					if(p.clusterNrOfProjectiles > 4)
					{
						_loc2_.ttl = 0.6 * p.ttlMax;
					}
					else
					{
						_loc2_.ttl = p.ttlMax;
					}
					_loc2_.numberOfHits = 1;
					_loc3_ -= clusterAngle;
					_loc4_++;
				}
			}
			super.execute();
		}
	}
}

