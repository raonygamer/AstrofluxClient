package core.hud.components {
import core.scene.Game;

import flash.geom.Rectangle;

import sound.ISound;
import sound.SoundLocator;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;

public class Button extends Sprite {
    public static const STYLE_POSITIVE:String = "positive";
    public static const STYLE_NEGATIVE:String = "negative";
    public static const STYLE_HIGHLIGHT:String = "highlight";
    public static const STYLE_BUY:String = "buy";
    public static const STYLE_NORMAL:String = "normal";
    public static const STYLE_REWARD:String = "reward";
    protected static const BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(25, 11, 8, 4);
    protected static var normalTexture:Texture;
    protected static var highlightTexture:Texture;
    protected static var positiveTexture:Texture;
    protected static var warningTexture:Texture;
    protected static var themeLoaded:Boolean;

    public static function loadTheme():void {
        themeLoaded = true;
        var _loc1_:ITextureManager = TextureLocator.getService();
        normalTexture = _loc1_.getTextureGUIByTextureName("button-normal");
        highlightTexture = _loc1_.getTextureGUIByTextureName("button-highlight");
        positiveTexture = _loc1_.getTextureGUIByTextureName("button-positive");
        warningTexture = _loc1_.getTextureGUIByTextureName("button-warning");
    }

    public function Button(callback:Function, buttonText:String = "I\'m a button yeah", style:String = "normal", size:int = 13, font:String = "font13") {
        super();
        this.callback = callback;
        this.style = style;
        useHandCursor = true;
        if (!Button.themeLoaded && normalTexture == null) {
            normalTexture = Game.assets.getTexture("button_normal");
            highlightTexture = Game.assets.getTexture("button_highlight");
            positiveTexture = Game.assets.getTexture("button_positive");
            warningTexture = Game.assets.getTexture("button_warning");
        }
        updateStyle();
        addChild(styleImage);
        addChild(hoverImage);
        if (buttonText == "") {
            buttonText = "Button Text";
        }
        tf = new TextField(500, size * 2, buttonText, new TextFormat(font, size, 0xffffff));
        tf.width = tf.textBounds.width + 2 * padding;
        tf.batchable = true;
        tf.touchable = false;
        addChild(tf);
        update();
        addEventListener("touch", onTouch);
        addEventListener("addedToStage", update);
    }
    public var autoEnableAfterClick:Boolean = false;
    public var callback:Function;
    protected var styleImage:Image;
    protected var hoverImage:Image;
    protected var style:String;
    protected var tf:TextField;
    protected var autoscale:Boolean = true;
    protected var padding:int = 16;

    override public function get width():Number {
        return tf.width;
    }

    override public function set width(value:Number):void {
        tf.width = value;
        autoscale = false;
        update();
    }

    override public function set x(value:Number):void {
        super.x = Math.round(value);
    }

    override public function set y(value:Number):void {
        super.y = Math.round(value);
    }

    public function get text():String {
        return tf.text;
    }

    public function set text(value:String):void {
        tf.text = value;
        update();
    }

    public function set size(value:int):void {
        var _loc2_:int = autoscale ? 500 : tf.width;
        tf.format.size = value;
        if (value == 20) {
            tf.format.font = "font20";
        }
        update();
    }

    public function set enabled(value:Boolean):void {
        if (value) {
            alpha = 1;
            if (!hasEventListener("touch")) {
                addEventListener("touch", onTouch);
            }
        } else {
            alpha = 0.2;
            removeEventListener("touch", onTouch);
        }
        useHandCursor = value;
    }

    public function centerPivot():void {
        pivotX = width / 2;
        pivotY = height / 2;
    }

    public function alignWithText():void {
        y -= Math.round((tf.height - 14) / 2);
    }

    protected function updateStyle():void {
        var _loc1_:Texture = null;
        if (style == "highlight") {
            _loc1_ = highlightTexture;
        } else if (style == "positive" || style == "buy" || style == "reward") {
            _loc1_ = positiveTexture;
        } else if (style == "negative") {
            _loc1_ = warningTexture;
        } else {
            _loc1_ = normalTexture;
        }
        styleImage = new Image(_loc1_);
        hoverImage = new Image(_loc1_);
        styleImage.scale9Grid = BUTTON_SCALE_9_GRID;
        hoverImage.scale9Grid = BUTTON_SCALE_9_GRID;
        hoverImage.blendMode = "screen";
        hoverImage.visible = false;
    }

    protected function update(e:Event = null):void {
        if (!this.stage) {
            return;
        }
        if (autoscale) {
            tf.width = tf.textBounds.width + 2 * padding;
        }
        hoverImage.width = styleImage.width = tf.width;
        hoverImage.height = styleImage.height = tf.height;
        if (hasEventListener("addedToStage")) {
            removeEventListener("addedToStage", update);
        }
    }

    private function onTouch(e:TouchEvent):void {
        if (e.getTouch(this, "began")) {
            onClick(e);
            e.stopPropagation();
        } else if (e.interactsWith(this)) {
            mouseOver(e);
        } else if (!e.interactsWith(this)) {
            mouseOut(e);
        }
    }

    private function onClick(e:TouchEvent):void {
        var _loc2_:ISound = SoundLocator.getService();
        if (_loc2_ != null) {
            _loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
        }
        if (!autoEnableAfterClick) {
            enabled = false;
        }
        hoverImage.visible = false;
        if (callback != null) {
            callback(e);
        }
    }

    private function mouseOver(e:TouchEvent):void {
        hoverImage.visible = true;
    }

    private function mouseOut(e:TouchEvent):void {
        hoverImage.visible = false;
    }
}
}

