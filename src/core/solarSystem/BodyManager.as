package core.solarSystem {
	import core.scene.Game;
	import debug.Console;
	import flash.utils.Dictionary;
	import playerio.Message;
	
	public class BodyManager {
		private static const MAX_ORBIT_DIFF:Number = 10;
		public var bodiesById:Dictionary;
		public var bodies:Vector.<Body>;
		public var roots:Vector.<Body>;
		public var visibleBodies:Vector.<Body>;
		private var startTime:Number;
		private var bodyId:int = 0;
		private var g:Game;
		
		public function BodyManager(m:Game) {
			super();
			this.g = m;
			bodies = new Vector.<Body>();
			roots = new Vector.<Body>();
			bodiesById = new Dictionary();
			visibleBodies = new Vector.<Body>();
		}
		
		public function addMessageHandlers() : void {
		}
		
		public function update() : void {
			var _local2:Body = null;
			var _local3:int = 0;
			if(g.me == null || g.me.ship == null) {
				return;
			}
			var _local1:int = int(roots.length);
			_local3 = _local1 - 1;
			while(_local3 > -1) {
				_local2 = roots[_local3];
				_local2.updateBody(startTime);
				_local3--;
			}
		}
		
		public function forceUpdate() : void {
			var _local2:Body = null;
			var _local3:int = 0;
			var _local1:int = int(bodies.length);
			_local3 = _local1 - 1;
			while(_local3 > -1) {
				_local2 = bodies[_local3];
				_local2.nextDistanceCalculation = 0;
				_local3--;
			}
		}
		
		public function getBodyByKey(key:String) : Body {
			for each(var _local2 in bodies) {
				if(_local2.key == key) {
					return _local2;
				}
			}
			return null;
		}
		
		public function getBody() : Body {
			var _local1:Body = new Body(g);
			bodies.push(_local1);
			return _local1;
		}
		
		public function getRoot() : Body {
			var _local1:Body = getBody();
			roots.push(_local1);
			return _local1;
		}
		
		public function syncBodies(m:Message, index:int, endIndex:int) : void {
			var _local5:* = 0;
			var _local4:Body = null;
			_local5 = index;
			while(_local5 < endIndex) {
				_local4 = getBodyByKey(m.getString(_local5));
				if(_local4 == null) {
					Console.write("Body is null in sync.");
				}
				_local5 += 2;
			}
		}
		
		public function initSolarSystem(m:Message) : void {
			var _local9:* = 0;
			var _local8:String = m.getString(0);
			startTime = m.getNumber(2);
			g.hud.uberStats.uberRank = m.getNumber(3);
			g.hud.uberStats.uberLives = m.getNumber(4);
			BodyFactory.createSolarSystem(g,_local8);
			g.solarSystem.pvpAboveCap = m.getBoolean(1);
			_local9 = 5;
			var _local5:int = m.getInt(_local9++);
			var _local6:int = _local5 * 5 + _local9;
			while(_local9 < _local6) {
				g.deathLineManager.addLine(m.getInt(_local9),m.getInt(_local9 + 1),m.getInt(_local9 + 2),m.getInt(_local9 + 3),m.getString(_local9 + 4));
				_local9 += 5;
			}
			var _local4:int = m.getInt(_local9++);
			_local6 = _local4 * 4 + _local9;
			g.bossManager.initBosses(m,_local9,_local6);
			_local9 = _local6;
			var _local7:int = m.getInt(_local9++);
			_local6 = _local7 * 5 + _local9;
			g.spawnManager.syncSpawners(m,_local9,_local6);
			_local9 = _local6;
			var _local2:int = m.getInt(_local9++);
			_local6 = _local2 * 5 + _local9;
			g.turretManager.syncTurret(m,_local9,_local6);
			_local9 = _local6;
			var _local3:int = m.getInt(_local9++);
			_local6 = _local3 * 2 + _local9;
			g.bodyManager.syncBodies(m,_local9,_local6);
			_local9 = _local6;
		}
		
		public function dispose() : void {
			bodiesById = null;
			for each(var _local1 in bodies) {
				_local1.reset();
			}
			bodies = null;
		}
	}
}

