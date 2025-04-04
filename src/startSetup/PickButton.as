package startSetup {
import com.greensock.TweenMax;

import core.hud.components.Box;

import sound.ISound;
import sound.SoundLocator;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.TouchEvent;
import starling.filters.GlowFilter;

import textures.TextureLocator;

public class PickButton extends Sprite {
    public function PickButton(imageName:String, callback:Function, isGuiTexture:Boolean = false) {
        super();
        if (isGuiTexture) {
            image = new Image(TextureLocator.getService().getTextureGUIByTextureName(imageName));
        } else {
            image = new Image(TextureLocator.getService().getTextureMainByTextureName(imageName));
        }
        this.callback = callback;
        var _loc4_:Number = 100;
        bgr = new Box(90, 90, "normal", 0.8, 0);
        addChild(bgr);
        image.pivotX = image.width / 2;
        image.pivotY = image.height / 2;
        image.x = bgr.width / 2;
        image.y = bgr.height / 2;
        addChild(image);
        addEventListener("touch", onTouch);
        useHandCursor = true;
        pivotX = width / 2;
        pivotY = height / 2;
    }
    public var mouseOverCallback:Function = null;
    private var bgr:Box;
    private var callback:Function;
    private var image:Image;
    private var isSelected:Boolean = false;

    public function select():void {
        isSelected = true;
        image.alpha = 1;
        var rotationTween:com.greensock.TweenMax = TweenMax.to(image, 0.7, {
            "rotation": 3.141592653589793 * 1.5,
            "onComplete": function ():void {
                if (!RymdenRunt.isBuggedFlashVersion) {
                    image.filter = new GlowFilter(0xffffff, 1, 1, 0.7);
                }
                image.scaleX = 1.3;
                image.scaleY = 1.3;
            }
        });
        bgr.filter = new GlowFilter(0xffffff, 0.8, 1, 0.7);
    }

    public function deselect():void {
        isSelected = false;
        if (!RymdenRunt.isBuggedFlashVersion) {
            bgr.filter = new GlowFilter(0xffffff, 0.4, 1, 0.7);
        }
        image.alpha = 0.4;
        image.scaleX = 1;
        image.scaleY = 1;
        if (image.filter) {
            image.filter.dispose();
        }
        image.filter = null;
        TweenMax.to(image, 1, {"rotation": 0});
    }

    private function onTouch(e:TouchEvent):void {
        var _loc2_:ISound = null;
        if (isSelected) {
            return;
        }
        if (e.getTouch(this, "began")) {
            callback();
            e.stopPropagation();
            _loc2_ = SoundLocator.getService();
            if (_loc2_ != null) {
                _loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
            }
        } else if (e.interactsWith(this)) {
            callback();
        }
    }
}
}

