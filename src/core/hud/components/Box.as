package core.hud.components {
import core.scene.Game;

import flash.geom.Rectangle;

import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;

public class Box extends Sprite {
    public static const STYLE_HIGHLIGHT:String = "highlight";
    public static const STYLE_NORMAL:String = "normal";
    public static const STYLE_BUY:String = "buy";
    public static const STYLE_DARK_GRAY:String = "light";
    protected static const BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(25, 25, 8, 4);
    protected static var normalTexture:Texture;
    protected static var highlightTexture:Texture;
    protected static var buyTexture:Texture;
    protected static var lightTexture:Texture;
    protected static var themeLoaded:Boolean;

    public static function loadTheme():void {
        themeLoaded = true;
        var _loc1_:ITextureManager = TextureLocator.getService();
        normalTexture = _loc1_.getTextureGUIByTextureName("box-normal");
        highlightTexture = _loc1_.getTextureGUIByTextureName("box-highlight");
        buyTexture = _loc1_.getTextureGUIByTextureName("box-buy");
        lightTexture = _loc1_.getTextureGUIByTextureName("box-light");
    }

    public function Box(width:Number, height:Number, style:String = "normal", alpha:Number = 1, padding:Number = 20) {
        super();
        if (!Box.themeLoaded && normalTexture == null) {
            normalTexture = Game.assets.getTexture("box_normal");
            highlightTexture = Game.assets.getTexture("box_highlight");
        }
        this._style = style;
        updateStyle();
        styleImage.alpha = alpha;
        this._padding = padding;
        this.width = width;
        this.height = height;
    }
    protected var w:Number;
    protected var h:Number;
    protected var styleImage:Image;

    override public function set alpha(value:Number):void {
        styleImage.alpha = value;
    }

    override public function set width(value:Number):void {
        w = value + padding * 2;
        draw();
    }

    override public function set height(value:Number):void {
        h = value + padding * 2;
        draw();
    }

    protected var _style:String;

    public function get style():String {
        return _style;
    }

    public function set style(value:String):void {
        _style = value;
        updateStyle();
    }

    protected var _padding:Number;

    public function get padding():Number {
        return _padding;
    }

    public function updateStyle():void {
        var _loc1_:Texture = null;
        if (style == "highlight") {
            _loc1_ = highlightTexture;
        } else if (style == "buy") {
            _loc1_ = buyTexture;
        } else if (style == "light") {
            _loc1_ = lightTexture;
        } else {
            _loc1_ = normalTexture;
        }
        if (styleImage) {
            removeChild(styleImage);
        }
        styleImage = new Image(_loc1_);
        styleImage.scale9Grid = BUTTON_SCALE_9_GRID;
        addChildAt(styleImage, 0);
        draw();
    }

    protected function draw():void {
        if (padding && w && h) {
            styleImage.x = -padding;
            styleImage.y = -padding;
            styleImage.width = w;
            styleImage.height = h;
        }
    }
}
}

