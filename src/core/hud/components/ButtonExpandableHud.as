package core.hud.components {
import flash.geom.Rectangle;

import sound.ISound;
import sound.SoundLocator;

import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;

public class ButtonExpandableHud extends DisplayObjectContainer {
    private static var bgrLeftTexture:Texture;
    private static var bgrMidTexture:Texture;
    private static var bgrRightTexture:Texture;
    private static var hoverLeftTexture:Texture;
    private static var hoverMidTexture:Texture;
    private static var hoverRightTexture:Texture;

    public function ButtonExpandableHud(clickCallback:Function, caption:String) {
        super();
        callback = clickCallback;
        var padding:Number = 8;
        captionText = new TextBitmap(padding, 2, caption);
        captionText.format.color = Style.COLOR_HIGHLIGHT;
        useHandCursor = true;
        addEventListener("removedFromStage", clean);
        load();
    }
    private var captionText:TextBitmap;
    private var hoverContainer:Sprite = new Sprite();
    private var callback:Function;

    private var _enabled:Boolean = true;

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(value:Boolean):void {
        _enabled = value;
        if (value) {
            alpha = 1;
        } else {
            alpha = 0.5;
        }
    }

    public function set text(value:String):void {
        captionText.text = value;
    }

    public function set select(value:Boolean):void {
        if (value) {
            captionText.format.color = 0xffffaa;
        } else {
            captionText.format.color = Style.COLOR_HIGHLIGHT;
        }
    }

    public function load():void {
        var _loc8_:ITextureManager = TextureLocator.getService();
        var _loc2_:Texture = _loc8_.getTextureGUIByTextureName("button.png");
        var padding:Number = 8;
        if (bgrLeftTexture == null) {
            bgrLeftTexture = Texture.fromTexture(_loc2_, new Rectangle(0, 0, padding, 21));
            bgrMidTexture = Texture.fromTexture(_loc2_, new Rectangle(padding, 0, padding, 21));
            bgrRightTexture = Texture.fromTexture(_loc2_, new Rectangle(_loc2_.width - padding, 0, padding, 21));
        }
        var _loc3_:Image = new Image(bgrLeftTexture);
        var _loc4_:Image = new Image(bgrMidTexture);
        var _loc9_:Image = new Image(bgrRightTexture);
        _loc4_.x = padding;
        _loc4_.width = captionText.width;
        _loc9_.x = _loc4_.x + _loc4_.width;
        addChild(_loc3_);
        addChild(_loc4_);
        addChild(_loc9_);
        var _loc5_:Texture = _loc8_.getTextureGUIByTextureName("button_hover.png");
        if (hoverLeftTexture == null) {
            hoverLeftTexture = Texture.fromTexture(_loc5_, new Rectangle(0, 0, padding, 21));
            hoverMidTexture = Texture.fromTexture(_loc5_, new Rectangle(padding, 0, padding, 21));
            hoverRightTexture = Texture.fromTexture(_loc5_, new Rectangle(_loc2_.width - padding, 0, padding, 21));
        }
        var _loc1_:Image = new Image(hoverLeftTexture);
        var _loc6_:Image = new Image(hoverMidTexture);
        var _loc7_:Image = new Image(hoverRightTexture);
        _loc6_.x = padding;
        _loc6_.width = captionText.width;
        _loc7_.x = _loc4_.x + _loc4_.width;
        hoverContainer.addChild(_loc1_);
        hoverContainer.addChild(_loc6_);
        hoverContainer.addChild(_loc7_);
        hoverContainer.visible = false;
        addChild(hoverContainer);
        addEventListener("touch", onTouch);
        addChild(captionText);
    }

    private function onMouseOver(e:TouchEvent):void {
        hoverContainer.visible = true;
    }

    private function onMouseOut(e:TouchEvent):void {
        hoverContainer.visible = false;
    }

    private function onClick(e:TouchEvent):void {
        var _loc2_:ISound = SoundLocator.getService();
        if (_loc2_ != null) {
            _loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
        }
        hoverContainer.visible = false;
        enabled = false;
        if (callback == null) {
            return;
        }
        callback();
    }

    private function onTouch(e:TouchEvent):void {
        if (!_enabled) {
            return;
        }
        if (e.getTouch(this, "ended")) {
            onClick(e);
        } else if (e.interactsWith(this)) {
            onMouseOver(e);
        } else if (!e.interactsWith(this)) {
            onMouseOut(e);
        }
    }

    private function clean(e:Event = null):void {
        removeEventListener("touch", onTouch);
        removeEventListener("removedFromStage", clean);
    }
}
}

