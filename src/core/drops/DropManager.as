package core.drops
{
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import debug.Console;
	import flash.utils.Dictionary;
	import generics.Random;
	import playerio.Message;
	
	public class DropManager
	{
		public static const PICKUPINTERVAL:Number = 250;
		
		public static const ATTEMPTS_TO_TIMEOUT:int = 80;
		
		public var dropsById:Dictionary;
		
		public var drops:Vector.<Drop>;
		
		private var createdDropIds:Dictionary;
		
		private var pickupQueue:Vector.<PickUpMsg>;
		
		private var nextPickUpTime:Number;
		
		private var g:Game;
		
		public function DropManager(g:Game)
		{
			super();
			this.g = g;
			nextPickUpTime = 0;
			drops = new Vector.<Drop>();
			dropsById = new Dictionary();
			createdDropIds = new Dictionary();
			pickupQueue = new Vector.<PickUpMsg>();
		}
		
		public function addMessageHandlers() : void
		{
			g.addMessageHandler("spawnDrops",onSpawn);
		}
		
		public function initDrops(m:Message) : void
		{
			spawn(m);
		}
		
		public function update() : void
		{
			var _loc2_:int = 0;
			var _loc1_:Drop = null;
			var _loc3_:int = int(drops.length);
			_loc2_ = _loc3_ - 1;
			while(_loc2_ > -1)
			{
				_loc1_ = drops[_loc2_];
				_loc1_.update();
				if(_loc1_.expired)
				{
					remove(_loc1_,_loc2_);
					g.emitterManager.clean(_loc1_);
				}
				_loc2_--;
			}
			if(nextPickUpTime > g.time)
			{
				return;
			}
			_loc3_ = int(pickupQueue.length);
			_loc2_ = _loc3_ - 1;
			while(_loc2_ > -1)
			{
				if(pickupQueue.length > _loc2_)
				{
					tryPickup(null,pickupQueue[_loc2_],pickupQueue[_loc2_].i);
				}
				_loc2_--;
			}
			nextPickUpTime = g.time + 250;
		}
		
		public function getDrop() : Drop
		{
			return new Drop(g);
		}
		
		private function remove(drop:Drop, index:int) : void
		{
			drops.splice(index,1);
			g.hud.radar.remove(drop);
			createdDropIds[drop.id.toString()] = false;
			dropsById[drop.id.toString()] = null;
			drop.removeFromCanvas();
			drop.reset();
		}
		
		private function onSpawn(m:Message) : void
		{
			spawn(m);
		}
		
		public function spawn(m:Message, start:int = 0, end:int = 0) : void
		{
			var _loc5_:* = 0;
			var _loc7_:String = null;
			var _loc6_:int = 0;
			var _loc8_:Boolean = false;
			var _loc4_:int = int(end != 0 ? end : m.length - start);
			_loc5_ = start;
			while(_loc5_ < start + _loc4_)
			{
				_loc7_ = m.getString(_loc5_);
				_loc6_ = m.getInt(_loc5_ + 1);
				_loc8_ = m.getBoolean(_loc5_ + 2);
				if(_loc7_ == null || _loc7_ == "")
				{
					g.showErrorDialog("Init drops didn\'t work correctly! message: " + m.toString(),true);
					return;
				}
				if(_loc7_ == "empty")
				{
					return;
				}
				createdDropIds[_loc6_.toString()] = true;
				if(!_loc8_)
				{
					createSetDrop(DropFactory.createDrop(_loc7_,g),m,_loc5_);
				}
				else
				{
					createSetDrop(DropFactory.createDropFromCargo(_loc7_,g),m,_loc5_);
				}
				_loc5_ += 10;
			}
		}
		
		public function getDropItems(key:String, g:Game, seed:Number) : DropBase
		{
			var _loc7_:Boolean = false;
			var _loc8_:int = 0;
			var _loc6_:int = 0;
			var _loc11_:int = 0;
			var _loc9_:DropItem = null;
			if(key == "" || key == null)
			{
				return null;
			}
			var _loc4_:Random = new Random(seed);
			var _loc10_:Object = DataLocator.getService().loadKey("Drops",key);
			var _loc12_:DropBase = new DropBase();
			_loc12_.crate = _loc10_.crate;
			if(_loc12_.crate)
			{
				if(_loc4_.randomNumber() >= _loc10_.chance)
				{
					_loc12_.crate = false;
					return null;
				}
				_loc7_ = Boolean(_loc10_.artifactChance);
				_loc12_.containsArtifact = _loc7_ > _loc4_.randomNumber();
			}
			if(_loc10_.type == "mission")
			{
				_loc8_ = int(_loc10_.fluxMax);
				_loc6_ = int(_loc10_.fluxMin);
				_loc12_.flux = _loc6_;
				_loc11_ = 0;
				while(_loc11_ < _loc8_ - _loc6_)
				{
					if(_loc4_.randomNumber() <= 0.5)
					{
						break;
					}
					_loc12_.flux += 1;
					_loc11_++;
				}
				if(_loc12_.flux == _loc8_)
				{
					if(_loc4_.randomNumber() > 0.5)
					{
						_loc12_.flux = _loc6_;
					}
				}
				_loc12_.artifactAmount = _loc10_.artifactAmount;
				_loc12_.artifactLevel = _loc10_.artifactLevel;
			}
			else
			{
				_loc12_.flux = _loc10_.fluxMin + _loc4_.random(_loc10_.fluxMax - _loc10_.fluxMin + 1);
			}
			_loc12_.xp = _loc10_.xpMin + _loc4_.random(_loc10_.xpMax - _loc10_.xpMin + 1);
			if(_loc10_.reputation)
			{
				_loc12_.reputation = _loc10_.reputation;
			}
			else
			{
				_loc12_.reputation = 0;
			}
			for each(var _loc5_ in _loc10_.dropItems)
			{
				_loc9_ = getDropItem(_loc5_,_loc4_);
				if(_loc9_ != null)
				{
					_loc12_.items.push(_loc9_);
				}
			}
			return _loc12_;
		}
		
		public function getDropItem(obj:Object, r:Random) : DropItem
		{
			var _loc5_:DropItem = null;
			var _loc4_:int = 0;
			var _loc6_:int = 0;
			var _loc8_:int = 0;
			var _loc3_:Object = null;
			var _loc7_:Object = null;
			if(r.randomNumber() <= obj.chance)
			{
				_loc5_ = new DropItem();
				_loc4_ = 0;
				_loc6_ = 0;
				if(obj.min && obj.max)
				{
					_loc4_ = int(obj.min);
					_loc6_ = int(obj.max);
				}
				_loc8_ = _loc6_ - _loc4_;
				_loc5_.quantity = _loc4_ + r.random(_loc8_);
				_loc5_.item = obj.item;
				_loc5_.table = obj.table;
				if(_loc5_.quantity == 0)
				{
					return null;
				}
				_loc3_ = DataLocator.getService().loadKey(_loc5_.table,_loc5_.item);
				_loc5_.name = _loc3_.name;
				_loc5_.hasTechTree = _loc3_.hasTechTree;
				if(_loc5_.table == "Weapons")
				{
					_loc5_.bitmapKey = _loc3_.techIcon;
				}
				else if(_loc5_.table == "Skins")
				{
					_loc7_ = DataLocator.getService().loadKey("Ships",_loc3_.ship);
					_loc5_.bitmapKey = _loc7_.bitmap;
				}
				else
				{
					_loc5_.bitmapKey = _loc3_.bitmap;
				}
				return _loc5_;
			}
			return null;
		}
		
		private function createSetDrop(drop:Drop, m:Message, i:int) : void
		{
			var _loc4_:Drop = null;
			if(drop == null)
			{
				return;
			}
			drop.id = m.getInt(i + 1);
			drop.x = 0.01 * m.getInt(i + 3);
			drop.y = 0.01 * m.getInt(i + 4);
			drop.speed.x = 0.01 * m.getInt(i + 5);
			drop.speed.y = 0.01 * m.getInt(i + 6);
			drop.expireTime = m.getNumber(i + 7);
			drop.quantity = m.getInt(i + 8);
			drop.containsUniqueArtifact = m.getBoolean(i + 9);
			if(dropsById[drop.id.toString()] != null)
			{
				_loc4_ = dropsById[drop.id.toString()];
				_loc4_.expire();
			}
			dropsById[drop.id.toString()] = drop;
			drops.push(drop);
		}
		
		public function tryBeamPickup(m:Message, i:int) : void
		{
			var _loc5_:String = m.getString(i);
			var _loc4_:int = m.getInt(i + 1);
			var _loc6_:Player = g.playerManager.playersById[_loc5_];
			var _loc3_:Drop = dropsById[_loc4_.toString()];
			if(_loc3_ != null && _loc6_ != null)
			{
				_loc3_.tractorBeamPlayer = _loc6_;
				_loc3_.expireTime = g.time + 2000;
			}
			pickupQueue.push(new PickUpMsg(m,3 * 80,i));
		}
		
		public function tryPickup(m:Message = null, po:PickUpMsg = null, i:int = 0) : void
		{
			var _loc9_:int = 0;
			if(m == null)
			{
				m = po.msg;
			}
			else if(m.length < i + 2)
			{
				return;
			}
			var _loc8_:int = m.getInt(i - 1);
			var _loc10_:String = m.getString(i);
			var _loc5_:String = m.getInt(i + 1).toString();
			var _loc4_:Drop = dropsById[_loc5_];
			if(_loc4_ == null && createdDropIds[_loc5_] != null)
			{
				if(createdDropIds[_loc5_] == true)
				{
					for each(var _loc6_ in pickupQueue)
					{
						if(_loc6_.msg == m)
						{
							Console.write("Pickup already queued. dropId: " + _loc5_);
							return;
						}
					}
					Console.write("Pickup queued.");
					pickupQueue.push(new PickUpMsg(m,80,i));
					return;
				}
				_loc9_ = int(pickupQueue.indexOf(po));
				pickupQueue.splice(_loc9_,1);
				return;
			}
			if(_loc4_ == null)
			{
				Console.write("FAILED Pickup. No drop with id : " + _loc5_);
				_loc9_ = int(pickupQueue.indexOf(po));
				if(po != null && _loc9_ != -1)
				{
					po.timeout--;
					if(po.timeout < 1)
					{
						pickupQueue.splice(_loc9_,1);
						Console.write("FAILED Pickup. Removed from queue due to timeout.");
					}
				}
				return;
			}
			var _loc11_:Player = g.playerManager.playersById[_loc10_];
			if(_loc11_ == null || _loc11_.ship == null)
			{
				return;
			}
			var _loc7_:Boolean = _loc4_.pickup(_loc11_,m,i + 2);
			if(!_loc7_)
			{
				return;
			}
			delete dropsById[_loc5_];
			_loc9_ = int(pickupQueue.indexOf(po));
			if(_loc9_ != -1)
			{
				pickupQueue.splice(_loc9_,1);
			}
		}
		
		private function buyTractorBeam() : void
		{
			g.send("buyTractorBeam");
		}
		
		public function dispose() : void
		{
			for each(var _loc1_ in drops)
			{
				_loc1_.removeFromCanvas();
				_loc1_.reset();
			}
			drops = null;
			createdDropIds = null;
			pickupQueue = null;
			dropsById = null;
		}
		
		public function forceUpdate() : void
		{
			var _loc1_:Drop = null;
			var _loc2_:int = 0;
			_loc2_ = 0;
			while(_loc2_ < drops.length)
			{
				_loc1_ = drops[_loc2_];
				_loc1_.nextDistanceCalculation = -1;
				_loc2_++;
			}
		}
	}
}

import playerio.Message;

class PickUpMsg
{
	public var msg:Message;
	
	public var timeout:int;
	
	public var i:int;
	
	public function PickUpMsg(m:Message, timeout:int, i:int = 0)
	{
		super();
		this.timeout = timeout;
		this.i = i;
		this.msg = m;
	}
}
