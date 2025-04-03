package core.boss
{
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.unit.Unit;
	import debug.Console;
	import flash.geom.Point;
	import movement.Heading;
	import playerio.Message;
	import sound.SoundLocator;
	
	public class BossManager
	{
		private var g:Game;
		
		public var bosses:Vector.<Boss>;
		
		public var callbackMessages:Vector.<Message>;
		
		public var callbackFunctions:Vector.<Function>;
		
		public function BossManager(g:Game)
		{
			super();
			this.g = g;
			bosses = new Vector.<Boss>();
			callbackMessages = new Vector.<Message>();
			callbackFunctions = new Vector.<Function>();
		}
		
		public function update() : void
		{
			var _loc1_:Boss = null;
			var _loc2_:int = 0;
			_loc2_ = bosses.length - 1;
			while(_loc2_ >= 0)
			{
				_loc1_ = bosses[_loc2_];
				_loc1_.update();
				_loc2_--;
			}
		}
		
		public function forceUpdate() : void
		{
			var _loc1_:Boss = null;
			var _loc2_:int = 0;
			_loc2_ = bosses.length - 1;
			while(_loc2_ >= 0)
			{
				_loc1_ = bosses[_loc2_];
				_loc1_.nextDistanceCalculation = 0;
				_loc2_--;
			}
		}
		
		public function addMessageHandlers() : void
		{
			g.addMessageHandler("aiBossTargetChanged",aiBossTargetChanged);
			g.addMessageHandler("aiBossCourse",aiBossCourse);
			g.addMessageHandler("aiBossFireAtBody",aiBossFireAtBody);
			g.addMessageHandler("initBoss",initSyncBoss);
			g.addMessageHandler("bossKilled",bossKilled);
			g.addMessageHandler("spawnBoss",spawnBoss);
		}
		
		public function initBosses(m:Message, i:int, endIndex:int) : void
		{
			var _loc4_:String = null;
			var _loc9_:String = null;
			var _loc8_:* = null;
			var _loc6_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc5_:int = (endIndex - 2) / 4;
			if(_loc5_ == 0)
			{
				return;
			}
			i;
			while(i < endIndex)
			{
				_loc4_ = m.getString(i);
				_loc9_ = m.getString(i + 1);
				_loc6_ = m.getNumber(i + 2);
				_loc7_ = m.getNumber(i + 3);
				createBoss(_loc4_,_loc9_,_loc6_,_loc7_);
				i += 4;
			}
		}
		
		public function spawnBoss(m:Message) : void
		{
			var _loc2_:String = null;
			var _loc6_:String = null;
			var _loc4_:int = 0;
			var _loc3_:Number = NaN;
			var _loc5_:Number = NaN;
			_loc4_ = 0;
			while(_loc4_ < m.length - 1)
			{
				_loc2_ = m.getString(_loc4_);
				_loc6_ = m.getString(_loc4_ + 1);
				_loc3_ = m.getNumber(_loc4_ + 2);
				_loc5_ = m.getNumber(_loc4_ + 3);
				createBoss(_loc2_,_loc6_,_loc3_,_loc5_);
				_loc4_ += 4;
			}
		}
		
		public function createBoss(boss:String, key:String, x:Number, y:Number) : void
		{
			var _loc6_:Body = g.bodyManager.getBodyByKey(key);
			if(_loc6_ == null)
			{
				return;
			}
			var _loc5_:Boss = BossFactory.createBoss(boss,_loc6_,_loc6_.wpArray,key,g);
			_loc5_.course.pos.x = x;
			_loc5_.course.pos.y = y;
			_loc5_.x = x;
			_loc5_.y = y;
			g.bossManager.add(_loc5_);
			if(g.gameStartedTime != 0 && g.time - g.gameStartedTime > 10000 && g.me.level > 1)
			{
				g.textManager.createBossSpawnedText(_loc5_.name + " has spawned");
				SoundLocator.getService().play("q0CoOEzFYk2yFBRYQtfYvw");
			}
		}
		
		private function bossKilled(m:Message) : void
		{
			var _loc2_:Boss = getBossFromKey(m.getString(0));
			if(_loc2_ != null)
			{
				killBoss(_loc2_);
			}
		}
		
		private function killBoss(b:Boss) : void
		{
			b.destroy();
			g.hud.radar.remove(b);
			b.removeFromCanvas();
			bosses.splice(bosses.indexOf(b),1);
			Console.write("BOSS killed!");
		}
		
		public function aiTeleport(m:Message, i:int) : void
		{
			var _loc3_:Boss = g.bossManager.getBossFromKey(m.getString(i));
			if(_loc3_ == null)
			{
				return;
			}
			_loc3_.teleportExitPoint = new Point(m.getNumber(i + 1),m.getNumber(i + 2));
			_loc3_.teleportExitTime = m.getNumber(i + 3);
			_loc3_.startTeleportEffect();
		}
		
		public function aiBossFireAtBody(m:Message) : void
		{
			var _loc2_:Boss = g.bossManager.getBossFromKey(m.getString(0));
			if(_loc2_ == null)
			{
				callbackMessages.push(m);
				callbackFunctions.push(aiBossFireAtBody);
				return;
			}
			_loc2_.bodyTarget = g.bodyManager.getBodyByKey(m.getString(1));
			_loc2_.bodyDestroyStart = m.getNumber(2);
			_loc2_.bodyDestroyEnd = m.getNumber(3);
		}
		
		public function aiBossCourse(m:Message) : void
		{
			var _loc6_:int = 0;
			var _loc2_:Boss = g.bossManager.getBossFromKey(m.getString(0));
			if(_loc2_ == null)
			{
				callbackMessages.push(m);
				callbackFunctions.push(aiBossCourse);
				return;
			}
			var _loc5_:Heading = new Heading();
			var _loc3_:int = m.getInt(1);
			if(_loc3_ != 0 && (_loc2_.currentWaypoint == null || _loc3_ != _loc2_.currentWaypoint.id))
			{
				_loc6_ = 0;
				while(_loc6_ < _loc2_.waypoints.length)
				{
					if(_loc3_ == _loc2_.waypoints[_loc6_].id)
					{
						_loc2_.currentWaypoint = _loc2_.waypoints[_loc6_];
						break;
					}
					_loc6_++;
				}
			}
			var _loc4_:int = m.getInt(2);
			var _loc7_:Unit = g.unitManager.getTarget(_loc4_);
			_loc2_.target = _loc7_;
			_loc5_.parseMessage(m,3);
			_loc2_.setConvergeTarget(_loc5_);
		}
		
		public function aiBossTargetChanged(m:Message) : void
		{
			var _loc2_:Boss = g.bossManager.getBossFromKey(m.getString(0));
			var _loc3_:Unit = g.shipManager.getShipFromId(m.getInt(1));
			if(_loc2_ == null)
			{
				callbackMessages.push(m);
				callbackFunctions.push(aiBossTargetChanged);
				return;
			}
			_loc2_.target = _loc3_;
		}
		
		public function getBossFromKey(key:String) : Boss
		{
			for each(var _loc2_ in bosses)
			{
				if(_loc2_.key == key)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getComponentById(id:int) : Unit
		{
			for each(var _loc2_ in bosses)
			{
				for each(var _loc3_ in _loc2_.allComponents)
				{
					if(_loc3_.syncId == id)
					{
						return _loc3_;
					}
				}
			}
			return null;
		}
		
		public function add(b:Boss) : void
		{
			var _loc3_:int = 0;
			var _loc4_:Message = null;
			var _loc2_:Function = null;
			bosses.push(b);
			g.hud.radar.add(b);
			b.addToCanvas();
			_loc3_ = callbackMessages.length - 1;
			while(_loc3_ > -1)
			{
				if(callbackFunctions[_loc3_] == initSyncBoss)
				{
					callbackFunctions.shift();
					_loc4_ = callbackMessages.shift();
					initSyncBoss(_loc4_);
				}
				_loc3_--;
			}
			_loc3_ = callbackMessages.length - 1;
			while(_loc3_ > -1)
			{
				_loc4_ = callbackMessages.shift();
				_loc2_ = callbackFunctions.shift();
				_loc2_(_loc4_);
				_loc3_--;
			}
		}
		
		public function killed(m:Message, i:int) : void
		{
			var _loc4_:int = m.getInt(i);
			var _loc3_:Unit = getComponentById(_loc4_);
			if(_loc3_ == null)
			{
				Console.write("No bc to kill by id: " + _loc4_);
				return;
			}
			_loc3_.destroy();
		}
		
		public function damaged(m:Message, i:int) : void
		{
			var _loc4_:int = m.getInt(i + 1);
			var _loc3_:Unit = getComponentById(_loc4_);
			if(_loc3_ == null)
			{
				return;
			}
			var _loc5_:int = m.getInt(i + 2);
			_loc3_.takeDamage(_loc5_);
			_loc3_.shieldHp = m.getInt(i + 3);
			_loc3_.hp = m.getInt(i + 4);
			if(m.getBoolean(i + 5))
			{
				_loc3_.doDOTEffect(m.getInt(i + 6),m.getString(i + 7));
			}
		}
		
		public function initSyncBoss(m:Message) : void
		{
			var _loc7_:int = 0;
			var _loc4_:Unit = null;
			Console.write("SYNC BOSS!");
			var _loc5_:int = 0;
			var _loc2_:Boss = getBossFromKey(m.getString(_loc5_));
			if(_loc2_ == null)
			{
				callbackMessages.push(m);
				callbackFunctions.push(initSyncBoss);
				return;
			}
			_loc2_.awaitingActivation = false;
			_loc2_.target = g.unitManager.getTarget(m.getInt(_loc5_ + 1));
			_loc2_.alive = m.getBoolean(_loc5_ + 2);
			var _loc3_:int = m.getInt(_loc5_ + 3);
			_loc7_ = 0;
			while(_loc7_ < _loc2_.waypoints.length)
			{
				if(_loc2_.waypoints[_loc7_].id == _loc3_)
				{
					_loc2_.currentWaypoint = _loc2_.waypoints[_loc7_];
					break;
				}
				_loc7_++;
			}
			_loc2_.rotationForced = m.getBoolean(_loc5_ + 4);
			_loc2_.rotationSpeed = m.getNumber(_loc5_ + 5);
			var _loc6_:Heading = new Heading();
			_loc5_ = _loc6_.parseMessage(m,_loc5_ + 6);
			_loc2_.course = _loc6_;
			var _loc8_:int = m.getInt(_loc5_);
			_loc5_++;
			_loc7_ = 0;
			while(_loc7_ < _loc8_)
			{
				_loc4_ = _loc2_.getComponent(m.getInt(_loc5_));
				_loc4_.id = m.getInt(_loc5_ + 1);
				_loc4_.hp = m.getInt(_loc5_ + 2);
				_loc4_.shieldHp = m.getInt(_loc5_ + 3);
				_loc4_.invulnerable = m.getBoolean(_loc5_ + 4);
				_loc4_.active = m.getBoolean(_loc5_ + 5);
				_loc4_.alive = m.getBoolean(_loc5_ + 6);
				_loc4_.triggersToActivte = m.getInt(_loc5_ + 7);
				Console.write("----------- Sync boss part --------------");
				Console.write(_loc4_.name);
				Console.write("sync id: ",_loc4_.syncId);
				Console.write("id: ",_loc4_.id);
				Console.write("hp: ",_loc4_.hp);
				Console.write("shiledHp: ",_loc4_.shieldHp);
				Console.write("invulnerable",_loc4_.invulnerable);
				Console.write("active",_loc4_.active);
				Console.write("alive",_loc4_.alive);
				Console.write("triggersToActivte",_loc4_.triggersToActivte);
				if(!_loc4_.alive)
				{
					_loc4_.destroy();
				}
				_loc4_.nextDistanceCalculation = 0;
				_loc4_.distanceToCamera = 0;
				_loc5_ += 8;
				_loc7_++;
			}
		}
	}
}

