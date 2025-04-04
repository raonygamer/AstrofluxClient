package core.engine {
import core.GameObject;
import core.particle.Emitter;
import core.particle.EmitterFactory;
import core.scene.Game;
import core.ship.Ship;

import extensions.RibbonSegment;
import extensions.RibbonTrail;

import flash.geom.Point;

import generics.Color;

public class Engine extends GameObject {
    public function Engine(g:Game) {
        super();
        this.g = g;
        acceleration = 0;
        speed = 0;
        rotationSpeed = 0;
        rotationMod = 1;
        rotation = 0;
        alive = true;
        ship = null;
        accelerating = false;
    }
    public var thrustEmitters:Vector.<Emitter>;
    public var idleThrustEmitters:Vector.<Emitter>;
    public var speed:Number;
    public var rotationMod:Number;
    public var acceleration:Number;
    public var accelerating:Boolean;
    public var ship:Ship;
    public var alive:Boolean;
    public var dual:Boolean = false;
    public var dualDistance:int = 0;
    public var obj:Object;
    public var colorHue:Number = 0;
    public var ribbonBaseMovingRatio:Number = 1;
    public var hasRibbonTrail:Boolean = false;
    public var ribbonThickness:Number = 0;
    public var ribbonTrail:RibbonTrail;
    public var followingRibbonSegmentLine:Vector.<RibbonSegment> = new <RibbonSegment>[followingRibbonSegment];
    private var g:Game;
    private var followingRibbonSegment:RibbonSegment = new RibbonSegment();

    private var _rotationSpeed:Number;

    public function get rotationSpeed():Number {
        return _rotationSpeed * rotationMod;
    }

    public function set rotationSpeed(value:Number):void {
        _rotationSpeed = value;
    }

    override public function update():void {
        var _loc8_:Point = null;
        var _loc5_:Number = NaN;
        var _loc4_:Number = NaN;
        var _loc7_:Number = NaN;
        var _loc6_:Number = NaN;
        var _loc1_:Number = NaN;
        var _loc3_:Number = NaN;
        var _loc2_:Number = NaN;
        if (alive && ship != null && ship.alive) {
            _loc8_ = ship.enginePos;
            _loc5_ = _loc8_.y;
            _loc4_ = _loc8_.x;
            _loc7_ = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
            _loc6_ = 0;
            if (_loc4_ != 0) {
                _loc6_ = Math.atan(_loc5_ / _loc4_);
            }
            _rotation = ship.rotation + 3.141592653589793;
            _loc1_ = Math.cos(_rotation + _loc6_) * _loc7_;
            _loc3_ = Math.sin(_rotation + _loc6_) * _loc7_;
            _pos.x = ship.x + _loc1_;
            _pos.y = ship.y + _loc3_;
            if (ribbonTrail && ribbonTrail.isPlaying) {
                if (ship.speed.x != 0 || ship.speed.y != 0) {
                    _loc2_ = Math.atan2(ship.speed.y, ship.speed.x) + 3.141592653589793;
                } else {
                    _loc2_ = ship.rotation + 3.141592653589793;
                }
                followingRibbonSegment.setTo2(_pos.x, _pos.y, ribbonThickness, _loc2_, 1);
                ribbonTrail.advanceTime(33);
            }
        }
    }

    override public function reset():void {
        thrustEmitters = null;
        idleThrustEmitters = null;
        _rotationSpeed = 0;
        acceleration = 0;
        speed = 0;
        rotationSpeed = 0;
        rotationMod = 1;
        rotation = 0;
        alive = true;
        ship = null;
        accelerating = false;
        ribbonBaseMovingRatio = 1;
        hasRibbonTrail = false;
        ribbonThickness = 0;
        if (ribbonTrail) {
            g.ribbonTrailPool.removeRibbonTrail(ribbonTrail);
            ribbonTrail.isPlaying = false;
            ribbonTrail.resetAllTo(0, 0, 0, 0, 0);
            ribbonTrail = null;
        }
    }

    public function accelerate():void {
        var _loc1_:int = 0;
        var _loc2_:int = 0;
        if (accelerating) {
            return;
        }
        if (ribbonTrail) {
            ribbonTrail.movingRatio = ribbonBaseMovingRatio;
        }
        accelerating = true;
        if (!thrustEmitters) {
            return;
        }
        _loc1_ = 0;
        while (_loc1_ < thrustEmitters.length) {
            thrustEmitters[_loc1_].play();
            _loc1_++;
        }
        if (idleThrustEmitters != null) {
            _loc2_ = 0;
            while (_loc2_ < idleThrustEmitters.length) {
                idleThrustEmitters[_loc2_].stop();
                _loc2_++;
            }
        }
    }

    public function idle():void {
        var _loc1_:int = 0;
        var _loc2_:int = 0;
        if (!accelerating) {
            return;
        }
        if (ribbonTrail) {
            ribbonTrail.movingRatio = ribbonBaseMovingRatio * 1.5;
        }
        accelerating = false;
        if (!thrustEmitters) {
            return;
        }
        _loc1_ = 0;
        while (_loc1_ < thrustEmitters.length) {
            thrustEmitters[_loc1_].stop();
            _loc1_++;
        }
        if (idleThrustEmitters != null) {
            _loc2_ = 0;
            while (_loc2_ < idleThrustEmitters.length) {
                idleThrustEmitters[_loc2_].play();
                _loc2_++;
            }
        }
    }

    public function stop():void {
        var _loc1_:int = 0;
        var _loc2_:int = 0;
        if (ribbonTrail) {
            ribbonTrail.movingRatio = ribbonBaseMovingRatio * 1.5;
        }
        accelerating = false;
        if (!thrustEmitters) {
            return;
        }
        _loc1_ = 0;
        while (_loc1_ < thrustEmitters.length) {
            thrustEmitters[_loc1_].stop();
            _loc1_++;
        }
        if (idleThrustEmitters != null) {
            _loc2_ = 0;
            while (_loc2_ < idleThrustEmitters.length) {
                idleThrustEmitters[_loc2_].stop();
                _loc2_++;
            }
        }
    }

    public function destroy():void {
        hide();
        reset();
    }

    public function hide():void {
        var _loc1_:int = 0;
        var _loc2_:int = 0;
        if (hasRibbonTrail) {
            ribbonTrail.isPlaying = false;
        }
        if (!thrustEmitters) {
            return;
        }
        _loc1_ = 0;
        while (_loc1_ < thrustEmitters.length) {
            thrustEmitters[_loc1_].alive = false;
            _loc1_++;
        }
        if (idleThrustEmitters != null) {
            _loc2_ = 0;
            while (_loc2_ < idleThrustEmitters.length) {
                idleThrustEmitters[_loc2_].alive = false;
                _loc2_++;
            }
        }
        thrustEmitters = null;
        idleThrustEmitters = null;
    }

    public function show():void {
        var _loc2_:* = undefined;
        var _loc3_:Emitter = null;
        var _loc7_:* = undefined;
        var _loc8_:* = undefined;
        var _loc1_:* = undefined;
        if (hasRibbonTrail) {
            ribbonTrail.isPlaying = true;
            resetTrail();
        }
        if (!obj.useEffects || obj.effect == null) {
            return;
        }
        if (thrustEmitters != null) {
            return;
        }
        var _loc5_:int = 0;
        thrustEmitters = new Vector.<Emitter>();
        if (dual) {
            _loc2_ = EmitterFactory.create(obj.effect, g, x, y, this, accelerating);
            _loc5_ = 0;
            while (_loc5_ < _loc2_.length) {
                _loc3_ = _loc2_[_loc5_];
                _loc3_.yOffset = dualDistance / 2;
                thrustEmitters.push(_loc3_);
                _loc5_++;
            }
            _loc7_ = EmitterFactory.create(obj.effect, g, x, y, this, accelerating);
            _loc5_ = 0;
            while (_loc5_ < _loc7_.length) {
                _loc3_ = _loc7_[_loc5_];
                _loc3_.yOffset = -dualDistance / 2;
                thrustEmitters.push(_loc3_);
                _loc5_++;
            }
        } else {
            thrustEmitters = EmitterFactory.create(obj.effect, g, x, y, this, accelerating);
        }
        if (obj.changeThrustColors) {
            for each(var _loc6_ in thrustEmitters) {
                _loc6_.startColor = Color.HEXHue(obj.thrustStartColor, colorHue);
                _loc6_.finishColor = Color.HEXHue(obj.thrustFinishColor, colorHue);
            }
        } else {
            for each(_loc6_ in thrustEmitters) {
                _loc6_.changeHue(colorHue);
            }
        }
        idleThrustEmitters = new Vector.<Emitter>();
        if (dual) {
            _loc8_ = EmitterFactory.create(obj.idleEffect, g, x, y, this, !accelerating);
            _loc5_ = 0;
            while (_loc5_ < _loc8_.length) {
                _loc8_[_loc5_].yOffset = dualDistance / 2;
                idleThrustEmitters.push(_loc8_[_loc5_]);
                _loc5_++;
            }
            _loc1_ = EmitterFactory.create(obj.idleEffect, g, x, y, this, !accelerating);
            _loc5_ = 0;
            while (_loc5_ < _loc1_.length) {
                _loc1_[_loc5_].yOffset = -dualDistance / 2;
                idleThrustEmitters.push(_loc1_[_loc5_]);
                _loc5_++;
            }
        } else {
            idleThrustEmitters = EmitterFactory.create(obj.idleEffect, g, x, y, this, !accelerating);
        }
        if (obj.changeIdleThrustColors) {
            for each(var _loc4_ in idleThrustEmitters) {
                _loc4_.startColor = Color.HEXHue(obj.idleThrustStartColor, colorHue);
                _loc4_.finishColor = Color.HEXHue(obj.idleThrustFinishColor, colorHue);
            }
        } else {
            for each(_loc4_ in idleThrustEmitters) {
                _loc4_.changeHue(colorHue);
            }
        }
    }

    public function resetTrail():void {
        if (hasRibbonTrail) {
            followingRibbonSegment.setTo2(ship.pos.x, ship.pos.y, 2, 0, 1);
            ribbonTrail.resetAllTo(ship.pos.x, ship.pos.y, ship.pos.x, ship.pos.y, 0.85);
            ribbonTrail.advanceTime(33);
        }
    }
}
}

