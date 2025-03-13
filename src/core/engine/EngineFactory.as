package core.engine {
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import data.DataLocator;
	import data.IDataManager;
	
	public class EngineFactory {
		public function EngineFactory() {
			super();
		}
		
		public static function create(key:String, g:Game, s:Ship) : Engine {
			var _local4:Engine = null;
			var _local6:PlayerShip = null;
			var _local7:IDataManager = DataLocator.getService();
			var _local5:Object = _local7.loadKey("Engines",key);
			if(!g.isLeaving) {
				_local4 = new Engine(g);
				_local4.obj = _local5;
				_local4.name = _local5.name;
				_local4.ship = s;
				_local4.speed = _local5.speed == 0 ? 0.000001 : _local5.speed;
				_local4.acceleration = _local5.acceleration == 0 ? 0.000001 : _local5.acceleration;
				_local4.rotationSpeed = _local5.rotationSpeed == 0 ? 0.000001 : _local5.rotationSpeed;
				if(!_local5.ribbonTrail) {
				}
				if(s is PlayerShip) {
					_local6 = s as PlayerShip;
					_local4.rotationMod = _local6.player.rotationSpeedMod;
				}
				if(_local5.dual) {
					_local4.dual = true;
				}
				if(_local5.dualDistance) {
					_local4.dualDistance = _local5.dualDistance;
				}
				_local4.alive = true;
				_local4.accelerating = false;
				return _local4;
			}
			return null;
		}
	}
}

