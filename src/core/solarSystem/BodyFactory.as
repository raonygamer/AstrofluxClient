package core.solarSystem {
	import core.hud.components.pvp.DominationManager;
	import core.hud.components.pvp.PvpManager;
	import core.hud.components.starMap.SolarSystem;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	
	public class BodyFactory {
		public function BodyFactory() {
			super();
		}
		
		public static function createSolarSystem(g:Game, key:String) : void {
			var _local5:IDataManager = DataLocator.getService();
			var _local3:Object = _local5.loadKey("SolarSystems",key);
			g.solarSystem = new SolarSystem(g,_local3,key);
			g.hud.uberStats.uberLevel = g.hud.uberStats.CalculateUberLevelFromRank(g.hud.uberStats.uberRank);
			g.parallaxManager.load(_local3,null);
			var _local4:Object = _local5.loadRange("Bodies","solarSystem",key);
			createBodies(g,_local4);
			if(g.solarSystem.type == "pvp arena" || g.solarSystem.type == "pvp dm" || g.solarSystem.type == "pvp dom") {
				addUpgradeStation(g);
				if(g.solarSystem.type == "pvp dom") {
					g.pvpManager = new DominationManager(g);
				} else {
					g.pvpManager = new PvpManager(g);
				}
				if(_local3.hasOwnProperty("items")) {
					g.pvpManager.addZones(_local3.items);
				}
			}
		}
		
		private static function addUpgradeStation(g:Game) : void {
			var _local3:Body = g.bodyManager.getRoot();
			_local3.course.pos.x = -1834;
			_local3.course.pos.y = -15391;
			_local3.key = "Research Station";
			_local3.name = "PvP Warm Up Area";
			_local3.boss = "";
			_local3.canTriggerMission = false;
			_local3.mission = "";
			var _local2:Object = {};
			_local2.bitmap = "sf86oalQ9ES4qnb4O9w6Yw";
			_local2.name = "Research Station";
			_local2.type = "research";
			_local2.safeZoneRadius = 200;
			_local2.hostileZoneRadius = 0;
			_local3.switchTexturesByObj(_local2,"texture_body.png");
			_local3.obj = _local2;
			_local3.labelOffset = 0;
			_local3.safeZoneRadius = 200;
			_local3.level = 1;
			_local3.collisionRadius = 80;
			_local3.type = "research";
			_local3.inhabitants = "none";
			_local3.population = 0;
			_local3.size = "average";
			_local3.defence = "none";
			_local3.time = 0;
			_local3.explorable = false;
			_local3.landable = true;
			_local3.elite = false;
			_local3.hostileZoneRadius = 0;
			_local3.preDraw(_local2);
		}
		
		private static function createBodies(g:Game, bodies:Object) : void {
			var _local8:int = 0;
			var _local4:Object = null;
			var _local6:Body = null;
			if(bodies == null) {
				return;
			}
			var _local7:int = 0;
			for(var _local9:* in bodies) {
				_local8++;
			}
			for(var _local10:* in bodies) {
				_local4 = bodies[_local10];
				if(_local4.parent == "") {
					_local6 = g.bodyManager.getRoot();
					_local6.course.pos.x = _local4.x;
					_local6.course.pos.y = _local4.y;
				} else {
					_local6 = g.bodyManager.getBody();
					_local6.course.orbitAngle = _local4.orbitAngle;
					_local6.course.orbitRadius = _local4.orbitRadius;
					_local6.course.orbitSpeed = _local4.orbitSpeed;
					if(_local6.course.orbitRadius != 0) {
						_local6.course.orbitSpeed /= _local6.course.orbitRadius * (60);
					}
					_local6.course.rotationSpeed = _local4.rotationSpeed / 80;
				}
				_local6.switchTexturesByObj(_local4,"texture_body.png");
				_local6.obj = _local4;
				_local6.key = _local10;
				_local6.name = _local4.name;
				if(_local4.hasOwnProperty("warningRadius")) {
					_local6.warningRadius = _local4.warningRadius;
				}
				if(_local4.hasOwnProperty("labelOffset")) {
					_local6.labelOffset = _local4.labelOffset;
				} else {
					_local6.labelOffset = 0;
				}
				if(_local4.hasOwnProperty("seed")) {
					_local6.seed = _local4.seed;
				} else {
					_local6.seed = Math.random();
				}
				if(_local4.hasOwnProperty("extraAreas")) {
					_local6.extraAreas = _local4.extraAreas;
				} else {
					_local6.extraAreas = 0;
				}
				if(_local4.hasOwnProperty("waypoints")) {
					_local6.wpArray = _local4.waypoints;
				}
				_local6.level = _local4.level;
				_local6.landable = _local4.landable;
				_local6.explorable = _local4.explorable;
				_local6.description = _local4.description;
				_local6.collisionRadius = _local4.collisionRadius;
				_local6.type = _local4.type;
				_local6.inhabitants = _local4.inhabitants;
				_local6.population = _local4.population;
				_local6.size = _local4.size;
				_local6.defence = _local4.defence;
				_local6.time = _local4.time * (60) * 1000;
				_local6.safeZoneRadius = g.isSystemTypeSurvival() ? 0 : _local4.safeZoneRadius;
				if(_local4.controlZoneTimeFactor == null) {
					_local6.controlZoneTimeFactor = 0.2;
					_local6.controlZoneCompleteRewardFactor = 0.2;
					_local6.controlZoneGrabRewardFactor = 0.2;
				} else {
					_local6.controlZoneTimeFactor = _local4.controlZoneTimeFactor;
					_local6.controlZoneCompleteRewardFactor = _local4.controlZoneCompleteRewardFactor;
					_local6.controlZoneGrabRewardFactor = _local4.controlZoneGrabRewardFactor;
				}
				_local6.canTriggerMission = _local4.canTriggerMission;
				_local6.mission = _local4.mission;
				if(_local6.canTriggerMission) {
					if(g.dataManager.loadKey("MissionTypes",_local6.mission).majorType == "time") {
						_local6.missionHint.format.color = 0xff8844;
					} else {
						_local6.missionHint.format.color = 0x88ff88;
					}
					_local6.missionHint.format.font = "DAIDRR";
					_local6.missionHint.text = "?";
					_local6.missionHint.format.size = 100;
					_local6.missionHint.pivotX = _local6.missionHint.width / 2;
					_local6.missionHint.pivotY = _local6.missionHint.height / 2;
				}
				if(_local4.hasOwnProperty("elite")) {
					_local6.elite = _local4.elite;
				}
				if(_local4.effect != null) {
					EmitterFactory.create(_local4.effect,g,_local6.pos.x,_local6.pos.y,_local6,true);
				}
				if(_local6.type == "sun") {
					_local6.gravityDistance = _local4.gravityDistance == null ? 640000 : _local4.gravityDistance * _local4.gravityDistance;
					_local6.gravityForce = _local4.gravityForce == null ? _local6.collisionRadius * 5000 : _local6.collisionRadius * _local4.gravityForce;
					_local6.gravityMin = _local4.gravityMin == null ? 15 * 60 : _local4.gravityMin * _local4.gravityMin;
				}
				_local6.addSpawners(_local4,_local10);
			}
			for each(var _local3:* in g.bodyManager.bodies) {
				for each(var _local5:* in g.bodyManager.bodies) {
					if(_local5.obj.parent == _local3.key) {
						_local3.addChild(_local5);
					}
				}
			}
			Console.write("complete init solar stuff");
		}
	}
}

