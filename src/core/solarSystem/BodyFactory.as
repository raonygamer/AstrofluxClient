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
    public static function createSolarSystem(g:Game, key:String):void {
        var _loc5_:IDataManager = DataLocator.getService();
        var _loc3_:Object = _loc5_.loadKey("SolarSystems", key);
        g.solarSystem = new SolarSystem(g, _loc3_, key);
        g.hud.uberStats.uberLevel = g.hud.uberStats.CalculateUberLevelFromRank(g.hud.uberStats.uberRank);
        g.parallaxManager.load(_loc3_, null);
        var _loc4_:Object = _loc5_.loadRange("Bodies", "solarSystem", key);
        createBodies(g, _loc4_);
        if (g.solarSystem.type == "pvp arena" || g.solarSystem.type == "pvp dm" || g.solarSystem.type == "pvp dom") {
            addUpgradeStation(g);
            if (g.solarSystem.type == "pvp dom") {
                g.pvpManager = new DominationManager(g);
            } else {
                g.pvpManager = new PvpManager(g);
            }
            if (_loc3_.hasOwnProperty("items")) {
                g.pvpManager.addZones(_loc3_.items);
            }
        }
    }

    private static function addUpgradeStation(g:Game):void {
        var _loc3_:Body = g.bodyManager.getRoot();
        _loc3_.course.pos.x = -1834;
        _loc3_.course.pos.y = -15391;
        _loc3_.key = "Research Station";
        _loc3_.name = "PvP Warm Up Area";
        _loc3_.boss = "";
        _loc3_.canTriggerMission = false;
        _loc3_.mission = "";
        var _loc2_:Object = {};
        _loc2_.bitmap = "sf86oalQ9ES4qnb4O9w6Yw";
        _loc2_.name = "Research Station";
        _loc2_.type = "research";
        _loc2_.safeZoneRadius = 200;
        _loc2_.hostileZoneRadius = 0;
        _loc3_.switchTexturesByObj(_loc2_, "texture_body.png");
        _loc3_.obj = _loc2_;
        _loc3_.labelOffset = 0;
        _loc3_.safeZoneRadius = 200;
        _loc3_.level = 1;
        _loc3_.collisionRadius = 80;
        _loc3_.type = "research";
        _loc3_.inhabitants = "none";
        _loc3_.population = 0;
        _loc3_.size = "average";
        _loc3_.defence = "none";
        _loc3_.time = 0;
        _loc3_.explorable = false;
        _loc3_.landable = true;
        _loc3_.elite = false;
        _loc3_.hostileZoneRadius = 0;
        _loc3_.preDraw(_loc2_);
    }

    private static function createBodies(g:Game, bodies:Object):void {
        var _loc5_:int = 0;
        var _loc3_:Object = null;
        var _loc10_:Body = null;
        if (bodies == null) {
            return;
        }
        var _loc6_:int = 0;
        for (var _loc4_ in bodies) {
            _loc5_++;
        }
        for (var _loc7_ in bodies) {
            _loc3_ = bodies[_loc7_];
            if (_loc3_.parent == "") {
                _loc10_ = g.bodyManager.getRoot();
                _loc10_.course.pos.x = _loc3_.x;
                _loc10_.course.pos.y = _loc3_.y;
            } else {
                _loc10_ = g.bodyManager.getBody();
                _loc10_.course.orbitAngle = _loc3_.orbitAngle;
                _loc10_.course.orbitRadius = _loc3_.orbitRadius;
                _loc10_.course.orbitSpeed = _loc3_.orbitSpeed;
                if (_loc10_.course.orbitRadius != 0) {
                    _loc10_.course.orbitSpeed /= _loc10_.course.orbitRadius * (60);
                }
                _loc10_.course.rotationSpeed = _loc3_.rotationSpeed / 80;
            }
            _loc10_.switchTexturesByObj(_loc3_, "texture_body.png");
            _loc10_.obj = _loc3_;
            _loc10_.key = _loc7_;
            _loc10_.name = _loc3_.name;
            if (_loc3_.hasOwnProperty("warningRadius")) {
                _loc10_.warningRadius = _loc3_.warningRadius;
            }
            if (_loc3_.hasOwnProperty("labelOffset")) {
                _loc10_.labelOffset = _loc3_.labelOffset;
            } else {
                _loc10_.labelOffset = 0;
            }
            if (_loc3_.hasOwnProperty("seed")) {
                _loc10_.seed = _loc3_.seed;
            } else {
                _loc10_.seed = Math.random();
            }
            if (_loc3_.hasOwnProperty("extraAreas")) {
                _loc10_.extraAreas = _loc3_.extraAreas;
            } else {
                _loc10_.extraAreas = 0;
            }
            if (_loc3_.hasOwnProperty("waypoints")) {
                _loc10_.wpArray = _loc3_.waypoints;
            }
            _loc10_.level = _loc3_.level;
            _loc10_.landable = _loc3_.landable;
            _loc10_.explorable = _loc3_.explorable;
            _loc10_.description = _loc3_.description;
            _loc10_.collisionRadius = _loc3_.collisionRadius;
            _loc10_.type = _loc3_.type;
            _loc10_.inhabitants = _loc3_.inhabitants;
            _loc10_.population = _loc3_.population;
            _loc10_.size = _loc3_.size;
            _loc10_.defence = _loc3_.defence;
            _loc10_.time = _loc3_.time * (60) * 1000;
            _loc10_.safeZoneRadius = g.isSystemTypeSurvival() ? 0 : _loc3_.safeZoneRadius;
            if (_loc3_.controlZoneTimeFactor == null) {
                _loc10_.controlZoneTimeFactor = 0.2;
                _loc10_.controlZoneCompleteRewardFactor = 0.2;
                _loc10_.controlZoneGrabRewardFactor = 0.2;
            } else {
                _loc10_.controlZoneTimeFactor = _loc3_.controlZoneTimeFactor;
                _loc10_.controlZoneCompleteRewardFactor = _loc3_.controlZoneCompleteRewardFactor;
                _loc10_.controlZoneGrabRewardFactor = _loc3_.controlZoneGrabRewardFactor;
            }
            _loc10_.canTriggerMission = _loc3_.canTriggerMission;
            _loc10_.mission = _loc3_.mission;
            if (_loc10_.canTriggerMission) {
                if (g.dataManager.loadKey("MissionTypes", _loc10_.mission).majorType == "time") {
                    _loc10_.missionHint.format.color = 0xff8844;
                } else {
                    _loc10_.missionHint.format.color = 0x88ff88;
                }
                _loc10_.missionHint.format.font = "DAIDRR";
                _loc10_.missionHint.text = "?";
                _loc10_.missionHint.format.size = 100;
                _loc10_.missionHint.pivotX = _loc10_.missionHint.width / 2;
                _loc10_.missionHint.pivotY = _loc10_.missionHint.height / 2;
            }
            if (_loc3_.hasOwnProperty("elite")) {
                _loc10_.elite = _loc3_.elite;
            }
            if (_loc3_.effect != null) {
                EmitterFactory.create(_loc3_.effect, g, _loc10_.pos.x, _loc10_.pos.y, _loc10_, true);
            }
            if (_loc10_.type == "sun") {
                _loc10_.gravityDistance = _loc3_.gravityDistance == null ? 640000 : _loc3_.gravityDistance * _loc3_.gravityDistance;
                _loc10_.gravityForce = _loc3_.gravityForce == null ? _loc10_.collisionRadius * 5000 : _loc10_.collisionRadius * _loc3_.gravityForce;
                _loc10_.gravityMin = _loc3_.gravityMin == null ? 15 * 60 : _loc3_.gravityMin * _loc3_.gravityMin;
            }
            _loc10_.addSpawners(_loc3_, _loc7_);
        }
        for each(var _loc8_ in g.bodyManager.bodies) {
            for each(var _loc9_ in g.bodyManager.bodies) {
                if (_loc9_.obj.parent == _loc8_.key) {
                    _loc8_.addChild(_loc9_);
                }
            }
        }
        Console.write("complete init solar stuff");
    }

    public function BodyFactory() {
        super();
    }
}
}

