package core.hud.components {
import core.weapon.Damage;

import flash.display.Sprite;

import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

import textures.TextureManager;

public class ShopItemBarStats extends starling.display.Sprite {
    private static const BAR_WIDTH:Number = 18;
    private static const BAR_HEIGHT:Number = 14;

    public function ShopItemBarStats(obj:Object, compact:Boolean = false) {
        super();
        this.compact = compact;
        var _loc3_:flash.display.Sprite = new flash.display.Sprite();
        _loc3_.graphics.beginFill(0x555555);
        _loc3_.graphics.drawRoundRect(0, 0, 18 + 4, 14 + 4, 4);
        _loc3_.graphics.endFill();
        bar = TextureManager.textureFromDisplayObject(_loc3_, "weapon_bar");
        var _loc5_:flash.display.Sprite = new flash.display.Sprite();
        _loc5_.graphics.beginFill(0x555555);
        _loc5_.graphics.drawRoundRect(0, 0, 18 + 4, 14 + 4, 4);
        _loc5_.graphics.beginFill(0x55ff55);
        _loc5_.graphics.drawRoundRect(2, 2, 18, 14, 4);
        _loc5_.graphics.endFill();
        barFull = TextureManager.textureFromDisplayObject(_loc5_, "weapon_bar_full");
        _loc3_ = null;
        var _loc4_:int = 0;
        if (!compact) {
            addText("Damage (" + Damage.TYPE[obj.damageType] + ")", 60);
            addBar(obj.descriptionDmg, 80);
            addText("Range", 100);
            addBar(obj.descriptionRange, 2 * 60);
            addText("Refire", 140);
            addBar(obj.descriptionRefire, 160);
            addText("Power", 3 * 60);
            addBar(obj.descriptionHeat, 200);
            _loc4_ = 210;
        }
        addText("Difficulty", 10 + _loc4_);
        addBar(obj.descriptionDifficulty, 10 + _loc4_ + 20);
        addText("Speciality: \n" + obj.description, 10 + _loc4_ + 60);
    }
    private var bar:Texture;
    private var barFull:Texture;
    private var compact:Boolean;

    private function addBar(n:int, y:Number):void {
        var _loc3_:Image = null;
        var _loc4_:int = 0;
        _loc4_ = 0;
        while (_loc4_ < 10) {
            if (_loc4_ < n) {
                _loc3_ = new Image(barFull);
            } else {
                _loc3_ = new Image(bar);
            }
            _loc3_.x = _loc4_ * (_loc3_.width + 4);
            _loc3_.y = y;
            addChild(_loc3_);
            _loc4_++;
        }
    }

    private function addText(s:String, y:Number):void {
        var _loc3_:Text = new Text();
        _loc3_.text = s;
        _loc3_.width = 5 * 60;
        _loc3_.wordWrap = true;
        _loc3_.color = 0xaaaaaa;
        _loc3_.y = y;
        _loc3_.visible = true;
        _loc3_.size = 10;
        addChild(_loc3_);
    }
}
}

