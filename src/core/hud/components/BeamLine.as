package core.hud.components {
import core.scene.Game;

import starling.display.MeshBatch;

public class BeamLine extends MeshBatch {
    public function BeamLine(g:Game) {
        super();
        this.g = g;
    }
    public var nodeFrequence:int;
    public var thickness:Number;
    public var amplitude:Number;
    private var ampFactor:Number;
    private var glowWidth:Number;
    private var glowColor:Number;
    private var lineTexture:String;
    private var lines:Vector.<Line> = new Vector.<Line>();
    private var g:Game;

    private var _color:uint;

    override public function get color():uint {
        return _color;
    }

    override public function set color(value:uint):void {
        var _loc2_:int = 0;
        var _loc3_:Line = null;
        _loc2_ = 0;
        while (_loc2_ < lines.length) {
            _loc3_ = lines[_loc2_];
            _loc3_.color = value;
            _loc2_++;
        }
        _color = value;
    }

    override public function set touchable(value:Boolean):void {
        var _loc2_:int = 0;
        var _loc3_:Line = null;
        _loc2_ = 0;
        while (_loc2_ < lines.length) {
            _loc3_ = lines[0];
            _loc3_.touchable = value;
            _loc2_++;
        }
        super.touchable = value;
    }

    override public function clear():void {
        var _loc1_:int = 0;
        super.clear();
        _loc1_ = 0;
        while (_loc1_ < lines.length) {
            g.linePool.removeLine(lines[_loc1_]);
            _loc1_++;
        }
        lines.length = 0;
    }

    public function init(thickness:Number = 3, nodeFrequence:int = 3, amplitude:Number = 2, color:uint = 16777215, alpha:Number = 1, glowWidth:Number = 3, glowColor:uint = 16711680, lineTexture:String = "line2"):void {
        this.thickness = thickness * 2;
        this.nodeFrequence = nodeFrequence;
        this.amplitude = amplitude;
        this.ampFactor = ampFactor;
        this.alpha = alpha;
        this.glowWidth = glowWidth;
        this.glowColor = glowColor;
        this.lineTexture = lineTexture;
        this.blendMode = "add";
        _color = color;
        this.touchable = true;
    }

    public function lineTo(toX:Number, toY:Number, chargeUpEffect:Number = 1):void {
        var _loc9_:int = 0;
        var _loc11_:Line = null;
        var _loc15_:int = 0;
        var _loc8_:Line = null;
        var _loc13_:Number = NaN;
        var _loc12_:Number = NaN;
        var _loc6_:Number = toX - x;
        var _loc7_:Number = toY - y;
        var _loc16_:Number = _loc6_ * _loc6_ + _loc7_ * _loc7_;
        var _loc14_:Number = Math.sqrt(_loc16_);
        var period:int = 100;
        var _loc10_:Number = Math.round(_loc14_ / period * nodeFrequence);
        if (_loc10_ == 0) {
            _loc10_ = 1;
        }
        if (_loc10_ > lines.length) {
            _loc15_ = _loc10_ - lines.length;
            _loc9_ = 0;
            while (_loc9_ < _loc15_) {
                _loc11_ = g.linePool.getLine();
                _loc11_.init(lineTexture, thickness, color, 1, true);
                _loc11_.blendMode = "add";
                lines.push(_loc11_);
                _loc9_++;
            }
        } else if (_loc10_ < lines.length) {
            _loc9_ = _loc10_;
            while (_loc9_ < lines.length) {
                g.linePool.removeLine(lines[_loc9_]);
                _loc9_++;
            }
            lines.length = _loc10_;
        }
        super.clear();
        var _loc4_:* = 0;
        var _loc5_:* = 0;
        _loc9_ = 0;
        while (_loc9_ < lines.length) {
            _loc8_ = lines[_loc9_];
            _loc13_ = 2 - Math.abs((_loc10_ / 2 - _loc9_) / _loc10_) * 2;
            _loc8_.x = _loc4_;
            _loc8_.y = _loc5_;
            _loc12_ = (_loc9_ + 1) / _loc10_;
            _loc4_ = _loc6_ * _loc12_ + (amplitude - Math.random() * amplitude * 2) * _loc13_;
            _loc5_ = _loc7_ * _loc12_ + (amplitude - Math.random() * amplitude * 2) * _loc13_;
            if (_loc9_ == _loc10_ - 1) {
                _loc4_ = _loc6_;
                _loc5_ = _loc7_;
            }
            _loc8_.lineTo(_loc4_, _loc5_);
            _loc8_.thickness = thickness + chargeUpEffect;
            this.addMesh(_loc8_);
            _loc9_++;
        }
    }
}
}

