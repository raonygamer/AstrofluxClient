package core.hud.components.explore {
import core.scene.Game;
import core.solarSystem.Body;

import debug.Console;

import flash.display.Sprite;
import flash.geom.Point;

import generics.Random;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;

import textures.ITextureManager;
import textures.TextureLocator;
import textures.TextureManager;

public class ExploreMap extends starling.display.Sprite {
    private static const X_SIZE:int = 130;
    private static const Y_SIZE:int = 45;
    private static const FINAL_X_SIZE:int = 660;
    private static const FINAL_Y_SIZE:int = 660;
    private static const STEPS_OF_POSTPROCCESSING:int = 0;
    private static const directions:Vector.<Vector.<int>> = Vector.<Vector.<int>>([Vector.<int>([0, 1]), Vector.<int>([1, 1]), Vector.<int>([1, 0]), Vector.<int>([1, -1]), Vector.<int>([0, -1]), Vector.<int>([-1, -1]), Vector.<int>([-1, 0]), Vector.<int>([-1, 1])]);
    public static var selectedArea:Object = null;
    public static var forceSelectAreaKey:String = null;

    public function ExploreMap(g:Game, bodyAreas:Array, explored:Array, b:Body) {
        super();
        this.raw_areas = bodyAreas;
        this.extraAreas = b.extraAreas;
        this.explored = explored;
        this.seed = b.seed;
        this.g = g;
        if (!b.generatedAreas || !b.generatedShells) {
            generateMap();
            b.generatedAreas = areas;
            b.generatedShells = shell;
        } else {
            areas = b.generatedAreas;
            shell = b.generatedShells;
        }
        drawMap();
    }
    public var areas:Array;
    public var shell:Vector.<Vector.<Point>>;
    private var explored:Array;
    private var seed:Number;
    private var g:Game;
    private var r:Random;
    private var m:Vector.<Vector.<int>>;
    private var grid:Vector.<Vector.<Point>>;
    private var lastPos:int;
    private var raw_areas:Array;
    private var extraAreas:int;
    private var area_key_index:int = 0;
    private var map_areas:Vector.<ExploreMapArea>;
    private var x_chance:int = 35;
    private var y_chance:int = 25;

    public function getMapArea(key:String):ExploreMapArea {
        if (map_areas != null) {
            for each(var _loc2_ in map_areas) {
                if (_loc2_.key != null && _loc2_.key == key) {
                    return _loc2_;
                }
            }
        }
        return null;
    }

    public function moveOnTop(area:ExploreMapArea):void {
        addChild(area);
    }

    public function clearSelected(area:ExploreMapArea):void {
        for each(var _loc2_ in map_areas) {
            if (_loc2_ != area) {
                _loc2_.clearSelect();
            }
        }
    }

    private function drawMap():void {
        var _loc8_:* = null;
        var _loc9_:Number = 5.076923076923077;
        var _loc10_:Number = 5.076923076923077;
        var _loc7_:ITextureManager = TextureLocator.getService();
        addChild(new Image(_loc7_.getTextureGUIByTextureName("grid.png")));
        var _loc6_:int = 0;
        map_areas = new Vector.<ExploreMapArea>();
        for each(var _loc5_ in shell) {
            _loc8_ = null;
            for each(var _loc4_ in explored) {
                if (_loc4_.area == areas[_loc6_].key) {
                    _loc8_ = _loc4_;
                }
            }
            map_areas.push(new ExploreMapArea(g, this, areas[_loc6_], _loc5_, _loc9_, _loc10_, 130));
            _loc6_++;
        }
        _loc6_ = 10;
        while (_loc6_ > 0) {
            for each(var _loc3_ in map_areas) {
                if (_loc3_.size == _loc6_) {
                    addChild(_loc3_);
                }
            }
            _loc6_--;
        }
        selectEasiest();
        var _loc1_:Quad = new Quad(11 * 60, 80, 0);
        _loc1_.y = 65;
        var _loc2_:Quad = new Quad(11 * 60, 80, 0);
        _loc2_.y = 490;
        addChild(_loc2_);
    }

    private function generateGrid(nrX:int, nrY:int):void {
        var _loc4_:int = 0;
        var _loc3_:* = undefined;
        var _loc5_:int = 0;
        grid = new Vector.<Vector.<Point>>();
        _loc4_ = 8;
        while (_loc4_ < nrX - 6) {
            _loc3_ = new Vector.<Point>();
            _loc5_ = 1;
            while (_loc5_ < nrY + 1) {
                _loc3_.push(new Point(_loc5_ / nrX * 130, _loc4_ / nrY * 130));
                _loc5_++;
            }
            grid.push(_loc3_);
            _loc4_++;
        }
        _loc5_ = 1;
        while (_loc5_ < nrX + 1) {
            _loc3_ = new Vector.<Point>();
            _loc4_ = 8;
            while (_loc4_ < nrY - 6) {
                _loc3_.push(new Point(_loc5_ / nrX * 130, _loc4_ / nrY * 130));
                _loc4_++;
            }
            grid.push(_loc3_);
            _loc5_++;
        }
    }

    private function drawGrid(kx:Number, ky:Number):void {
        var _loc5_:int = 0;
        var _loc3_:flash.display.Sprite = new flash.display.Sprite();
        _loc3_.graphics.lineStyle(2, 0x22ff22, 0.2);
        for each(var _loc4_ in grid) {
            _loc3_.graphics.moveTo(_loc4_[0].x * kx, _loc4_[0].y * ky);
            _loc5_ = 1;
            while (_loc5_ < _loc4_.length) {
                _loc3_.graphics.lineTo(_loc4_[_loc5_].x * kx, _loc4_[_loc5_].y * ky);
                _loc5_++;
            }
        }
        _loc3_.graphics.endFill();
        addChild(TextureManager.imageFromSprite(_loc3_, "planetGrid"));
    }

    private function transformMap():void {
        var _loc5_:Number = NaN;
        var _loc4_:Number = NaN;
        var _loc7_:Number = NaN;
        var _loc3_:Number = 65;
        var _loc2_:Number = 65;
        for each(var _loc6_ in grid) {
            for each(var _loc1_ in _loc6_) {
                _loc5_ = _loc1_.x - _loc3_;
                _loc4_ = _loc1_.y - _loc2_;
                _loc7_ = Math.sin(0.5 * 3.141592653589793 * _loc5_ / _loc3_ + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _loc4_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_;
                _loc1_.x = Math.cos(0.5 * 3.141592653589793 * _loc5_ / _loc3_ + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _loc4_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_ + _loc3_ + _loc7_ * 0.1;
                _loc1_.y = Math.cos(0.5 * 3.141592653589793 * _loc4_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_ + _loc3_ + _loc7_ * 0.1;
            }
        }
        for each(_loc6_ in shell) {
            for each(_loc1_ in _loc6_) {
                _loc1_.y += 42.5;
                _loc5_ = _loc1_.x - _loc3_;
                _loc4_ = _loc1_.y - _loc2_;
                _loc7_ = Math.sin(0.5 * 3.141592653589793 * _loc5_ / _loc3_ + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _loc4_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_;
                _loc1_.x = Math.cos(0.5 * 3.141592653589793 * _loc5_ / _loc3_ + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _loc4_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_ + _loc3_ + _loc7_ * 0.1;
                _loc1_.y = Math.cos(0.5 * 3.141592653589793 * _loc4_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_ + _loc3_ + _loc7_ * 0.1;
            }
        }
    }

    private function transformMap3():void {
        var _loc7_:Number = NaN;
        var _loc5_:Number = NaN;
        var _loc2_:Number = NaN;
        var _loc6_:Number = NaN;
        var _loc4_:Number = 65;
        var _loc3_:Number = 65;
        for each(var _loc8_ in grid) {
            for each(var _loc1_ in _loc8_) {
                _loc7_ = _loc1_.x - _loc4_;
                _loc5_ = _loc1_.y - _loc3_;
                _loc6_ = Math.sqrt(_loc7_ * _loc7_ + _loc5_ * _loc5_) / _loc4_;
                _loc2_ = Math.atan2(_loc5_, _loc7_);
                if (_loc6_ <= 1) {
                    _loc6_ = Math.sqrt(_loc6_);
                }
                _loc1_.x = Math.cos(_loc2_) * _loc6_ * _loc4_ + _loc4_;
                _loc1_.y = Math.sin(_loc2_) * _loc6_ * _loc4_ + _loc3_;
            }
        }
        for each(_loc8_ in shell) {
            for each(_loc1_ in _loc8_) {
                _loc1_.y += 42.5;
                _loc7_ = _loc1_.x - _loc4_;
                _loc5_ = _loc1_.y - _loc3_;
                _loc6_ = Math.sqrt(_loc7_ * _loc7_ + _loc5_ * _loc5_) / _loc4_;
                _loc2_ = Math.atan2(_loc5_, _loc7_);
                if (_loc6_ < 1) {
                    _loc6_ = Math.sqrt(_loc6_);
                }
                _loc1_.x = Math.cos(_loc2_) * _loc6_ * _loc4_ + _loc4_;
                _loc1_.y = Math.sin(_loc2_) * _loc6_ * _loc4_ + _loc3_;
            }
        }
    }

    private function transformMap2():void {
        var _loc6_:Number = NaN;
        var _loc4_:Number = NaN;
        var _loc8_:Number = 130;
        var _loc3_:Number = 65;
        var _loc5_:Number = 130;
        var _loc2_:Number = 65;
        var _loc9_:Number = 0.5;
        for each(var _loc7_ in shell) {
            for each(var _loc1_ in _loc7_) {
                _loc1_.y += 42.5;
                _loc6_ = _loc1_.x;
                _loc4_ = _loc1_.y;
                _loc1_.x = (Math.sin(3.141592653589793 * (_loc6_ - _loc3_) / _loc3_) * _loc3_ + _loc3_) * (Math.sin(3.141592653589793 * _loc4_ / _loc5_) * _loc9_ + (1 - _loc9_)) + (1 - Math.sin(3.141592653589793 * _loc4_ / _loc5_)) * 0.5 * _loc9_ * _loc8_;
                _loc6_ = _loc1_.x;
                _loc4_ = _loc1_.y;
                _loc1_.y = (Math.sin(3.141592653589793 * (_loc4_ - _loc2_) / _loc2_) * _loc2_ + _loc2_) * (Math.sin(3.141592653589793 * _loc6_ / _loc8_) * (1 - _loc9_) + _loc9_) + (1 - Math.sin(3.141592653589793 * _loc6_ / _loc8_)) * 0.5 * (1 - _loc9_) * _loc5_;
            }
        }
        for each(_loc7_ in grid) {
            for each(_loc1_ in _loc7_) {
                _loc6_ = _loc1_.x;
                _loc4_ = _loc1_.y;
                _loc1_.x = (Math.sin(3.141592653589793 * (_loc6_ - _loc3_) / _loc3_) * _loc3_ + _loc3_) * (Math.sin(3.141592653589793 * _loc4_ / _loc5_) * _loc9_ + (1 - _loc9_)) + (1 - Math.sin(3.141592653589793 * _loc4_ / _loc5_)) * 0.5 * _loc9_ * _loc8_;
                _loc6_ = _loc1_.x;
                _loc4_ = _loc1_.y;
                _loc1_.y = (Math.sin(3.141592653589793 * (_loc4_ - _loc2_) / _loc2_) * _loc2_ + _loc2_) * (Math.sin(3.141592653589793 * _loc6_ / _loc8_) * (1 - _loc9_) + _loc9_) + (1 - Math.sin(3.141592653589793 * _loc6_ / _loc8_)) * 0.5 * (1 - _loc9_) * _loc5_;
            }
        }
    }

    private function selectEasiest():void {
        var _loc4_:int = 10000;
        var _loc5_:* = null;
        var _loc2_:* = null;
        var _loc3_:* = null;
        for each(var _loc1_ in map_areas) {
            _loc1_.clearSelect();
            if (!(_loc1_.explore != null && _loc1_.explore.finished && _loc1_.explore.lootClaimed)) {
                if (_loc4_ > _loc1_.area.skillLevel) {
                    if (ExploreMap.forceSelectAreaKey != null) {
                        if (ExploreMap.forceSelectAreaKey == _loc1_.key) {
                            _loc3_ = _loc1_;
                        }
                    } else if (_loc1_.shouldBlink()) {
                        _loc3_ = _loc1_;
                    } else if (_loc1_.fraction < 100) {
                        _loc4_ = int(_loc1_.area.skillLevel);
                        _loc2_ = _loc1_;
                    } else {
                        _loc5_ = _loc1_;
                    }
                }
            }
        }
        if (_loc3_ != null) {
            _loc3_.select();
            selectedArea = _loc3_.area;
        } else if (_loc2_ != null && _loc3_ == null) {
            _loc2_.select();
            selectedArea = _loc2_.area;
        } else if (_loc5_ != null && _loc2_ != null && _loc3_ != null) {
            _loc5_.select();
            selectedArea = _loc5_.area;
        }
    }

    private function generateMap():void {
        var done:Boolean = false;
        while (!done) {
            r = new Random(seed);
            done = tryGenerateMap();
            if (!done) {
                Console.write("Error: invalid seed!");
                seed += 0.12341;
                if (seed > 1) {
                    seed /= 2;
                }
            }
        }
    }

    private function tryGenerateMap():Boolean {
        var _loc5_:int = 0;
        var _loc3_:Object = null;
        areas = [];
        _loc5_ = 0;
        while (_loc5_ < raw_areas.length) {
            areas.push(raw_areas[_loc5_]);
            _loc5_++;
        }
        _loc5_ = 0;
        while (_loc5_ < extraAreas) {
            _loc3_ = {};
            _loc3_.size = r.random(4) + 7;
            _loc3_.majorType = -1;
            _loc3_.key = area_key_index++;
            areas.splice(r.random(areas.length), 0, _loc3_);
            _loc5_++;
        }
        var _loc6_:Number = 0;
        var _loc7_:int = int(areas.length);
        for each(var _loc1_ in areas) {
            if (_loc1_.size < 7) {
                _loc6_ += 0.5 * _loc1_.size;
            } else {
                _loc6_ += _loc1_.size;
            }
        }
        var _loc2_:int = r.random(_loc7_ - 1) + 1;
        var _loc4_:int = 0;
        var fraction_cover:Number = 0.1;
        fraction_cover += 0.01 * r.random(6) * _loc7_;
        if (fraction_cover > 0.4) {
            fraction_cover = 0.4;
        }
        fraction_cover += 0.005 * r.random(50);
        m = createMatrix(130, 45);
        _loc5_ = 1;
        while (_loc5_ <= _loc2_) {
            x_chance = 10 + r.random(50);
            y_chance = 10 + r.random(50);
            if (_loc1_.size < 7) {
                _loc4_ = Math.ceil(fraction_cover * (0.5 * areas[_loc5_ - 1].size) * 130 * 45 / _loc6_);
            } else {
                _loc4_ = Math.ceil(fraction_cover * areas[_loc5_ - 1].size * 130 * 45 / _loc6_);
            }
            if (!startNewGroup(_loc5_)) {
                return false;
            }
            if (!addSquaresToGroup(_loc5_, _loc4_)) {
                return false;
            }
            _loc5_++;
        }
        _loc5_ = _loc2_ + 1;
        while (_loc5_ <= _loc7_) {
            x_chance = 10 + r.random(50);
            y_chance = 10 + r.random(50);
            if (_loc1_.size < 7) {
                _loc4_ = Math.ceil(fraction_cover * (0.5 * areas[_loc5_ - 1].size) * 130 * 45 / _loc6_);
            } else {
                _loc4_ = Math.ceil(fraction_cover * areas[_loc5_ - 1].size * 130 * 45 / _loc6_);
            }
            if (!joinOldGroup(_loc5_)) {
                return false;
            }
            if (!addSquaresToGroup(_loc5_, _loc4_)) {
                return false;
            }
            _loc5_++;
        }
        removeInterior();
        shell = createShells(_loc7_);
        if (shell == null) {
            return false;
        }
        Console.write("explore area map done");
        return true;
    }

    private function startNewGroup(i:int):Boolean {
        var _loc3_:Vector.<int> = getRandomPosList();
        for each(var _loc2_ in _loc3_) {
            if (canAddNew(_loc2_, i)) {
                lastPos = _loc2_;
                return true;
            }
        }
        return false;
    }

    private function joinOldGroup(i:int):Boolean {
        var _loc3_:Vector.<int> = getRandomPosList();
        for each(var _loc2_ in _loc3_) {
            if (canJoinOld(_loc2_, i)) {
                lastPos = _loc2_;
                return true;
            }
        }
        return false;
    }

    private function addSquaresToGroup(i:int, nrSquares:int):Boolean {
        var _loc7_:int = 0;
        var _loc8_:int = 0;
        var _loc4_:int = 0;
        var _loc3_:* = 0;
        var _loc6_:Boolean = false;
        var _loc5_:int = 0;
        var _loc9_:int = 0;
        while (_loc4_ < nrSquares) {
            _loc6_ = false;
            _loc7_ = 0;
            while (_loc7_ < 130) {
                _loc8_ = 0;
                while (_loc8_ < 45) {
                    _loc3_ = _loc4_;
                    _loc4_ += tryAddNeighbours(_loc7_, _loc8_, i, nrSquares - _loc4_, _loc9_);
                    if (_loc4_ != _loc3_) {
                        _loc6_ = true;
                        _loc9_ = 0;
                    }
                    _loc8_++;
                }
                _loc7_++;
            }
            if (_loc6_ == false) {
                _loc5_++;
                _loc9_ += 20;
            }
            if (_loc5_ > 5) {
                Console.write("error: no space left for area " + i + ", added " + _loc4_ + " of " + nrSquares);
                return false;
            }
        }
        return true;
    }

    private function getRandomPosList():Vector.<int> {
        var _loc1_:int = 0;
        var _loc2_:Vector.<int> = new Vector.<int>();
        _loc1_ = 0;
        while (_loc1_ < 130 * 45) {
            _loc2_.splice(r.random(_loc2_.length), 0, _loc1_);
            _loc1_++;
        }
        return _loc2_;
    }

    private function enoughNrNeighbours(x:int, y:int, i:int):Boolean {
        var _loc8_:int = 0;
        var _loc7_:int = 0;
        var _loc9_:int = 0;
        var _loc4_:int = lastPos % 130;
        var _loc6_:int = (lastPos - _loc4_) / 130;
        var _loc5_:int = 0;
        if (x == _loc4_ && y == _loc6_) {
            return true;
        }
        _loc9_ = 0;
        while (_loc9_ < 8) {
            _loc8_ = x + directions[_loc9_][0];
            _loc7_ = y + directions[_loc9_][1];
            if (_loc8_ >= 0 && _loc8_ < 130 && m[_loc8_][_loc7_] == i) {
                _loc5_++;
            } else if (_loc8_ == -1 && m[130 - 1][_loc7_] == i) {
                _loc5_++;
            } else if (_loc8_ == 130 && m[0][_loc7_] == i) {
                _loc5_++;
            }
            _loc9_++;
        }
        if (_loc5_ >= 2) {
            return true;
        }
        return false;
    }

    private function tryAddNeighbours(x:int, y:int, i:int, nrLeft:int, psr:int):int {
        if (m[x][y] != i) {
            return 0;
        }
        var _loc6_:int = 0;
        if (y > 0 && y < 45 - 1 && enoughNrNeighbours(x, y, i)) {
            if (nrLeft > 0 && x + 1 < 130 && m[x + 1][y] == 0 && r.random(100) < x_chance + psr) {
                m[x + 1][y] = i;
                nrLeft--;
                _loc6_++;
            }
            if (nrLeft > 0 && x - 1 >= 0 && m[x - 1][y] == 0 && r.random(100) < x_chance + psr) {
                m[x - 1][y] = i;
                nrLeft--;
                _loc6_++;
            }
            if (nrLeft > 0 && y + 1 < 45 && m[x][y + 1] == 0 && r.random(100) < y_chance + psr) {
                m[x][y + 1] = i;
                nrLeft--;
                _loc6_++;
            }
            if (nrLeft > 0 && y - 1 >= 0 && m[x][y - 1] == 0 && r.random(100) < y_chance + psr) {
                m[x][y - 1] = i;
                nrLeft--;
                _loc6_++;
            }
        }
        return _loc6_;
    }

    private function canJoinOld(pos:int, i:int):Boolean {
        var _loc3_:int = 0;
        var _loc4_:int = 0;
        _loc3_ = pos % 130;
        _loc4_ = (pos - _loc3_) / 130;
        if (_loc4_ < 0.2 * 45 || _loc4_ > 0.8 * 45) {
            return false;
        }
        if (_loc3_ < 0.2 * 130 || _loc3_ > 0.8 * 130) {
            return false;
        }
        if (_loc4_ < 0.2 * 45 || _loc4_ > 0.8 * 45) {
            return false;
        }
        if (m[_loc3_][_loc4_] == 0 && (_loc3_ - 1 >= 0 && m[_loc3_ - 1][_loc4_] != 0 || _loc3_ + 1 < 130 && m[_loc3_ + 1][_loc4_] != 0 || _loc4_ - 1 >= 0 && m[_loc3_][_loc4_ - 1] != 0 || _loc4_ + 1 < 45 && m[_loc3_][_loc4_ + 1] != 0)) {
            m[_loc3_][_loc4_] = i;
            return true;
        }
        return false;
    }

    private function getMinDist(x:int, y:int):int {
        var _loc5_:int = 0;
        var _loc4_:int = 0;
        var _loc6_:* = 130;
        var _loc3_:int = 0;
        _loc5_ = 0;
        while (_loc5_ < 130) {
            _loc4_ = 0;
            while (_loc4_ < 45) {
                if (m[_loc5_][_loc4_] > 0) {
                    _loc3_ = dist2(x, y, _loc5_, _loc4_);
                    if (_loc3_ < _loc6_) {
                        _loc6_ = _loc3_;
                    }
                }
                _loc4_++;
            }
            _loc5_++;
        }
        return _loc6_;
    }

    private function canAddNew(pos:int, i:int):Boolean {
        var _loc3_:int = 0;
        var _loc4_:int = 0;
        _loc3_ = pos % 130;
        _loc4_ = (pos - _loc3_) / 130;
        if (_loc4_ < 0.2 * 45 || _loc4_ > 0.8 * 45) {
            return false;
        }
        if (_loc3_ < 0.25 * 130 || _loc3_ > 0.75 * 130) {
            return false;
        }
        if (m[_loc3_][_loc4_] == 0 && (_loc3_ - 1 >= 0 && m[_loc3_ - 1][_loc4_] == 0) && (_loc3_ + 1 < 130 && m[_loc3_ + 1][_loc4_] == 0) && (_loc4_ - 1 >= 0 && m[_loc3_][_loc4_ - 1] == 0) && (_loc4_ + 1 < 45 && m[_loc3_][_loc4_ + 1] == 0)) {
            m[_loc3_][_loc4_] = i;
            return true;
        }
        return false;
    }

    private function removeInterior():void {
        var _loc2_:int = 0;
        var _loc1_:int = 0;
        var _loc3_:int = 0;
        _loc1_ = 0;
        while (_loc1_ < 130) {
            _loc3_ = 0;
            while (_loc3_ < 45) {
                if (_loc3_ + 1 < 45) {
                    _loc2_ = m[_loc1_][_loc3_ + 1];
                    if (m[_loc1_][_loc3_] == 0 && _loc2_ != 0 && (_loc1_ - 1 >= 0 && m[_loc1_ - 1][_loc3_] != 0 || _loc1_ - 1 == -1 && m[130 - 1][_loc3_] != 0) && (_loc1_ + 1 < 130 && m[_loc1_ + 1][_loc3_] != 0 || _loc1_ + 1 == 130 && m[0][_loc3_] != 0) && (_loc3_ - 1 >= 0 && m[_loc1_][_loc3_ - 1] != 0) && (_loc3_ + 1 < 45 && m[_loc1_][_loc3_ + 1] != 0)) {
                        m[_loc1_][_loc3_] = _loc2_;
                    }
                }
                _loc3_++;
            }
            _loc1_++;
        }
        _loc1_ = 0;
        while (_loc1_ < 130) {
            if (_loc1_ + 1 < 130) {
                _loc2_ = m[_loc1_ + 1][0];
                if (m[_loc1_][0] == 0 && _loc2_ != 0 && (_loc1_ - 1 >= 0 && m[_loc1_ - 1][0] != 0 || _loc1_ - 1 == -1 && m[130 - 1][0] != 0) && (_loc1_ + 1 < 130 && m[_loc1_ + 1][0] != 0 || _loc1_ + 1 == 130 && m[0][0] != 0) && m[_loc1_][1] != 0) {
                    m[_loc1_][0] = _loc2_;
                }
                _loc2_ = m[_loc1_ + 1][45 - 1];
                if (m[_loc1_][45 - 1] == 0 && _loc2_ != 0 && (_loc1_ - 1 >= 0 && m[_loc1_ - 1][45 - 1] != 0 || _loc1_ - 1 == -1 && m[130 - 1][45 - 1] != 0) && (_loc1_ + 1 < 130 && m[_loc1_ + 1][45 - 1] != 0 || _loc1_ + 1 == 130 && m[0][45 - 1] != 0) && m[_loc1_][45 - 2] != 0) {
                    m[_loc1_][45 - 1] = _loc2_;
                }
            }
            _loc1_++;
        }
        _loc1_ = 0;
        while (_loc1_ < 130) {
            _loc3_ = 0;
            while (_loc3_ < 45) {
                _loc2_ = m[_loc1_][_loc3_];
                if (_loc2_ > 0 && (_loc1_ - 1 >= 0 && (m[_loc1_ - 1][_loc3_] == _loc2_ || m[_loc1_ - 1][_loc3_] == -_loc2_) || _loc1_ - 1 == -1 && (m[130 - 1][_loc3_] == _loc2_ || m[130 - 1][_loc3_] == -_loc2_)) && (_loc1_ + 1 < 130 && (m[_loc1_ + 1][_loc3_] == _loc2_ || m[_loc1_ + 1][_loc3_] == -_loc2_) || _loc1_ + 1 == 130 && (m[0][_loc3_] == _loc2_ || m[0][_loc3_] == -_loc2_)) && (_loc3_ - 1 >= 0 && (m[_loc1_][_loc3_ - 1] == _loc2_ || m[_loc1_][_loc3_ - 1] == -_loc2_)) && (_loc3_ + 1 < 45 && (m[_loc1_][_loc3_ + 1] == _loc2_ || m[_loc1_][_loc3_ + 1] == -_loc2_))) {
                    m[_loc1_][_loc3_] = -_loc2_;
                }
                _loc3_++;
            }
            _loc1_++;
        }
    }

    private function createShells(nrAreas:int):Vector.<Vector.<Point>> {
        var _loc3_:int = 0;
        var _loc2_:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
        _loc3_ = 1;
        while (_loc3_ <= nrAreas) {
            _loc2_.push(createShell(_loc3_));
            if (_loc2_[_loc2_.length - 1] == null) {
                return null;
            }
            _loc3_++;
        }
        return _loc2_;
    }

    private function getStartPoint(v:Vector.<Point>, i:int, x:int = 0, y:int = 0):void {
        if (x != 0) {
            x += 1;
        }
        if (y != 0) {
            y += 1;
        }
        x = 0;
        while (x < 130) {
            y = 0;
            while (y < 45) {
                if (m[x][y] == i) {
                    if (v == null) {
                        return;
                    }
                    v.push(new Point(x, y));
                    return;
                }
                y++;
            }
            x++;
        }
    }

    private function createShell(i:int, old_v:Vector.<Point> = null):Vector.<Point> {
        var _loc3_:Point = null;
        var _loc6_:int = 0;
        var _loc7_:int = 0;
        var _loc5_:int = 0;
        var _loc8_:int = 0;
        var _loc4_:Vector.<Point> = new Vector.<Point>();
        var _loc9_:int = 0;
        if (old_v != null) {
            _loc6_ = 0;
            _loc7_ = 0;
            for each(_loc3_ in old_v) {
                if (_loc3_.x > _loc6_) {
                    _loc6_ = _loc3_.x;
                }
                if (_loc3_.y > _loc7_) {
                    _loc7_ = _loc3_.y;
                }
            }
            getStartPoint(_loc4_, i, _loc6_, _loc7_);
            if (_loc4_.length == 0) {
                return null;
            }
        } else {
            getStartPoint(_loc4_, i);
        }
        while (!isDone(_loc4_)) {
            _loc3_ = _loc4_[_loc4_.length - 1];
            _loc9_ = getDirection(_loc4_);
            _loc4_.push(getNextPoint(_loc3_.x, _loc3_.y, i, _loc9_));
            _loc5_ = m[_loc3_.x][_loc3_.y];
        }
        if (_loc4_.length < 10) {
            return null;
        }
        _loc8_ = 0;
        while (_loc8_ < 3) {
            removeNarrows(_loc4_);
            _loc8_++;
        }
        postProccessEdge(_loc4_);
        return _loc4_;
    }

    private function getNextPoint(x:int, y:int, i:int, direction:int):Point {
        var _loc7_:int = 0;
        var _loc6_:int = 0;
        var _loc8_:int = 0;
        var _loc5_:int = direction - 1;
        _loc8_ = 0;
        while (_loc8_ < 8) {
            if (_loc5_ < 0) {
                _loc5_ = 7;
            }
            _loc7_ = x + directions[_loc5_][0];
            _loc6_ = y + directions[_loc5_][1];
            if (_loc7_ < 0) {
                _loc7_ = 130 - 1;
            }
            if (_loc7_ >= 130) {
                _loc7_ = 0;
            }
            if (_loc6_ >= 0 && _loc6_ < 45 && m[_loc7_][_loc6_] == i) {
                return new Point(_loc7_, _loc6_);
            }
            _loc5_--;
            _loc8_++;
        }
        return null;
    }

    private function getDirection(v:Vector.<Point>):int {
        var _loc6_:int = 0;
        var _loc3_:int = 0;
        var _loc4_:int = 0;
        var _loc2_:int = 0;
        var _loc5_:int = 0;
        if (v.length < 2) {
            _loc4_ = v[v.length - 1].x;
            _loc2_ = v[v.length - 1].y;
            _loc5_ = 0;
            while (_loc5_ < 8) {
                if (_loc4_ + directions[_loc5_][0] >= 0 && _loc4_ + directions[_loc5_][0] < 130 && _loc2_ + directions[_loc5_][1] >= 0 && _loc2_ + directions[_loc5_][1] < 45 && m[_loc4_ + directions[_loc5_][0]][_loc2_ + directions[_loc5_][1]] < 0) {
                    return _loc5_;
                }
                _loc5_++;
            }
            _loc5_ = 0;
            while (_loc5_ < 8) {
                if (_loc4_ + directions[_loc5_][0] >= 0 && _loc4_ + directions[_loc5_][0] < 130 && _loc2_ + directions[_loc5_][1] >= 0 && _loc2_ + directions[_loc5_][1] < 45 && m[_loc4_ + directions[_loc5_][0]][_loc2_ + directions[_loc5_][1]] == 0) {
                    _loc5_ -= 4;
                    if (_loc5_ < 0) {
                        _loc5_ = 8 + _loc5_;
                    }
                    return _loc5_;
                }
                _loc5_++;
            }
        } else {
            _loc6_ = v[v.length - 1].x;
            _loc3_ = v[v.length - 1].y;
            _loc4_ = v[v.length - 2].x;
            _loc2_ = v[v.length - 2].y;
            if (_loc6_ == 0 && _loc4_ == 130 - 1) {
                _loc4_ = -1;
            }
            if (_loc6_ == 130 - 1 && _loc4_ == 0) {
                _loc4_ = 130;
            }
            if (_loc4_ == 0 && _loc6_ == 130 - 1) {
                _loc6_ = -1;
            }
            if (_loc4_ == 130 - 1 && _loc6_ == 0) {
                _loc6_ = 130;
            }
            _loc5_ = 0;
            while (_loc5_ < 8) {
                if (_loc4_ == _loc6_ + directions[_loc5_][0] && _loc2_ == _loc3_ + directions[_loc5_][1]) {
                    return _loc5_;
                }
                _loc5_++;
            }
        }
        return 0;
    }

    private function isDone(v:Vector.<Point>):Boolean {
        if (v.length <= 2) {
            return false;
        }
        if (v[0].x == v[v.length - 1].x && v[0].y == v[v.length - 1].y) {
            return true;
        }
        return false;
    }

    private function removeNarrows(v:Vector.<Point>):void {
        var _loc2_:int = 0;
        var _loc3_:int = 0;
        var _loc4_:int = 0;
        _loc4_ = v.length - 1;
        while (_loc4_ > -1) {
            _loc2_ = _loc4_ - 1;
            _loc3_ = _loc4_ + 1;
            if (_loc2_ < 0) {
                _loc2_ = v.length + _loc2_;
            }
            if (_loc3_ >= v.length) {
                _loc3_ -= v.length;
            }
            if (v[_loc2_].x == v[_loc3_].x && v[_loc2_].y == v[_loc3_].y) {
                v.splice(_loc4_, 1);
            }
            _loc4_--;
        }
    }

    private function postProccessEdge(v:Vector.<Point>):void {
        var _loc2_:int = 0;
        var _loc5_:Boolean = false;
        var _loc3_:int = 0;
        var _loc6_:Vector.<int> = Vector.<int>([1, 3, 5, 7, 0, 2, 4, 6]);
        _loc3_ = 1;
        while (_loc3_ < v.length - 1) {
            if (v[_loc3_].x != 0 && v[_loc3_].x != 130 - 1) {
                _loc5_ = false;
                for each(var _loc4_ in _loc6_) {
                    if (v[_loc3_].y == 45 - 1 || v[_loc3_].y == 0) {
                        v[_loc3_].x += 0.01 * (-40 + r.random(80));
                        v[_loc3_].y += 0.01 * (-40 + r.random(80));
                        _loc5_ = true;
                    } else if (!_loc5_ && m[v[_loc3_].x + directions[_loc4_][0]][v[_loc3_].y + directions[_loc4_][1]] == 0) {
                        v[_loc3_].x += 0.01 * directions[_loc4_][0] * (10 + r.random(30)) + 0.01 * (-10 + r.random(20));
                        v[_loc3_].y += 0.01 * directions[_loc4_][1] * (10 + r.random(30)) + 0.01 * (-10 + r.random(20));
                        _loc5_ = true;
                    } else if (!_loc5_ && m[v[_loc3_].x + directions[_loc4_][0]][v[_loc3_].y + directions[_loc4_][1]] != m[v[_loc3_].x][v[_loc3_].y] && m[v[_loc3_].x + directions[_loc4_][0]][v[_loc3_].y + directions[_loc4_][1]] > 0) {
                        v[_loc3_].x += 0.01 * directions[_loc4_][0] * (30 + r.random(0));
                        v[_loc3_].y += 0.01 * directions[_loc4_][1] * (30 + r.random(0));
                        _loc5_ = true;
                    }
                }
            }
            _loc3_++;
        }
    }

    private function dist2(x1:int, y1:int, x2:int, y2:int):int {
        return Math.max(Math.abs(x1 - x2), Math.abs(y1 - y2));
    }

    private function dist(p1:Point, p2:Point):Number {
        return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y);
    }

    private function findClosesPoint(p1:Point, v1:Vector.<Point>):Point {
        var _loc4_:Number = NaN;
        var _loc7_:* = 16900;
        var _loc5_:* = null;
        for each(var _loc6_ in shell) {
            if (_loc6_ != v1) {
                for each(var _loc3_ in _loc6_) {
                    if (_loc3_.x != 0 && _loc3_.y != 0 && _loc3_.x != 130 - 1 && _loc3_.y != 45 - 1) {
                        _loc4_ = dist(p1, _loc3_);
                        if (_loc4_ < _loc7_) {
                            _loc7_ = _loc4_;
                            _loc5_ = _loc3_;
                        }
                    }
                }
            }
        }
        return _loc5_;
    }

    private function postProccessShells(treshhold:Number):void {
        var _loc3_:* = null;
        for each(var _loc4_ in shell) {
            for each(var _loc2_ in _loc4_) {
                if (_loc2_.x != 0 && _loc2_.y != 0 && _loc2_.x != 130 - 1 && _loc2_.y != 45 - 1) {
                    _loc3_ = findClosesPoint(_loc2_, _loc4_);
                    if (dist(_loc2_, _loc3_) < treshhold) {
                        _loc2_.x = (_loc2_.x + _loc3_.x) / 2;
                        _loc2_.y = (_loc2_.y + _loc3_.y) / 2;
                        _loc3_ = _loc2_;
                    }
                }
            }
        }
        for each(_loc4_ in shell) {
            removeNarrows(_loc4_);
        }
    }

    private function createMatrix(n:int, m:int):Vector.<Vector.<int>> {
        var _loc6_:* = undefined;
        var _loc3_:int = 0;
        var _loc4_:int = 0;
        var _loc5_:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
        _loc3_ = 0;
        while (_loc3_ < n) {
            _loc6_ = new Vector.<int>();
            _loc4_ = 0;
            while (_loc4_ < m) {
                _loc6_.push(0);
                _loc4_++;
            }
            _loc5_.push(_loc6_);
            _loc3_++;
        }
        return _loc5_;
    }
}
}

