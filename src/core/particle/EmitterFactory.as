package core.particle {
import com.greensock.TweenMax;

import core.GameObject;
import core.scene.Game;
import core.ship.EnemyShip;

import data.*;

import debug.Console;

import generics.Color;

import starling.display.Sprite;
import starling.textures.Texture;

import textures.*;

public class EmitterFactory {
    public static function create(key:String, g:Game, x:int = 0, y:int = 0, target:GameObject = null, play:Boolean = false, addToRenderList:Boolean = true, multipleAllowed:Boolean = true, canvasTarget:Sprite = null):Vector.<Emitter> {
        var delay:Number;
        var emitters:Vector.<Emitter>;
        var obj:Object;
        var e:Emitter;
        var txt:Texture;
        var bitmapObj:Object;
        var dataManager:IDataManager = DataLocator.getService();
        var effectObj:Object = dataManager.loadKey("Effects", key);
        if (!g.isLeaving && effectObj != null) {
            if (effectObj.multiple && multipleAllowed) {
                delay = Number(effectObj.multipleDelay);
                TweenMax.delayedCall(delay / 1000, function ():void {
                    var _loc3_:Number = Number(effectObj.multipleRadius);
                    var _loc1_:Number = x + (_loc3_ - _loc3_ * 2 * Math.random());
                    var _loc2_:Number = y + (_loc3_ - _loc3_ * 2 * Math.random());
                    create(key, g, _loc1_, _loc2_, target, play, addToRenderList, false);
                });
            }
            emitters = new Vector.<Emitter>();
            for each(obj in effectObj.emitters) {
                if (effectObj.singleUse && !g.camera.isOnScreen(x, y)) {
                    return null;
                }
                if (addToRenderList) {
                    e = g.emitterManager.getEmitter();
                } else {
                    e = new Emitter(g);
                }
                if (e == null) {
                    return null;
                }
                if (e.oldImageKey == obj.bitmap && e.oldImageKey != "self") {
                    txt = e.txt;
                } else {
                    txt = resolveTexture(obj, target);
                }
                e.oldImageKey = obj.bitmap;
                if (txt == null) {
                    return null;
                }
                e.txt = txt;
                e.key = key;
                e.name = effectObj.name;
                e.alive = true;
                e.duration = obj.duration;
                e.ttl = obj.ttl;
                e.ttlVariance = obj.ttlVariance;
                e.startColor = Color.fixColorCode(obj.startColor, false);
                e.finishColor = Color.fixColorCode(obj.finishColor, false);
                e.maxParticles = obj.maxParticles;
                e.startSize = obj.startSize;
                e.finishSize = obj.finishSize;
                e.speed = obj.speed;
                e.speedVariance = obj.speedVariance;
                e.angleVariance = obj.angleVariance;
                if (obj.hasOwnProperty("uniformDistribution")) {
                    e.uniformDistribution = obj.uniformDistribution;
                } else {
                    e.uniformDistribution = false;
                }
                e.startAlpha = obj.startAlpha;
                e.finishAlpha = obj.finishAlpha;
                e.startBlendMode = "add";
                e.finishBlendMode = "add";
                e.global = false;
                e.forceUpdate = true;
                e.startSizeVariance = obj.startSizeVariance;
                e.finishSizeVariance = obj.finishSizeVariance;
                e.gravityY = obj.gravityY;
                e.gravityX = obj.gravityX;
                e.centralGravity = obj.centralGravity;
                if (obj.hasOwnProperty("useFriction")) {
                    e.useFriction = obj.useFriction;
                }
                e.steadyStream = obj.steadyStream;
                e.sourceVarianceX = obj.sourceVarianceX;
                e.sourceVarianceY = obj.sourceVarianceY;
                e.followEmitter = obj.followEmitter;
                e.followTarget = obj.followTarget;
                e.shakeIntensity = obj.shakeIntensity / 1000;
                e.shakeDuration = obj.shakeDuration;
                e.posX = x;
                e.posY = y;
                bitmapObj = g.dataManager.loadKey("Images", obj.bitmap);
                if (obj.bitmap == "self" && target != null) {
                    e.startSize *= target.movieClip.scaleX;
                    e.finishSize *= target.movieClip.scaleX;
                }
                if (play) {
                    e.play();
                }
                if (e.followTarget) {
                    e.target = target;
                }
                if (canvasTarget != null) {
                    e.canvasTarget = canvasTarget;
                }
                e.collectiveMeshBatch = CollectiveMeshBatch.Create(e);
                e.collectiveMeshBatch.blendMode = "add";
                emitters.push(e);
                if (emitters.length == effectObj.emitters.length) {
                    return emitters;
                }
            }
        }
        return null;
    }

    public static function createRareType(g:Game, enemy:EnemyShip, rareType:int = 0):Vector.<Emitter> {
        var _loc4_:* = undefined;
        var _loc5_:* = undefined;
        if (g.isLeaving) {
            return new Vector.<Emitter>();
        }
        if (rareType == 1) {
            return EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw", g, enemy.pos.x, enemy.pos.y, enemy, true);
        }
        if (rareType == 2) {
            return EmitterFactory.create("Go4yOCnz40u-tQvx7g9wNg", g, enemy.pos.x, enemy.pos.y, enemy, true);
        }
        if (rareType == 4) {
            _loc4_ = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw", g, enemy.pos.x, enemy.pos.y, enemy, true);
            for each(var _loc6_ in _loc4_) {
                _loc6_.finishSize = 2.5;
                _loc6_.startSize = 2.5;
                _loc6_.startColor = 0x44ff44;
                _loc6_.finishColor = 0x44ff44;
            }
            return _loc4_;
        }
        if (rareType == 5) {
            _loc4_ = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw", g, enemy.pos.x, enemy.pos.y, enemy, true);
            for each(_loc6_ in _loc4_) {
                _loc6_.finishSize = 2.5;
                _loc6_.startSize = 2.5;
                _loc6_.startColor = 0xffff22;
                _loc6_.finishColor = 0xffff22;
                _loc6_.startAlpha = 0.3;
                _loc6_.finishAlpha = 0;
            }
            _loc5_ = _loc4_;
            _loc4_ = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw", g, enemy.pos.x, enemy.pos.y, enemy, true);
            for each(_loc6_ in _loc4_) {
                _loc6_.finishSize = 1.4;
                _loc6_.startSize = 1.4;
                _loc6_.startColor = 0xff8822;
                _loc6_.finishColor = 0xff8822;
                _loc6_.startAlpha = 0.3;
                _loc6_.finishAlpha = 0;
            }
            return _loc5_.concat(_loc4_);
        }
        if (rareType == 3) {
            return EmitterFactory.create("FWSygsW1x0q2sKlULeGZMA", g, enemy.pos.x, enemy.pos.y, enemy, true);
        }
        return new Vector.<Emitter>();
    }

    private static function resolveTexture(obj:Object, target:GameObject = null):Texture {
        var _loc4_:ITextureManager = null;
        var _loc3_:* = null;
        if (obj.bitmap == "self") {
            if (target == null) {
                Console.write("No self for effect.");
                return null;
            }
            if (target is GameObject) {
                return target.texture;
            }
            return null;
        }
        _loc4_ = TextureLocator.getService();
        return _loc4_.getTextureMainByKey(obj.bitmap);
    }

    public function EmitterFactory() {
        super();
    }
}
}

