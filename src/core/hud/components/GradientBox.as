package core.hud.components {
import flash.display.Sprite;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;
import textures.TextureManager;

public class GradientBox extends starling.display.Sprite {
    public function GradientBox(width:Number, height:Number, color:uint = 0, alpha:Number = 1, padding:Number = 15, headerTint:uint = 16777215) {
        super();
        w = width;
        h = height;
        this.color = color;
        this.colorAlpha = alpha;
        this.padding = padding;
        this.headerTint = headerTint;
        addBorder(0x1c1c1c, 1, 2);
        addEventListener("removedFromStage", clean);
    }
    public var padding:Number;
    protected var radius:Number;
    protected var colorAlpha:Number;
    protected var w:Number;
    protected var h:Number;
    protected var borderWidth:Number = 0;
    protected var borderColor:uint = 0;
    protected var borderAlpha:Number = 0;
    private var background:Image;
    private var backgroundTexture:Texture;
    private var headerTint:uint;

    override public function set width(value:Number):void {
        w = value;
        draw();
    }

    override public function set height(value:Number):void {
        h = value;
        draw();
    }

    protected var _color:uint;

    public function set color(value:uint):void {
        _color = value;
        draw();
    }

    public function load():void {
        var _loc1_:ITextureManager = TextureLocator.getService();
        var headerBitmapData:starling.textures.Texture = _loc1_.getTextureGUIByTextureName("gradient_box_header.png");
        var headerBmp:starling.display.Image = new Image(headerBitmapData);
        headerBmp.width = w + padding * 2 - borderWidth;
        headerBmp.x = -padding + borderWidth / 2;
        headerBmp.y = -padding + borderWidth / 2;
        headerBmp.color = headerTint;
        addChild(headerBmp);
    }

    public function addBorder(borderColor:uint, borderAlpha:Number, borderWidth:Number):void {
        this.borderWidth = borderWidth;
        this.borderColor = borderColor;
        this.borderAlpha = borderAlpha;
        draw();
    }

    protected function draw():void {
        drawBox();
    }

    private function drawBox():void {
        if (background != null) {
            removeChild(background);
            background.dispose();
            backgroundTexture.dispose();
        }
        var _loc2_:Vector.<int> = new Vector.<int>();
        var _loc3_:Vector.<Number> = new Vector.<Number>();
        _loc2_.push(1, 2, 2, 2, 2);
        _loc3_.push(0 - padding, 0 - padding);
        _loc3_.push(0 - padding, h + padding);
        _loc3_.push(w + padding, h + padding);
        _loc3_.push(w + padding, 0 - padding);
        _loc3_.push(0 - padding, 0 - padding);
        var _loc1_:flash.display.Sprite = new flash.display.Sprite();
        _loc1_.graphics.beginFill(_color, colorAlpha);
        _loc1_.graphics.drawPath(_loc2_, _loc3_);
        _loc1_.graphics.endFill();
        backgroundTexture = TextureManager.textureFromDisplayObject(_loc1_);
        background = new Image(backgroundTexture);
        background.x = -padding;
        addChildAt(background, 0);
    }

    private function clean(e:Event = null):void {
        removeEventListeners();
        if (background != null) {
            removeChild(background);
            background.dispose();
            backgroundTexture.dispose();
        }
    }
}
}

