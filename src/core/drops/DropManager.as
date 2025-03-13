package core.drops {
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import debug.Console;
	import flash.utils.Dictionary;
	import generics.Random;
	import playerio.Message;
	
	public class DropManager {
		public static const PICKUPINTERVAL:Number = 250;
		public static const ATTEMPTS_TO_TIMEOUT:int = 80;
		public var dropsById:Dictionary;
		public var drops:Vector.<Drop>;
		private var createdDropIds:Dictionary;
		private var pickupQueue:Vector.<PickUpMsg>;
		private var nextPickUpTime:Number;
		private var g:Game;
		
		public function DropManager(g:Game) {
			super();
			this.g = g;
			nextPickUpTime = 0;
			drops = new Vector.<Drop>();
			dropsById = new Dictionary();
			createdDropIds = new Dictionary();
			pickupQueue = new Vector.<PickUpMsg>();
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("spawnDrops",onSpawn);
		}
		
		public function initDrops(m:Message) : void {
			spawn(m);
		}
		
		public function update() : void {
			var _local3:int = 0;
			var _local1:Drop = null;
			var _local2:int = int(drops.length);
			_local3 = _local2 - 1;
			while(_local3 > -1) {
				_local1 = drops[_local3];
				_local1.update();
				if(_local1.expired) {
					remove(_local1,_local3);
					g.emitterManager.clean(_local1);
				}
				_local3--;
			}
			if(nextPickUpTime > g.time) {
				return;
			}
			_local2 = int(pickupQueue.length);
			_local3 = _local2 - 1;
			while(_local3 > -1) {
				if(pickupQueue.length > _local3) {
					tryPickup(null,pickupQueue[_local3],pickupQueue[_local3].i);
				}
				_local3--;
			}
			nextPickUpTime = g.time + 250;
		}
		
		public function getDrop() : Drop {
			return new Drop(g);
		}
		
		private function remove(drop:Drop, index:int) : void {
			drops.splice(index,1);
			g.hud.radar.remove(drop);
			createdDropIds[drop.id.toString()] = false;
			dropsById[drop.id.toString()] = null;
			drop.removeFromCanvas();
			drop.reset();
		}
		
		private function onSpawn(m:Message) : void {
			spawn(m);
		}
		
		public function spawn(m:Message, start:int = 0, end:int = 0) : void {
			var _local8:* = 0;
			var _local6:String = null;
			var _local4:int = 0;
			var _local7:Boolean = false;
			var _local5:int = int(end != 0 ? end : m.length - start);
			_local8 = start;
			while(_local8 < start + _local5) {
				_local6 = m.getString(_local8);
				_local4 = m.getInt(_local8 + 1);
				_local7 = m.getBoolean(_local8 + 2);
				if(_local6 == null || _local6 == "") {
					g.showErrorDialog("Init drops didn\'t work correctly! message: " + m.toString(),true);
					return;
				}
				if(_local6 == "empty") {
					return;
				}
				createdDropIds[_local4.toString()] = true;
				if(!_local7) {
					createSetDrop(DropFactory.createDrop(_local6,g),m,_local8);
				} else {
					createSetDrop(DropFactory.createDropFromCargo(_local6,g),m,_local8);
				}
				_local8 += 9;
			}
		}
		
		public function getDropItems(key:String, g:Game, seed:Number) : DropBase {
			var _local5:Boolean = false;
			var _local6:int = 0;
			var _local4:int = 0;
			var _local12:int = 0;
			var _local7:DropItem = null;
			if(key == "" || key == null) {
				return null;
			}
			var _local8:Random = new Random(seed);
			var _local11:Object = DataLocator.getService().loadKey("Drops",key);
			var _local10:DropBase = new DropBase();
			_local10.crate = _local11.crate;
			if(_local10.crate) {
				if(_local8.randomNumber() >= _local11.chance) {
					_local10.crate = false;
					return null;
				}
				_local5 = Boolean(_local11.artifactChance);
				_local10.containsArtifact = _local5 > _local8.randomNumber();
			}
			if(_local11.type == "mission") {
				_local6 = int(_local11.fluxMax);
				_local4 = int(_local11.fluxMin);
				_local10.flux = _local4;
				_local12 = 0;
				while(_local12 < _local6 - _local4) {
					if(_local8.randomNumber() <= 0.5) {
						break;
					}
					_local10.flux += 1;
					_local12++;
				}
				if(_local10.flux == _local6) {
					if(_local8.randomNumber() > 0.5) {
						_local10.flux = _local4;
					}
				}
				_local10.artifactAmount = _local11.artifactAmount;
				_local10.artifactLevel = _local11.artifactLevel;
			} else {
				_local10.flux = _local11.fluxMin + _local8.random(_local11.fluxMax - _local11.fluxMin + 1);
			}
			_local10.xp = _local11.xpMin + _local8.random(_local11.xpMax - _local11.xpMin + 1);
			if(_local11.reputation) {
				_local10.reputation = _local11.reputation;
			} else {
				_local10.reputation = 0;
			}
			for each(var _local9 in _local11.dropItems) {
				_local7 = getDropItem(_local9,_local8);
				if(_local7 != null) {
					_local10.items.push(_local7);
				}
			}
			return _local10;
		}
		
		public function getDropItem(obj:Object, r:Random) : DropItem {
			var _local6:DropItem = null;
			var _local3:int = 0;
			var _local5:int = 0;
			var _local8:int = 0;
			var _local4:Object = null;
			var _local7:Object = null;
			if(r.randomNumber() <= obj.chance) {
				_local6 = new DropItem();
				_local3 = 0;
				_local5 = 0;
				if(obj.min && obj.max) {
					_local3 = int(obj.min);
					_local5 = int(obj.max);
				}
				_local8 = _local5 - _local3;
				_local6.quantity = _local3 + r.random(_local8);
				_local6.item = obj.item;
				_local6.table = obj.table;
				if(_local6.quantity == 0) {
					return null;
				}
				_local4 = DataLocator.getService().loadKey(_local6.table,_local6.item);
				_local6.name = _local4.name;
				_local6.hasTechTree = _local4.hasTechTree;
				if(_local6.table == "Weapons") {
					_local6.bitmapKey = _local4.techIcon;
				} else if(_local6.table == "Skins") {
					_local7 = DataLocator.getService().loadKey("Ships",_local4.ship);
					_local6.bitmapKey = _local7.bitmap;
				} else {
					_local6.bitmapKey = _local4.bitmap;
				}
				return _local6;
			}
			return null;
		}
		
		private function createSetDrop(drop:Drop, m:Message, i:int) : void {
			var _local4:Drop = null;
			if(drop == null) {
				return;
			}
			drop.id = m.getInt(i + 1);
			drop.x = 0.01 * m.getInt(i + 3);
			drop.y = 0.01 * m.getInt(i + 4);
			drop.speed.x = 0.01 * m.getInt(i + 5);
			drop.speed.y = 0.01 * m.getInt(i + 6);
			drop.expireTime = m.getNumber(i + 7);
			drop.quantity = m.getInt(i + 8);
			if(dropsById[drop.id.toString()] != null) {
				_local4 = dropsById[drop.id.toString()];
				_local4.expire();
			}
			dropsById[drop.id.toString()] = drop;
			drops.push(drop);
		}
		
		public function tryBeamPickup(m:Message, i:int) : void {
			var _local5:String = m.getString(i);
			var _local4:int = m.getInt(i + 1);
			var _local3:Player = g.playerManager.playersById[_local5];
			var _local6:Drop = dropsById[_local4.toString()];
			if(_local6 != null && _local3 != null) {
				_local6.tractorBeamPlayer = _local3;
				_local6.expireTime = g.time + 2000;
			}
			pickupQueue.push(new PickUpMsg(m,3 * 80,i));
		}
		
		public function tryPickup(m:Message = null, po:PickUpMsg = null, i:int = 0) : void {
			var _local9:int = 0;
			if(m == null) {
				m = po.msg;
			} else if(m.length < i + 2) {
				return;
			}
			var _local8:int = m.getInt(i - 1);
			var _local6:String = m.getString(i);
			var _local5:String = m.getInt(i + 1).toString();
			var _local7:Drop = dropsById[_local5];
			if(_local7 == null && createdDropIds[_local5] != null) {
				if(createdDropIds[_local5] == true) {
					for each(var _local11 in pickupQueue) {
						if(_local11.msg == m) {
							Console.write("Pickup already queued. dropId: " + _local5);
							return;
						}
					}
					Console.write("Pickup queued.");
					pickupQueue.push(new PickUpMsg(m,80,i));
					return;
				}
				_local9 = int(pickupQueue.indexOf(po));
				pickupQueue.splice(_local9,1);
				return;
			}
			if(_local7 == null) {
				Console.write("FAILED Pickup. No drop with id : " + _local5);
				_local9 = int(pickupQueue.indexOf(po));
				if(po != null && _local9 != -1) {
					po.timeout--;
					if(po.timeout < 1) {
						pickupQueue.splice(_local9,1);
						Console.write("FAILED Pickup. Removed from queue due to timeout.");
					}
				}
				return;
			}
			var _local4:Player = g.playerManager.playersById[_local6];
			if(_local4 == null || _local4.ship == null) {
				return;
			}
			var _local10:Boolean = _local7.pickup(_local4,m,i + 2);
			if(!_local10) {
				return;
			}
			delete dropsById[_local5];
			_local9 = int(pickupQueue.indexOf(po));
			if(_local9 != -1) {
				pickupQueue.splice(_local9,1);
			}
		}
		
		private function buyTractorBeam() : void {
			g.send("buyTractorBeam");
		}
		
		public function dispose() : void {
			for each(var _local1 in drops) {
				_local1.removeFromCanvas();
				_local1.reset();
			}
			drops = null;
			createdDropIds = null;
			pickupQueue = null;
			dropsById = null;
		}
		
		public function forceUpdate() : void {
			var _local1:Drop = null;
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < drops.length) {
				_local1 = drops[_local2];
				_local1.nextDistanceCalculation = -1;
				_local2++;
			}
		}
	}
}

import playerio.Message;

class PickUpMsg {
	public var msg:Message;
	public var timeout:int;
	public var i:int;
	
	public function PickUpMsg(m:Message, timeout:int, i:int = 0) {
		super();
		this.timeout = timeout;
		this.i = i;
		this.msg = m;
	}
}
