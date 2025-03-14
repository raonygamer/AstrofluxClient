package core.states.AIStates {
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	
	public class Blastwave implements IState {
		private var m:Game;
		private var p:Projectile;
		private var sm:StateMachine;
		private var delay:int;
		private var follow:Boolean;
		private var blastStartTime:Number = 0;
		
		public function Blastwave(m:Game, p:Projectile, delay:int, follow:Boolean) {
			super();
			this.m = m;
			this.p = p;
			this.delay = delay;
			this.follow = follow;
		}
		
		public function enter() : void {
			blastStartTime = m.time + delay;
		}
		
		public function execute() : void {
			var _local2:Boolean = false;
			var _local1:Unit = null;
			p.updateHeading(p.course);
			if(blastStartTime < m.time) {
				_local2 = m.camera.isCircleOnScreen(p.pos.x,p.pos.y,p.dmgRadius);
				_local1 = null;
				if(follow) {
					_local1 = p.target;
				}
				p.explode(_local2,_local1);
				p.destroy(false);
			}
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "Blastwave";
		}
	}
}

