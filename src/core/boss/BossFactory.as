package core.boss {
import core.particle.EmitterFactory;
import core.scene.Game;
import core.solarSystem.Body;
import core.spawner.*;
import core.states.AIStates.AIBoss;
import core.states.AIStates.AITurret;
import core.turret.*;
import core.unit.Unit;

import data.*;

import flash.geom.Point;

import generics.Util;

public class BossFactory {
    public static function createBoss(key:String, body:Body, wpArray:Array, parentKey:String, g:Game):Boss {
        var _loc7_:Number = NaN;
        var _loc9_:IDataManager = DataLocator.getService();
        var _loc8_:Object = _loc9_.loadKey("Bosses", key);
        var _loc6_:Boss = new Boss(g);
        _loc6_.name = _loc8_.name;
        _loc6_.parentBody = body;
        _loc6_.key = key;
        _loc6_.alive = true;
        _loc6_.isHostile = true;
        _loc6_.awaitingActivation = true;
        _loc6_.xp = _loc8_.xp;
        _loc6_.level = _loc8_.level;
        _loc6_.layer = _loc8_.layer;
        _loc6_.hp = 0;
        _loc6_.hpMax = 1;
        _loc6_.resetTime = _loc8_.resetTime;
        _loc6_.respawnTime = _loc8_.respawnTime;
        _loc6_.speed = _loc8_.speed;
        _loc6_.rotationSpeed = _loc8_.rotationSpeed;
        _loc6_.rotationForced = _loc8_.rotationForced;
        _loc6_.acceleration = _loc8_.acceleration;
        _loc6_.holonomic = _loc8_.holonomic;
        if (_loc8_.hasOwnProperty("AIFaction1") && _loc8_.AIFaction1 != "") {
            _loc6_.factions.push(_loc8_.AIFaction1);
        }
        if (_loc8_.hasOwnProperty("AIFaction2") && _loc8_.AIFaction2 != "") {
            _loc6_.factions.push(_loc8_.AIFaction2);
        }
        if (_loc8_.hasOwnProperty("regen")) {
            _loc6_.hpRegen = _loc8_.regen;
        } else {
            _loc6_.hpRegen = 0;
        }
        _loc6_.targetRange = _loc8_.targetRange;
        _loc6_.orbitOrign = new Point();
        _loc6_.bossRadius = _loc8_.radius;
        for each(var _loc10_ in wpArray) {
            _loc6_.waypoints.push(new Waypoint(g, _loc10_.body, _loc10_.xpos, _loc10_.ypos, _loc10_.id));
        }
        _loc6_.waypoints.push(new Waypoint(g, parentKey, 0, 0, 1));
        if (_loc8_.hasOwnProperty("explosionSound")) {
            _loc6_.explosionSound = _loc8_.explosionSound;
        } else {
            _loc6_.explosionSound = "";
        }
        if (_loc8_.hasOwnProperty("explosionEffect")) {
            _loc6_.explosionEffect = _loc8_.explosionEffect;
        } else {
            _loc6_.explosionEffect = "";
        }
        _loc6_.switchTexturesByObj(_loc8_);
        if (g.isSystemTypeSurvival()) {
            if (_loc6_.name == "Tefat") {
                _loc6_.level = 6;
            } else {
                if (_loc6_.name == "Mandrom") {
                    _loc6_.level = 12;
                }
                if (_loc6_.name == "Rotator") {
                    _loc6_.level = 15;
                }
                if (_loc6_.name == "Dominator") {
                    _loc6_.level = 7;
                }
                if (_loc6_.name == "Chelonidron") {
                    _loc6_.level = 94;
                }
                if (_loc6_.name == "Motherbrain") {
                    _loc6_.level = 54;
                }
                if (g.hud.uberStats.uberRank == 1) {
                    _loc6_.level = 7;
                }
            }
        }
        addTurrets(_loc8_, g, _loc6_);
        addSpawners(_loc8_, g, _loc6_);
        addBossComponents(_loc8_, g, _loc6_);
        if (g.isSystemTypeSurvival() && _loc6_.level < g.hud.uberStats.uberLevel) {
            _loc7_ = g.hud.uberStats.CalculateUberRankFromLevel(_loc6_.level);
            _loc6_.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _loc7_, _loc6_.level);
            _loc6_.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _loc6_.level) / 100;
            _loc6_.xp *= _loc6_.uberLevelFactor;
            _loc6_.level = g.hud.uberStats.uberLevel;
            _loc6_.speed *= _loc6_.uberLevelFactor;
            if (_loc6_.speed > 380) {
                _loc6_.speed = 380;
            }
        } else if (_loc6_.name == "Chelonidron") {
            _loc6_.level = 54;
        }
        _loc6_.addFactions();
        sortComponents(g, _loc6_);
        _loc6_.calcHpMax();
        _loc6_.stateMachine.changeState(new AIBoss(g, _loc6_));
        return _loc6_;
    }

    private static function addTurrets(obj:Object, g:Game, b:Boss):void {
        var _loc4_:Array = obj.turrets;
        for each(var _loc5_ in _loc4_) {
            createTurret(_loc5_, b, g);
        }
    }

    private static function createTurret(turretObj:Object, b:Boss, g:Game):void {
        var _loc4_:Turret = TurretFactory.createTurret(turretObj, turretObj.turret, g, b);
        _loc4_.offset = new Point(turretObj.xpos, turretObj.ypos);
        _loc4_.startAngle = Util.degreesToRadians(turretObj.angle);
        _loc4_.syncId = turretObj.id;
        _loc4_.parentObj = b;
        _loc4_.alive = true;
        _loc4_.name = turretObj.name;
        _loc4_.rotation = _loc4_.startAngle;
        _loc4_.hideIfInactive = turretObj.hideIfInactive;
        _loc4_.essential = turretObj.essential;
        _loc4_.active = turretObj.active;
        _loc4_.invulnerable = turretObj.invulnerable;
        _loc4_.triggersToActivte = turretObj.triggersToActivte;
        _loc4_.triggers = getTriggers(turretObj, g);
        _loc4_.layer = turretObj.layer;
        b.turrets.push(_loc4_);
        b.allComponents.push(_loc4_);
        _loc4_.stateMachine.changeState(new AITurret(g, _loc4_));
    }

    private static function addSpawners(obj:Object, g:Game, b:Boss):void {
        var _loc7_:Object = null;
        var _loc4_:IDataManager = DataLocator.getService();
        var _loc5_:Array = obj.spawners;
        if (_loc5_.length == 0) {
            return;
        }
        for (var _loc6_ in _loc5_) {
            _loc7_ = _loc5_[_loc6_];
            createSpawner(_loc7_, _loc6_.toString(), b, g);
        }
    }

    private static function createSpawner(bossSpawnObj:Object, key:String, b:Boss, g:Game):void {
        var _loc6_:Object = DataLocator.getService().loadKey("Spawners", bossSpawnObj.spawner);
        var _loc5_:Spawner = SpawnFactory.createSpawner(_loc6_, "bossSpawner_" + b.key + "_" + key, g, b);
        _loc5_.parentObj = b;
        _loc5_.offset = new Point(bossSpawnObj.xpos, bossSpawnObj.ypos);
        _loc5_.imageOffset = new Point(bossSpawnObj.imageOffsetX, bossSpawnObj.imageOffsetY);
        _loc5_.syncId = bossSpawnObj.id;
        _loc5_.alive = true;
        _loc5_.rotation = bossSpawnObj.angle / (3 * 60) * 3.141592653589793;
        _loc5_.angleOffset = _loc5_.parentObj.rotation - _loc5_.rotation;
        _loc5_.name = bossSpawnObj.name;
        _loc5_.hideIfInactive = bossSpawnObj.hideIfInactive;
        _loc5_.essential = bossSpawnObj.essential;
        _loc5_.active = bossSpawnObj.active;
        _loc5_.invulnerable = bossSpawnObj.invulnerable;
        _loc5_.triggersToActivte = bossSpawnObj.triggersToActivte;
        _loc5_.triggers = getTriggers(bossSpawnObj, g);
        _loc5_.orbitRadius = 0;
        _loc5_.orbitAngle = 0;
        _loc5_.offset = new Point(bossSpawnObj.xpos, bossSpawnObj.ypos);
        _loc5_.imageOffset = new Point(bossSpawnObj.imageOffsetX, bossSpawnObj.imageOffsetY);
        _loc5_.layer = bossSpawnObj.layer;
        b.spawners.push(_loc5_);
        b.allComponents.push(_loc5_);
    }

    private static function addBossComponents(obj:Object, g:Game, b:Boss):void {
        var _loc4_:Array = obj.basicObjs;
        for each(var _loc5_ in _loc4_) {
            createBossComponent(_loc5_, b, g);
        }
    }

    private static function createBossComponent(compObj:Object, b:Boss, g:Game):void {
        var _loc5_:Number = NaN;
        var _loc4_:BossComponent = new BossComponent(g);
        _loc4_.switchTexturesByObj(compObj);
        _loc4_.parentObj = b;
        _loc4_.offset = new Point(compObj.xpos, compObj.ypos);
        _loc4_.imageOffset = new Point(compObj.imageOffsetX, compObj.imageOffsetY);
        _loc4_.syncId = compObj.id;
        _loc4_.parentObj = b;
        _loc4_.hp = compObj.hp;
        _loc4_.hpMax = compObj.hp;
        _loc4_.shieldHp = 0;
        _loc4_.shieldHpMax = 0;
        _loc4_.xp = compObj.xp;
        _loc4_.level = compObj.level;
        _loc4_.essential = compObj.essential;
        if (g.isSystemTypeSurvival() && b != null) {
            _loc4_.level = b.level;
        }
        if (g.isSystemTypeSurvival() && _loc4_.level < g.hud.uberStats.uberLevel && _loc4_.essential) {
            _loc5_ = g.hud.uberStats.CalculateUberRankFromLevel(_loc4_.level);
            _loc4_.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _loc5_, _loc4_.level);
            _loc4_.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _loc4_.level) / 100;
            if (b != null) {
                _loc4_.uberDifficulty *= g.hud.uberStats.uberRank / 2 + 1;
            }
            _loc4_.xp *= _loc4_.uberLevelFactor;
            _loc4_.level = g.hud.uberStats.uberLevel;
            _loc4_.hp = _loc4_.hpMax = _loc4_.hpMax * _loc4_.uberDifficulty;
            _loc4_.shieldHp = _loc4_.shieldHpMax = _loc4_.shieldHpMax * _loc4_.uberDifficulty;
        }
        _loc4_.alive = true;
        _loc4_.imageAngle = Util.degreesToRadians(compObj.angle);
        _loc4_.name = compObj.name;
        _loc4_.imageScale = compObj.scale;
        _loc4_.imageRotationSpeed = compObj.rotationSpeed;
        _loc4_.imageRotationMax = compObj.maxAngle;
        _loc4_.imageRotationMin = compObj.minAngle;
        _loc4_.imagePivotPoint = new Point(compObj.pivotPointX, compObj.pivotPointY);
        _loc4_.hideIfInactive = compObj.hideIfInactive;
        _loc4_.active = compObj.active;
        _loc4_.invulnerable = compObj.invulnerable;
        _loc4_.triggersToActivte = compObj.triggersToActivte;
        _loc4_.triggers = getTriggers(compObj, g);
        _loc4_.isHostile = true;
        _loc4_.collisionRadius = compObj.collisionRadius;
        _loc4_.layer = compObj.layer;
        b.allComponents.push(_loc4_);
        b.bossComponents.push(_loc4_);
        if (compObj.hasOwnProperty("explosionEffect")) {
            _loc4_.explosionEffect = compObj.explosionEffect;
        }
        if (compObj.hasOwnProperty("effect")) {
            _loc4_.effectX = compObj.effectX;
            _loc4_.effectY = compObj.effectY;
            _loc4_.effect = EmitterFactory.create(compObj.effect, g, 0, 0, _loc4_.effectTarget, true);
        }
    }

    private static function getTriggers(obj:Object, g:Game):Vector.<Trigger> {
        var _loc5_:int = 0;
        var _loc6_:Object = null;
        var _loc4_:Trigger = null;
        var _loc7_:Vector.<Trigger> = new Vector.<Trigger>();
        var _loc3_:Array = obj.triggers;
        if (_loc3_ == null) {
            return _loc7_;
        }
        _loc5_ = 0;
        while (_loc5_ < _loc3_.length) {
            _loc6_ = _loc3_[_loc5_];
            _loc4_ = new Trigger(g);
            _loc4_.id = _loc6_.id;
            _loc4_.target = _loc6_.target;
            _loc4_.delay = _loc6_.delay;
            _loc4_.activate = _loc6_.activte;
            _loc4_.inactivate = _loc6_.inactivte;
            _loc4_.vulnerable = _loc6_.vulnerable;
            _loc4_.invulnerable = _loc6_.invulnerable;
            _loc4_.kill = _loc6_.kill;
            _loc4_.threshhold = Number(_loc6_.threshhold) / 100;
            _loc4_.inactivateSelf = _loc6_.inactivateSelf;
            if (_loc6_.hasOwnProperty("sound")) {
                _loc4_.soundName = _loc6_.sound;
            } else {
                _loc4_.soundName = "";
            }
            if (_loc6_.hasOwnProperty("explosionEffect")) {
                _loc4_.explosionEffect = _loc6_.explosionEffect;
                _loc4_.xpos = _loc6_.xpos;
                _loc4_.ypos = _loc6_.ypos;
            } else {
                _loc4_.explosionEffect = "";
                _loc4_.xpos = 0;
                _loc4_.ypos = 0;
            }
            _loc4_.editBase = _loc6_.editBase;
            _loc4_.speed = _loc6_.speed;
            _loc4_.acceleration = _loc6_.acceleration;
            _loc4_.rotationForced = _loc6_.rotationForced;
            _loc4_.rotationSpeed = _loc6_.rotationSpeed;
            _loc4_.targetRange = _loc6_.targetRange;
            _loc7_.push(_loc4_);
            _loc5_++;
        }
        return _loc7_;
    }

    private static function sortComponents(g:Game, b:Boss):void {
        b.allComponents.sort(compareFunction);
        for each(var _loc3_ in b.allComponents) {
            _loc3_.isBossUnit = true;
            _loc3_.distanceToCamera = 0;
            g.unitManager.add(_loc3_, g.canvasBosses, false);
        }
    }

    private static function compareFunction(u1:Unit, u2:Unit):int {
        if (u1.layer < u2.layer) {
            return -1;
        }
        if (u1.layer > u2.layer) {
            return 1;
        }
        return 0;
    }

    public function BossFactory() {
        super();
    }
}
}

