package core.hud.components {
import core.scene.Game;

import debug.Console;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.system.Capabilities;

import starling.core.Starling;

public class FullScreenButton extends Sprite {
    public function FullScreenButton() {
        super();
        tabChildren = false;
        tabEnabled = false;
        graphics.beginFill(1842461);
        graphics.lineStyle(1, 4409416);
        graphics.drawRoundRect(0, 0, 22, 25, 4, 4);
        graphics.beginFill(0xc6c6c6);
        graphics.lineStyle(0, 0);
        graphics.drawRoundRect(3, 8, 16, 12, 2, 2);
        graphics.beginFill(0);
        graphics.drawRoundRect(6, 12, 10, 4, 2, 2);
        graphics.endFill();
        hoverImage.graphics.beginFill(1842461);
        hoverImage.graphics.lineStyle(1, 4409416);
        hoverImage.graphics.drawRoundRect(0, 0, 22, 25, 4, 4);
        hoverImage.graphics.beginFill(0xc6c6c6);
        hoverImage.graphics.lineStyle(0, 0);
        hoverImage.graphics.drawRoundRect(3, 8, 16, 12, 2, 2);
        hoverImage.graphics.beginFill(0);
        hoverImage.graphics.drawRoundRect(6, 12, 10, 4, 2, 2);
        hoverImage.graphics.endFill();
        hoverImage.blendMode = "add";
        hoverImage.visible = false;
        addChild(hoverImage);
        addEventListener("click", onFullscreen);
        addEventListener("mouseOver", function (param1:MouseEvent):void {
            hoverImage.visible = true;
        });
        addEventListener("mouseOut", function (param1:MouseEvent):void {
            hoverImage.visible = false;
        });
        this.buttonMode = true;
        this.useHandCursor = true;
    }
    private var hoverImage:Sprite = new Sprite();

    public function onFullscreen(e:MouseEvent):void {
        var _loc6_:* = Starling.current.nativeStage.displayState == "fullScreenInteractive";
        _loc6_ = !_loc6_;
        var _loc4_:String = Capabilities.version;
        var _loc3_:Array = _loc4_.split(" ");
        var _loc5_:Array = _loc3_[1].split(",");
        var _loc2_:String = _loc3_[0];
        var _loc7_:Number = Number(_loc5_[0]);
        _loc7_ = _loc7_ + _loc5_[1] / 10;
        if (_loc6_ && _loc7_ >= 1.3) {
            Starling.current.nativeStage.displayState = "fullScreenInteractive";
        } else if (_loc6_) {
            Console.write("You need flash version 11.3");
        } else {
            Starling.current.nativeStage.displayState = "normal";
        }
        Game.instance.hud.resize();
        Game.instance.hud.removeFullScreenHint();
    }
}
}

