package core.hud.components {
import generics.Util;

import playerio.Message;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;

import textures.ITextureManager;
import textures.TextureLocator;

public class TopPvPPlayersList extends Sprite {
    private static var topPvpPlayersList:Array;

    public function TopPvPPlayersList() {
        super();
        textureManager = TextureLocator.getService();
    }
    private var textureManager:ITextureManager;

    public function showHighscore(m:Message):void {
        var _loc3_:int = 0;
        var _loc2_:Object = null;
        topPvpPlayersList = [];
        _loc3_ = 0;
        while (_loc3_ < m.length) {
            _loc2_ = {};
            _loc2_.rank = m.getInt(_loc3_);
            _loc2_.name = m.getString(_loc3_ + 1);
            _loc2_.key = m.getString(_loc3_ + 2);
            _loc2_.level = m.getInt(_loc3_ + 3);
            _loc2_.clan = m.getString(_loc3_ + 4);
            _loc2_.value = m.getNumber(_loc3_ + 5);
            topPvpPlayersList.push(_loc2_);
            _loc3_ += 6;
        }
        drawTopPvpPlayers();
    }

    private function drawTopPvpPlayers():void {
        var _loc2_:int = 0;
        var _loc1_:int = 0;
        _loc2_ = 0;
        while (_loc2_ < topPvpPlayersList.length) {
            drawPlayerObject(topPvpPlayersList[_loc2_], _loc2_, this);
            _loc1_ = int(topPvpPlayersList[_loc2_].rank);
            _loc2_++;
        }
    }

    private function drawPlayerObject(player:Object, i:int, canvas:Sprite):void {
        var _loc4_:Quad = null;
        var _loc10_:Image = null;
        var _loc7_:int = i * 45;
        if (Login.client.connectUserId == player.key) {
            _loc4_ = new Quad(670, 40, 0x424242);
        } else {
            _loc4_ = new Quad(670, 40, 0x212121);
        }
        _loc4_.y = _loc7_;
        _loc7_ += 10;
        var _loc8_:TextBitmap = new TextBitmap();
        _loc8_.text = topPvpPlayersList[i].rank;
        _loc8_.size = 14;
        _loc8_.y = _loc7_;
        _loc8_.x = 10;
        var _loc6_:TextBitmap = new TextBitmap();
        _loc6_.text = player.name;
        _loc6_.y = _loc7_;
        _loc6_.size = 14;
        _loc6_.format.color = 0xff4444;
        _loc6_.x = _loc8_.x + _loc8_.width + 10;
        var _loc5_:TextBitmap = new TextBitmap();
        _loc5_.text = "(Lv. " + player.level + ")";
        _loc5_.y = _loc7_;
        _loc5_.size = 14;
        _loc5_.format.color = 0xff4444;
        _loc5_.x = _loc6_.x + _loc6_.width + 10;
        var _loc9_:TextBitmap = new TextBitmap();
        _loc9_.text = Util.formatAmount(Math.floor(player.value));
        _loc9_.y = _loc7_;
        _loc9_.size = 14;
        _loc9_.format.color = Style.COLOR_YELLOW;
        _loc9_.x = 610 - _loc9_.width - 10;
        _loc10_ = new Image(textureManager.getTextureGUIByTextureName("clan_logo3.png"));
        _loc10_.y = _loc7_ + 20;
        _loc10_.color = 0xff0000;
        _loc10_.x = _loc9_.x + _loc9_.width + 10;
        _loc10_.scaleX = _loc10_.scaleY = 0.25;
        _loc10_.rotation = -0.5 * 3.141592653589793;
        canvas.addChild(_loc4_);
        canvas.addChild(_loc8_);
        canvas.addChild(_loc6_);
        canvas.addChild(_loc5_);
        canvas.addChild(_loc9_);
        canvas.addChild(_loc10_);
    }
}
}

