package core.states.AIStates {
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.*;
	
	public class AIStateFactory {
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
		
		public function AIStateFactory() {
			super();
		}
		
		public static function createProjectileAI(obj:Object, g:Game, p:Projectile) : IState {
			var _local6:Number = NaN;
			var _local5:Number = NaN;
			var _local4:IState = null;
			p.ai = obj.ai;
			switch(obj.ai) {
				case "cluster":
					_local4 = new Cluster(g,p);
					break;
				case "bullet":
				case "targetPainter":
					_local4 = new ProjectileBullet(g,p);
					break;
				case "blastwave":
					_local4 = new Blastwave(g,p,obj.aiDelay,obj.aiFollow);
					break;
				case "homingMissile":
					if(obj.hasOwnProperty("aiStick") && obj.aiStick == true) {
						p.aiStuckDuration = obj.aiStickDuration;
					}
					if(obj.aiDelayedAcceleration == true) {
						p.aiDelayedAccelerationTime = obj.aiDelayedAccelerationTime;
					}
					_local4 = new Missile(g,p);
					break;
				case "boomerang":
					_local4 = new Boomerang(g,p);
					break;
				case "bouncing":
					p.aiTargetSelf = obj.aiTargetSelf;
					_local4 = new Bouncing(g,p);
					break;
				case "mine":
					if(obj.hasOwnProperty("aiDelay")) {
						_local4 = new Mine(g,p,obj.aiDelay);
					} else {
						_local4 = new Mine(g,p,5000);
					}
					break;
				case "instantSplitting":
					_local4 = new InstantSplitting(g,p,obj.color,obj.glowColor,obj.thickness,obj.alpha,obj.aiMaxNrOfLines,obj.aiBranchingFactor,obj.aiSplitChance);
					break;
				case "instant":
					_local6 = 0;
					_local5 = 0.1;
					if(obj.hasOwnProperty("amplitude")) {
						_local6 = Number(obj.amplitude);
					}
					if(obj.hasOwnProperty("frequency")) {
						_local5 = 0.1 * Number(obj.frequency);
					}
					_local4 = new Instant(g,p,obj.color,obj.glowColor,obj.thickness,obj.alpha,_local6,_local5,obj.texture);
			}
			return _local4;
		}
	}
}

