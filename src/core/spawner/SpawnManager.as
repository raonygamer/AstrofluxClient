package core.spawner
{
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;
	
	public class SpawnManager
	{
		public var spawners:Vector.<Spawner>;
		
		private var g:Game;
		
		private var id:int = 0;
		
		public function SpawnManager(g:Game)
		{
			super();
			this.g = g;
			spawners = new Vector.<Spawner>();
		}
		
		public function addMessageHandlers() : void
		{
			g.addMessageHandler("spawnerUpdate",onSpawnerUpdate);
		}
		
		public function addEarlyMessageHandlers() : void
		{
			g.addMessageHandler("spawnerKilled",killed);
			g.addMessageHandler("spawnerRebuild",rebuild);
		}
		
		public function syncSpawners(m:Message, index:int, stopIndex:int) : void
		{
			var _loc5_:* = 0;
			var _loc4_:Spawner = null;
			_loc5_ = index;
			while(_loc5_ < stopIndex)
			{
				_loc4_ = getSpawnerByKey(m.getString(_loc5_));
				if(_loc4_ == null || _loc4_.isBossUnit)
				{
					Console.write("Spawner is null, something went wrong while syncing.");
				}
				else
				{
					_loc4_.id = m.getInt(_loc5_ + 1);
					_loc4_.rotationSpeed = m.getNumber(_loc5_ + 2);
					_loc4_.orbitAngle = m.getNumber(_loc5_ + 3);
					_loc4_.alive = m.getBoolean(_loc5_ + 4);
					if(!_loc4_.hidden)
					{
						g.unitManager.add(_loc4_,g.canvasSpawners);
						if(!_loc4_.alive)
						{
							_loc4_.destroy(false);
						}
					}
				}
				_loc5_ += 5;
			}
		}
		
		public function update() : void
		{
		}
		
		public function getSpawner(type:String) : Spawner
		{
			var _loc2_:Spawner = null;
			if(type == "organic")
			{
				_loc2_ = new OrganicSpawner(g);
			}
			else
			{
				_loc2_ = new Spawner(g);
			}
			spawners.push(_loc2_);
			return _loc2_;
		}
		
		public function removeSpawner(s:Spawner) : void
		{
			spawners.splice(spawners.indexOf(s),1);
		}
		
		public function getSpawnerByKey(key:String) : Spawner
		{
			for each(var _loc2_ in spawners)
			{
				if(_loc2_.key == key)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getSpawnerById(id:int) : Spawner
		{
			for each(var _loc2_ in spawners)
			{
				if(_loc2_.id == id)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function damaged(m:Message, i:int) : void
		{
			var _loc6_:String = m.getString(i);
			var _loc3_:Spawner = getSpawnerByKey(_loc6_);
			if(_loc3_ == null)
			{
				Console.write("No spawner to damage by key: " + _loc6_);
				return;
			}
			var _loc7_:int = m.getInt(i + 2);
			var _loc5_:int = m.getInt(i + 3);
			var _loc4_:int = m.getInt(i + 4);
			if(m.getBoolean(i + 5))
			{
				_loc3_.doDOTEffect(m.getInt(i + 6),m.getString(i + 7),m.getInt(i + 8));
			}
			_loc3_.takeDamage(_loc7_);
			_loc3_.shieldHp = _loc5_;
			if(_loc3_.shieldHp == 0)
			{
				if(_loc3_.shieldRegenCounter > -1000)
				{
					_loc3_.shieldRegenCounter = -1000;
				}
			}
			_loc3_.hp = _loc4_;
		}
		
		private function onSpawnerUpdate(m:Message) : void
		{
			var _loc3_:int = 0;
			var _loc4_:String = m.getString(_loc3_++);
			var _loc2_:Spawner = getSpawnerByKey(_loc4_);
			if(_loc2_ == null)
			{
				Console.write("No spawner to update, key: " + _loc4_);
				return;
			}
			_loc2_.hp = m.getInt(_loc3_++);
			_loc2_.shieldHp = m.getInt(_loc3_++);
			if(_loc2_.hp < _loc2_.hpMax || _loc2_.shieldHp < _loc2_.shieldHpMax)
			{
				_loc2_.isInjured = true;
			}
		}
		
		public function killed(m:Message, i:int) : void
		{
			var _loc4_:String = m.getString(i);
			var _loc3_:Spawner = getSpawnerByKey(_loc4_);
			if(_loc3_ == null)
			{
				Console.write("No spawner to kill by key: " + _loc4_);
				return;
			}
			_loc3_.destroy();
		}
		
		public function rebuild(m:Message) : void
		{
			var _loc3_:String = m.getString(0);
			var _loc2_:Spawner = getSpawnerByKey(_loc3_);
			if(_loc2_ == null)
			{
				Console.write("No spawner to rebuild by key: " + _loc3_);
				return;
			}
			_loc2_.rebuild();
		}
		
		public function dispose() : void
		{
			for each(var _loc1_ in spawners)
			{
				_loc1_.reset();
				_loc1_.removeFromCanvas();
			}
			spawners = null;
		}
	}
}

