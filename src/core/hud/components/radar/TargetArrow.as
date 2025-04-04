package core.hud.components.radar {
import com.greensock.TweenMax;

import core.GameObject;
import core.scene.Game;

import flash.geom.Point;

import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

import textures.ITextureManager;
import textures.TextureLocator;

public class TargetArrow extends Sprite {
    public function TargetArrow(g:Game, target:GameObject, color:uint) {
        super();
        this.g = g;
        this.target = target;
        var _loc6_:ITextureManager = TextureLocator.getService();
        var _loc5_:Texture = _loc6_.getTextureGUIByTextureName("map_arrow");
        var _loc4_:Image = new Image(_loc5_);
        _loc4_.color = color;
        addChild(_loc4_);
        _loc4_.blendMode = "add";
        pivotX = width / 2;
        pivotY = height / 2;
    }
    public var target:GameObject;
    private var g:Game;
    private var tween:TweenMax;

    public function activate():void {
        this.scaleX = 1;
        this.scaleY = 1;
        tween = TweenMax.to(this, 0.5, {
            "yoyo": true,
            "repeat": -1,
            "scaleX": 2,
            "scaleY": 2
        });
    }

    public function deactivate():void {
        if (tween != null) {
            tween.kill();
        }
    }

    public function update():void {
        var _loc1_:Point = g.camera.getCameraCenter();
        var _loc2_:Point = target.pos;
        if (g.camera.isOnScreen(target.pos.x, target.pos.y)) {
            visible = false;
        } else {
            visible = true;
        }
        var _loc3_:Point = _loc2_.subtract(_loc1_);
        _loc3_.normalize(1);
        rotation = Math.atan2(_loc3_.y, _loc3_.x);
        x = _loc1_.x + _loc3_.x * g.stage.stageWidth / 3;
        y = _loc1_.y + _loc3_.y * g.stage.stageHeight / 3;
    }
}
}

