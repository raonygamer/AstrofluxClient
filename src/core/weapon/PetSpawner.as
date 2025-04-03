package core.weapon
{
	import core.scene.Game;
	import core.ship.PlayerShip;
	
	public class PetSpawner extends Weapon
	{
		public var maxPets:int;
		
		public function PetSpawner(g:Game)
		{
			super(g);
		}
		
		override public function init(obj:Object, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : void
		{
			var _loc5_:int = 0;
			var _loc6_:Object = null;
			super.init(obj,techLevel,eliteTechLevel,eliteTech);
			maxPets = 1;
			if(obj.hasOwnProperty("maxPets"))
			{
				maxPets = obj.maxPets;
			}
			if(techLevel > 0)
			{
				_loc6_ = obj.techLevels[techLevel - 1];
				if(_loc6_.hasOwnProperty("maxPets"))
				{
					maxPets = _loc6_.maxPets;
				}
			}
			reloadTime = 40 * 60;
		}
		
		override protected function shoot() : void
		{
			var _loc2_:PlayerShip = null;
			var _loc3_:Number = NaN;
			var _loc1_:Number = Number(g.time.valueOf());
			if(fireNextTime < g.time)
			{
				if(unit is PlayerShip)
				{
					_loc2_ = unit as PlayerShip;
					if(!_loc2_.weaponHeat.canFire(heatCost))
					{
						fireNextTime += 40 * 60;
						return;
					}
				}
				_loc3_ = 40 * 60;
				if(fireNextTime == 0 || lastFire == 0 || burstCurrent > 1)
				{
					fireNextTime = _loc1_ + _loc3_ - 33;
				}
				else
				{
					fireNextTime += _loc3_;
				}
				lastFire = g.time;
			}
		}
	}
}

