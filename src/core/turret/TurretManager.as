package core.turret
{
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;
	
	public class TurretManager
	{
		public var turrets:Vector.<Turret>;
		private var g:Game;
		
		public function TurretManager(g:Game)
		{
			super();
			this.g = g;
			turrets = new Vector.<Turret>();
		}
		
		public function addMessageHandlers() : void
		{
			g.addMessageHandler("turretChangedTarget",turretChangedTarget);
			g.addMessageHandler("turretUpdate",onTurretUpdate);
		}
		
		public function addEarlyMessageHandlers() : void
		{
			g.addMessageHandler("turretKilled",killed);
		}
		
		public function syncTurret(m:Message, index:int, stopIndex:int) : void
		{
			var _loc5_:* = 0;
			var _loc4_:Turret = null;
			_loc5_ = index;
			while(_loc5_ < stopIndex)
			{
				_loc4_ = getTurretsByParentAndSyncId(m.getInt(_loc5_),m.getInt(_loc5_ + 1));
				if(_loc4_ == null || _loc4_.isBossUnit)
				{
					Console.write("Turret is null, failed sync.");
				}
				else
				{
					_loc4_.id = m.getInt(_loc5_ + 2);
					_loc4_.alive = m.getBoolean(_loc5_ + 3);
					g.unitManager.add(_loc4_,g.canvasTurrets,false);
				}
				_loc5_ += 5;
			}
		}
		
		public function syncTurretTarget(m:Message, startIndex:int, endIndex:int) : void
		{
			var _loc5_:* = 0;
			var _loc4_:Turret = null;
			_loc5_ = startIndex;
			while(_loc5_ < endIndex - 3)
			{
				_loc4_ = getTurretById(m.getInt(_loc5_));
				if(_loc4_ != null)
				{
					_loc4_.target = g.shipManager.getShipFromId(m.getInt(_loc5_ + 1));
					_loc4_.rotation = m.getNumber(_loc5_ + 2);
					if(_loc4_.weapon != null)
					{
						_loc4_.weapon.fire = m.getBoolean(_loc5_ + 3);
					}
				}
				else
				{
					Console.write("ERROR: Missing turret with id: " + m.getInt(_loc5_));
				}
				_loc5_ += 4;
			}
		}
		
		public function turretChangedTarget(m:Message) : void
		{
			var _loc3_:int = 0;
			var _loc2_:Turret = null;
			_loc3_ = 0;
			while(_loc3_ < m.length)
			{
				_loc2_ = getTurretById(m.getInt(_loc3_));
				if(_loc2_ != null)
				{
					_loc2_.target = g.shipManager.getShipFromId(m.getInt(_loc3_ + 1));
				}
				else
				{
					Console.write("Error bad turret id: " + m.getInt(_loc3_ + 1));
				}
				_loc3_ += 2;
			}
		}
		
		private function onTurretUpdate(m:Message) : void
		{
			var _loc3_:int = 0;
			var _loc2_:Turret = getTurretById(m.getInt(_loc3_++));
			if(_loc2_ == null)
			{
				return;
			}
			_loc2_.hp = m.getInt(_loc3_++);
			_loc2_.shieldHp = m.getInt(_loc3_++);
			if(_loc2_.hp < _loc2_.hpMax || _loc2_.shieldHp < _loc2_.shieldHpMax)
			{
				_loc2_.isInjured = true;
			}
			_loc2_.target = g.shipManager.getShipFromId(m.getInt(_loc3_++));
			_loc2_.rotation = m.getNumber(_loc3_++);
			if(_loc2_.weapon != null)
			{
				_loc2_.weapon.fire = m.getBoolean(_loc3_++);
			}
		}
		
		public function update() : void
		{
		}
		
		public function turretFire(m:Message, i:int = 0) : void
		{
			var _loc3_:int = 0;
			var _loc6_:int = m.getInt(i);
			var _loc5_:Boolean = m.getBoolean(i + 1);
			var _loc4_:Turret = g.turretManager.getTurretById(_loc6_);
			if(_loc4_ != null && _loc4_.weapon != null)
			{
				_loc4_.weapon.fire = _loc5_;
				if(m.length > 2)
				{
					_loc3_ = m.getInt(i + 2);
					_loc4_.weapon.target = g.shipManager.getShipFromId(_loc3_);
				}
				return;
			}
		}
		
		public function getTurret() : Turret
		{
			var _loc1_:Turret = new Turret(g);
			_loc1_.reset();
			turrets.push(_loc1_);
			return _loc1_;
		}
		
		public function removeTurret(t:Turret) : void
		{
			turrets.splice(turrets.indexOf(t),1);
		}
		
		public function getTurretById(id:int) : Turret
		{
			for each(var _loc2_ in turrets)
			{
				if(_loc2_.id == id)
				{
					return _loc2_;
				}
			}
			Console.write("Error: missing turret");
			return null;
		}
		
		public function getTurretsByParentAndSyncId(id:int, syncId:int) : Turret
		{
			for each(var _loc3_ in turrets)
			{
				if(_loc3_.parentObj != null && _loc3_.parentObj.id == id && _loc3_.syncId == syncId)
				{
					return _loc3_;
				}
			}
			Console.write("Error: missing turret in sync");
			return null;
		}
		
		public function damaged(m:Message, i:int) : void
		{
			var _loc5_:int = m.getInt(i + 1);
			var _loc3_:Turret = getTurretById(_loc5_);
			if(_loc3_ == null)
			{
				Console.write("No turret to damage by id: " + _loc5_);
				return;
			}
			var _loc7_:int = m.getInt(i + 2);
			var _loc6_:int = m.getInt(i + 3);
			if(_loc3_.shieldHp == 0)
			{
				if(_loc3_.shieldRegenCounter > -1000)
				{
					_loc3_.shieldRegenCounter = -1000;
				}
			}
			var _loc4_:int = m.getInt(i + 4);
			if(m.getBoolean(i + 5))
			{
				_loc3_.doDOTEffect(m.getInt(i + 6),m.getString(i + 7),m.getInt(i + 8));
			}
			if(_loc3_.isAddedToCanvas)
			{
				_loc3_.takeDamage(_loc7_);
			}
			_loc3_.shieldHp = _loc6_;
			_loc3_.hp = _loc4_;
		}
		
		public function killed(m:Message, i:int) : void
		{
			var _loc4_:int = m.getInt(i);
			var _loc3_:Turret = getTurretById(_loc4_);
			if(_loc3_ == null)
			{
				Console.write("No turret to kill by id: " + _loc4_);
				return;
			}
			_loc3_.destroy();
		}
	}
}

