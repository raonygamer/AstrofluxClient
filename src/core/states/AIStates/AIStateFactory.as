package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.*;
	
	public class AIStateFactory
	{
		public static const BULLET:String = "bullet";
		public static const HOMING_MISSILE:String = "homingMissile";
		public static const BLASTWAVE:String = "blastwave";
		public static const MINE:String = "mine";
		public static const BOOMERANG:String = "boomerang";
		public static const BOUNCING:String = "bouncing";
		public static const CLUSTER:String = "cluster";
		public static const INSTANTSPLITTING:String = "instantSplitting";
		public static const INSTANT:String = "instant";
		public static const TARGETPAINT:String = "targetPainter";
		
		public function AIStateFactory()
		{
			super();
		}
		
		public static function createProjectileAI(obj:Object, g:Game, p:Projectile) : IState
		{
			var _loc4_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc5_:IState = null;
			p.ai = obj.ai;
			switch(obj.ai)
			{
				case "cluster":
					_loc5_ = new Cluster(g,p);
					break;
				case "bullet":
				case "targetPainter":
					_loc5_ = new ProjectileBullet(g,p);
					break;
				case "blastwave":
					_loc5_ = new Blastwave(g,p,obj.aiDelay,obj.aiFollow);
					break;
				case "homingMissile":
					if(obj.hasOwnProperty("aiStick") && obj.aiStick == true)
					{
						p.aiStuckDuration = obj.aiStickDuration;
					}
					if(obj.aiDelayedAcceleration == true)
					{
						p.aiDelayedAccelerationTime = obj.aiDelayedAccelerationTime;
					}
					_loc5_ = new Missile(g,p);
					break;
				case "boomerang":
					_loc5_ = new Boomerang(g,p);
					break;
				case "bouncing":
					p.aiTargetSelf = obj.aiTargetSelf;
					_loc5_ = new Bouncing(g,p);
					break;
				case "mine":
					if(obj.hasOwnProperty("aiDelay"))
					{
						_loc5_ = new Mine(g,p,obj.aiDelay);
					}
					else
					{
						_loc5_ = new Mine(g,p,5000);
					}
					break;
				case "instantSplitting":
					_loc5_ = new InstantSplitting(g,p,obj.color,obj.glowColor,obj.thickness,obj.alpha,obj.aiMaxNrOfLines,obj.aiBranchingFactor,obj.aiSplitChance);
					break;
				case "instant":
					_loc4_ = 0;
					_loc6_ = 0.1;
					if(obj.hasOwnProperty("amplitude"))
					{
						_loc4_ = Number(obj.amplitude);
					}
					if(obj.hasOwnProperty("frequency"))
					{
						_loc6_ = 0.1 * Number(obj.frequency);
					}
					_loc5_ = new Instant(g,p,obj.color,obj.glowColor,obj.thickness,obj.alpha,_loc4_,_loc6_,obj.texture);
			}
			return _loc5_;
		}
	}
}

