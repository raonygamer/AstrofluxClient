package core.engine
{
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import data.DataLocator;
	import data.IDataManager;
	
	public class EngineFactory
	{
		public function EngineFactory()
		{
			super();
		}
		
		public static function create(key:String, g:Game, s:Ship) : Engine
		{
			var _loc5_:Engine = null;
			var _loc4_:PlayerShip = null;
			var _loc7_:IDataManager = DataLocator.getService();
			var _loc6_:Object = _loc7_.loadKey("Engines",key);
			if(!g.isLeaving)
			{
				_loc5_ = new Engine(g);
				_loc5_.obj = _loc6_;
				_loc5_.name = _loc6_.name;
				_loc5_.ship = s;
				_loc5_.speed = _loc6_.speed == 0 ? 0.000001 : _loc6_.speed;
				_loc5_.acceleration = _loc6_.acceleration == 0 ? 0.000001 : _loc6_.acceleration;
				_loc5_.rotationSpeed = _loc6_.rotationSpeed == 0 ? 0.000001 : _loc6_.rotationSpeed;
				if(!_loc6_.ribbonTrail)
				{
				}
				if(s is PlayerShip)
				{
					_loc4_ = s as PlayerShip;
					_loc5_.rotationMod = _loc4_.player.rotationSpeedMod;
				}
				if(_loc6_.dual)
				{
					_loc5_.dual = true;
				}
				if(_loc6_.dualDistance)
				{
					_loc5_.dualDistance = _loc6_.dualDistance;
				}
				_loc5_.alive = true;
				_loc5_.accelerating = false;
				return _loc5_;
			}
			return null;
		}
	}
}

