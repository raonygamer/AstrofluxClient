package core.solarSystem {
import camerafocus.StarlingCameraFocus;

import com.greensock.TweenMax;

import core.GameObject;
import core.hud.components.explore.ExploreArea;
import core.hud.components.explore.ExploreMap;
import core.particle.Emitter;
import core.particle.EmitterFactory;
import core.player.Player;
import core.scene.Game;
import core.scene.SceneBase;
import core.spawner.SpawnFactory;
import core.spawner.Spawner;

import data.DataLocator;
import data.IDataManager;

import debug.Console;

import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Dictionary;

import generics.Random;

import sound.ISound;
import sound.SoundLocator;

import starling.display.Image;
import starling.filters.DropShadowFilter;
import starling.filters.FragmentFilter;
import starling.filters.GlowFilter;
import starling.text.TextField;

import textures.ITextureManager;
import textures.TextureLocator;
import textures.TextureManager;

public class Body extends GameObject {
    public static const TYPE_SUN:String = "sun";
    public static const TYPE_PLANET:String = "planet";
    public static const TYPE_RECYCLE_STATION:String = "junk yard";
    public static const TYPE_WEAPONS_FACTORY:String = "shop";
    public static const TYPE_UPGRADE_STATION:String = "research";
    public static const TYPE_WARP_GATE:String = "warpGate";
    public static const TYPE_COMET:String = "comet";
    public static const TYPE_HIDDEN:String = "hidden";
    public static const TYPE_BOSS:String = "boss";
    public static const TYPE_PIRATE:String = "pirate";
    public static const TYPE_WARNING:String = "warning";
    public static const TYPE_HANGAR:String = "hangar";
    public static const TYPE_CANTINA:String = "cantina";
    public static const TYPE_PAINT_SHOP:String = "paintShop";
    public static const TYPE_LORE:String = "lore";
    public static const INHABITANTS_NONE:String = "none";
    public static const INHABITANTS_FRIENDLY:String = "friendly";
    public static const INHABITANTS_NEUTRAL:String = "neutral";
    public static const INHABITANTS_HOSTILE:String = "hostile";
    public static const DEFENCE_NONE:String = "none";
    public static const DEFENCE_WEAK:String = "weak";
    public static const DEFENCE_AVERAGE:String = "medium";
    public static const DEFENCE_STRONG:String = "strong";
    public static const DEFENCE_VERY_STRONG:String = "very strong";
    public static const SIZE_TINY:String = "tiny";
    public static const SIZE_SMALL:String = "small";
    public static const SIZE_AVERAGE:String = "average";
    public static const SIZE_LARGE:String = "large";
    public static const SIZE_ENORMOUS:String = "enormous";
    public static const COLOR_WARP_GATE:uint = 2271846;
    public static const COLOR_RESEARCH:uint = 6702114;
    public static const COLOR_SHOP:uint = 4474111;
    public static const COLOR_PIRATE:uint = 16729156;
    public static const COLOR_RECYCLE_STATION:uint = 8921702;
    public static const COLOR_PLANET:uint = 16689475;
    public static const COLOR_ORBIT:uint = 49151;
    public static const COLOR_WARNING:uint = 15636992;
    public static const COLOR_CLAN:uint = 16746666;
    public static const COLOR_CANTINA:uint = 14412091;
    public static const COLOR_PAINT_SHOP:uint = 16720639;
    public static const COLOR_LORE:uint = 16720639;
    public static const SELECTED_COLOR_WARP_GATE:uint = 8978346;
    public static const SELECTED_COLOR_RESEARCH:uint = 16746530;
    public static const SELECTED_COLOR_SHOP:uint = 11184895;
    public static const SELECTED_COLOR_JUNK_YARD:uint = 16729258;
    public static const SELECTED_COLOR_PLANET:uint = 16777215;
    public static const SELECTED_COLOR_PIRATE:uint = 16746632;
    public static const SELECTED_COLOR_HANGAR:uint = 16746717;
    public static const SELECTED_COLOR_CANTINA:uint = 7796211;
    public static const SELECTED_COLOR_LORE:uint = 7796211;
    private static const EXPLOSION_EFFECT:String = "A-jBfvjj0EOstT59I4n-3w";
    private static const CREW_SPAWN_CHANCE:int = 20;

    public function Body(g:Game) {
        super();
        this.g = g;
        children = new Vector.<Body>();
        emitters = new Vector.<Emitter>();
        spawners = new Vector.<Spawner>();
        effectTarget = new GameObject();
        elite = false;
        course = new BodyHeading(this);
        soundManager = SoundLocator.getService();
        dataManager = DataLocator.getService();
    }
    public var key:String;
    public var explorable:Boolean;
    public var landable:Boolean;
    public var level:int;
    public var spawnersCleared:Boolean = true;
    public var extraAreas:int;
    public var energyFieldGoingDownStartTime:Number = 0;
    public var obj:Object;
    public var areas:Dictionary;
    public var warningRadius:int;
    public var labelOffset:int;
    public var population:int;
    public var type:String;
    public var size:String;
    public var defence:String;
    public var inhabitants:String;
    public var description:String;
    public var elite:Boolean;
    public var exploreAreas:Vector.<ExploreArea>;
    public var exploreMap:ExploreMap;
    public var generatedShells:Vector.<Vector.<Point>>;
    public var generatedAreas:Array;
    public var boss:String;
    public var safeZoneRadius:int;
    public var hostileZoneRadius:int;
    public var time:Number;
    public var course:BodyHeading;
    public var parentBody:Body;
    public var effectTarget:GameObject;
    public var emitters:Vector.<Emitter>;
    public var children:Vector.<Body>;
    public var spawners:Vector.<Spawner>;
    public var collisionRadius:Number;
    public var seed:Number;
    public var wpArray:Array;
    public var gravityForce:Number = 0;
    public var gravityDistance:Number = 0;
    public var gravityMin:Number = 0;
    public var canTriggerMission:Boolean = false;
    public var mission:String = "";
    public var missionHint:TextField = new TextField(5 * 60, 5 * 60, "?");
    public var controlZoneTimeFactor:Number = 0;
    public var controlZoneCompleteRewardFactor:Number = 0;
    public var controlZoneGrabRewardFactor:Number = 0;
    private var tween:TweenMax = null;
    private var tween2:TweenMax = null;
    private var safeZoneActive:Image;
    private var safeZoneDisabled:Image;
    private var hostileZone:Image;
    private var g:Game;
    private var soundManager:ISound;
    private var dataManager:IDataManager;
    private var rand:Random;
    private var spawnPeriod:int;
    private var currentRandom:int;
    private var currentStep:int;
    private var step:int;
    private var bodyFilter:FragmentFilter;
    private var glowImage:Image;
    private var glow:Boolean = false;
    private var glowOffsetX:Number = 0;
    private var glowOffsetY:Number = 0;
    private var hintTween:TweenMax;
    private var glowTween:TweenMax = null;

    public function get parentPos():Point {
        if (parentBody == null) {
            return course.pos;
        }
        return parentBody.course.pos;
    }

    public function set effect(emitters:Vector.<Emitter>):void {
        var _loc2_:int = 0;
        this.emitters = emitters;
        _loc2_ = 0;
        while (_loc2_ < emitters.length) {
            emitters[_loc2_].play();
            _loc2_++;
        }
    }

    public function get typeColor():uint {
        var _loc1_:* = 0;
        switch (type) {
            case "junk yard":
                _loc1_ = 8921702;
                break;
            case "research":
                _loc1_ = 6702114;
                break;
            case "shop":
                _loc1_ = 4474111;
                break;
            case "pirate":
                _loc1_ = 16729156;
                break;
            case "warpGate":
                _loc1_ = 2271846;
                break;
            case "hangar":
                _loc1_ = 16746666;
                break;
            case "cantina":
                _loc1_ = 14412091;
                break;
            case "paintShop":
                _loc1_ = 16720639;
                break;
            case "lore":
                _loc1_ = 16720639;
            default:
                _loc1_ = 16689475;
        }
        return _loc1_;
    }

    public function get selectedTypeColor():uint {
        var _loc1_:* = 0;
        switch (type) {
            case "junk yard":
                _loc1_ = 16729258;
                break;
            case "pirate":
                _loc1_ = 16746632;
                break;
            case "research":
                _loc1_ = 16746530;
                break;
            case "shop":
                _loc1_ = 11184895;
                break;
            case "warpGate":
                _loc1_ = 8978346;
                break;
            case "hangar":
                _loc1_ = 16746717;
                break;
            case "cantina":
                _loc1_ = 7796211;
                break;
            case "lore":
                _loc1_ = 7796211;
                break;
            default:
                _loc1_ = 16777215;
        }
        return _loc1_;
    }

    public function get isStation():Boolean {
        return type == "warpGate" || type == "junk yard" || type == "research" || type == "shop";
    }

    override public function draw():void {
        if (type == "hidden" || type == "boss") {
            return;
        }
        if (safeZoneRadius > 0) {
            safeZoneActive.visible = true;
            safeZoneDisabled.visible = false;
        }
        if (hostileZone != null) {
            hostileZone.visible = false;
            if (tween != null) {
                if (energyFieldGoingDownStartTime > 0 && g.time - energyFieldGoingDownStartTime > 100 * 60) {
                    Console.write("KILL TWEENER");
                    if (tween != null) {
                        tween.kill();
                    }
                    if (tween2 != null) {
                        tween2.kill();
                    }
                    hostileZone.alpha = 1;
                    if (safeZoneActive != null) {
                        safeZoneActive.alpha = 1;
                    }
                    energyFieldGoingDownStartTime = 0;
                }
            }
            if (!this.spawnersCleared || this.energyFieldGoingDownStartTime != 0) {
                hostileZone.visible = true;
            }
            if (!this.spawnersCleared && safeZoneActive != null) {
                safeZoneActive.visible = false;
            }
        }
        if (canTriggerMission && !g.me.hasTriggeredMission(mission)) {
            missionHint.visible = true;
            missionHint.x = pos.x + 10;
            missionHint.y = pos.y - 20;
        } else if (mission == "qDgXhMMZXUma7BljqEvl0w") {
            if (!g.me.hasTriggeredMission("h-13KxSyb0mOfP5frW6o0w")) {
                missionHint.visible = true;
                missionHint.x = pos.x + 10;
                missionHint.y = pos.y - 20;
            }
        } else {
            missionHint.visible = false;
        }
        if (glowImage != null) {
            glowImage.x = pos.x + glowOffsetX;
            glowImage.y = pos.y + glowOffsetY;
        }
        super.draw();
    }

    override public function removeFromCanvas():void {
        if (!isAddedToCanvas || !canvas) {
            return;
        }
        canvas.removeChild(safeZoneActive);
        canvas.removeChild(safeZoneDisabled);
        canvas.removeChild(hostileZone);
        canvas.removeChild(glowImage);
        canvas.removeChild(missionHint);
        if (_mc.filter) {
            _mc.filter.dispose();
            _mc.filter = null;
        }
        super.removeFromCanvas();
    }

    override public function reset():void {
        if (bodyFilter != null) {
            _mc.filter = null;
            bodyFilter.dispose();
            bodyFilter = null;
        }
        if (glowTween != null) {
            glowTween.kill();
        }
        if (hintTween != null) {
            hintTween.kill();
        }
        super.reset();
    }

    public function updateIsNear():void {
        if (g.me.ship == null || type == "hidden" || type == "boss") {
            return;
        }
        var _loc3_:Point = this.pos;
        var _loc1_:Point = g.camera.getCameraCenter();
        distanceToCameraX = _loc3_.x - _loc1_.x;
        distanceToCameraY = _loc3_.y - _loc1_.y;
        var _loc4_:Number = g.stage.stageWidth * 1.5;
        distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
        var _loc2_:Number = distanceToCamera - _loc4_;
        nextDistanceCalculation = _loc2_ / (10 * 60) * 100;
        if (distanceToCamera < _loc4_) {
            if (isAddedToCanvas) {
                return;
            }
            addToCanvasForReal();
        } else {
            if (!isAddedToCanvas) {
                return;
            }
            removeFromCanvas();
        }
    }

    public function updateBody(startTime:Number):void {
        var _loc3_:int = 0;
        var _loc4_:int = 0;
        var _loc2_:Number = g.time;
        course.update(startTime, _loc2_);
        x = course.pos.x;
        y = course.pos.y;
        rotation = course.angle;
        if (type == "warning") {
            return;
        }
        _loc3_ = 0;
        while (_loc3_ < spawners.length) {
            spawners[_loc3_].update();
            spawners[_loc3_].updatePos(startTime);
            _loc3_++;
        }
        _loc4_ = 0;
        while (_loc4_ < children.length) {
            children[_loc4_].updateBody(startTime);
            _loc4_++;
        }
        super.update();
        if (safeZoneActive != null) {
            safeZoneActive.x = x;
            safeZoneActive.y = y;
        }
        if (safeZoneDisabled != null) {
            safeZoneDisabled.x = x;
            safeZoneDisabled.y = y;
        }
        if (hostileZone != null) {
            hostileZone.x = x;
            hostileZone.y = y;
        }
        if (nextDistanceCalculation <= 0) {
            updateIsNear();
        } else {
            nextDistanceCalculation -= 33;
        }
    }

    public function addChild(child:Body):void {
        this.children.push(child);
        child.parentBody = this;
    }

    public function setSpawnersCleared(playSound:Boolean = true):void {
        var _loc2_:int = 0;
        spawnersCleared = true;
        energyFieldGoingDownStartTime = g.time;
        _loc2_ = 0;
        while (_loc2_ < spawners.length) {
            if (!spawners[_loc2_].hidden && spawners[_loc2_].alive) {
                spawnersCleared = false;
                return;
            }
            _loc2_++;
        }
        if (landable && playSound && g.camera.isCircleOnScreen(pos.x, pos.y, radius)) {
            soundManager.play("pvcBcrUjRE21W64-abDnCQ");
        }
        if (hostileZone != null) {
            tween = TweenMax.fromTo(hostileZone, 6, {"alpha": 1}, {
                "alpha": 0,
                "repeat": 0
            });
        }
        if (safeZoneActive != null) {
            safeZoneActive.visible = true;
            safeZoneActive.alpha = 0;
            tween2 = TweenMax.fromTo(safeZoneActive, 6, {"alpha": 0}, {
                "alpha": 1,
                "repeat": 0
            });
        }
    }

    public function getExploreAreaTypes():Array {
        var _loc3_:Object = null;
        var _loc4_:Array = [];
        var _loc1_:Array = [];
        for each(var _loc2_ in obj.exploreAreas) {
            _loc4_.push(_loc2_);
        }
        if (_loc4_.length == 0) {
            return _loc1_;
        }
        for each(var _loc5_ in _loc4_) {
            _loc3_ = dataManager.loadKey("BodyAreas", _loc5_);
            if (_loc3_ != null) {
                _loc3_["key"] = _loc5_;
                _loc1_.push(_loc3_);
            }
        }
        return _loc1_;
    }

    public function isPlayerOverMe(p:Player):Boolean {
        if (!landable || p.ship == null) {
            return false;
        }
        var _loc2_:Number = pos.x - p.ship.x;
        var _loc3_:Number = pos.y - p.ship.y;
        if (_loc2_ * _loc2_ + _loc3_ * _loc3_ <= (collisionRadius + p.ship.collisionRadius) * (collisionRadius + p.ship.collisionRadius)) {
            return true;
        }
        return false;
    }

    public function addChildren(childrenArray:Vector.<Body>):void {
        for each(var _loc2_ in childrenArray) {
            this.children.push(_loc2_);
            _loc2_.parentBody = this;
        }
    }

    public function preDraw(obj:Object):void {
        var _loc2_:Matrix = null;
        var _loc9_:Sprite = null;
        var _loc4_:Sprite = null;
        var _loc8_:Sprite = null;
        if (obj.type == "hidden" || obj.type == "boss" || obj.type == "sun" || obj.type == "comet") {
            return;
        }
        var _loc6_:Number = 5 * 60;
        var _loc5_:Number = 0;
        if (safeZoneRadius > 0) {
            _loc2_ = new Matrix();
            _loc2_.createGradientBox(2 * _loc6_, 2 * _loc6_, 0, -_loc6_, -_loc6_);
            _loc5_ = safeZoneRadius / _loc6_;
            _loc9_ = new Sprite();
            _loc9_.graphics.lineStyle(1, 0x8888ff, 0.2);
            _loc9_.graphics.beginGradientFill("radial", [0, 0, 0x8888ff], [0, 0, 0.2], [0, 200, 255], _loc2_);
            _loc9_.graphics.drawCircle(0, 0, _loc6_);
            _loc9_.graphics.endFill();
            this.safeZoneActive = TextureManager.imageFromSprite(_loc9_, "safeZoneActive");
            this.safeZoneActive.pivotX = _loc9_.width / 2;
            this.safeZoneActive.pivotY = _loc9_.height / 2;
            this.safeZoneActive.scaleX = _loc5_;
            this.safeZoneActive.scaleY = _loc5_;
            this.safeZoneActive.blendMode = "add";
            _loc4_ = new Sprite();
            _loc4_.graphics.lineStyle(1, 0xff8888, 0.2);
            _loc4_.graphics.beginGradientFill("radial", [0, 0, 0xff8888], [0, 0, 0.2], [0, 200, 255], _loc2_);
            _loc4_.graphics.drawCircle(0, 0, _loc6_);
            _loc4_.graphics.endFill();
            this.safeZoneDisabled = TextureManager.imageFromSprite(_loc4_, "safeZoneDisabled");
            this.safeZoneDisabled.pivotX = _loc4_.width / 2;
            this.safeZoneDisabled.pivotY = _loc4_.height / 2;
            this.safeZoneDisabled.scaleX = _loc5_;
            this.safeZoneDisabled.scaleY = _loc5_;
            this.safeZoneDisabled.blendMode = "add";
        }
        if (hostileZoneRadius > 0) {
            _loc2_ = new Matrix();
            _loc2_.createGradientBox(2 * _loc6_, 2 * _loc6_, 0, -_loc6_, -_loc6_);
            _loc5_ = hostileZoneRadius / _loc6_;
            _loc8_ = new Sprite();
            _loc8_.graphics.lineStyle(1, 0xff8888, 0.3);
            _loc8_.graphics.beginGradientFill("radial", [0, 0, 0xff8888], [0, 0, 0.3], [0, 200, 255], _loc2_);
            _loc8_.graphics.drawCircle(0, 0, _loc6_);
            _loc8_.graphics.endFill();
            this.hostileZone = TextureManager.imageFromSprite(_loc8_, "hostileZone");
            this.hostileZone.pivotX = _loc8_.width / 2;
            this.hostileZone.pivotY = _loc8_.height / 2;
            this.hostileZone.scaleX = _loc5_;
            this.hostileZone.scaleY = _loc5_;
            this.hostileZone.blendMode = "add";
        }
        var _loc3_:Random = new Random(obj.radius * id);
        var _loc7_:ITextureManager = TextureLocator.getService();
        glowImage = new Image(_loc7_.getTextureByTextureName("fluff.png", "texture_main_NEW.png"));
        glowImage.touchable = false;
        glowImage.blendMode = "add";
        glowImage.pivotX = glowImage.width / 2;
        glowImage.pivotY = glowImage.height / 2;
        if (!Game.highSettings) {
            return;
        }
        if (obj.type == "planet") {
            if (obj.atmosphereColor != null && obj.atmosphereColor != 0) {
                _loc5_ = _loc5_ > 1 ? 1 : _loc5_;
                bodyFilter = new GlowFilter(obj.atmosphereColor, 0.5, 5 * _loc5_, 0.25);
                bodyFilter.cache();
            }
        } else {
            bodyFilter = new DropShadowFilter(20, 0.785, 0, 0.3, 5);
            bodyFilter.cache();
        }
        if (obj.type == "warpGate") {
            glow = true;
            glowImage.color = 2271846;
            glowImage.width = 200;
            glowImage.height = 200;
            glowOffsetX = -60;
            glowOffsetY = 0;
            glowTween = TweenMax.fromTo(glowImage, 1, {"alpha": 0.1}, {
                "alpha": 0.3,
                "yoyo": true,
                "repeat": -1
            });
        } else if (obj.type == "junk yard") {
            glow = true;
            glowImage.color = 0xffaa44;
            glowImage.width = 100;
            glowImage.height = 100;
            glowOffsetX = 0;
            glowOffsetY = 0;
            glowTween = TweenMax.fromTo(glowImage, 0.2, {"alpha": 0.1}, {
                "alpha": 0.2,
                "yoyo": true,
                "repeat": -1
            });
        } else if (obj.type == "research") {
            glow = true;
            glowImage.color = 0xffff44;
            glowImage.width = 200;
            glowImage.height = 200;
            glowOffsetX = 0;
            glowOffsetY = 0;
            glowTween = TweenMax.fromTo(glowImage, 1, {"alpha": 0.1}, {
                "alpha": 0.3,
                "yoyo": true,
                "repeat": -1
            });
        } else if (obj.type == "shop") {
            glow = true;
            glowImage.color = 0x8888ff;
            glowImage.width = 200;
            glowImage.height = 200;
            glowOffsetX = -15;
            glowOffsetY = -40;
            glowTween = TweenMax.fromTo(glowImage, 1.5, {"alpha": 0.1}, {
                "alpha": 0.35,
                "yoyo": true,
                "repeat": -1
            });
        } else if (obj.type == "pirate") {
            glow = true;
            glowImage.color = 0xff8888;
            glowImage.width = 200;
            glowImage.height = 200;
            glowOffsetX = -5;
            glowOffsetY = -10;
            glowTween = TweenMax.fromTo(glowImage, 1.5, {"alpha": 0.1}, {
                "alpha": 0.35,
                "yoyo": true,
                "repeat": -1
            });
        } else if (obj.type == "hangar") {
            glow = true;
            glowImage.color = 0xff88aa;
            glowImage.width = 220;
            glowImage.height = 220;
            glowOffsetX = 0;
            glowOffsetY = 0;
            glowTween = TweenMax.fromTo(glowImage, 1.5, {"alpha": 0.1}, {
                "alpha": 0.35,
                "yoyo": true,
                "repeat": -1
            });
        } else if (obj.type == "cantina") {
            glow = true;
            glowImage.color = 0xff88aa;
            glowImage.width = 220;
            glowImage.height = 220;
            glowOffsetX = 0;
            glowOffsetY = 0;
            glowTween = TweenMax.fromTo(glowImage, 1.5, {"alpha": 0.1}, {
                "alpha": 0.35,
                "yoyo": true,
                "repeat": -1
            });
        } else if (obj.type == "lore") {
            glow = true;
            glowImage.color = 0xff88aa;
            glowImage.width = 220;
            glowImage.height = 220;
            glowOffsetX = 0;
            glowOffsetY = 0;
            glowTween = TweenMax.fromTo(glowImage, 1.5, {"alpha": 0.1}, {
                "alpha": 0.35,
                "yoyo": true,
                "repeat": -1
            });
        }
        if (canTriggerMission) {
            hintTween = TweenMax.fromTo(missionHint, 1.4, {
                "scaleX": 0.5,
                "scaleY": 0.5
            }, {
                "scaleX": 1.5,
                "scaleY": 1.5,
                "yoyo": true,
                "repeat": -1
            });
        }
    }

    public function addSpawners(obj:Object, bodyKey:String):void {
        var _loc4_:Object = null;
        var _loc3_:* = this;
        var _loc5_:Object = dataManager.loadRange("Spawners", "body", bodyKey);
        var _loc6_:int = 0;
        for each(var _loc8_ in _loc5_) {
            _loc6_++;
        }
        if (_loc6_ == 0) {
            _loc3_.hostileZoneRadius = 0;
            _loc3_.preDraw(obj);
            return;
        }
        _loc3_.hostileZoneRadius = 1.5 * _loc3_.collisionRadius;
        _loc3_.preDraw(obj);
        for (var _loc7_ in _loc5_) {
            _loc4_ = _loc5_[_loc7_];
            createSpawner(_loc4_, _loc7_.toString(), _loc3_, _loc6_);
        }
    }

    public function setInSafeZone(p:Player):void {
        if (safeZoneRadius == 0) {
            return;
        }
        if (p.ship == null) {
            return;
        }
        var _loc4_:Point = p.ship.pos;
        var _loc2_:Number = pos.x - _loc4_.x;
        var _loc3_:Number = pos.y - _loc4_.y;
        if (spawnersCleared && _loc2_ * _loc2_ + _loc3_ * _loc3_ < safeZoneRadius * safeZoneRadius) {
            p.inSafeZone = true;
            if (p.ship == null) {
                return;
            }
            if (p.ship.weapon == null) {
                return;
            }
            p.ship.weapon.fire = false;
        }
    }

    public function isOnScreen(c:StarlingCameraFocus):Boolean {
        if (safeZoneRadius > 0) {
            return c.isCircleOnScreen(pos.x, pos.y, safeZoneRadius);
        }
        if (hostileZoneRadius > 0) {
            return c.isCircleOnScreen(pos.x, pos.y, hostileZoneRadius);
        }
        return c.isCircleOnScreen(pos.x, pos.y, radius);
    }

    public function explode():void {
        type = "hidden";
        EmitterFactory.create("A-jBfvjj0EOstT59I4n-3w", g, pos.x, pos.y, null, true);
        if (g.camera.isCircleOnScreen(pos.x, pos.y, radius)) {
            soundManager.play("5psyX2Y9e0m39q43L_uEGg");
        }
    }

    public function turnOffEffects():void {
        if (bodyFilter) {
            _mc.filter = null;
            bodyFilter.dispose();
            bodyFilter = null;
        }
        if (glowImage != null) {
            if (canvas) {
                canvas.removeChild(glowImage);
            }
            glowImage = null;
        }
        if (glowTween != null) {
            glowTween.kill();
        }
    }

    private function stepRandomTo(i:int):void {
        while (i > currentRandom) {
            rand.random(1);
            currentRandom++;
        }
    }

    private function createSpawner(spawnObj:Object, key:String, b:Body, n:int):void {
        var _loc5_:Spawner = SpawnFactory.createSpawner(spawnObj, key, g);
        _loc5_.orbitAngle = b.spawners.length / n * 2 * 3.141592653589793;
        _loc5_.parentObj = b;
        if (!_loc5_.hidden) {
            b.spawnersCleared = false;
        }
        b.spawners.push(_loc5_);
    }

    private function addToCanvasForReal():void {
        canvas = g.canvasBodies;
        addToCanvas();
        if (safeZoneActive != null) {
            canvas.addChild(safeZoneActive);
        }
        if (safeZoneDisabled != null) {
            canvas.addChild(safeZoneDisabled);
        }
        if (hostileZone != null) {
            canvas.addChild(hostileZone);
        }
        if (glow && glowImage != null) {
            canvas.addChild(glowImage);
        }
        if (canTriggerMission) {
            canvas.addChild(missionHint);
        }
        if (bodyFilter != null) {
            if (SceneBase.settings.showEffects) {
                _mc.filter = bodyFilter;
                _mc.filter.cache();
            }
        }
    }
}
}

