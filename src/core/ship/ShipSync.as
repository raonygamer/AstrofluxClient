package core.ship {
import core.particle.EmitterFactory;
import core.player.Player;
import core.scene.Game;
import core.states.AIStates.AIChase;
import core.states.AIStates.AIExit;
import core.states.AIStates.AIFlee;
import core.states.AIStates.AIFollow;
import core.states.AIStates.AIIdle;
import core.states.AIStates.AIKamikaze;
import core.states.AIStates.AIMelee;
import core.states.AIStates.AIObserve;
import core.states.AIStates.AIOrbit;
import core.states.AIStates.AIResurect;
import core.states.AIStates.AIReturnOrbit;
import core.states.AIStates.AITeleport;
import core.states.AIStates.AITeleportExit;
import core.sync.Converger;
import core.unit.Unit;

import debug.Console;

import flash.geom.Point;
import flash.utils.Dictionary;

import movement.Heading;

import playerio.Message;

public class ShipSync {
    public function ShipSync(g:Game) {
        super();
        this.g = g;
    }
    private var g:Game;

    public function addMessageHandlers():void {
        g.addMessageHandler("aiCourse", aiCourse);
        g.addMessageHandler("mirrorCourse", mirrorCourse);
        g.addMessageHandler("AIStickyStart", aiStickyStart);
        g.addMessageHandler("AIStickyEnd", aiStickyEnd);
    }

    public function playerCourse(m:Message, i:int = 0):void {
        var _loc8_:Dictionary = g.playerManager.playersById;
        var _loc7_:String = m.getString(i);
        var _loc4_:Heading = new Heading();
        _loc4_.parseMessage(m, i + 1);
        var _loc9_:Player = _loc8_[_loc7_];
        if (_loc9_ == null || _loc9_.ship == null) {
            return;
        }
        var _loc5_:Ship = _loc9_.ship;
        if (_loc5_.getConverger() == null || _loc5_.course == null) {
            return;
        }
        var _loc3_:Converger = _loc5_.getConverger();
        var _loc6_:Heading = _loc5_.course;
        if (_loc6_ == null) {
            return;
        }
        if (_loc9_.isMe) {
            fastforwardMe(_loc5_, _loc4_);
            if (!_loc6_.almostEqual(_loc4_)) {
                _loc3_.setConvergeTarget(_loc4_);
            }
        } else {
            _loc6_.accelerate = _loc4_.accelerate;
            _loc6_.rotateLeft = _loc4_.rotateLeft;
            _loc6_.rotateRight = _loc4_.rotateRight;
            _loc3_.setConvergeTarget(_loc4_);
        }
    }

    public function playerUsedBoost(m:Message, i:int):void {
        var _loc8_:Dictionary = g.playerManager.playersById;
        var _loc7_:String = m.getString(i);
        var _loc4_:Heading = new Heading();
        _loc4_.parseMessage(m, i + 1);
        var _loc9_:Player = _loc8_[_loc7_];
        if (_loc9_ == null || _loc9_.ship == null) {
            return;
        }
        var _loc5_:PlayerShip = _loc9_.ship;
        var _loc3_:Converger = _loc5_.getConverger();
        var _loc6_:Heading = _loc5_.course;
        if (_loc6_ == null || _loc3_ == null) {
            return;
        }
        if (_loc9_.isMe) {
            fastforwardMe(_loc5_, _loc4_);
            if (!_loc6_.almostEqual(_loc4_)) {
                _loc3_.setConvergeTarget(_loc4_);
            }
        } else {
            _loc6_.accelerate = true;
            _loc6_.deaccelerate = false;
            _loc6_.rotateLeft = false;
            _loc6_.rotateRight = false;
            _loc5_.boost();
            _loc3_.setConvergeTarget(_loc4_);
        }
    }

    public function aiCourse(m:Message):void {
        var _loc6_:int = 0;
        var _loc13_:int = 0;
        var _loc4_:Heading = null;
        var _loc7_:EnemyShip = null;
        var _loc3_:int = 0;
        var _loc12_:String = null;
        var _loc10_:Unit = null;
        var _loc5_:int = 0;
        var _loc8_:int = 0;
        var _loc2_:String = null;
        var _loc14_:Boolean = false;
        var _loc9_:Unit = null;
        var _loc15_:Dictionary = g.shipManager.enemiesById;
        _loc6_ = 0;
        while (_loc6_ < m.length) {
            _loc13_ = m.getInt(_loc6_);
            _loc4_ = new Heading();
            _loc4_.parseMessage(m, _loc6_ + 1);
            _loc7_ = _loc15_[_loc13_];
            if (_loc7_ == null) {
                Console.write("Error bad enemy id in course sync: " + _loc13_);
                return;
            }
            if (!_loc7_.aiCloak) {
                _loc7_.setConvergeTarget(_loc4_);
            }
            _loc3_ = m.getInt(_loc6_ + 1 + 10);
            _loc12_ = m.getString(_loc6_ + 2 + 10);
            _loc10_ = g.unitManager.getTarget(_loc3_);
            _loc7_.target = _loc10_;
            if (!_loc7_.stateMachine.inState(_loc12_)) {
                switch (_loc14_) {
                    case "AIChase":
                        _loc7_.stateMachine.changeState(new AIChase(g, _loc7_, _loc10_, _loc4_, 0));
                        break;
                    case "AIFollow":
                        _loc7_.stateMachine.changeState(new AIFollow(g, _loc7_, _loc10_, _loc4_, 0));
                        break;
                    case "AIMelee":
                        _loc7_.stateMachine.changeState(new AIMelee(g, _loc7_, _loc10_, _loc4_, 0));
                }
            }
            _loc5_ = m.getInt(_loc6_ + 3 + 10);
            _loc8_ = 0;
            while (_loc8_ < _loc5_) {
                _loc2_ = m.getString(_loc6_ + _loc8_ * 3 + 4 + 10);
                _loc14_ = m.getBoolean(_loc6_ + _loc8_ * 3 + 5 + 10);
                _loc9_ = g.unitManager.getTarget(m.getInt(_loc6_ + _loc8_ * 3 + 6 + 10));
                for each(var _loc11_ in _loc7_.weapons) {
                    if (_loc11_.name == _loc2_) {
                        _loc11_.fire = _loc14_;
                        _loc11_.target = _loc9_;
                    }
                }
                _loc8_++;
            }
            _loc6_ += _loc5_ * 3;
            _loc6_ = _loc6_ + (4 + 10);
        }
    }

    public function mirrorCourse(m:Message):void {
        var _loc2_:Ship = g.playerManager.me.mirror;
        if (_loc2_ == null) {
            return;
        }
        var _loc3_:Heading = new Heading();
        _loc3_.parseMessage(m, 0);
        _loc2_.course = _loc3_;
    }

    public function aiStickyStart(m:Message):void {
        var _loc5_:Dictionary = g.shipManager.enemiesById;
        var _loc4_:int = m.getInt(0);
        var _loc2_:int = m.getInt(1);
        var _loc3_:EnemyShip = _loc5_[_loc4_];
        var _loc6_:Unit = g.unitManager.getTarget(_loc2_);
        if (_loc3_ == null || !_loc3_.alive || _loc6_ == null) {
            return;
        }
        if (_loc3_.meleeChargeEndTime != 0) {
            _loc3_.meleeChargeEndTime = 1;
        }
        _loc3_.target = _loc6_;
        _loc3_.meleeOffset = new Point(m.getNumber(2), m.getNumber(3));
        _loc3_.meleeTargetStartAngle = m.getNumber(4);
        _loc3_.meleeTargetAngleDiff = m.getNumber(5);
        _loc3_.meleeStuck = true;
    }

    public function aiStickyEnd(m:Message):void {
        var _loc4_:Dictionary = g.shipManager.enemiesById;
        var _loc3_:int = m.getInt(0);
        var _loc2_:EnemyShip = _loc4_[_loc3_];
        if (_loc2_ == null || !_loc2_.alive) {
            return;
        }
        _loc2_.meleeStuck = false;
    }

    public function aiCharge(m:Message, i:int):void {
        var _loc5_:Dictionary = g.shipManager.enemiesById;
        var _loc4_:int = m.getInt(i);
        var _loc3_:EnemyShip = _loc5_[_loc4_];
        if (_loc3_ == null || !_loc3_.alive) {
            return;
        }
        _loc3_.meleeChargeEndTime = g.time + _loc3_.meleeChargeDuration;
        _loc3_.oldSpeed = _loc3_.engine.speed;
        _loc3_.oldTurningSpeed = _loc3_.engine.rotationSpeed;
        _loc3_.engine.rotationSpeed = 0;
        _loc3_.course.rotation = m.getNumber(i + 1);
        _loc3_.engine.speed = (1 + _loc3_.meleeChargeSpeedBonus) * _loc3_.engine.speed;
        _loc3_.chargeEffect = EmitterFactory.create("nHVuxJzeyE-JVcn7M-UOwA", g, _loc3_.pos.x, _loc3_.pos.y, _loc3_, true);
    }

    public function aiStateChanged(m:Message, i:int = 0):void {
        var _loc13_:Dictionary = null;
        var _loc11_:int = 0;
        var _loc12_:String = null;
        var _loc5_:int = 0;
        var _loc6_:Heading = null;
        var _loc7_:EnemyShip = null;
        var _loc4_:int = 0;
        var _loc8_:Unit = null;
        var _loc9_:Number = NaN;
        var _loc10_:Number = NaN;
        var _loc3_:Point = null;
        try {
            _loc13_ = g.shipManager.enemiesById;
            _loc11_ = m.getInt(i);
            _loc12_ = m.getString(i + 1);
            _loc5_ = m.getInt(i + 2);
            _loc6_ = new Heading();
            i = _loc6_.parseMessage(m, i + 3);
            _loc7_ = _loc13_[_loc11_];
            if (_loc7_ == null || !_loc7_.alive) {
                return;
            }
            switch (_loc12_) {
                case "AICloakStarted":
                    _loc7_.cloakStart();
                    break;
                case "AICloakEnded":
                    _loc7_.cloakEnd(_loc6_);
                    break;
                case "AIHardenShield":
                    _loc7_.hardenShield();
                    break;
                case "AIObserve":
                    _loc4_ = m.getInt(i);
                    _loc8_ = g.unitManager.getTarget(_loc4_);
                    if (_loc8_ != null) {
                        _loc7_.stateMachine.changeState(new AIObserve(g, _loc7_, _loc8_, _loc6_, _loc5_));
                    } else {
                        Console.write("No Ai target: " + _loc4_);
                    }
                    break;
                case "AIChase":
                    _loc4_ = m.getInt(i);
                    _loc8_ = g.unitManager.getTarget(_loc4_);
                    if (_loc8_ != null) {
                        _loc7_.stateMachine.changeState(new AIChase(g, _loc7_, _loc8_, _loc6_, _loc5_));
                    } else {
                        Console.write("No Ai target: " + _loc4_);
                    }
                    break;
                case "AIResurect":
                    _loc7_.stateMachine.changeState(new AIResurect(g, _loc7_));
                case "AIFollow":
                    _loc4_ = m.getInt(i);
                    _loc8_ = g.unitManager.getTarget(_loc4_);
                    if (_loc8_ != null) {
                        _loc7_.stateMachine.changeState(new AIFollow(g, _loc7_, _loc8_, _loc6_, _loc5_));
                    } else {
                        Console.write("No Ai target: " + _loc4_);
                    }
                    break;
                case "AIMelee":
                    _loc4_ = m.getInt(i);
                    _loc8_ = g.unitManager.getTarget(_loc4_);
                    if (_loc8_ != null) {
                        _loc7_.stateMachine.changeState(new AIMelee(g, _loc7_, _loc8_, _loc6_, _loc5_));
                    } else {
                        Console.write("No Ai target: " + _loc4_);
                    }
                    break;
                case "AIOrbit":
                    _loc7_.stateMachine.changeState(new AIOrbit(g, _loc7_));
                    break;
                case "AIIdle":
                    _loc7_.stateMachine.changeState(new AIIdle(g, _loc7_, _loc7_.course));
                    break;
                case "AIReturn":
                    _loc9_ = m.getNumber(i);
                    _loc10_ = m.getNumber(i + 1);
                    _loc7_.stateMachine.changeState(new AIReturnOrbit(g, _loc7_, _loc9_, _loc10_, _loc6_, _loc5_));
                    break;
                case "AIKamikaze":
                    _loc4_ = m.getInt(i);
                    _loc8_ = g.unitManager.getTarget(_loc4_);
                    if (_loc8_ != null) {
                        _loc7_.stateMachine.changeState(new AIKamikaze(g, _loc7_, _loc8_, _loc6_, _loc5_));
                    } else {
                        Console.write("No Ai target: " + _loc4_);
                    }
                    break;
                case "AIFlee":
                    _loc3_ = new Point(m.getNumber(i), m.getNumber(i + 1));
                    _loc7_.stateMachine.changeState(new AIFlee(g, _loc7_, _loc3_, _loc6_, _loc5_));
                    break;
                case "AITeleport":
                    _loc7_.stateMachine.changeState(new AITeleport(g, _loc7_, _loc7_.target, _loc5_, m.getNumber(i), m.getNumber(i + 1)));
                    break;
                case "AITeleportExit":
                    _loc7_.stateMachine.changeState(new AITeleportExit(g, _loc7_));
                    break;
                case "AIExit":
                    _loc7_.stateMachine.changeState(new AIExit(g, _loc7_));
            }
        } catch (e:Error) {
            g.client.errorLog.writeError("MSG PACK: " + e.toString(), "State: " + _loc12_, e.getStackTrace(), {});
        }
    }

    private function fastforwardMe(myShip:Ship, heading:Heading):void {
        g.commandManager.clearCommands(heading.time);
        while (heading.time < myShip.course.time) {
            g.commandManager.runCommand(heading, heading.time);
            myShip.convergerUpdateHeading(heading);
        }
    }

    private function fastforward(ship:Ship, heading:Heading):void {
        var _loc3_:Heading = ship.course;
        while (heading.time < _loc3_.time) {
            ship.convergerUpdateHeading(heading);
        }
    }
}
}

