package core.parallax {
import com.greensock.TweenMax;

import core.scene.SceneBase;

import data.DataLocator;

import debug.Console;

import generics.Random;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.MeshBatch;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;

public class ParallaxManager {
    private static const SIZE:Number = 1.8;
    private static const MINI_STARS:int = 70;
    private static const STARS:int = 40;
    private static const MINI_DUSTS:int = 25;

    public function ParallaxManager(g:SceneBase, target:DisplayObjectContainer, isIntro:Boolean = false) {
        super();
        this.g = g;
        this.target = target;
        this.isIntro = isIntro;
        nebulaContainer.blendMode = "none";
        if (!g) {
            return;
        }
        g.addResizeListener(resize);
    }
    public var stars:Vector.<Quad> = new Vector.<Quad>();
    public var miniStars:Vector.<Quad> = new Vector.<Quad>();
    public var miniDusts:Vector.<Quad> = new Vector.<Quad>();
    public var nebulas:Vector.<Quad> = new Vector.<Quad>();
    public var cx:Number = -3;
    public var cy:Number = -2;
    public var visible:Boolean = true;
    private var NEBULAS:int = 8;
    private var g:SceneBase;
    private var width:Number;
    private var height:Number;
    private var halfWidth:Number;
    private var halfHeight:Number;
    private var isIntro:Boolean;
    private var random:Random;
    private var target:DisplayObjectContainer;
    private var starBatch:MeshBatch = new MeshBatch();
    private var nebulaContainer:Sprite = new Sprite();
    private var starTxt:Texture;
    private var nebulaTxt:Texture;
    private var initialized:Boolean = false;
    private var nebulaUpdateCount:int;
    private var lastAdjustment:Number = 0;

    public function load(solarSystemObj:Object, callback:Function):void {
        var textureManager:ITextureManager = TextureLocator.getService();
        loadData(solarSystemObj, function (param1:Event):void {
            starTxt = textureManager.getTextureMainByTextureName("star.png");
            var _loc2_:Object = DataLocator.getService().loadKey("Images", solarSystemObj.background);
            var nebulaType:String = _loc2_.textureName;
            random = new Random(solarSystemObj.x * solarSystemObj.y + solarSystemObj.x + solarSystemObj.y);
            nebulaTxt = textureManager.getTextureByTextureName(_loc2_.textureName, _loc2_.fileName);
            if (solarSystemObj.galaxy == "Rapir System") {
                NEBULAS = 4;
            }
            resize();
            if (callback != null) {
                callback();
            }
        });
    }

    public function refresh():void {
        var _loc2_:int = 0;
        var _loc3_:Image = null;
        var _loc1_:Image = null;
        if (initialized) {
            clear();
        }
        if (g) {
            visible = SceneBase.settings.showBackground;
        }
        if (!nebulaTxt || !starTxt) {
            Console.write("Parallaxmanager not loaded yet, refreshing");
            TweenMax.delayedCall(0.3, refresh);
            return;
        }
        if (visible) {
            _loc2_ = 0;
            while (_loc2_ < NEBULAS) {
                _loc3_ = new Image(nebulaTxt);
                _loc3_.blendMode = "add";
                _loc3_.pivotX = _loc3_.width / 2;
                _loc3_.pivotY = _loc3_.height / 2;
                nebulas.push(_loc3_);
                if (isIntro) {
                    _loc3_.alpha = 0;
                }
                nebulaContainer.addChild(_loc3_);
                _loc2_++;
            }
            var NEBULA_UPDATE_INTERVAL:int = 200;
            nebulaUpdateCount = NEBULA_UPDATE_INTERVAL;
        } else {
            nebulaContainer.removeChildren(0, -1);
        }
        _loc2_ = 0;
        while (_loc2_ < 40) {
            _loc1_ = new Image(starTxt);
            stars.push(_loc1_);
            _loc2_++;
        }
        _loc2_ = 0;
        while (_loc2_ < 70) {
            _loc1_ = new Image(starTxt);
            miniStars.push(_loc1_);
            _loc2_++;
        }
        _loc2_ = 0;
        while (_loc2_ < 25) {
            _loc1_ = new Image(starTxt);
            miniDusts.push(_loc1_);
            _loc2_++;
        }
        target.addChild(nebulaContainer);
        target.addChild(starBatch);
        initialized = true;
        resize();
    }

    public function randomize():void {
        var _loc1_:Quad = null;
        var _loc2_:int = 0;
        _loc2_ = 0;
        while (_loc2_ < nebulas.length) {
            _loc1_ = nebulas[_loc2_];
            if (_loc2_ == 0) {
                _loc1_.x = 0;
                _loc1_.y = 0;
            } else {
                _loc1_.x = -1500 + 50 * 60 * random.randomNumber();
                _loc1_.y = -1500 + 50 * 60 * random.randomNumber();
            }
            if (isIntro) {
                _loc1_.x += 1024;
                _loc1_.y += 1024;
            }
            _loc1_.rotation = 3.141592653589793 * 2 * random.randomNumber();
            _loc2_++;
        }
        var NEBULA_UPDATE_INTERVAL:int = 200;
        nebulaUpdateCount = NEBULA_UPDATE_INTERVAL;
        _loc2_ = 0;
        while (_loc2_ < miniStars.length) {
            _loc1_ = miniStars[_loc2_];
            if (isIntro) {
                _loc1_.x = width * Math.random();
                _loc1_.y = height * Math.random();
            } else {
                _loc1_.x = -halfWidth + width * Math.random();
                _loc1_.y = -halfHeight + height * Math.random();
            }
            _loc2_++;
        }
        _loc2_ = 0;
        while (_loc2_ < stars.length) {
            _loc1_ = stars[_loc2_];
            if (isIntro) {
                _loc1_.x = width * Math.random();
                _loc1_.y = height * Math.random();
            } else {
                _loc1_.x = -halfWidth + width * Math.random();
                _loc1_.y = -halfHeight + height * Math.random();
            }
            _loc2_++;
        }
        _loc2_ = 0;
        while (_loc2_ < miniDusts.length) {
            _loc1_ = miniDusts[_loc2_];
            if (isIntro) {
                _loc1_.x = width * Math.random() * 2;
                _loc1_.y = height * Math.random() * 2;
            } else {
                _loc1_.x = -halfWidth + width * Math.random();
                _loc1_.y = -halfHeight + height * Math.random();
            }
            _loc2_++;
        }
    }

    public function update():void {
        var _loc7_:int = 0;
        var _loc8_:int = 0;
        var _loc3_:Quad = null;
        if (g != null) {
            cx = g.camera.speed.x;
            cy = g.camera.speed.y;
        }
        var _loc1_:Number = cx / 7;
        var _loc10_:Number = cy / 7;
        var _loc11_:Number = cx / 6;
        var _loc9_:Number = cy / 6;
        var _loc5_:Number = cx / 4;
        var _loc2_:Number = cy / 4;
        var _loc6_:Number = cx / 1.8;
        var _loc4_:Number = cy / 1.8;
        if (visible) {
            nebulaUpdateCount++;
            var NEBULA_UPDATE_INTERVAL:int = 200;
            if (nebulaUpdateCount > NEBULA_UPDATE_INTERVAL) {
                nebulaUpdateCount = 0;
                _loc8_ = int(nebulas.length);
                _loc7_ = 0;
                while (_loc7_ < _loc8_) {
                    _loc3_ = nebulas[_loc7_];
                    _loc3_.x -= _loc1_ * (_loc7_ / _loc8_);
                    _loc3_.y -= _loc10_ * (_loc7_ / _loc8_);
                    _loc7_++;
                }
            }
        }
        starBatch.clear();
        _loc8_ = int(stars.length);
        _loc7_ = 0;
        while (_loc7_ < _loc8_) {
            _loc3_ = stars[_loc7_];
            _loc3_.x -= _loc5_;
            _loc3_.y -= _loc2_;
            starBatch.addMesh(_loc3_);
            _loc7_++;
        }
        _loc8_ = int(miniStars.length);
        _loc7_ = 0;
        while (_loc7_ < _loc8_) {
            _loc3_ = miniStars[_loc7_];
            _loc3_.x -= _loc11_;
            _loc3_.y -= _loc9_;
            starBatch.addMesh(_loc3_);
            _loc7_++;
        }
        _loc8_ = int(miniDusts.length);
        _loc7_ = 0;
        while (_loc7_ < _loc8_) {
            _loc3_ = miniDusts[_loc7_];
            _loc3_.x -= _loc6_;
            _loc3_.y -= _loc4_;
            starBatch.addMesh(_loc3_);
            _loc7_++;
        }
    }

    public function draw():void {
        var _loc1_:int = 0;
        var _loc3_:int = 0;
        var _loc2_:Number = NaN;
        if (g) {
            _loc2_ = g.time - lastAdjustment;
            if (_loc2_ < 1000) {
                return;
            }
            lastAdjustment = g.time;
        }
        _loc3_ = int(stars.length);
        _loc1_ = 0;
        while (_loc1_ < _loc3_) {
            adjustPosition(stars[_loc1_]);
            _loc1_++;
        }
        _loc3_ = int(miniStars.length);
        _loc1_ = 0;
        while (_loc1_ < _loc3_) {
            adjustPosition(miniStars[_loc1_]);
            _loc1_++;
        }
        _loc3_ = int(miniDusts.length);
        _loc1_ = 0;
        while (_loc1_ < _loc3_) {
            adjustPosition(miniDusts[_loc1_]);
            _loc1_++;
        }
    }

    public function glow():void {
        var _loc1_:int = 0;
        var _loc2_:int = 0;
        _loc2_ = int(nebulas.length);
        _loc1_ = 0;
        while (_loc1_ < _loc2_) {
            nebulas[_loc1_].rotation = 0;
            nebulas[_loc1_].width *= 100;
            _loc1_++;
        }
        _loc2_ = int(stars.length);
        _loc1_ = 0;
        while (_loc1_ < _loc2_) {
            stars[_loc1_].scaleY = 0.1;
            stars[_loc1_].scaleX = 100;
            _loc1_++;
        }
        _loc2_ = int(miniStars.length);
        _loc1_ = 0;
        while (_loc1_ < _loc2_) {
            miniStars[_loc1_].scaleY = 0.3;
            miniStars[_loc1_].scaleX = 100;
            _loc1_++;
        }
        _loc2_ = int(miniDusts.length);
        _loc1_ = 0;
        while (_loc1_ < _loc2_) {
            miniDusts[_loc1_].scaleY = 0.5;
            miniDusts[_loc1_].scaleX = 100;
            _loc1_++;
        }
    }

    public function removeGlow():void {
        var _loc1_:int = 0;
        var _loc2_:int = 0;
        _loc2_ = int(nebulas.length);
        _loc1_ = 0;
        while (_loc1_ < _loc2_) {
            nebulas[_loc1_].rotation = 0;
            nebulas[_loc1_].width /= 100;
            _loc1_++;
        }
        _loc2_ = int(stars.length);
        _loc1_ = 0;
        while (_loc1_ < _loc2_) {
            stars[_loc1_].scaleY = 1;
            stars[_loc1_].scaleX = 1;
            _loc1_++;
        }
        _loc2_ = int(miniStars.length);
        _loc1_ = 0;
        while (_loc1_ < _loc2_) {
            miniStars[_loc1_].scaleY = 1;
            miniStars[_loc1_].scaleX = 1;
            _loc1_++;
        }
        _loc2_ = int(miniDusts.length);
        _loc1_ = 0;
        while (_loc1_ < _loc2_) {
            miniDusts[_loc1_].scaleY = 1;
            miniDusts[_loc1_].scaleX = 1;
            _loc1_++;
        }
    }

    private function loadData(solarSystemObj:Object, callback:Function):void {
        var _loc3_:Object = DataLocator.getService().loadKey("Images", solarSystemObj.background);
        var _loc4_:String = _loc3_.textureName;
        var _loc5_:ITextureManager = TextureLocator.getService();
        _loc5_.loadTextures([_loc4_ + ".xml", _loc4_ + ".jpg"]);
        _loc5_.addEventListener("preloadComplete", createLoadComplete(callback));
    }

    private function createLoadComplete(callback:Function):Function {
        return (function ():* {
            var lc:Function;
            return lc = function (param1:Event):void {
                callback(param1);
                TextureLocator.getService().removeEventListener("preloadComplete", lc);
            };
        })();
    }

    private function clear():void {
        if (!initialized) {
            return;
        }
        target.removeChildren(0, -1, true);
        nebulas.length = 0;
        stars.length = 0;
        miniStars.length = 0;
        miniDusts.length = 0;
    }

    private function adjustPosition(img:DisplayObject):void {
        var _loc2_:Number = img.x;
        var _loc3_:Number = img.y;
        if (isIntro) {
            if (_loc2_ > halfWidth * 2) {
                img.x = _loc2_ - width;
            } else if (_loc2_ < -halfWidth * 2) {
                img.x = _loc2_ + width;
            }
            if (_loc3_ > halfHeight * 2) {
                img.y = _loc3_ - height;
            } else if (_loc3_ < -halfHeight * 2) {
                img.y = _loc3_ + height;
            }
            return;
        }
        if (_loc2_ > halfWidth) {
            img.x = _loc2_ - width;
        } else if (_loc2_ < -halfWidth) {
            img.x = _loc2_ + width;
        }
        if (_loc3_ > halfHeight) {
            img.y = _loc3_ - height;
        } else if (_loc3_ < -halfHeight) {
            img.y = _loc3_ + height;
        }
    }

    private function resize(e:Event = null):void {
        width = Starling.current.stage.stageWidth * 1.8;
        height = Starling.current.stage.stageHeight * 1.8;
        halfWidth = width / 2;
        halfHeight = height / 2;
        randomize();
    }
}
}

