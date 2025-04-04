package core.solarSystem {
import core.scene.Game;

import debug.Console;

import flash.utils.Dictionary;

import playerio.Message;

public class BodyManager {
    private static const MAX_ORBIT_DIFF:Number = 10;

    public function BodyManager(m:Game) {
        super();
        this.g = m;
        bodies = new Vector.<Body>();
        roots = new Vector.<Body>();
        bodiesById = new Dictionary();
        visibleBodies = new Vector.<Body>();
    }
    public var bodiesById:Dictionary;
    public var bodies:Vector.<Body>;
    public var roots:Vector.<Body>;
    public var visibleBodies:Vector.<Body>;
    private var startTime:Number;
    private var bodyId:int = 0;
    private var g:Game;

    public function addMessageHandlers():void {
    }

    public function update():void {
        var _loc3_:Body = null;
        var _loc1_:int = 0;
        if (g.me == null || g.me.ship == null) {
            return;
        }
        var _loc2_:int = int(roots.length);
        _loc1_ = _loc2_ - 1;
        while (_loc1_ > -1) {
            _loc3_ = roots[_loc1_];
            _loc3_.updateBody(startTime);
            _loc1_--;
        }
    }

    public function forceUpdate():void {
        var _loc3_:Body = null;
        var _loc1_:int = 0;
        var _loc2_:int = int(bodies.length);
        _loc1_ = _loc2_ - 1;
        while (_loc1_ > -1) {
            _loc3_ = bodies[_loc1_];
            _loc3_.nextDistanceCalculation = 0;
            _loc1_--;
        }
    }

    public function getBodyByKey(key:String):Body {
        for each(var _loc2_ in bodies) {
            if (_loc2_.key == key) {
                return _loc2_;
            }
        }
        return null;
    }

    public function getBody():Body {
        var _loc1_:Body = new Body(g);
        bodies.push(_loc1_);
        return _loc1_;
    }

    public function getRoot():Body {
        var _loc1_:Body = getBody();
        roots.push(_loc1_);
        return _loc1_;
    }

    public function syncBodies(m:Message, index:int, endIndex:int):void {
        var _loc5_:* = 0;
        var _loc4_:Body = null;
        _loc5_ = index;
        while (_loc5_ < endIndex) {
            _loc4_ = getBodyByKey(m.getString(_loc5_));
            if (_loc4_ == null) {
                Console.write("Body is null in sync.");
            }
            _loc5_ += 2;
        }
    }

    public function initSolarSystem(m:Message):void {
        var _loc7_:* = 0;
        var _loc8_:String = m.getString(0);
        startTime = m.getNumber(2);
        g.hud.uberStats.uberRank = m.getNumber(3);
        g.hud.uberStats.uberLives = m.getNumber(4);
        BodyFactory.createSolarSystem(g, _loc8_);
        g.solarSystem.pvpAboveCap = m.getBoolean(1);
        _loc7_ = 5;
        var _loc4_:int = m.getInt(_loc7_++);
        var _loc6_:int = _loc4_ * 5 + _loc7_;
        while (_loc7_ < _loc6_) {
            g.deathLineManager.addLine(m.getInt(_loc7_), m.getInt(_loc7_ + 1), m.getInt(_loc7_ + 2), m.getInt(_loc7_ + 3), m.getString(_loc7_ + 4));
            _loc7_ += 5;
        }
        var _loc2_:int = m.getInt(_loc7_++);
        _loc6_ = _loc2_ * 4 + _loc7_;
        g.bossManager.initBosses(m, _loc7_, _loc6_);
        _loc7_ = _loc6_;
        var _loc5_:int = m.getInt(_loc7_++);
        _loc6_ = _loc5_ * 5 + _loc7_;
        g.spawnManager.syncSpawners(m, _loc7_, _loc6_);
        _loc7_ = _loc6_;
        var _loc3_:int = m.getInt(_loc7_++);
        _loc6_ = _loc3_ * 5 + _loc7_;
        g.turretManager.syncTurret(m, _loc7_, _loc6_);
        _loc7_ = _loc6_;
        var _loc9_:int = m.getInt(_loc7_++);
        _loc6_ = _loc9_ * 2 + _loc7_;
        g.bodyManager.syncBodies(m, _loc7_, _loc6_);
        _loc7_ = _loc6_;
    }

    public function dispose():void {
        bodiesById = null;
        for each(var _loc1_ in bodies) {
            _loc1_.reset();
        }
        bodies = null;
    }
}
}

