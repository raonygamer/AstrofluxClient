package core.hud.components.starMap {
import flash.display.Sprite;

import sound.ISound;
import sound.SoundLocator;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.TouchEvent;

import textures.TextureManager;

public class TransitButton extends starling.display.Sprite {
    public function TransitButton(target:SolarSystem, color:uint) {
        super();
        this.target = target;
        this.color = color;
        draw();
        useHandCursor = true;
        addEventListener("touch", onTouch);
    }
    public var target:SolarSystem;
    private var hovered:Boolean;
    private var color:uint;

    override public function dispose():void {
        super.dispose();
    }

    private function draw():void {
        removeChildren();
        var _loc1_:flash.display.Sprite = new flash.display.Sprite();
        _loc1_.graphics.clear();
        var _loc2_:Vector.<int> = new Vector.<int>();
        var _loc3_:Vector.<Number> = new Vector.<Number>();
        _loc2_.push(1, 2, 2, 2);
        _loc3_.push(-8, 8);
        _loc3_.push(8, 8);
        _loc3_.push(0, -8);
        _loc3_.push(-8, 8);
        var _loc4_:uint = color;
        if (hovered) {
            _loc4_ = 0xffffff;
        }
        _loc1_.graphics.lineStyle(2, _loc4_);
        _loc1_.graphics.beginFill(0);
        _loc1_.graphics.drawPath(_loc2_, _loc3_);
        _loc1_.graphics.endFill();
        var textureImage:starling.display.Image = TextureManager.imageFromSprite(_loc1_, "transitButton" + hovered.toString());
        addChild(textureImage);
    }

    private function mouseOver(e:TouchEvent):void {
        hovered = true;
        draw();
    }

    private function mouseOut(e:TouchEvent):void {
        hovered = false;
        draw();
    }

    private function onTouch(e:TouchEvent):void {
        if (e.getTouch(this, "ended")) {
            click(e);
        } else if (e.interactsWith(this)) {
            mouseOver(e);
        } else if (!e.interactsWith(this)) {
            mouseOut(e);
        }
    }

    private function click(e:TouchEvent):void {
        var _loc2_:ISound = SoundLocator.getService();
        _loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
    }
}
}

