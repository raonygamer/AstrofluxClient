package core.hud.components {
import starling.display.Image;

import textures.ITextureManager;
import textures.TextureLocator;

public class Line extends Image {
    public function Line(textureName:String = "line1") {
        var _loc2_:ITextureManager = TextureLocator.getService();
        super(_loc2_.getTextureMainByTextureName(textureName));
    }
    public var toX:Number;
    public var toY:Number;
    private var overlap:Boolean;
    private var oldTextureName:String;

    public function set thickness(value:Number):void {
        var _loc2_:Number = this.rotation;
        this.rotation = 0;
        height = value;
        this.rotation = _loc2_;
    }

    override public function dispose():void {
        super.dispose();
    }

    public function init(textureName:String = "line1", thickness:int = 1, color:uint = 16777215, alpha:Number = 1, overlap:Boolean = false):void {
        var _loc6_:ITextureManager = null;
        if (oldTextureName != textureName) {
            _loc6_ = TextureLocator.getService();
            this.texture = _loc6_.getTextureMainByTextureName(textureName);
            this.readjustSize(texture.width, texture.height);
            pivotY = texture.height / 2;
        }
        oldTextureName = textureName;
        this.color = color;
        this.alpha = alpha;
        this.overlap = overlap;
        this.thickness = thickness;
        this.touchable = true;
        this.visible = true;
    }

    public function lineTo(toX:Number, toY:Number):void {
        this.toX = toX;
        this.toY = toY;
        var _loc3_:Number = toX - x;
        var _loc5_:Number = toY - y;
        var _loc4_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc5_ * _loc5_);
        if (_loc4_ == 0) {
            return;
        }
        this.rotation = 0;
        width = overlap ? _loc4_ + height : _loc4_;
        this.rotation = Math.atan2(_loc5_, _loc3_);
    }
}
}

